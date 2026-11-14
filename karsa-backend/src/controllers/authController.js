import { supabase, createAuthClient } from '../config/supabase.js'

export const register = async (req, res) => {
  try {
    const { email, password, nama, kota } = req.body
    if (!email || !password || !nama || !kota)
      return res.status(400).json({ error: 'All fields required' })

    let userId = null
    const { data: authData, error: authError } =
      await supabase.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { nama, kota }
      })

    if (authError) {
      // Jika user sempat terbuat di auth.users tapi belum masuk public.users, coba sign in
      const tempAuth = createAuthClient()
      const { data: existingSignIn, error: existingErr } =
        await tempAuth.auth.signInWithPassword({ email, password })
      if (existingErr || !existingSignIn?.user) {
        return res.status(400).json({ error: authError.message })
      }
      userId = existingSignIn.user.id
    } else {
      userId = authData.user.id
    }

    const fallbackProfile = { id: userId, email, nama, kota }
    const { data: profile, error: profileError } = await supabase
      .from('users')
      .upsert(fallbackProfile)
      .select()
      .single()

    if (profileError) {
      console.error('Users upsert warning:', profileError.message)
    }

    const authClient = createAuthClient()
    const { data: session, error: sessionError } =
      await authClient.auth.signInWithPassword({ email, password })
    if (sessionError || !session?.session) {
      return res.status(500).json({ error: sessionError?.message || 'Failed to create session' })
    }

    res.status(201).json({
      user: profile || fallbackProfile,
      token: session.session.access_token
    })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

export const login = async (req, res) => {
  try {
    const { email, password } = req.body
    if (!email || !password)
      return res.status(400).json({ error: 'Email and password required' })

    const authClient = createAuthClient()
    const { data, error } = await authClient.auth.signInWithPassword({ email, password })
    if (error || !data?.user || !data?.session)
      return res.status(401).json({ error: 'Invalid credentials' })

    let { data: profile } = await supabase
      .from('users').select('*').eq('id', data.user.id).single()

    if (!profile) {
      const fallbackProfile = {
        id: data.user.id,
        email: data.user.email || email,
        nama: data.user.user_metadata?.nama || (data.user.email || email).split('@')[0],
        kota: data.user.user_metadata?.kota || ''
      }
      const { data: created } = await supabase
        .from('users')
        .upsert(fallbackProfile)
        .select()
        .single()
      profile = created || fallbackProfile
    }

    res.json({ user: profile, token: data.session.access_token })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}