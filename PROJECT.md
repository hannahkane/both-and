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

## User stories

**Core solving**
- As a player, I want to see today's Novice (2-circle) and Expert (3-circle) puzzles, so I can choose which to play.
- As a player, I want to see the fixed, pre-filled exclusive-category words for today's puzzle, so I understand the categories I'm working within.
- As a Novice player, I want to fill in the single overlap segment, so I can submit my answer.
- As an Expert player, I want to fill in all 4 overlap regions (3 pairwise + the center) one at a time, with a clear indicator of which region I'm currently on, so the harder puzzle stays manageable.
- As a player, I want to submit only once per puzzle per tier, so the game has a fair, Wordle-like daily cadence.
- As a player, I want confirmation that my submission is locked in, so I know I won't be accused of copying others after seeing theirs.

**Social / voting**
- As a player, I want submitting my own answer to unlock the ability to see and vote on others' submissions, so no one can copy another player's answer before submitting their own.
- As a Novice player, I want to browse other players' submissions in a scrollable feed, so I can enjoy their wordplay.
- As an Expert player, I want to page through other players' full solved diagrams one at a time, so I can read all 4 of their answers without a cramped thumbnail view.
- As a player, I want a budget of 3 votes per day I can spend across different submissions, so I'm not forced to lock in a single "best so far" pick early and miss voting for something better later in the day.
- As a player, I want the voting feed shown in shuffled (non-chronological) order, so early submissions don't get an unfair advantage just from being visible longer.
- As a player, I want submissions ranked by a rate (votes ÷ views) rather than raw vote count, so a great late-posted answer isn't buried under an earlier one that simply got more total exposure.
- As a player, I want to see the day's "Funniest" result and how my submission ranked, so there's a payoff to the ritual.

**Retention / identity**
- As a player, I want to sign in with Apple or Google, so my streak, history, and votes are tied to a real, portable identity.
- As a returning player, I want to see my streak and history, so I have a reason to come back daily.
- As a player, I want to keep my streak even if my submission gets few or no votes (e.g. a last-minute submission), so streak reflects participation, not popularity.
- As a player, I want to browse (but not play) past days' puzzles, so I can revisit good answers without diluting the "you had to be there" shared-ritual feeling.

**Safety / moderation**
- As a player, I want obviously abusive or profane submissions automatically blocked before they're ever visible to others, so the game stays usable without relying only on reports.
- As a player, I want to report a submission that slips through the filter, so it can be reviewed and removed.
- As the app owner, I want reported submissions to land in a review queue I check personally, so I keep tight control over content given the game's small scale.

**Content pipeline**
- As the app owner, I want an AI-assisted tool to propose each day's puzzle categories and pre-filled words, so I don't have to hand-author everything from scratch.
- As the app owner, I want to review and approve/edit each day's AI-generated puzzle before it goes live, so nothing nonsensical or low-quality gets published under my name.

## Design

