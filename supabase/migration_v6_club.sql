-- Halı Saha Pro v6: Takım modu (rakiplere karşı maçlar)
create table if not exists public.club(
  group_id   uuid primary key default public.current_group_id() references public.groups(id) on delete cascade,
  name       text not null default '',
  squad      text[] not null default '{}',
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.fixtures(
  id            text primary key,
  group_id      uuid not null default public.current_group_id() references public.groups(id) on delete cascade,
  match_date    date not null,
  kickoff       text,
  opponent      text not null,
  venue         text,
  comp          text,
  score_for     smallint,
  score_against smallint,
  lineup        jsonb not null default '{}'::jsonb,
  stats         jsonb not null default '{}'::jsonb,
  note          text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index if not exists fixtures_group_date_idx on public.fixtures(group_id, match_date desc);
alter table public.club     enable row level security;
alter table public.fixtures enable row level security;
do $$ declare t text; begin
  foreach t in array array['club','fixtures'] loop
    execute format('drop policy if exists "grp_all_%1$s" on public.%1$I', t);
    execute format('create policy "grp_all_%1$s" on public.%1$I for all to anon, authenticated using (group_id = public.current_group_id()) with check (group_id = public.current_group_id())', t);
  end loop;
end $$;
grant select, insert, update, delete on public.club, public.fixtures to anon, authenticated;
notify pgrst, 'reload schema';
select 'ok' as sonuc;
