import { supabase } from '../config/supabase.js'

export const getUmkm = async (req, res) => {
  try {
    const { tipe_sampah } = req.query

    if (!tipe_sampah) {
      const { data, error } = await supabase.from('umkm').select('*')
      if (error) return res.status(500).json({ error: error.message })
      return res.json({ umkm: data })
    }

    const types = tipe_sampah.split(',').map(t => t.trim())

    // Query per type, then deduplicate
    const queries = types.map(t =>
      supabase.from('umkm').select('*').contains('bahan_baku', [t])
    )
    const results = await Promise.all(queries)
    const all = results.flatMap(r => r.data || [])
    const unique = [...new Map(all.map(u => [u.id, u])).values()]

    res.json({ umkm: unique })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

export const getUmkmById = async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('umkm').select('*').eq('id', req.params.id).single()
    if (error || !data)
      return res.status(404).json({ error: 'UMKM not found' })
    res.json(data)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}