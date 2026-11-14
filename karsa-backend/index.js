import express from 'express'
import cors from 'cors'
import authRoutes from './src/routes/auth.js'
import profileRoutes from './src/routes/profile.js'
import submissionsRoutes from './src/routes/submissions.js'
import umkmRoutes from './src/routes/umkm.js'
import recapRoutes from './src/routes/recap.js'
import insightRoutes from './src/routes/insight.js'
import uploadRoutes from './src/routes/upload.js'

const app = express()

app.use(cors())
app.use(express.json())

app.use('/api/v1/auth', authRoutes)
app.use('/api/v1/users', profileRoutes)
app.use('/api/v1/submissions', submissionsRoutes)
app.use('/api/v1/umkm', umkmRoutes)
app.use('/api/v1/recap', recapRoutes)
app.use('/api/v1/insight', insightRoutes)
app.use('/api/v1/upload', uploadRoutes)

app.get('/health', (_, res) => res.json({ status: 'ok', app: 'Karsa API' }))

const PORT = process.env.PORT || 3000
app.listen(PORT, () => console.log(`Karsa API running on :${PORT}`))