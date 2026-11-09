-- Halı Saha Pro · Supabase şeması (blapcesouonfptmoxlbc projesinde kurulu)
create table if not exists public.players (
  id text primary key, name text not null,
  overall smallint not null check (overall between 1 and 10),
  stamina smallint not null check (stamina between 1 and 10),
  gk smallint not null check (gk between 1 and 10),
  def smallint not null check (def between 1 and 10),
  mid smallint not null check (mid between 1 and 10),
  fwd smallint not null check (fwd between 1 and 10),
  positions text[] not null default '{}',
  speed smallint check (speed between 1 and 10), passing smallint check (passing between 1 and 10),
  shooting smallint check (shooting between 1 and 10), defending smallint check (defending between 1 and 10),
  active boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.matches (
  id text primary key, match_date date not null, player_ids text[] not null default '{}',
  team_a jsonb not null, team_b jsonb not null, metrics jsonb, score_a smallint, score_b smallint, note text,
  created_at timestamptz not null default now()
);
create table if not exists public.attendance (match_date date primary key, player_ids text[] not null default '{}');
create table if not exists public.app_settings (id text primary key, data jsonb not null);
alter table public.players enable row level security;
alter table public.matches enable row level security;
alter table public.attendance enable row level security;
alter table public.app_settings enable row level security;
-- Herkese açık okuma/yazma (grup içi kullanım)
create policy "anon_all_players" on public.players for all to anon, authenticated using (true) with check (true);
create policy "anon_all_matches" on public.matches for all to anon, authenticated using (true) with check (true);
create policy "anon_all_attendance" on public.attendance for all to anon, authenticated using (true) with check (true);
create policy "anon_all_app_settings" on public.app_settings for all to anon, authenticated using (true) with check (true);
grant select, insert, update, delete on public.players, public.matches, public.attendance, public.app_settings to anon, authenticated;
