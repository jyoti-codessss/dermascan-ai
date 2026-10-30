import type { Config } from 'jest';

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: ['**/*.test.ts'],
  verbose: true,
  forceExit: true,
  clearMocks: true,
  resetMocks: true,
  restoreMocks: true,
  detectOpenHandles: true,
  // Allow 5 min per test — the first run downloads the MongoDB binary
  testTimeout: 300000,
  globals: {
    'ts-jest': {
      tsconfig: {
        strict: true,
      },
    },
  },
};

export default config;
