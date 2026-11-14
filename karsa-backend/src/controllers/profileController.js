import { supabase } from '../config/supabase.js'

export const getProfile = async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('users').select('*').eq('id', req.user.id).single()
    if (error || !data) {
      return res.json({
        id: req.user.id,
        email: req.user.email || '',
        nama: req.user.user_metadata?.nama || (req.user.email || '').split('@')[0],
        kota: req.user.user_metadata?.kota || ''
      })
    }
    res.json(data)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

export const updateProfile = async (req, res) => {
  try {
    const { nama, kota } = req.body
    const { data, error } = await supabase
      .from('users')
      .upsert({
        id: req.user.id,
        email: req.user.email || '',
        nama,
        kota
      })
      .select()
      .single()
    if (error) return res.status(500).json({ error: error.message })
    res.json(data)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

export const getStats = async (req, res) => {
  try {
    const { data: subs, error } = await supabase
      .from('submissions')
      .select('berat_kg, umkm_id, status')
      .eq('user_id', req.user.id)
    if (error) return res.status(500).json({ error: error.message })

    const done = subs.filter(s => s.status === 'done')
    const active = subs.filter(s =>
      ['pending', 'confirmed', 'picked_up'].includes(s.status))

    const total_kg = done.reduce((a, s) => a + s.berat_kg, 0)
    const co2_saved = +(total_kg * 1.5).toFixed(2)
    const total_umkm = new Set(done.map(s => s.umkm_id)).size

    res.json({
      total_kg: +total_kg.toFixed(2),
      total_submissions: subs.length,
      total_submissions_active: active.length,
      total_umkm_helped: total_umkm,
      co2_saved
    })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}