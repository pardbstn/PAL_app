import OpenAI from "openai";
import {GoogleGenerativeAI} from "@google/generative-ai";

/**
 * OpenAI 클라이언트 (지연 초기화, 싱글톤)
 */
let openaiClient: OpenAI | null = null;

export const getOpenAIClient = (): OpenAI => {
  if (!openaiClient) {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      throw new Error("OPENAI_API_KEY is not configured");
    }
    openaiClient = new OpenAI({apiKey});
  }
  return openaiClient;
};

/**
 * Google AI 클라이언트 (지연 초기화, 싱글톤)
 */
let googleAIClient: GoogleGenerativeAI | null = null;

export const getGoogleAIClient = (): GoogleGenerativeAI => {
  if (!googleAIClient) {
    const apiKey = process.env.GOOGLE_AI_API_KEY;
    if (!apiKey) {
      throw new Error("GOOGLE_AI_API_KEY is not configured");
    }
    googleAIClient = new GoogleGenerativeAI(apiKey);
  }
  return googleAIClient;
};

/**
 * GPT 채팅 호출 헬퍼
 */
export const callGPT = async (
  prompt: string,
  options?: {
    model?: string;
    maxTokens?: number;
    temperature?: number;
    jsonMode?: boolean;
    systemPrompt?: string;
  }
): Promise<string> => {
  const openai = getOpenAIClient();
  const messages: OpenAI.Chat.Completions.ChatCompletionMessageParam[] = [];

  if (options?.systemPrompt) {
    messages.push({role: "system", content: options.systemPrompt});
  }
  messages.push({role: "user", content: prompt});

  const response = await openai.chat.completions.create({
    model: options?.model || "gpt-4o-mini",
    max_tokens: options?.maxTokens || 2000,
    temperature: options?.temperature ?? 0.7,
    messages,
    ...(options?.jsonMode ? {response_format: {type: "json_object" as const}} : {}),
  });

  return response.choices[0].message.content || "";
};

/**
 * Gemini 호출 헬퍼
 */
export const callGemini = async (
  prompt: string,
  options?: {
    model?: string;
    temperature?: number;
    jsonMode?: boolean;
  }
): Promise<string> => {
  const genAI = getGoogleAIClient();
  const model = genAI.getGenerativeModel({
    model: options?.model || "gemini-1.5-flash",
    generationConfig: {
      temperature: options?.temperature ?? 0.7,
      ...(options?.jsonMode ? {responseMimeType: "application/json"} : {}),
    },
  });

  const result = await model.generateContent(prompt);
  return result.response.text();
};

/**
 * Vision API 호출 (이미지 분석)
 */
export const callVision = async (
  prompt: string,
  imageUrl: string,
  options?: {
    model?: string;
    maxTokens?: number;
  }
): Promise<string> => {
  const openai = getOpenAIClient();
  const response = await openai.chat.completions.create({
    model: options?.model || "gpt-4o",
    max_tokens: options?.maxTokens || 2000,
    messages: [{
      role: "user",
      content: [
        {type: "text", text: prompt},
        {type: "image_url", image_url: {url: imageUrl}},
      ],
    }],
  });

  return response.choices[0].message.content || "";
};
