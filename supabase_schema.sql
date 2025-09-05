-- events
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sport text,
  location text,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz default now()
);

-- photos
create table if not exists public.photos (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references public.events(id) on delete cascade not null,
  photographer_id uuid,
  status text check (status in ('uploaded','processed')) default 'uploaded',
  original_url text not null,
  edited_url text,
  athlete_tag text,
  team_tag text,
  taken_at timestamptz default now(),
  processed_at timestamptz,
  meta jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

-- Enable RLS
alter table public.events enable row level security;
alter table public.photos enable row level security;

-- Basic policies (adjust for production)
create policy if not exists photos_read_public on public.photos
for select using (true);

create policy if not exists photos_insert_auth on public.photos
for insert with check (auth.role() = 'authenticated');

create policy if not exists photos_update_auth on public.photos
for update using (auth.role() = 'authenticated');

-- NOTE: Enable Realtime replication for 'photos' in Supabase dashboard.
