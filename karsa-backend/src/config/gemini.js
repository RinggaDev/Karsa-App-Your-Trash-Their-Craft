import { GoogleGenerativeAI } from '@google/generative-ai'

const genAI = new GoogleGenerativeAI((process.env.GEMINI_API_KEY || '').trim())

export const model = genAI.getGenerativeModel({
  model: 'gemini-3.5-flash-lite',
  generationConfig: {
    maxOutputTokens: 350,
    temperature: 0.8
  }
})