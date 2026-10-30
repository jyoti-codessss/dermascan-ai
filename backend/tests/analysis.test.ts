import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose from 'mongoose';
import supertest from 'supertest';
import { createApp } from '../src/app';

let mongod: MongoMemoryServer;
let app: ReturnType<typeof createApp>;
let request: ReturnType<typeof supertest>;

const SETUP_TIMEOUT = 5 * 60 * 1000;

beforeAll(async () => {
  process.env.MONGOMS_VERSION = '6.0.12';
  process.env.MONGOMS_MD5_CHECK = '0';

  mongod = await MongoMemoryServer.create({
    binary: { version: '6.0.12' },
  });
  const uri = mongod.getUri();
  await mongoose.connect(uri);

  app = createApp();
  request = supertest(app);
}, SETUP_TIMEOUT);

afterAll(async () => {
  await mongoose.disconnect();
  await mongod.stop();
}, SETUP_TIMEOUT);

afterEach(async () => {
  const collections = mongoose.connection.collections;
  for (const key in collections) {
    await collections[key].deleteMany({});
  }
});

// ─── Helper to generate valid PNG Image Buffer ──────────────────────────────────
function createValidPngBuffer(width = 256, height = 256): Buffer {
  const pngHeader = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  // IHDR chunk
  const ihdrChunk = Buffer.alloc(25);
  ihdrChunk.writeUInt32BE(13, 0); // length
  ihdrChunk.write('IHDR', 4, 4, 'ascii');
  ihdrChunk.writeUInt32BE(width, 8);
  ihdrChunk.writeUInt32BE(height, 12);
  ihdrChunk[16] = 8; // bit depth
  ihdrChunk[17] = 2; // color type (truecolor RGB)
  ihdrChunk[18] = 0; // compression
  ihdrChunk[19] = 0; // filter
  ihdrChunk[20] = 0; // interlace
  // pseudo CRC
  ihdrChunk.writeUInt32BE(0x12345678, 21);

  // IDAT payload with dermatological variance simulation
  const rawData = Buffer.alloc(2048);
  for (let i = 0; i < rawData.length; i++) {
    rawData[i] = (i * 37) % 256;
  }

  const idatChunk = Buffer.alloc(8 + rawData.length);
  idatChunk.writeUInt32BE(rawData.length, 0);
  idatChunk.write('IDAT', 4, 4, 'ascii');
  rawData.copy(idatChunk, 8);

  const iendChunk = Buffer.from([0, 0, 0, 0, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82]);

  return Buffer.concat([pngHeader, ihdrChunk, idatChunk, iendChunk]);
}

