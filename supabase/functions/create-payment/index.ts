// supabase/functions/create-payment/index.ts
// Supabase Edge Function – proxy Midtrans Snap API calls server-side.
// Deploy with:  supabase functions deploy create-payment --no-verify-jwt

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

// ─── Midtrans configuration ───────────────────────────────────────────────────
// Key diambil dari environment variable (Supabase secret), bukan hardcode.
// Set dengan: supabase secrets set MIDTRANS_SERVER_KEY=Mid-server-xxxx
const SERVER_KEY = Deno.env.get('MIDTRANS_SERVER_KEY') ?? ''

// Hardcode true untuk sandbox, false untuk production
const IS_SANDBOX = true

const SNAP_URL = IS_SANDBOX
  ? 'https://app.sandbox.midtrans.com/snap/v1/transactions'
  : 'https://app.midtrans.com/snap/v1/transactions'

const STATUS_BASE_URL = IS_SANDBOX
  ? 'https://api.sandbox.midtrans.com/v2'
  : 'https://api.midtrans.com/v2'

const BASE64_AUTH = btoa(`${SERVER_KEY}:`)

console.log(`[create-payment] Mode: ${IS_SANDBOX ? 'SANDBOX' : 'PRODUCTION'}`)

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ─── Helper ───────────────────────────────────────────────────────────────────
function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

// ─── Handler ─────────────────────────────────────────────────────────────────
serve(async (req: Request) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { action, payload, orderId } = await req.json()

    // ── Create Snap Transaction ──────────────────────────────────────────────
    if (action === 'create') {
      // Kirim payload apa adanya dari Flutter — jangan tambah enabled_payments
      // agar Midtrans otomatis tampilkan semua channel yang tersedia untuk akun ini.
      const enrichedPayload = { ...payload }

      console.log('[create-payment] Calling Midtrans Snap:', JSON.stringify(enrichedPayload))

      const response = await fetch(SNAP_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': `Basic ${BASE64_AUTH}`,
        },
        body: JSON.stringify(enrichedPayload),
      })

      const data = await response.json()
      console.log('[create-payment] Midtrans response:', response.status, JSON.stringify(data))

      if (response.status === 201) {
        return jsonResponse({
          success: true,
          token: data.token,
          redirect_url: data.redirect_url,
        })
      }

      return jsonResponse({
        success: false,
        error: `Midtrans error ${response.status}: ${JSON.stringify(data)}`,
      }, 400)
    }

    // ── Check Transaction Status ─────────────────────────────────────────────
    if (action === 'status') {
      const response = await fetch(`${STATUS_BASE_URL}/${orderId}/status`, {
        headers: {
          'Accept': 'application/json',
          'Authorization': `Basic ${BASE64_AUTH}`,
        },
      })

      const data = await response.json()
      const status = data['transaction_status'] as string | undefined

      if (response.status === 200) {
        return jsonResponse({
          success: true,
          status,
          fraud_status: data['fraud_status'],
        })
      }

      return jsonResponse({
        success: false,
        error: `Status check failed ${response.status}: ${JSON.stringify(data)}`,
      }, 400)
    }

    return jsonResponse({ success: false, error: 'Unknown action' }, 400)
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err)
    console.error('[create-payment] Unhandled error:', message)
    return jsonResponse({ success: false, error: message }, 500)
  }
})
