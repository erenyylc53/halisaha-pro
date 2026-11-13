-- Halı Saha Pro v5: gol/asist, maç sonu oylaması, katılım bildirimi
alter table public.matches add column if not exists stats jsonb not null default '{}'::jsonb;

create table if not exists public.votes(
  group_id   uuid not null default public.current_group_id() references public.groups(id) on delete cascade,
  match_id   text not null,
  voter_id   text not null,
  mvp_id     text,
  ratings    jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (group_id, match_id, voter_id)
);
create table if not exists public.rsvp(
  group_id   uuid not null default public.current_group_id() references public.groups(id) on delete cascade,
  match_date date not null,
  player_id  text not null,
  status     text not null check (status in ('yes','no','maybe')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (group_id, match_date, player_id)
);
alter table public.votes enable row level security;
alter table public.rsvp  enable row level security;
do $$ declare t text; begin
  foreach t in array array['votes','rsvp'] loop
    execute format('drop policy if exists "grp_all_%1$s" on public.%1$I', t);
    execute format('create policy "grp_all_%1$s" on public.%1$I for all to anon, authenticated using (group_id = public.current_group_id()) with check (group_id = public.current_group_id())', t);
  end loop;
end $$;
grant select, insert, update, delete on public.votes, public.rsvp to anon, authenticated;
notify pgrst, 'reload schema';
