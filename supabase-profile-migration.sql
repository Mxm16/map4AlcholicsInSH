-- Run once in the Supabase SQL Editor. Existing bar_visits is retained as a backup.
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null check (char_length(nickname) between 1 and 24),
  avatar text not null default '🍸'
);
create table if not exists public.visit_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  bar_id text not null,
  visit_day date,
  visit_count integer not null default 1 check (visit_count > 0),
  created_at timestamptz not null default now(),
  legacy_key text,
  unique (user_id, legacy_key)
);
create unique index if not exists visit_events_one_per_day on public.visit_events(user_id,bar_id,visit_day) where visit_day is not null;
create table if not exists public.bar_reviews (
  user_id uuid not null references auth.users(id) on delete cascade,
  bar_id text not null,
  rating smallint check (rating between 1 and 5),
  note text not null default '' check (char_length(note) <= 500),
  updated_at timestamptz not null default now(),
  primary key (user_id,bar_id),
  check (rating is not null or length(trim(note)) > 0)
);
-- One known last visit is preserved; additional historical visits retain their count with an unknown date.
insert into public.visit_events(user_id,bar_id,visit_day,visit_count,created_at,legacy_key)
select user_id,bar_id,last_visited_on,1,coalesce((last_visited_on::timestamp + interval '12 hours') at time zone 'Asia/Shanghai',now()),'last:'||bar_id
from public.bar_visits where last_visited_on is not null
on conflict (user_id,legacy_key) do nothing;
insert into public.visit_events(user_id,bar_id,visit_day,visit_count,legacy_key)
select user_id,bar_id,null,visit_count-case when last_visited_on is null then 0 else 1 end,'older:'||bar_id
from public.bar_visits where visit_count>case when last_visited_on is null then 0 else 1 end
on conflict (user_id,legacy_key) do nothing;
-- Never expose another person's profile, visit list or private review.
alter table public.profiles enable row level security;
alter table public.visit_events enable row level security;
alter table public.bar_reviews enable row level security;
revoke all on public.profiles, public.visit_events, public.bar_reviews from anon, authenticated;
grant select, insert, update, delete on public.profiles, public.visit_events, public.bar_reviews to authenticated;
create policy "read own profile" on public.profiles for select to authenticated using ((select auth.uid())=user_id);
create policy "insert own profile" on public.profiles for insert to authenticated with check ((select auth.uid())=user_id);
create policy "update own profile" on public.profiles for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "read own events" on public.visit_events for select to authenticated using ((select auth.uid())=user_id);
create policy "insert own events" on public.visit_events for insert to authenticated with check ((select auth.uid())=user_id);
create policy "delete own events" on public.visit_events for delete to authenticated using ((select auth.uid())=user_id);
create policy "read own reviews" on public.bar_reviews for select to authenticated using ((select auth.uid())=user_id);
create policy "insert own reviews" on public.bar_reviews for insert to authenticated with check ((select auth.uid())=user_id);
create policy "update own reviews" on public.bar_reviews for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "delete own reviews" on public.bar_reviews for delete to authenticated using ((select auth.uid())=user_id);
