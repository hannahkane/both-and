// Flips today's approved puzzles (novice + expert) to published. Meant to run
// on a daily cron trigger at the game's fixed global reset time — schedule it
// from the Supabase Dashboard (Database > Cron Jobs) once deployed, since cron
// scheduling is a per-project dashboard/pg_cron setting, not something in this repo.
import "@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!

Deno.serve(async (_req) => {
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY)

  const today = new Date().toISOString().slice(0, 10)

  const { data, error } = await supabase
    .from("puzzles")
    .update({ status: "published" })
    .eq("puzzle_date", today)
    .eq("status", "approved")
    .select("id, tier")

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    })
  }

  if (!data || data.length === 0) {
    console.error(`No approved puzzles found for ${today} — nothing published`)
  }

  return new Response(JSON.stringify({ published: data }), {
    headers: { "Content-Type": "application/json" },
  })
})
