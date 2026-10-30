import https from 'https';
import { query as pgQuery, getPostgresStatus } from '../config/postgres';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface OsmDoctor {
  name: string;
  lat: number;
  lng: number;
  phone: string | null;
  address: string | null;
}

/** Shape of a single element returned by the Overpass JSON endpoint. */
interface OverpassElement {
  type: string;
  id: number;
  lat?: number;
  lon?: number;
  center?: { lat: number; lon: number };
  tags?: Record<string, string>;
}

interface OverpassResponse {
  elements: OverpassElement[];
}

// ---------------------------------------------------------------------------
// In-memory cache (fast L1 — 1-hour TTL)
// ---------------------------------------------------------------------------

const memCache = new Map<string, { timestamp: number; data: OsmDoctor[] }>();
const MEM_CACHE_TTL_MS = 60 * 60 * 1000; // 1 hour

// ---------------------------------------------------------------------------
// Supabase / PostgreSQL cache helpers (persistent L2 — 24-hour TTL)
// ---------------------------------------------------------------------------

const DB_CACHE_TTL_HOURS = 24;

export function makeCacheKey(lat: number, lng: number, radiusKm: number): string {
  return `osm_doctors_${lat.toFixed(2)}_${lng.toFixed(2)}_${radiusKm}`;
}

export async function cacheOsmDoctorsInCacheTable(
  lat: number,
  lng: number,
  radiusKm: number,
  doctors: (OsmDoctor | RawOsmDoctor)[]
): Promise<void> {
  const cacheKey = makeCacheKey(lat, lng, radiusKm);
  const mapped: OsmDoctor[] = doctors.map((d) => ({
    name: d.name,
    category: (d as any).category || (d as any).type || 'doctor',
    type: (d as any).type || (d as any).category || 'doctor',
    lat: d.lat,
    lng: d.lng,
    phone: d.phone ?? null,
    address: d.address ?? null,
  }));
  await writeToSupabase(cacheKey, mapped);
}

/**
 * Reads cached doctor rows from `osm_doctors_cache` if they were inserted
 * within the last 24 hours.  Returns `null` on miss or if Postgres is offline.
 */
async function readFromSupabase(cacheKey: string): Promise<OsmDoctor[] | null> {
  if (!getPostgresStatus()) return null;

  try {
    const result = await pgQuery<{
      name: string;
      lat: number;
      lng: number;
      phone: string | null;
      address: string | null;
    }>(
      `SELECT name, lat, lng, phone, address
         FROM osm_doctors_cache
        WHERE cache_key = $1
          AND fetched_at > NOW() - INTERVAL '${DB_CACHE_TTL_HOURS} hours'
        ORDER BY name ASC`,
      [cacheKey]
    );

    if (result.rows.length > 0) {
      console.log(`[OSM] Supabase cache hit for ${cacheKey} (${result.rows.length} doctors)`);
      return result.rows;
    }
  } catch (err: any) {
    console.warn('[OSM] Supabase read error (non-fatal):', err.message);
  }

  return null;
}

/**
 * Persists an array of doctors into `osm_doctors_cache`.
 * Deletes any stale rows for the same cache key first, then bulk-inserts.
 */
async function writeToSupabase(cacheKey: string, doctors: OsmDoctor[]): Promise<void> {
  if (!getPostgresStatus() || doctors.length === 0) return;

  try {
    // Delete old rows for this grid cell
    await pgQuery('DELETE FROM osm_doctors_cache WHERE cache_key = $1', [cacheKey]);

    // Build a bulk INSERT with parameterised values
    const values: any[] = [];
    const placeholders: string[] = [];
    let idx = 1;

    for (const doc of doctors) {
      placeholders.push(`($${idx++}, $${idx++}, $${idx++}, $${idx++}, $${idx++}, $${idx++})`);
      values.push(cacheKey, doc.name, doc.lat, doc.lng, doc.phone, doc.address);
    }

    await pgQuery(
      `INSERT INTO osm_doctors_cache (cache_key, name, lat, lng, phone, address)
       VALUES ${placeholders.join(', ')}`,
      values
    );

    console.log(`[OSM] Cached ${doctors.length} doctors in Supabase for key ${cacheKey}`);
  } catch (err: any) {
    // Non-fatal — the in-memory cache still serves this request
    console.warn('[OSM] Supabase write error (non-fatal):', err.message);
  }
}

