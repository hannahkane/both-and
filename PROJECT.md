# Both/And

A daily wordplay game for wordplay enthusiasts, built around Venn diagrams. Every day the app publishes a diagram with the non-overlapping segments pre-filled; players fill in the overlapping segment(s), submit, then browse and vote on each other's answers.

Scope: a polished portfolio piece — real and functional, not a revenue play. iOS + Android, built by one person (with AI assistance), minimal art/asset budget. Niche audience of wordplay enthusiasts, not mass-market casual gamers.

## Theory of fun

- **Pattern recognition / "aha" moment** (Koster): the fun is finding a word or phrase that plausibly satisfies two (or three) categories at once.
- **Humor from incongruity**: unlike Wordle, the reward is wit, not speed or correctness — voting rewards the most surprising valid answer.
- **Shared ritual**: everyone solves the same diagram on the same day, which is most of why Wordle-likes retain — it gives people something to compare and talk about.
- **Delayed social reward**: the payoff isn't just solving, it's seeing how your answer lands with other players.

## Core mechanics (decided)

- **Cadence**: daily, fixed global reset time (not per-user local time, not weekly) — daily habit/streak formation matters more than perfect timezone fairness. Both puzzle tiers reset together.
- **Tiers**: two puzzles per day, **Novice** (2-circle) and **Expert** (3-circle). A player can play one or both.
  - Novice: one blank to fill (the single overlap).
  - Expert: **all 4 overlap regions** must be filled (3 pairwise overlaps + the center triple-overlap). Decided over the alternative (pre-fill the 3 pairwise overlaps, user fills only the center) because it's the richer, more "expert" puzzle and is actually *lighter* on the content pipeline (only 3 fixed exclusive words needed either way).
- **Submission**: one submission per puzzle per tier. **Submit-to-view gate** — you can't see or vote on anyone else's submissions until you've submitted your own (prevents copying, keeps the "immediate" feel without needing a blind/staggered reveal window).
- **Voting**: shuffled (non-chronological) feed order + rate-based scoring (votes ÷ views, not raw counts) so late-but-good submissions aren't structurally buried. Each voter gets a **3-votes-per-day budget**, one vote per submission, spendable across the day. Single vote category ("Funniest") — considered and rejected a second "Most Clever" category as not meaningfully distinct.
  - Novice voting: scrollable list of compact cards.
  - Expert voting: one full submission at a time (paged), since 4 answers can't be shown legibly at thumbnail size in a list.
- **Archive**: past days are browsable but not playable (preserves the "you had to be there" shared-ritual feeling).
- **Identity**: Sign in with Apple/Google — enables streaks, history, cross-device sync, and real vote integrity.
- **Content pipeline**: AI-assisted generation of daily puzzles, with human (owner) approval before publish.
- **Moderation**: automated profanity/toxicity filter blocks obvious bad content pre-publish; user reports route to a manual review queue.

## User stories (draft — see conversation history for full list)

Core solving, social/voting, retention, and safety stories were drafted during the PM phase covering: seeing today's diagram, filling and submitting an answer once per day, browsing and voting on others' answers, seeing daily results and streaks, and reporting/moderating abusive content. (To be formalized into a tracked backlog during the engineering phase.)

## Design

- **Name**: Both/And (chosen over "Venndle" — felt too derivative of the Wordle-clone naming trend).
- **Visual direction**: **Memphis Geometric Pop** — bold flat colors (cobalt #2645F5, hot pink #FF3E8E, yellow #FFD400, ink #14141A, warm white #FFFDF7), thick black borders, hard offset "sticker" shadows, tilted/skewed elements, scattered geometric confetti shapes. Typefaces: Unbounded (display) + Work Sans (body). Chosen over five other explored directions (Editorial Minimal, Bold Pop Playful, Retro Paper/Handcrafted, Dark Neon Arcade, Soft Pastel Zen) — see `design/` for all explorations.
- **Screens built** (`design/*.dc.html`, a multi-artboard design canvas): Sign In, Today's Puzzle, Fill In, Submitted, Vote, Results, Profile, Archive (Novice/shared), plus Today, Fill In, Vote, and Results variants for the Expert (3-circle, 4-blank) tier.
- Design canvas source lives in `design/` (`.dc.html` files are Design Components — plain HTML/CSS/inline-SVG artboards, no build step). `canvas.json` defines the layout across two pages: "Screens" (finished set) and "Explorations" (style-direction sketches and rejected mechanic sketches, kept for reference).

## Open / next steps

- Engineering build plan: platform/tech stack, backend architecture for daily puzzle publishing + submissions + voting + moderation queue, security/privacy review.
- Apple Developer Program — ✅ already enrolled.
- Google Play Console enrollment — pending (user action).
- Support email — pending (user action).
- Privacy policy URL — pending; will be hosted on GitHub Pages.
- Formalize user stories into a tracked backlog.
