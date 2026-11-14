import express from 'express'
import { authenticate } from '../middleware/auth.js'
import { getProfile, updateProfile, getStats } from '../controllers/profileController.js'
const router = express.Router()
router.get('/profile', authenticate, getProfile)
router.put('/profile', authenticate, updateProfile)
router.get('/stats', authenticate, getStats)
export default router

