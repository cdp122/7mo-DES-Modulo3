import { defineConfig } from 'vitest/config';
import { resolve } from 'path';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: [resolve(__dirname, './setup.ts')],
    include: ['src/**/*.test.ts'],
    testTimeout: 30000,
    hookTimeout: 60000,
    coverage: {
      provider: 'v8',
      reporter: ['html', 'text'],
      reportsDirectory: resolve(__dirname, './coverage'),
      include: ['src/**/*.ts'],
      exclude: ['src/**/*.test.ts', 'src/**/*.graphql']
    }
  }
});
