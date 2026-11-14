import { model } from '../config/gemini.js'
import { supabase } from '../config/supabase.js'

export const getMicroInsight = async (req, res) => {
  try {
    const { submission_id } = req.body
    const user_id = req.user.id

    // Return cached
    const { data: cached } = await supabase.from('insights')
      .select('konten').eq('submission_id', submission_id).eq('tipe', 'micro').single()
    if (cached) return res.json({ insight: cached.konten })

    const { data: sub, error } = await supabase
      .from('submissions').select('*, umkm(*)')
      .eq('id', submission_id).eq('user_id', user_id).single()
    if (error || !sub) return res.status(404).json({ error: 'Submission not found' })
    if (sub.status !== 'done')
      return res.status(400).json({ error: 'Submission not completed yet' })

    const co2_saved = (sub.berat_kg * 1.5).toFixed(2)

    const prompt = `
Kamu adalah Karsa AI — teman yang suportif dan mengapresiasi kontribusi kecil pengguna.

Data kontribusi yang baru selesai:
- Tipe sampah: ${sub.tipe_sampah.join(', ')}
- Berat: ${sub.berat_kg} kg
- UMKM tujuan: ${sub.umkm.nama} di ${sub.umkm.lokasi}
- Produk yang dibuat UMKM: ${sub.umkm.produk_dibuat}
- Estimasi CO₂ saved: ${co2_saved} kg

Tulis 2-3 kalimat insight personal dalam Bahasa Indonesia yang:
1. Apresiasi kontribusi dengan nada teman, bukan guru
2. Terjemahkan CO₂ saved atau berat ke dampak yang bisa dibayangkan
3. Kasih motivasi ringan untuk terus berkontribusi

Gunakan "kamu". Kasual, optimis, memberdayakan. Jangan terlalu panjang.
    `.trim()

    const result = await model.generateContent(prompt)
    const konten = result.response.text()

    await supabase.from('insights')
      .insert({ user_id, tipe: 'micro', submission_id, konten })

    res.json({ insight: konten })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

export const getMacroInsight = async (req, res) => {
  try {
    const user_id = req.user.id
    const periode = req.query.periode || 'weekly'

    // Return cached (24h)
    const yesterday = new Date(Date.now() - 86400000).toISOString()
    const { data: cached } = await supabase.from('insights')
      .select('konten, generated_at')
      .eq('user_id', user_id).eq('tipe', 'macro').eq('periode', periode)
      .gte('generated_at', yesterday)
      .order('generated_at', { ascending: false }).limit(1).single()
    if (cached) return res.json({ insight: cached.konten, periode, generated_at: cached.generated_at })

    const { data: subs } = await supabase
      .from('submissions').select('tipe_sampah, berat_kg, umkm_id')
      .eq('user_id', user_id).eq('status', 'done')
    if (!subs?.length)
      return res.status(404).json({ error: 'No completed submissions yet' })

    const total_kg = subs.reduce((a, s) => a + s.berat_kg, 0).toFixed(2)
    const total_done = subs.length
    const total_umkm = new Set(subs.map(s => s.umkm_id)).size
    const co2_saved = (total_kg * 1.5).toFixed(2)

    const tipe_count = {}
    subs.forEach(s => s.tipe_sampah.forEach(t => {
      tipe_count[t] = (tipe_count[t] || 0) + 1
    }))
    const top_tipe = Object.entries(tipe_count).sort((a, b) => b[1] - a[1])[0][0]

    const prompt = `
Kamu adalah Karsa AI — teman yang suportif dan menginspirasi.

Data akumulasi kontribusi user (periode: ${periode}):
- Total sampah tersalurkan: ${total_kg} kg
- Total distribusi selesai: ${total_done} kali
- Jumlah UMKM berbeda yang dibantu: ${total_umkm}
- Tipe sampah terbanyak: ${top_tipe}
- Estimasi CO₂ saved: ${co2_saved} kg

Tulis 3-4 kalimat insight komprehensif dalam Bahasa Indonesia yang:
1. Rekap pencapaian dengan nada bangga dan hangat
2. Terjemahkan angka ke dampak nyata yang bisa dibayangkan
3. Motivasi untuk terus berkontribusi di periode berikutnya

Gunakan "kamu". Kasual, optimis, memberdayakan.
    `.trim()

    const result = await model.generateContent(prompt)
    const konten = result.response.text()
    const generated_at = new Date().toISOString()

    await supabase.from('insights')
      .insert({ user_id, tipe: 'macro', konten, periode })

    res.json({ insight: konten, periode, generated_at })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}