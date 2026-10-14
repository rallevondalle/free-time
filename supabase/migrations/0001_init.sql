-- Free Time: schema v1
-- Sessions are uploaded by the app; points are computed server-side.

create extension if not exists "pgcrypto";

-- ---------- profiles ----------
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  username    text unique not null check (username ~ '^[a-z0-9_]{3,20}$'),
  display_name text,
  avatar_url  text,
  platform    text check (platform in ('android','ios')),
  created_at  timestamptz not null default now()
);

alter table public.profiles enable row level security;
create policy "profiles are readable by authenticated users"
  on public.profiles for select to authenticated using (true);
create policy "users manage own profile"
  on public.profiles for insert to authenticated with check (auth.uid() = id);
create policy "users update own profile"
  on public.profiles for update to authenticated using (auth.uid() = id);

-- ---------- scoring rules ----------
-- Multipliers live in the DB so they can be tuned without an app release.
create table public.scoring_rules (
  key         text primary key,
  multiplier  numeric not null,
  flat_bonus  integer not null default 0,
  description text
);

insert into public.scoring_rules (key, multiplier, flat_bonus, description) values
  ('base_still',   1.0,  0,  'Points per minute while still, screen off'),
  ('ringer_normal',1.0,  0,  'Sound on'),
  ('ringer_vibrate',1.5, 0,  'Vibrate'),
  ('ringer_silent',2.0,  0,  'Silent'),
  ('dnd',          2.5,  0,  'Do not disturb / Focus'),
  ('airplane',     4.0,  0,  'Airplane mode'),
  ('powered_off',  6.0,  0,  'Phone turned off'),
  ('reboot',       0.0,  50, 'Flat bonus per reboot'),
  ('screen_on',    0.5,  0,  'Factor when lying still with the screen on (locked)'),
  ('unverified',   0.5,  0,  'Factor when the OS could not confirm stillness / no use'),
  ('moving',       0.0,  0,  'Phone in motion / in pocket: no points');

-- ---------- sessions ----------
-- One row per contiguous period the phone was "down".
-- mode = the strongest state that held for the WHOLE session; the client
-- splits a session whenever the state changes, so a session has one mode.
create type public.session_mode as enum
  ('normal','vibrate','silent','dnd','airplane','powered_off');

create type public.session_source as enum
  ('manual',          -- user started it (iOS and Android)
   'auto',            -- Android service detected stillness
   'shutdown',        -- derived from shutdown/boot timestamps
   'reboot');         -- shutdown+boot with short gap

create table public.sessions (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.profiles(id) on delete cascade,
  client_id    text not null,                 -- idempotency key from device
  started_at   timestamptz not null,
  ended_at     timestamptz not null,
  mode         public.session_mode not null default 'normal',
  source       public.session_source not null,
  verified     boolean not null default false, -- true when the OS confirmed stillness/no usage
  self_reported boolean not null default false, -- iOS honor-system toggles for silent/airplane
  pickups      integer not null default 0,     -- interruptions detected
  screen_on    boolean not null default false,  -- lying still, screen on but locked
  points       integer not null default 0,     -- computed by trigger
  created_at   timestamptz not null default now(),
  unique (user_id, client_id),
  check (ended_at > started_at),
  check (ended_at - started_at <= interval '48 hours')
);

create index sessions_user_started_idx on public.sessions (user_id, started_at desc);

alter table public.sessions enable row level security;
create policy "users read own sessions"
  on public.sessions for select to authenticated using (auth.uid() = user_id);
create policy "users insert own sessions"
  on public.sessions for insert to authenticated with check (auth.uid() = user_id);

-- ---------- scoring ----------
create or replace function public.compute_points(
  p_mode public.session_mode,
  p_source public.session_source,
  p_started timestamptz,
  p_ended timestamptz,
  p_verified boolean,
  p_screen_on boolean default false
) returns integer
language plpgsql stable as $$
declare
  minutes numeric := extract(epoch from (p_ended - p_started)) / 60.0;
  mult numeric;
  bonus integer := 0;
  rule_key text;