// ---------------------------------------------------------------------------
// Overpass Mirrors & Configuration
// ---------------------------------------------------------------------------

const OVERPASS_ENDPOINTS = [
  'https://overpass.kumi.systems/api/interpreter',
  'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
  'https://overpass-api.de/api/interpreter',
];

// ---------------------------------------------------------------------------
// Overpass QL query builder
// ---------------------------------------------------------------------------

/**
 * Builds an Overpass QL query that finds all nodes and ways tagged
 * `amenity=doctors`, `healthcare=doctor`, `amenity=clinic`, `amenity=hospital`,
 * `healthcare=clinic`, and `healthcare=hospital` within `radiusKm` of the
 * given coordinates. Output is JSON with coordinates and tags metadata.
 */
function buildOverpassQuery(lat: number, lng: number, radiusKm: number): string {
  const radiusMeters = Math.round(radiusKm * 1000);

  return `
[out:json][timeout:25][maxsize:1048576];
(
  node["amenity"="doctors"](around:${radiusMeters},${lat},${lng});
  node["healthcare"="doctor"](around:${radiusMeters},${lat},${lng});
  node["amenity"="clinic"](around:${radiusMeters},${lat},${lng});
  node["amenity"="hospital"](around:${radiusMeters},${lat},${lng});
  node["healthcare"="clinic"](around:${radiusMeters},${lat},${lng});
  node["healthcare"="hospital"](around:${radiusMeters},${lat},${lng});
  way["amenity"="doctors"](around:${radiusMeters},${lat},${lng});
  way["healthcare"="doctor"](around:${radiusMeters},${lat},${lng});
  way["amenity"="clinic"](around:${radiusMeters},${lat},${lng});
  way["amenity"="hospital"](around:${radiusMeters},${lat},${lng});
  way["healthcare"="clinic"](around:${radiusMeters},${lat},${lng});
  way["healthcare"="hospital"](around:${radiusMeters},${lat},${lng});
);
out center body;
`.trim();
}

// ---------------------------------------------------------------------------
// Low-level HTTPS POST helper with Mirror Fallbacks and Retries
// ---------------------------------------------------------------------------

/**
 * Executes a single HTTPS POST request to a given Overpass mirror endpoint.
 */
function executeOverpassPost(endpointUrl: string, query: string, timeoutMs = 25_000): Promise<string> {
  const postBody = `data=${encodeURIComponent(query)}`;
  const parsedUrl = new URL(endpointUrl);

  return new Promise((resolve, reject) => {
    const req = https.request(
      parsedUrl,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Content-Length': Buffer.byteLength(postBody),
          'User-Agent': 'DermaScanAI/1.0 (HealthMedicalApp)',
          Accept: 'application/json',
        },
      },
      (res) => {
        let body = '';
        res.on('data', (chunk: Buffer | string) => (body += chunk));
        res.on('end', () => {
          if (res.statusCode && res.statusCode >= 400) {
            reject(new Error(`Overpass mirror ${endpointUrl} responded with HTTP ${res.statusCode}: ${body.slice(0, 200)}`));
          } else {
            resolve(body);
          }
        });
      }
    );

    req.on('error', reject);
    req.setTimeout(timeoutMs, () => {
      req.destroy();
      reject(new Error(`Overpass API request to ${endpointUrl} timed out after ${timeoutMs}ms`));
    });

    req.write(postBody);
    req.end();
  });
}

/**
 * Sends a URL-encoded POST request to Overpass with up to 3 retries across reliable mirrors
 * and a 2-second delay between attempts.
 */
