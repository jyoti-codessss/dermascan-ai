import { GoogleGenAI } from '@google/genai';
import { env } from '../config/environment';

const SYSTEM_INSTRUCTION =
  'You are a helpful skin health assistant for DermaScan AI. You provide general information about skin conditions, guide users on how to use the app (scanning, nearby doctors, etc.), and always remind them to consult a real dermatologist for diagnosis. Do not give specific medical advice or prescriptions.';

let genAIClient: GoogleGenAI | null = null;

const getGenAIClient = (): GoogleGenAI => {
  const apiKey = env.geminiApiKey || process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY is not configured in the environment.');
  }

  if (!genAIClient) {
    genAIClient = new GoogleGenAI({ apiKey });
  }
  return genAIClient;
};

export interface ChatHistoryMessage {
  role: 'user' | 'model' | 'assistant';
  parts?: Array<{ text: string }> | string;
  text?: string;
  content?: string;
}

/**
 * Sanitizes and formats chat history into Gemini contents format.
 */
const formatContents = (message: string, history?: any[]) => {
  const contents: any[] = [];

  if (Array.isArray(history) && history.length > 0) {
    for (const item of history) {
      if (!item) continue;
      const role = (item.role === 'assistant' || item.role === 'model') ? 'model' : 'user';
      let textContent = '';

      if (typeof item.text === 'string') {
        textContent = item.text;
      } else if (typeof item.content === 'string') {
        textContent = item.content;
      } else if (typeof item.parts === 'string') {
        textContent = item.parts;
      } else if (Array.isArray(item.parts) && item.parts.length > 0) {
        textContent = item.parts.map((p: any) => (typeof p === 'string' ? p : p.text || '')).join(' ');
      } else if (typeof item.message === 'string') {
        textContent = item.message;
      }

      if (textContent.trim()) {
        contents.push({
          role,
          parts: [{ text: textContent.trim() }],
        });
      }
    }
  }

  // Append current user message
  contents.push({
    role: 'user',
    parts: [{ text: message.trim() }],
  });

  return contents;
};

const CANDIDATE_MODELS = [
  'gemini-3.8-flash',
  'gemini-3.5-flash-lite',
  'gemini-flash-latest',
  'gemini-2.5-flash',
];

/**
 * Generates an AI chat response using Gemini Flash with multi-model resilience.
 *
 * @param message The user's input message
 * @param history Optional conversation history
 * @returns AI generated response text
 */
export const generateChatResponse = async (
  message: string,
  history?: any[]
): Promise<string> => {
  const ai = getGenAIClient();
  const contents = formatContents(message, history);

  let lastError: any = null;

  for (const modelName of CANDIDATE_MODELS) {
    try {
      const response = await ai.models.generateContent({
        model: modelName,
        contents,
        config: {
          systemInstruction: SYSTEM_INSTRUCTION,
          temperature: 0.7,
        },
      });

      const responseText = response.text;
      if (responseText && responseText.trim()) {
        return responseText.trim();
      }
    } catch (error: any) {
      lastError = error;
      const sanitizedErrorMsg = (error?.message || 'Unknown error')
        .replace(/AIza[0-9A-Za-z-_]{35}/g, '[REDACTED_API_KEY]');
      console.warn(`[GeminiService] Model ${modelName} failed: ${sanitizedErrorMsg}. Trying next candidate...`);
    }
  }

  // If all models failed
  console.error('[GeminiService] All candidate Gemini models failed:', lastError?.message || lastError);
  throw new Error(
    'DermaScan AI Assistant is currently unavailable. Please check your connection or consult a dermatologist directly for clinical guidance.'
  );
};
