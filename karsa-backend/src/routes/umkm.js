import express from 'express'
import { authenticate } from '../middleware/auth.js'
import { getUmkm, getUmkmById } from '../controllers/umkmController.js'
const router = express.Router()
router.get('/', authenticate, getUmkm)
router.get('/:id', authenticate, getUmkmById)
export default router

