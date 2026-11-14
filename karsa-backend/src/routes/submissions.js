import express from 'express'
import { authenticate } from '../middleware/auth.js'
import {
  createSubmission, getSubmissions,
  getActiveSubmissions, getSubmissionById
} from '../controllers/submissionsController.js'
const router = express.Router()
router.post('/', authenticate, createSubmission)
router.get('/', authenticate, getSubmissions)
router.get('/active', authenticate, getActiveSubmissions)
router.get('/:id', authenticate, getSubmissionById)
export default router