describe('HAM10000 AI Analysis Pipeline & Image Upload API', () => {
  let userToken: string;
  let otherUserToken: string;

  beforeEach(async () => {
    // Register user 1
    const reg1 = await request.post('/api/v1/auth/register').send({
      name: 'Dr. Jane Smith',
      email: 'jane@dermascan.ai',
      password: 'SecurePass@123',
    });
    userToken = reg1.body.data.tokens.accessToken;

    // Register user 2
    const reg2 = await request.post('/api/v1/auth/register').send({
      name: 'Dr. Other User',
      email: 'other@dermascan.ai',
      password: 'SecurePass@123',
    });
    otherUserToken = reg2.body.data.tokens.accessToken;
  });

  // ─── POST /api/v1/analyses ──────────────────────────────────────────────────

  describe('POST /api/v1/analyses', () => {
    it('uploads a real image, executes HAM10000 inference, and stores result', async () => {
      const imageBuffer = createValidPngBuffer(300, 300);

      const res = await request
        .post('/api/v1/analyses')
        .set('Authorization', `Bearer ${userToken}`)
        .attach('image', imageBuffer, 'lesion_sample.png');

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);

      const data = res.body.data;
      expect(data.analysis).toBeDefined();
      expect(data.analysis._id).toBeDefined();
      expect(data.analysis.modelVersion).toContain('HAM10000');
      expect(data.analysis.predictedClass).toBeDefined();
      expect(data.analysis.conditionName).toBeDefined();
      expect(data.analysis.confidence).toBeGreaterThan(0);
      expect(data.analysis.confidence).toBeLessThanOrEqual(100);

      // Probabilities must contain all 7 HAM10000 classes
      expect(data.analysis.probabilities).toHaveLength(7);
      const codes = data.analysis.probabilities.map((p: { code: string }) => p.code);
      expect(codes).toContain('mel');
      expect(codes).toContain('bcc');
      expect(codes).toContain('akiec');
      expect(codes).toContain('bkl');
      expect(codes).toContain('df');
      expect(codes).toContain('vasc');
      expect(codes).toContain('nv');

      // Clinical summary and recommendations
      expect(data.analysis.summary.length).toBeGreaterThan(20);
      expect(data.analysis.clinicalRecommendations.length).toBeGreaterThan(0);
      expect(data.analysis.riskLevel).toMatch(/Low|Moderate|High/);
    });

    it('supports base64 image payload upload', async () => {
      const imageBuffer = createValidPngBuffer(256, 256);
      const base64Image = `data:image/png;base64,${imageBuffer.toString('base64')}`;

      const res = await request
        .post('/api/v1/analyses')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          imageBase64: base64Image,
          fileName: 'base64_lesion.png',
        });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.analysis.predictedClass).toBeDefined();
    });

    it('rejects unauthenticated analysis requests with 401', async () => {
      const imageBuffer = createValidPngBuffer(256, 256);
      const res = await request
        .post('/api/v1/analyses')
        .attach('image', imageBuffer, 'sample.png');

      expect(res.status).toBe(401);
    });

    it('rejects non-image files with 400', async () => {
      const textBuffer = Buffer.from('<html><body>Not an image</body></html>');
      const res = await request
        .post('/api/v1/analyses')
        .set('Authorization', `Bearer ${userToken}`)
        .attach('image', textBuffer, 'document.html');

      expect(res.status).toBe(400);
      expect(res.body.error.code).toBe('INVALID_IMAGE_TYPE');
    });

    it('rejects empty image buffer with 400', async () => {
      const emptyBuffer = Buffer.alloc(10);
      const res = await request
        .post('/api/v1/analyses')
        .set('Authorization', `Bearer ${userToken}`)
        .attach('image', emptyBuffer, 'tiny.png');

      expect(res.status).toBe(400);
    });
  });

  // ─── GET /api/v1/analyses ───────────────────────────────────────────────────

  describe('GET /api/v1/analyses', () => {
    it('returns paginated analysis history for authenticated user', async () => {
      const imageBuffer = createValidPngBuffer(200, 200);

      // Create 2 analyses for user 1
      await request
        .post('/api/v1/analyses')
        .set('Authorization', `Bearer ${userToken}`)
        .attach('image', imageBuffer, 'scan1.png');

      await request
        .post('/api/v1/analyses')
        .set('Authorization', `Bearer ${userToken}`)
        .attach('image', imageBuffer, 'scan2.png');

      const res = await request
        .get('/api/v1/analyses?page=1&limit=10')
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.analyses).toHaveLength(2);
      expect(res.body.data.total).toBe(2);
    });

    it('isolates user history — user 2 sees 0 records when user 1 created records', async () => {
      const imageBuffer = createValidPngBuffer(200, 200);
      await request
        .post('/api/v1/analyses')
        .set('Authorization', `Bearer ${userToken}`)
        .attach('image', imageBuffer, 'scan1.png');

      const res = await request
        .get('/api/v1/analyses')
        .set('Authorization', `Bearer ${otherUserToken}`);

      expect(res.status).toBe(200);
      expect(res.body.data.analyses).toHaveLength(0);
      expect(res.body.data.total).toBe(0);
    });
  });

  // ─── GET /api/v1/analyses/:id ───────────────────────────────────────────────

  describe('GET /api/v1/analyses/:id', () => {
    it('retrieves single analysis details by ID', async () => {
      const imageBuffer = createValidPngBuffer(200, 200);
      const createRes = await request
        .post('/api/v1/analyses')
        .set('Authorization', `Bearer ${userToken}`)
        .attach('image', imageBuffer, 'scan.png');

      const analysisId = createRes.body.data.analysis._id;

      const res = await request
        .get(`/api/v1/analyses/${analysisId}`)
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.status).toBe(200);
      expect(res.body.data.analysis._id).toBe(analysisId);
    });

    it('prevents user from reading another user analysis (404)', async () => {
      const imageBuffer = createValidPngBuffer(200, 200);
      const createRes = await request
        .post('/api/v1/analyses')
        .set('Authorization', `Bearer ${userToken}`)
        .attach('image', imageBuffer, 'scan.png');

      const analysisId = createRes.body.data.analysis._id;

      const res = await request
        .get(`/api/v1/analyses/${analysisId}`)
        .set('Authorization', `Bearer ${otherUserToken}`);

      expect(res.status).toBe(404);
    });
  });

  // ─── DELETE /api/v1/analyses/:id ────────────────────────────────────────────

  describe('DELETE /api/v1/analyses/:id', () => {
    it('deletes analysis and removes from user history', async () => {
      const imageBuffer = createValidPngBuffer(200, 200);
      const createRes = await request
        .post('/api/v1/analyses')
        .set('Authorization', `Bearer ${userToken}`)
        .attach('image', imageBuffer, 'scan.png');

      const analysisId = createRes.body.data.analysis._id;

      const deleteRes = await request
        .delete(`/api/v1/analyses/${analysisId}`)
        .set('Authorization', `Bearer ${userToken}`);

      expect(deleteRes.status).toBe(200);

      // Verify it no longer exists
      const getRes = await request
        .get(`/api/v1/analyses/${analysisId}`)
        .set('Authorization', `Bearer ${userToken}`);
      expect(getRes.status).toBe(404);
    });
  });
});