begin
  if p_source = 'reboot' then
    select flat_bonus into bonus from public.scoring_rules where key = 'reboot';
    return coalesce(bonus, 0);
  end if;

  rule_key := case p_mode
    when 'normal'      then 'ringer_normal'
    when 'vibrate'     then 'ringer_vibrate'
    when 'silent'      then 'ringer_silent'
    when 'dnd'         then 'dnd'
    when 'airplane'    then 'airplane'
    when 'powered_off' then 'powered_off'
  end;

  select multiplier into mult from public.scoring_rules where key = rule_key;
  if not p_verified then
    mult := mult * coalesce((select multiplier from public.scoring_rules where key = 'unverified'), 0.5);
  end if;
  if p_screen_on then
    mult := mult * coalesce((select multiplier from public.scoring_rules where key = 'screen_on'), 0.5);
  end if;

  return floor(minutes * coalesce(mult, 1.0))::integer;
end $$;

create or replace function public.sessions_set_points()
returns trigger language plpgsql as $$
begin
  new.points := public.compute_points(new.mode, new.source, new.started_at, new.ended_at, new.verified, new.screen_on);
  return new;
end $$;

create trigger sessions_points_trg
  before insert or update on public.sessions
  for each row execute function public.sessions_set_points();

-- ---------- friends ----------
create table public.friendships (
  requester_id uuid not null references public.profiles(id) on delete cascade,
  addressee_id uuid not null references public.profiles(id) on delete cascade,
  status       text not null default 'pending' check (status in ('pending','accepted')),
  created_at   timestamptz not null default now(),
  primary key (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

alter table public.friendships enable row level security;
create policy "see own friendships"
  on public.friendships for select to authenticated
  using (auth.uid() in (requester_id, addressee_id));
create policy "send request"
  on public.friendships for insert to authenticated
  with check (auth.uid() = requester_id);
create policy "accept request"
  on public.friendships for update to authenticated
  using (auth.uid() = addressee_id);
create policy "remove friendship"
  on public.friendships for delete to authenticated
  using (auth.uid() in (requester_id, addressee_id));

create or replace function public.are_friends(a uuid, b uuid)
returns boolean language sql stable as $$
  select exists (
    select 1 from public.friendships
    where status = 'accepted'
      and ((requester_id = a and addressee_id = b) or (requester_id = b and addressee_id = a))
  );
$$;

-- ---------- leaderboard ----------
-- Weekly totals, visible to the user and their accepted friends.
create or replace view public.weekly_scores
with (security_invoker = true) as
  select
    user_id,
    date_trunc('week', started_at at time zone 'Europe/Copenhagen') as week_start,
    sum(points)::integer as points,
    sum(extract(epoch from (ended_at - started_at)))::integer / 60 as minutes
  from public.sessions
  group by user_id, week_start;

create policy "friends read each other's sessions"
  on public.sessions for select to authenticated
  using (public.are_friends(auth.uid(), user_id));

create or replace function public.friend_leaderboard(p_week date default null)
returns table (user_id uuid, username text, display_name text, avatar_url text, points integer, minutes integer)
language sql stable security definer set search_path = public as $$
  with wk as (
    select coalesce(
      date_trunc('week', p_week::timestamptz),
      date_trunc('week', now() at time zone 'Europe/Copenhagen')
    ) as start
  ),
  members as (
    select auth.uid() as id
    union
    select case when requester_id = auth.uid() then addressee_id else requester_id end
    from friendships
    where status = 'accepted' and auth.uid() in (requester_id, addressee_id)
  )
  select p.id, p.username, p.display_name, p.avatar_url,
         coalesce(sum(s.points), 0)::integer,
         coalesce(sum(extract(epoch from (s.ended_at - s.started_at))) / 60, 0)::integer
  from members m
  join profiles p on p.id = m.id
  left join sessions s
    on s.user_id = p.id
   and date_trunc('week', s.started_at at time zone 'Europe/Copenhagen') = (select start from wk)
  group by p.id, p.username, p.display_name, p.avatar_url
  order by 5 desc;
$$;
