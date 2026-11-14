import express from 'express'
import { authenticate } from '../middleware/auth.js'
import { getMicroInsight, getMacroInsight } from '../controllers/insightController.js'
const router = express.Router()
router.post('/micro', authenticate, getMicroInsight)
router.get('/macro', authenticate, getMacroInsight)
export default router