async function postOverpass(query: string, maxRetries = 3, retryDelayMs = 2000): Promise<string> {
  let lastError: Error | null = null;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    const endpoint = OVERPASS_ENDPOINTS[(attempt - 1) % OVERPASS_ENDPOINTS.length];
    try {
      console.log(`[OSM] Attempt ${attempt}/${maxRetries} querying Overpass mirror: ${endpoint}`);
      const body = await executeOverpassPost(endpoint, query, 25_000);
      return body;
    } catch (err: any) {
      lastError = err;
      console.warn(`[OSM] Attempt ${attempt}/${maxRetries} failed on ${endpoint}: ${err.message}`);
      if (attempt < maxRetries) {
        console.log(`[OSM] Waiting ${retryDelayMs / 1000}s before retry...`);
        await new Promise((resolve) => setTimeout(resolve, retryDelayMs));
      }
    }
  }

  throw lastError || new Error('All Overpass API mirrors and retries failed.');
}

// ---------------------------------------------------------------------------
// Response parser
// ---------------------------------------------------------------------------

/**
 * Extracts a human-readable address string from OSM tags.
 * Returns `null` when no address information is available.
 */
function buildAddress(tags: Record<string, string>): string | null {
  // Prefer the pre-formatted `addr:full` tag first
  if (tags['addr:full']) return tags['addr:full'];

  const parts: string[] = [];
  if (tags['addr:housenumber'] && tags['addr:street']) {
    parts.push(`${tags['addr:housenumber']} ${tags['addr:street']}`);
  } else if (tags['addr:street']) {
    parts.push(tags['addr:street']);
  }
  if (tags['addr:suburb']) parts.push(tags['addr:suburb']);
  if (tags['addr:city']) parts.push(tags['addr:city']);
  if (tags['addr:state']) parts.push(tags['addr:state']);
  if (tags['addr:postcode']) parts.push(tags['addr:postcode']);

  return parts.length > 0 ? parts.join(', ') : null;
}

export function determineOsmCategory(tags: Record<string, string>): 'doctor' | 'dermatologist' | 'hospital' | 'clinic' {
  const amenity = (tags['amenity'] || '').toLowerCase();
  const healthcare = (tags['healthcare'] || '').toLowerCase();
  const specialty = (tags['healthcare:speciality'] || tags['speciality'] || '').toLowerCase();
  const name = (tags['name'] || '').toLowerCase();

  if (specialty.includes('derma') || name.includes('derma') || name.includes('skin')) {
    return 'dermatologist';
  }
  if (amenity === 'doctors' || healthcare === 'doctor' || name.startsWith('dr') || name.includes('doctor')) {
    return 'doctor';
  }
  if (amenity === 'hospital' || healthcare === 'hospital' || name.includes('hospital')) {
    return 'hospital';
  }
  if (amenity === 'clinic' || healthcare === 'clinic' || name.includes('clinic')) {
    return 'clinic';
  }
  return 'doctor';
}

export interface RawOsmDoctor {
  osmId: number;
  name: string;
  category: 'doctor' | 'clinic' | 'hospital' | 'dermatologist';
  type: string;
  lat: number;
  lng: number;
  phone: string | null;
  address: string | null;
  city: string | null;
  website: string | null;
  specialty?: string;
  tags: Record<string, string>;
}

/**
 * Maps raw Overpass elements into a deduplicated array of RawOsmDoctor objects.
 */
export function parseRawElements(elements: OverpassElement[]): RawOsmDoctor[] {
  const doctors: RawOsmDoctor[] = [];
  const seen = new Set<number>();

  for (const el of elements) {
    if (seen.has(el.id)) continue;
    seen.add(el.id);

    const lat = el.lat ?? el.center?.lat;
    const lon = el.lon ?? el.center?.lon;
    if (lat == null || lon == null) continue;

    const tags = el.tags ?? {};
    const category = determineOsmCategory(tags);
    const fallbackName =
      category === 'doctor'
        ? 'Specialist Doctor'
        : category === 'dermatologist'
        ? 'Dermatology Specialist'
        : category === 'hospital'
        ? 'Community Hospital'
        : 'Medical Clinic';
    const name = tags.name || tags['name:en'] || tags['operator'] || fallbackName;
    const city = tags['addr:city'] || tags['addr:state'] || tags['addr:suburb'] || null;
    const address = buildAddress(tags);
    const phone = tags.phone || tags['contact:phone'] || null;
    const website = tags.website || tags['contact:website'] || null;
    const specialty =
      tags['healthcare:speciality'] ||
      tags['speciality'] ||
      (category === 'dermatologist'
        ? 'General Dermatology'
        : category === 'doctor'
        ? 'General Medicine & Dermatology'
        : 'Multi-Specialty Care');

    doctors.push({
      osmId: el.id,
      name,
      category,
      type: category,
      lat,
      lng: lon,
      phone,
      address,
      city,
      website,
      specialty,
      tags,
    });
  }

  return doctors;
}

