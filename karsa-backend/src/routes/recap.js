import express from 'express'
import { authenticate } from '../middleware/auth.js'
import { getRecap } from '../controllers/recapController.js'
const router = express.Router()
router.get('/', authenticate, getRecap)
export default router

