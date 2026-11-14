import { supabase } from '../config/supabase.js'

export const createSubmission = async (req, res) => {
  try {
    const user_id = req.user.id
    const {
      tipe_sampah, foto_url, berat_kg, kondisi,
      pickup_point, tanggal_pickup, catatan, umkm_id
    } = req.body

    if (!tipe_sampah?.length || !berat_kg || !kondisi
        || !pickup_point || !tanggal_pickup || !umkm_id)
      return res.status(400).json({ error: 'Missing required fields' })

    const { data: submission, error } = await supabase
      .from('submissions')
      .insert({ user_id, umkm_id, tipe_sampah, foto_url,
                berat_kg, kondisi, pickup_point, tanggal_pickup, catatan })
      .select().single()
    if (error) return res.status(500).json({ error: error.message })

    await supabase.from('status_history')
      .insert({ submission_id: submission.id, status: 'pending' })

    res.status(201).json(submission)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

export const getSubmissions = async (req, res) => {
  try {
    const user_id = req.user.id
    const { status } = req.query

    let query = supabase
      .from('submissions')
      .select('*, umkm(id, nama, lokasi)')
      .eq('user_id', user_id)
      .order('created_at', { ascending: false })

    if (status) query = query.eq('status', status)

    const { data, error } = await query
    if (error) return res.status(500).json({ error: error.message })

    res.json({ submissions: data })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

export const getActiveSubmissions = async (req, res) => {
  try {
    const user_id = req.user.id

    const { data, error } = await supabase
      .from('submissions')
      .select('*, umkm(id, nama, lokasi)')
      .eq('user_id', user_id)
      .in('status', ['pending', 'confirmed', 'picked_up'])
      .order('created_at', { ascending: false })
    if (error) return res.status(500).json({ error: error.message })

    res.json({ submissions: data, count: data.length })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

export const getSubmissionById = async (req, res) => {
  try {
    const user_id = req.user.id
    const { id } = req.params

    const { data: submission, error } = await supabase
      .from('submissions')
      .select('*, umkm(*)')
      .eq('id', id).eq('user_id', user_id)
      .single()
    if (error || !submission)
      return res.status(404).json({ error: 'Submission not found' })

    const { data: history } = await supabase
      .from('status_history')
      .select('*')
      .eq('submission_id', id)
      .order('changed_at', { ascending: true })

    res.json({ ...submission, status_history: history })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}