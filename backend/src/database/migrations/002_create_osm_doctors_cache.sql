-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: 002_create_osm_doctors_cache.sql
-- Description: Lightweight cache table for OSM Overpass API doctor results.
--              Rows are keyed by a rounded lat/lng grid cell + radius so
--              that nearby queries can reuse cached Overpass results for 24h.
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS osm_doctors_cache (
    id            SERIAL PRIMARY KEY,

    -- Grid cell key (lat/lng rounded to 2 decimals + radiusKm)
    cache_key     VARCHAR(80) NOT NULL,

    -- Individual doctor fields from Overpass
    name          TEXT        NOT NULL,
    lat           DOUBLE PRECISION NOT NULL,
    lng           DOUBLE PRECISION NOT NULL,
    phone         TEXT,
    address       TEXT,

    -- Housekeeping
    fetched_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Fast lookup by cache_key for the read path
CREATE INDEX IF NOT EXISTS idx_osm_cache_key ON osm_doctors_cache (cache_key);

-- Fast cleanup of stale rows (older than 24 h)
CREATE INDEX IF NOT EXISTS idx_osm_cache_fetched_at ON osm_doctors_cache (fetched_at);
