import { GoogleGenerativeAI } from '@google/generative-ai'

const genAI = new GoogleGenerativeAI((process.env.GEMINI_API_KEY || '').trim())

export const model = genAI.getGenerativeModel({
  model: 'gemini-2.0-flash',
  generationConfig: {
    maxOutputTokens: 350,
    temperature: 0.8
  }
})