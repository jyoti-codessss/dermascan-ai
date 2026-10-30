import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose from 'mongoose';
import supertest from 'supertest';
import { createApp } from '../src/app';
import { User } from '../src/models/user.model';

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

describe('POST /api/v1/auth/google', () => {
  const mockGoogleIdToken = 'test_google_token:google_sub_9999:dr_john@gmail.com:Dr. John Doe';

  it('registers a new user when Google email does not exist in DB', async () => {
    const res = await request
      .post('/api/v1/auth/google')
      .send({ idToken: mockGoogleIdToken });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.email).toBe('dr_john@gmail.com');
    expect(res.body.data.user.name).toBe('Dr. John Doe');
    expect(res.body.data.tokens.accessToken).toBeDefined();
    expect(res.body.data.tokens.refreshToken).toBeDefined();

    // Verify stored user in database
    const userInDb = await User.findOne({ email: 'dr_john@gmail.com' });
    expect(userInDb).not.toBeNull();
    expect(userInDb?.googleId).toBe('google_sub_9999');
    expect(userInDb?.authProvider).toBe('google');
  });

  it('logs in an existing Google user without creating duplicate record', async () => {
    // 1st login (registers)
    await request
      .post('/api/v1/auth/google')
      .send({ idToken: mockGoogleIdToken });

    // 2nd login (authenticates existing user)
    const res2 = await request
      .post('/api/v1/auth/google')
      .send({ idToken: mockGoogleIdToken });

    expect(res2.status).toBe(200);
    expect(res2.body.data.user.email).toBe('dr_john@gmail.com');

    // Verify only 1 record exists
    const count = await User.countDocuments({ email: 'dr_john@gmail.com' });
    expect(count).toBe(1);
  });

  it('links Google account to an existing email/password user', async () => {
    // Create existing local user
    const passwordHash = await User.hashPassword('ExistingPass@123');
    await User.create({
      name: 'Existing Local User',
      email: 'dr_john@gmail.com',
      passwordHash,
      authProvider: 'local',
    });

    const res = await request
      .post('/api/v1/auth/google')
      .send({ idToken: mockGoogleIdToken });

    expect(res.status).toBe(200);
    expect(res.body.data.user.email).toBe('dr_john@gmail.com');

    const updatedUser = await User.findOne({ email: 'dr_john@gmail.com' });
    expect(updatedUser?.googleId).toBe('google_sub_9999');
  });

  it('returns 400 when idToken is missing or empty', async () => {
    const res1 = await request.post('/api/v1/auth/google').send({});
    expect(res1.status).toBe(400);

    const res2 = await request.post('/api/v1/auth/google').send({ idToken: '   ' });
    expect(res2.status).toBe(400);
  });

  it('returns 401 when Google token is invalid or rejected by Google verification', async () => {
    const res = await request
      .post('/api/v1/auth/google')
      .send({ idToken: 'invalid_unverified_google_jwt_payload_12345' });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  it('allows token refresh after Google authentication', async () => {
    const loginRes = await request
      .post('/api/v1/auth/google')
      .send({ idToken: mockGoogleIdToken });

    const refreshToken = loginRes.body.data.tokens.refreshToken;

    const refreshRes = await request
      .post('/api/v1/auth/refresh')
      .send({ refreshToken });

    expect(refreshRes.status).toBe(200);
    expect(refreshRes.body.data.tokens.accessToken).toBeDefined();
    expect(refreshRes.body.data.tokens.refreshToken).not.toBe(refreshToken);
  });
});
