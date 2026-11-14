import { supabase } from '../config/supabase.js'

export const uploadPhoto = async (req, res) => {
  try {
    const file = req.file
    if (!file) return res.status(400).json({ error: 'No file uploaded' })

    const ext = file.originalname.split('.').pop()
    const fileName = `${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`

    const { error } = await supabase.storage
      .from('trash-photos')
      .upload(fileName, file.buffer, { contentType: file.mimetype })
    if (error) return res.status(500).json({ error: error.message })

    const { data: { publicUrl } } = supabase.storage
      .from('trash-photos').getPublicUrl(fileName)

    res.json({ foto_url: publicUrl })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}