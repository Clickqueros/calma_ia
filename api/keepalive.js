// Función que Vercel Cron ejecuta periódicamente para mantener activo
// el proyecto de Supabase (plan gratis) y que NO se pause por inactividad.
export default async function handler(req, res) {
  const key = 'sb_publishable_d0qI6nzXkgAOUTengyV6YA_5VXvfQsx';
  const url =
    'https://gtmqbduswftrpflqhpbm.supabase.co/rest/v1/mood_ratings?select=id&limit=1';
  try {
    const r = await fetch(url, {
      headers: { apikey: key, Authorization: `Bearer ${key}` },
    });
    return res.status(200).json({ ok: true, status: r.status });
  } catch (e) {
    return res.status(500).json({ ok: false, error: String(e) });
  }
}
