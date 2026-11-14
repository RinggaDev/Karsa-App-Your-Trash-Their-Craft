import { supabase } from '../config/supabase.js'

export const getRecap = async (req, res) => {
  try {
    const { data: subs, error } = await supabase
      .from('submissions')
      .select('*, umkm(id, nama, lokasi)')
      .eq('user_id', req.user.id)
      .order('created_at', { ascending: false })
    if (error) return res.status(500).json({ error: error.message })

    const done = subs.filter(s => s.status === 'done')
    const total_kg = done.reduce((a, s) => a + s.berat_kg, 0)

    res.json({
      stats: {
        total_kg: +total_kg.toFixed(2),
        total_submissions: subs.length,
        total_submissions_done: done.length,
        total_umkm_helped: new Set(done.map(s => s.umkm_id)).size,
        co2_saved: +(total_kg * 1.5).toFixed(2)
      },
      submissions: subs
    })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}