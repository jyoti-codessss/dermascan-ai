import request from 'supertest';
import { createApp } from '../src/app';
import * as geminiService from '../src/services/gemini.service';

const app = createApp();

describe('POST /api/v1/chat', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('should return 400 when message is missing or empty', async () => {
    const res = await request(app)
      .post('/api/v1/chat')
      .send({});

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('INVALID_CHAT_REQUEST');
  });

  it('should return 400 when message is an empty string', async () => {
    const res = await request(app)
      .post('/api/v1/chat')
      .send({ message: '   ' });

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });

  it('should return 200 with AI response when valid message is provided', async () => {
    const mockReply = 'A rash with red, itchy patches could be eczema. Please consult a dermatologist for an accurate diagnosis.';
    jest.spyOn(geminiService, 'generateChatResponse').mockResolvedValueOnce(mockReply);

    const res = await request(app)
      .post('/api/v1/chat')
      .send({
        message: 'What causes itchy red skin patches?',
        history: [
          { role: 'user', content: 'Hi' },
          { role: 'model', content: 'Hello! How can I assist you with skin health today?' },
        ],
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.response).toBe(mockReply);
    expect(res.body.data.model).toBe('gemini-2.5-flash');
    expect(res.body.data.timestamp).toBeDefined();
  });

  it('should gracefully handle Gemini API errors and never expose sensitive keys', async () => {
    jest.spyOn(geminiService, 'generateChatResponse').mockRejectedValueOnce(
      new Error('DermaScan AI Assistant is currently unavailable.')
    );

    const res = await request(app)
      .post('/api/v1/chat')
      .send({ message: 'Help me diagnose this' });

    expect(res.status).toBe(500);
    expect(res.body.success).toBe(false);
    expect(res.body.error.message).toContain('DermaScan AI Assistant is currently unavailable');
    // Ensure no API keys leaked
    expect(JSON.stringify(res.body)).not.toMatch(/AIza[0-9A-Za-z-_]{35}/);
  });
});
