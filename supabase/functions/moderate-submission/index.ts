// Moderation gate for new submissions: checks each answer against the Google
// Perspective API before the row is ever written, so blocked content never
// becomes visible (rather than being flagged for removal after the fact).
import "@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

const PERSPECTIVE_API_KEY = Deno.env.get("PERSPECTIVE_API_KEY")!
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!

// Reject a submission if any Perspective attribute score meets or exceeds this.
const TOXICITY_THRESHOLD = 0.8

interface SubmitRequest {
  puzzleId: string
  answers: Record<string, string>
}

async function checkText(text: string): Promise<{ blocked: boolean; reason?: string }> {
  const res = await fetch(
    `https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=${PERSPECTIVE_API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        comment: { text },
        languages: ["en"],
        requestedAttributes: { TOXICITY: {}, SEVERE_TOXICITY: {}, PROFANITY: {} },
      }),
    },
  )

  if (!res.ok) {
    throw new Error(`Perspective API error: ${res.status} ${await res.text()}`)
  }

  const { attributeScores } = await res.json()
  for (const [attribute, scored] of Object.entries(attributeScores) as [string, any][]) {
    if (scored.summaryScore.value >= TOXICITY_THRESHOLD) {
      return { blocked: true, reason: attribute }
    }
  }
  return { blocked: false }
}

Deno.serve(async (req) => {
  const authHeader = req.headers.get("Authorization")
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Missing Authorization header" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    })
  }

  const { puzzleId, answers }: SubmitRequest = await req.json()

  for (const text of Object.values(answers)) {
    const { blocked, reason } = await checkText(text)
    if (blocked) {
      return new Response(
        JSON.stringify({ error: "Submission blocked by moderation", attribute: reason }),
        { status: 422, headers: { "Content-Type": "application/json" } },
      )
    }
  }

  // Forward the caller's own JWT so the insert runs as that user and normal RLS applies.
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  })

  const { data: userData, error: userError } = await supabase.auth.getUser()
  if (userError || !userData.user) {
    return new Response(JSON.stringify({ error: "Invalid session" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    })
  }

  const { data, error } = await supabase
    .from("submissions")
    .insert({ puzzle_id: puzzleId, user_id: userData.user.id, answers })
    .select()
    .single()

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    })
  }

  return new Response(JSON.stringify({ submission: data }), {
    headers: { "Content-Type": "application/json" },
  })
})
