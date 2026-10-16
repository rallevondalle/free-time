-- 16/10-2026. Radios count outside airplane mode too (Rasmus: "fly gir max,
-- fly med WiFi er stadig forstyrrende").
--
-- A phone on silent with Wi-Fi, Bluetooth and mobile data off cannot show a
-- notification either, so it earns a little on top: ×1.1 per radio that is
-- off, stacking to ×1.33 with all three. Applies to normal / vibrate / silent /
-- DND. Airplane mode keeps its own table (3× with Wi-Fi on, 4× with Bluetooth
-- on, 5× with all radios off) and stays the top of a powered-on phone:
--   DND, all radios off      2.5 × 1.331 = 3.33×   (just above airplane + Wi-Fi)
--   airplane, all radios off              5×
-- Powered off is untouched.
--
-- Mobile data is new. Android measures it; iOS self-reports like the rest.
-- Unknown (older rows) means "on": no bonus for what was never measured.

alter table public.sessions
  add column if not exists data_on boolean not null default true;

insert into public.scoring_rules (key, multiplier, flat_bonus, description) values
  ('wifi_off',      1.1, 0, 'Wi-Fi off (outside airplane mode)'),
  ('bluetooth_off', 1.1, 0, 'Bluetooth off (outside airplane mode)'),
  ('data_off',      1.1, 0, 'Mobile data off (outside airplane mode)')
on conflict (key) do update set multiplier = excluded.multiplier, description = excluded.description;

drop function if exists public.compute_points(
  public.session_mode, public.session_source, timestamptz, timestamptz, boolean, boolean, boolean, boolean);

create function public.compute_points(
  p_mode         public.session_mode,
  p_source       public.session_source,
  p_started_at   timestamptz,
  p_ended_at     timestamptz,
  p_verified     boolean,
  p_screen_on    boolean,
  p_wifi_on      boolean default false,
  p_bluetooth_on boolean default false,
  p_data_on      boolean default true
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

  if p_mode in ('normal', 'vibrate', 'silent', 'dnd') then
    if not p_wifi_on then
      mult := mult * coalesce((select multiplier from public.scoring_rules where key = 'wifi_off'), 1.0);
    end if;
    if not p_bluetooth_on then
      mult := mult * coalesce((select multiplier from public.scoring_rules where key = 'bluetooth_off'), 1.0);
    end if;
    if not p_data_on then
      mult := mult * coalesce((select multiplier from public.scoring_rules where key = 'data_off'), 1.0);
    end if;
  end if;

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
    new.verified, new.screen_on, new.wifi_on, new.bluetooth_on, new.data_on);
  return new;
end $$;

-- Re-score existing rows: Android has measured Wi-Fi and Bluetooth on every
-- session since 0002, so history gets the bonus it earned.
update public.sessions set points = points where true;
