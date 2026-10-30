import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose from 'mongoose';
import supertest from 'supertest';
import { createApp } from '../src/app';

let mongod: MongoMemoryServer;
let app: ReturnType<typeof createApp>;
// supertest(app) returns a TestAgent — use ReturnType to avoid version mismatch
let request: ReturnType<typeof supertest>;

// ─── Setup / Teardown ──────────────────────────────────────────────────────────

// Allow up to 5 minutes for the one-time MongoDB binary download
const SETUP_TIMEOUT = 5 * 60 * 1000;

beforeAll(async () => {
  // Pin to MongoDB 6.0 so the binary is smaller (~300MB) and cacheable
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
  // Clean all collections between tests
  const collections = mongoose.connection.collections;
  for (const key in collections) {
    await collections[key].deleteMany({});
  }
});

// ─── Helper ────────────────────────────────────────────────────────────────────

const TEST_USER = {
  name: 'Test User',
  email: 'test@dermascan.ai',
  password: 'SecurePass@123',
};

const registerTestUser = async () => {
  return request.post('/api/v1/auth/register').send(TEST_USER);
};

// ─── Health Check ─────────────────────────────────────────────────────────────

describe('GET /health', () => {
  it('returns 200 and status ok', async () => {
    const res = await request.get('/health');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.status).toBe('ok');
  });
});

// ─── POST /api/v1/auth/register ───────────────────────────────────────────────

