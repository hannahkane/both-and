-- Both/And initial schema: puzzles, submissions, votes, impressions, reports.
-- RLS is default-deny; the owner's review workflow (Supabase Studio) uses the
-- service_role key, which bypasses RLS, so no explicit admin policies exist.

create type puzzle_tier as enum ('novice', 'expert');
create type puzzle_status as enum ('draft', 'approved', 'published');
create type report_status as enum ('pending', 'actioned', 'dismissed');

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz not null default now()
);

create table puzzles (
  id uuid primary key default gen_random_uuid(),
  puzzle_date date not null,
  tier puzzle_tier not null,
  -- exclusive_categories: labels for the non-overlapping segments (pre-filled).
  -- overlap_labels: labels for the blank(s) players fill in (1 for novice, 4 for expert).
  exclusive_categories jsonb not null,
  exclusive_words jsonb not null,
  overlap_labels jsonb not null,
  status puzzle_status not null default 'draft',
  created_at timestamptz not null default now(),
  unique (puzzle_date, tier)
);

create table submissions (
  id uuid primary key default gen_random_uuid(),
  puzzle_id uuid not null references puzzles(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  -- answers: { overlap_label_key: answer_text }, one key for novice, four for expert.
  answers jsonb not null,
  submitted_at timestamptz not null default now(),
  unique (puzzle_id, user_id)
);

create table votes (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references submissions(id) on delete cascade,
  voter_id uuid not null references profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (submission_id, voter_id)
);

create table impressions (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references submissions(id) on delete cascade,
  viewer_id uuid not null references profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table reports (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references submissions(id) on delete cascade,
  reporter_id uuid not null references profiles(id) on delete cascade,
  reason text not null,
  status report_status not null default 'pending',
  created_at timestamptz not null default now()
);

-- Rate-based ranking (votes / views) per submission, for the voting/results screens.
create view submission_scores as
select
  s.id as submission_id,
  s.puzzle_id,
  count(distinct v.id) as vote_count,
  count(distinct i.id) as impression_count,
  case
    when count(distinct i.id) = 0 then 0
    else count(distinct v.id)::numeric / count(distinct i.id)
  end as score
from submissions s
left join votes v on v.submission_id = s.id
left join impressions i on i.submission_id = s.id
group by s.id, s.puzzle_id;

alter table profiles enable row level security;
alter table puzzles enable row level security;
alter table submissions enable row level security;
alter table votes enable row level security;
alter table impressions enable row level security;
alter table reports enable row level security;

create policy "read own profile" on profiles
  for select using (id = auth.uid());

create policy "insert own profile" on profiles
  for insert with check (id = auth.uid());

-- Puzzles are only visible once published; drafts/approved stay owner-only (service_role).
create policy "read published puzzles" on puzzles
  for select using (status = 'published');

-- Submit-to-view gate: a submission is visible to a user only if it's their own,
-- or they've already submitted to the same puzzle, or the puzzle is a past day
-- (archive browsing is allowed to be open once the puzzle's day has passed).
create policy "submit-to-view gate" on submissions
  for select using (
    user_id = auth.uid()
    or exists (
      select 1 from submissions own
      where own.puzzle_id = submissions.puzzle_id
        and own.user_id = auth.uid()
    )
    or exists (
      select 1 from puzzles p
      where p.id = submissions.puzzle_id
        and p.puzzle_date < current_date
    )
  );

create policy "submit own answer" on submissions
  for insert with check (
    user_id = auth.uid()
    and exists (
      select 1 from puzzles p
      where p.id = puzzle_id and p.status = 'published'
    )
  );

-- Votes are only visible in aggregate via submission_scores; no direct SELECT policy.
create policy "cast a vote" on votes
  for insert with check (
    voter_id = auth.uid()
    -- must have submitted to the same puzzle before voting (mirrors the view gate)
    and exists (
      select 1 from submissions own
      join submissions target on target.puzzle_id = own.puzzle_id
      where own.user_id = auth.uid()
        and target.id = votes.submission_id
    )
    -- 3-votes-per-day budget, spendable across submissions
    and (
      select count(*) from votes v
      where v.voter_id = auth.uid()
        and v.created_at::date = current_date
    ) < 3
  );

create policy "log an impression" on impressions
  for insert with check (viewer_id = auth.uid());

create policy "report a submission" on reports
  for insert with check (
    reporter_id = auth.uid()
    and exists (
      select 1 from submissions own
      join submissions target on target.puzzle_id = own.puzzle_id
      where own.user_id = auth.uid()
        and target.id = reports.submission_id
    )
  );
