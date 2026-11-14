import { supabase } from '../config/supabase.js'

export const register = async (req, res) => {
  try {
    const { email, password, nama, kota } = req.body
    if (!email || !password || !nama || !kota)
      return res.status(400).json({ error: 'All fields required' })

    const { data: authData, error: authError } =
      await supabase.auth.admin.createUser({ email, password, email_confirm: true })
    if (authError) return res.status(400).json({ error: authError.message })

    const { data: profile, error: profileError } = await supabase
      .from('users')
      .insert({ id: authData.user.id, email, nama, kota })
      .select().single()
    if (profileError) return res.status(500).json({ error: profileError.message })

    const { data: session } = await supabase.auth.signInWithPassword({ email, password })

    res.status(201).json({ user: profile, token: session.session.access_token })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

export const login = async (req, res) => {
  try {
    const { email, password } = req.body
    if (!email || !password)
      return res.status(400).json({ error: 'Email and password required' })

    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) return res.status(401).json({ error: 'Invalid credentials' })

    const { data: profile } = await supabase
      .from('users').select('*').eq('id', data.user.id).single()

    res.json({ user: profile, token: data.session.access_token })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}