- **Name**: Both/And (chosen over "Venndle" — felt too derivative of the Wordle-clone naming trend).
- **Visual direction**: **Memphis Geometric Pop** — bold flat colors (cobalt #2645F5, hot pink #FF3E8E, yellow #FFD400, ink #14141A, warm white #FFFDF7), thick black borders, hard offset "sticker" shadows, tilted/skewed elements, scattered geometric confetti shapes. Typefaces: Unbounded (display) + Work Sans (body). Chosen over five other explored directions (Editorial Minimal, Bold Pop Playful, Retro Paper/Handcrafted, Dark Neon Arcade, Soft Pastel Zen) — see `design/` for all explorations.
- **Screens built** (`design/*.dc.html`, a multi-artboard design canvas): Sign In, Today's Puzzle, Fill In, Submitted, Vote, Results, Profile, Archive (Novice/shared), plus Today, Fill In, Vote, and Results variants for the Expert (3-circle, 4-blank) tier.
- Design canvas source lives in `design/` (`.dc.html` files are Design Components — plain HTML/CSS/inline-SVG artboards, no build step). `canvas.json` defines the layout across two pages: "Screens" (finished set) and "Explorations" (style-direction sketches and rejected mechanic sketches, kept for reference).

## Engineering (decided)

- **Frontend**: **React Native + Expo** (managed workflow). Single codebase for iOS + Android; chosen over native-per-platform or Flutter because it has the largest ecosystem/AI-training-data of any cross-platform option (relevant since this is being built with little/no prior coding background, leaning on AI assistance) and Expo's EAS Build/Submit handles App Store/Play Store packaging and code signing without needing Xcode/Android Studio expertise.
- **Backend**: **Supabase**, chosen over Firebase. Postgres (relational) fits this game's data shape — puzzles → submissions → votes → rankings — better than Firebase's NoSQL model, especially for the votes÷views rate calculation (a SQL view). Two things matter most for a solo, low-code-experience build:
  - **Row Level Security (RLS)**: game rules like the submit-to-view gate and the 3-votes/day budget are enforced as declarative database policies instead of custom backend code to write and debug.
  - **Built-in Auth**: Sign in with Apple and Google supported out of the box.
  - Generous free tier, appropriate for this app's niche/small scale.
- **Data model (sketch)**: `users`, `puzzles` (date, tier, categories, exclusive words, status: draft/approved/published), `submissions`, `votes`, `reports`. Rate-ranking is a SQL view over `votes` and impression counts.
- **View tracking** (for the votes÷views rate): a lightweight impression count, logged each time a submission is served in someone's feed.
- **Scheduling**: a Supabase scheduled Edge Function flips puzzle status and handles the daily publish/reset at the fixed global reset time.
- **Moderation**: submissions are checked against the **Google Perspective API** via an Edge Function before being stored; content that scores above threshold is rejected pre-publish instead of just flagged after the fact.
- **Content pipeline / AI puzzle generation**: **Claude** drafts each day's puzzle (categories + exclusive words) into the `puzzles` table as a `draft` row.
- **Admin tooling**: no separate admin app. Puzzle review/approval and the report queue are handled directly in **Supabase Studio** (its Table Editor, including a structured JSON editor for the categories/words columns, and SQL editor) — the right amount of tooling for a one-person, one-puzzle-a-day workload. Trade-off: no guardrails against typos and no one-click "hide + notify" actions, accepted in exchange for zero extra project to build or deploy.
- **Security/privacy notes**: no password handling (OAuth only via Apple/Google through Supabase Auth); RLS default-deny on all tables; moderation/LLM API keys kept server-side in Edge Function secrets, never exposed to the client; minimal PII collected (auth provider ID + display name only).

## Next steps (pick up here next session)

1. **Enable GitHub Pages** once privacy policy content exists (repo is public, so free-tier Pages works — just needs a source, e.g. a `docs/` folder).
2. **Scaffold the project**: initialize the Expo (React Native) app and the Supabase project (tables, RLS policies, Auth providers for Apple/Google, scheduled Edge Function for daily publish).
3. **Security/privacy review** of the engineering plan above before real user data flows through it (RLS policy correctness, moderation coverage, key handling).

**Pending on Hannah, in parallel (not blocking engineering start):**
- Google Play Console enrollment (~$25 one-time).
- A support email address.
- Privacy policy page content (target: GitHub Pages).

**Already done:**
- ✅ Project repo + git initialized locally, pushed to GitHub: [hannahkane/both-and](https://github.com/hannahkane/both-and) (public).
- ✅ Apple Developer Program enrollment.
- ✅ Product decisions (mechanics, tiers, voting, moderation) and design canvas (Memphis Geometric Pop, all core + Expert screens) — see above and `design/`.
- ✅ User stories formalized as tracked [GitHub Issues](https://github.com/hannahkane/both-and/issues) (22 issues, labeled `core-solving`, `social-voting`, `retention-identity`, `safety-moderation`, `content-pipeline`).
- ✅ Engineering build plan (stack, data model, moderation, content pipeline, admin tooling) — see "Engineering" above.
