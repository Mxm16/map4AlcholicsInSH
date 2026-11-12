create table if not exists public.bar_visits (
  user_id uuid not null references auth.users(id) on delete cascade,
  bar_id text not null,
  visit_count integer not null check (visit_count > 0),
  last_visited_on date,
  primary key (user_id, bar_id)
);
alter table public.bar_visits enable row level security;
revoke all on public.bar_visits from anon, authenticated;
grant select, insert, update, delete on public.bar_visits to authenticated;
create policy "read own visits" on public.bar_visits for select to authenticated using ((select auth.uid()) = user_id);
create policy "insert own visits" on public.bar_visits for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "update own visits" on public.bar_visits for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "delete own visits" on public.bar_visits for delete to authenticated using ((select auth.uid()) = user_id);
