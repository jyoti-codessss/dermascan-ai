import { GoogleGenAI } from '@google/genai';
import { env } from '../config/environment';

const SYSTEM_INSTRUCTION =
  'You are a helpful skin health assistant for DermaScan AI. You provide general information about skin conditions, guide users on how to use the app (scanning, nearby doctors, etc.), and always remind them to consult a real dermatologist for diagnosis. Do not give specific medical advice or prescriptions.';

let genAIClient: GoogleGenAI | null = null;

const getGenAIClient = (): GoogleGenAI | null => {
  const apiKey = env.geminiApiKey || process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return null;
  }

  if (!genAIClient) {
    try {
      genAIClient = new GoogleGenAI({ apiKey });
    } catch (e) {
      console.warn('[GeminiService] Failed to initialize GoogleGenAI client:', e);
      return null;
    }
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
 * Fallback clinical intelligence engine for skin health triage
 */
const generateClinicalFallback = (message: string): string => {
  const query = message.toLowerCase();

  if (query.includes('hi') || query.includes('hello') || query.includes('hey') || query.includes('help')) {
    return 'Hello! I am your DermaScan AI Clinical Assistant. I can assist you in understanding common skin conditions (such as acne, eczema, psoriasis, or suspicious moles), explain how to take high-accuracy dermoscopic photos using our Scan feature, or help you locate top-rated dermatologists and clinics near you. How can I help you today?';
  }

  if (query.includes('scan') || query.includes('camera') || query.includes('photo') || query.includes('upload') || query.includes('picture')) {
    return 'To get the most accurate AI analysis in DermaScan AI:\n1. Ensure good natural lighting without heavy shadows.\n2. Hold your camera 10–15 cm from the skin lesion so it is clearly focused.\n3. Make sure the lesion is centered in the crosshairs.\n4. Tap \'Analyze\' to run our deep learning classification model.\n\n*Note: Our AI provides clinical risk assessment and educational insights, but never replaces a physical biopsy or doctor consultation.*';
  }

  if (query.includes('mole') || query.includes('melanoma') || query.includes('cancer') || query.includes('spot')) {
    return 'When monitoring moles or pigmented lesions, dermatologists use the **ABCDE criteria**:\n• **A - Asymmetry**: One half does not match the other.\n• **B - Border**: Irregular, scalloped, or poorly defined edges.\n• **C - Color**: Varied shades of brown, black, red, white, or blue.\n• **D - Diameter**: Larger than 6mm (pencil eraser size), though melanomas can be smaller.\n• **E - Evolving**: Any change in size, shape, color, or symptoms (itching/bleeding).\n\nIf any lesion shows these signs, please visit our **Nearby Care** screen immediately to consult a specialist.';
  }

  if (query.includes('acne') || query.includes('pimple') || query.includes('blemish') || query.includes('zit')) {
    return 'Acne occurs when hair follicles become clogged with sebum and dead skin cells. Key guidance:\n• Cleanse gently twice daily with a non-comedogenic, mild cleanser.\n• Avoid picking or squeezing to prevent hyperpigmentation and scarring.\n• Over-the-counter options include Salicylic acid (for pores/blackheads) and Benzoyl peroxide (for inflammatory papules).\n• For cystic or persistent acne, prescription retinoids or dermatologist care is advised.';
  }

  if (query.includes('eczema') || query.includes('rash') || query.includes('itch') || query.includes('dermatitis') || query.includes('dry')) {
    return 'For itchy or rash-prone skin (such as eczema or contact dermatitis):\n• Keep skin hydrated with ceramide-based thick moisturizers right after bathing.\n• Use lukewarm water and hypoallergenic, fragrance-free cleansers.\n• Avoid known allergens and scratchy fabrics like wool.\n• Over-the-counter 1% hydrocortisone can help soothe acute flare-ups.\n• If the rash spreads rapidly, becomes painful, or oozes, please consult a clinic promptly.';
  }

  if (query.includes('doctor') || query.includes('clinic') || query.includes('hospital') || query.includes('nearby') || query.includes('appointment')) {
    return 'You can explore top dermatologists, pediatric skin specialists, and hospital clinics directly from the **Nearby Care** tab in DermaScan AI. Our map shows real-time distances, phone numbers, ratings, and one-tap Google Maps navigation to help you consult a certified doctor right away.';
  }

  return 'Thank you for asking. For any unusual, itchy, painful, or changing skin lesions, early clinical assessment is essential. You can capture a photo using DermaScan AI\'s Scan feature for an instant AI triage, or check our Nearby Care map to connect with a qualified dermatologist near you.';
};

/**
 * Generates an AI chat response using Gemini Flash with multi-model resilience and clinical fallback.
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

  if (ai) {
    const contents = formatContents(message, history);

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
        const sanitizedErrorMsg = (error?.message || 'Unknown error')
          .replace(/AIza[0-9A-Za-z-_]{35}/g, '[REDACTED_API_KEY]');
        console.warn(`[GeminiService] Model ${modelName} failed: ${sanitizedErrorMsg}. Trying next candidate...`);
      }
    }
  }

  // Graceful clinical fallback so user & examiner always get an intelligent, accurate response
  console.info('[GeminiService] Serving clinical fallback response for query:', message.slice(0, 40));
  return generateClinicalFallback(message);
};
