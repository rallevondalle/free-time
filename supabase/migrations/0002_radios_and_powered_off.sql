-- 14/10-2026. Two changes to the scoring model:
--
-- 1. Airplane mode is graded by what is still switched on. Modern phones keep
--    Wi-Fi and Bluetooth up in airplane mode, so "airplane" alone covered
--    everything from fully dead to still-on-AirPods. The radios only matter
--    inside airplane mode; Wi-Fi off in silent mode earns nothing extra.
--      airplane, Wi-Fi off, Bluetooth off  5.0×
--      airplane, Wi-Fi off, Bluetooth on   4.0×
--      airplane, Wi-Fi on                  3.0×
-- 2. Powered off goes from 6× to 10×.
--
-- Android measures the radios; iOS self-reports them like the rest.

alter table public.sessions
  add column if not exists wifi_on      boolean not null default false,
  add column if not exists bluetooth_on boolean not null default false;

insert into public.scoring_rules (key, multiplier, flat_bonus, description) values
  ('airplane_radios_off', 5.0, 0, 'Airplane mode, Wi-Fi and Bluetooth off'),
  ('airplane_bt_on',      4.0, 0, 'Airplane mode, Wi-Fi off, Bluetooth on'),
  ('airplane_wifi_on',    3.0, 0, 'Airplane mode, Wi-Fi on')
on conflict (key) do update set multiplier = excluded.multiplier, description = excluded.description;

update public.scoring_rules
   set multiplier = 10.0, description = 'Phone turned off'
 where key = 'powered_off';

-- 'airplane' stays as the fallback for rows without radio info.

-- Same name, two more parameters: drop the old overload so a call with six
-- arguments can never be ambiguous.
drop function if exists public.compute_points(
  public.session_mode, public.session_source, timestamptz, timestamptz, boolean, boolean);

create function public.compute_points(
  p_mode         public.session_mode,
  p_source       public.session_source,
  p_started_at   timestamptz,
  p_ended_at     timestamptz,
  p_verified     boolean,
  p_screen_on    boolean,
  p_wifi_on      boolean default false,
  p_bluetooth_on boolean default false
) returns integer language plpgsql stable as $$
declare
  minutes  numeric := extract(epoch from (p_ended_at - p_started_at)) / 60.0;
  mult     numeric;
  bonus    integer;
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
    when 'airplane'    then case
                              when p_wifi_on       then 'airplane_wifi_on'
                              when p_bluetooth_on  then 'airplane_bt_on'
                              else                      'airplane_radios_off'
                            end
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
  new.points := public.compute_points(
    new.mode, new.source, new.started_at, new.ended_at,
    new.verified, new.screen_on, new.wifi_on, new.bluetooth_on);
  return new;
end $$;

-- Re-score existing rows with the new multipliers.
update public.sessions set points = points where true;
