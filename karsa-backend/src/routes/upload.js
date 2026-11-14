import express from 'express'
import multer from 'multer'
import { authenticate } from '../middleware/auth.js'
import { uploadPhoto } from '../controllers/uploadController.js'
const router = express.Router()
const upload = multer({ storage: multer.memoryStorage() })
router.post('/photo', authenticate, upload.single('file'), uploadPhoto)
export default router