describe('POST /api/v1/auth/register', () => {
  it('registers a new user and returns tokens', async () => {
    const res = await registerTestUser();
    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.email).toBe(TEST_USER.email);
    expect(res.body.data.user.name).toBe(TEST_USER.name);
    expect(res.body.data.tokens.accessToken).toBeDefined();
    expect(res.body.data.tokens.refreshToken).toBeDefined();
    // Never expose password hash
    expect(res.body.data.user.passwordHash).toBeUndefined();
  });

  it('returns 409 when email already exists', async () => {
    await registerTestUser();
    const res = await registerTestUser();
    expect(res.status).toBe(409);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('EMAIL_ALREADY_EXISTS');
  });

  it('returns 400 for invalid email', async () => {
    const res = await request.post('/api/v1/auth/register').send({
      ...TEST_USER,
      email: 'not-an-email',
    });
    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('returns 400 for weak password missing uppercase', async () => {
    const res = await request.post('/api/v1/auth/register').send({
      ...TEST_USER,
      password: 'weakpassword1@',
    });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('returns 400 for password shorter than 8 characters', async () => {
    const res = await request.post('/api/v1/auth/register').send({
      ...TEST_USER,
      password: 'Ab1@',
    });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('returns 400 for missing name', async () => {
    const res = await request.post('/api/v1/auth/register').send({
      email: TEST_USER.email,
      password: TEST_USER.password,
    });
    expect(res.status).toBe(400);
  });
});

// ─── POST /api/v1/auth/login ──────────────────────────────────────────────────

describe('POST /api/v1/auth/login', () => {
  beforeEach(async () => {
    await registerTestUser();
  });

  it('logs in with correct credentials', async () => {
    const res = await request.post('/api/v1/auth/login').send({
      email: TEST_USER.email,
      password: TEST_USER.password,
    });
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.tokens.accessToken).toBeDefined();
    expect(res.body.data.tokens.refreshToken).toBeDefined();
    expect(res.body.data.user.email).toBe(TEST_USER.email);
  });

  it('returns 401 for wrong password', async () => {
    const res = await request.post('/api/v1/auth/login').send({
      email: TEST_USER.email,
      password: 'WrongPassword@999',
    });
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('INVALID_CREDENTIALS');
  });

  it('returns 401 for non-existent email', async () => {
    const res = await request.post('/api/v1/auth/login').send({
      email: 'nobody@dermascan.ai',
      password: TEST_USER.password,
    });
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('INVALID_CREDENTIALS');
  });

  it('does not expose password hash in response', async () => {
    const res = await request.post('/api/v1/auth/login').send({
      email: TEST_USER.email,
      password: TEST_USER.password,
    });
    expect(res.body.data.user.passwordHash).toBeUndefined();
    expect(res.body.data.user.refreshTokenHash).toBeUndefined();
  });
});

// ─── GET /api/v1/auth/me ──────────────────────────────────────────────────────

describe('GET /api/v1/auth/me', () => {
  let accessToken: string;

  beforeEach(async () => {
    const res = await registerTestUser();
    accessToken = res.body.data.tokens.accessToken as string;
  });

  it('returns user profile with valid token', async () => {
    const res = await request
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${accessToken}`);
    expect(res.status).toBe(200);
    expect(res.body.data.user.email).toBe(TEST_USER.email);
  });

  it('returns 401 without token', async () => {
    const res = await request.get('/api/v1/auth/me');
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('NO_TOKEN');
  });

  it('returns 401 with malformed token', async () => {
    const res = await request
      .get('/api/v1/auth/me')
      .set('Authorization', 'Bearer totally.invalid.token');
    expect(res.status).toBe(401);
  });
});

// ─── POST /api/v1/auth/refresh ────────────────────────────────────────────────

describe('POST /api/v1/auth/refresh', () => {
  let refreshToken: string;

  beforeEach(async () => {
    const res = await registerTestUser();
    refreshToken = res.body.data.tokens.refreshToken as string;
  });

  it('issues new token pair with valid refresh token', async () => {
    const res = await request.post('/api/v1/auth/refresh').send({ refreshToken });
    expect(res.status).toBe(200);
    expect(res.body.data.tokens.accessToken).toBeDefined();
    expect(res.body.data.tokens.refreshToken).toBeDefined();
    // New refresh token should be different (token rotation)
    expect(res.body.data.tokens.refreshToken).not.toBe(refreshToken);
  });

  it('returns 401 with invalid refresh token', async () => {
    const res = await request
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: 'invalid.refresh.token' });
    expect(res.status).toBe(401);
  });

  it('returns 400 when refreshToken field is missing', async () => {
    const res = await request.post('/api/v1/auth/refresh').send({});
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });
});

// ─── POST /api/v1/auth/logout ─────────────────────────────────────────────────

describe('POST /api/v1/auth/logout', () => {
  let accessToken: string;
  let refreshToken: string;

  beforeEach(async () => {
    const res = await registerTestUser();
    accessToken = res.body.data.tokens.accessToken as string;
    refreshToken = res.body.data.tokens.refreshToken as string;
  });

  it('logs out successfully and invalidates the refresh token', async () => {
    // Logout
    const logoutRes = await request
      .post('/api/v1/auth/logout')
      .set('Authorization', `Bearer ${accessToken}`);
    expect(logoutRes.status).toBe(200);

    // After logout, the refresh token should be rejected
    const refreshRes = await request
      .post('/api/v1/auth/refresh')
      .send({ refreshToken });
    expect(refreshRes.status).toBe(401);
  });

  it('returns 401 when no token is provided', async () => {
    const res = await request.post('/api/v1/auth/logout');
    expect(res.status).toBe(401);
  });
});

// ─── POST /api/v1/auth/forgot-password ───────────────────────────────────────

describe('POST /api/v1/auth/forgot-password', () => {
  it('always returns 200 to prevent email enumeration', async () => {
    const res = await request
      .post('/api/v1/auth/forgot-password')
      .send({ email: 'doesnotexist@dermascan.ai' });
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });

  it('returns 200 for a registered email too', async () => {
    await registerTestUser();
    const res = await request
      .post('/api/v1/auth/forgot-password')
      .send({ email: TEST_USER.email });
    expect(res.status).toBe(200);
  });

  it('returns 400 for invalid email format', async () => {
    const res = await request
      .post('/api/v1/auth/forgot-password')
      .send({ email: 'not-an-email' });
    expect(res.status).toBe(400);
  });
});

// ─── 404 Handler ─────────────────────────────────────────────────────────────

describe('Unknown route', () => {
  it('returns 404 for unknown endpoints', async () => {
    const res = await request.get('/api/v1/does-not-exist');
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe('ROUTE_NOT_FOUND');
  });
});