/**
 * Fetches raw OSM doctors directly from Overpass API.
 */
export async function fetchOsmDoctorsRaw(
  lat: number,
  lng: number,
  radiusKm = 10
): Promise<RawOsmDoctor[]> {
  const overpassQuery = buildOverpassQuery(lat, lng, radiusKm);
  try {
    const raw = await postOverpass(overpassQuery);
    const json: OverpassResponse = JSON.parse(raw);
    if (!json.elements || !Array.isArray(json.elements)) {
      return [];
    }
    return parseRawElements(json.elements);
  } catch (error) {
    console.error('[OSM] Error fetching raw OSM doctors from Overpass:', error);
    return [];
  }
}

/**
 * Maps raw Overpass elements into a deduplicated array of `OsmDoctor` objects.
 */
function parseElements(elements: OverpassElement[]): OsmDoctor[] {
  const rawList = parseRawElements(elements);
  return rawList.map((d) => ({
    name: d.name,
    lat: d.lat,
    lng: d.lng,
    phone: d.phone,
    address: d.address,
  }));
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/**
 * Fetches nearby doctors with a 3-tier caching strategy:
 *
 *   L1  In-memory Map   (1 hour TTL  — instant, same-process)
 *   L2  Supabase table  (24 hour TTL — survives restarts, shared across instances)
 *   L3  Overpass API    (live fetch  — writes back to L1 + L2)
 *
 * @param lat       Latitude of the search centre.
 * @param lng       Longitude of the search centre.
 * @param radiusKm  Search radius in kilometres (default 10 km).
 * @returns         Array of `OsmDoctor` objects sorted by name.
 */
export async function fetchNearbyDoctors(
  lat: number,
  lng: number,
  radiusKm = 10
): Promise<OsmDoctor[]> {
  const cacheKey = makeCacheKey(lat, lng, radiusKm);

  // ── L1: In-memory cache (1 h) ──────────────────────────────────────────
  const mem = memCache.get(cacheKey);
  if (mem && Date.now() - mem.timestamp < MEM_CACHE_TTL_MS && mem.data.length > 0) {
    console.log(`[OSM] L1 memory cache hit for ${cacheKey} (${mem.data.length} doctors)`);
    return mem.data;
  }

  // ── L2: Supabase / PostgreSQL cache (24 h) ─────────────────────────────
  const dbCached = await readFromSupabase(cacheKey);
  if (dbCached && dbCached.length > 0) {
    // Promote to L1 so subsequent calls are instant
    memCache.set(cacheKey, { timestamp: Date.now(), data: dbCached });
    return dbCached;
  }

  // ── L3: Live Overpass API fetch ────────────────────────────────────────
  const overpassQuery = buildOverpassQuery(lat, lng, radiusKm);
  console.log(`[OSM] L3 Overpass API fetch for doctors near (${lat}, ${lng}), radius ${radiusKm} km`);

  try {
    const raw = await postOverpass(overpassQuery);
    const json: OverpassResponse = JSON.parse(raw);

    if (!json.elements || !Array.isArray(json.elements)) {
      console.warn('[OSM] Unexpected Overpass response shape — returning empty array');
      return [];
    }

    const doctors = parseElements(json.elements);
    doctors.sort((a, b) => a.name.localeCompare(b.name));

    console.log(`[OSM] Found ${doctors.length} doctors from Overpass API`);

    if (doctors.length > 0) {
      // Write to L1
      memCache.set(cacheKey, { timestamp: Date.now(), data: doctors });

      // Write to L2 (async, non-blocking — errors logged but don't fail the request)
      writeToSupabase(cacheKey, doctors).catch(() => {});
    }

    return doctors;
  } catch (error) {
    console.error('[OSM] Error fetching nearby doctors:', error);
    return [];
  }
}
