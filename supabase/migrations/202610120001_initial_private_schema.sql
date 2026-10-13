-- Estrutura privada inicial do Roteiro Cuiabá.
-- Não inserir dados reais nesta migração.

create extension if not exists pgcrypto;
create schema if not exists private;

revoke all on schema private from public, anon, authenticated;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table public.cities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 2 and 120),
  state char(2) not null check (state = upper(state) and state ~ '^[A-Z]{2}$'),
  active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (id, user_id)
);

create unique index cities_owner_name_state_uidx
  on public.cities (user_id, lower(btrim(name)), state);

create table public.doctors (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  full_name text not null check (char_length(btrim(full_name)) between 2 and 180),
  crm text null check (crm is null or char_length(btrim(crm)) between 1 and 30),
  crm_state char(2) null check (crm_state is null or (crm_state = upper(crm_state) and crm_state ~ '^[A-Z]{2}$')),
  specialty text null check (specialty is null or char_length(btrim(specialty)) <= 120),
  reference_city_id uuid null,
  priority smallint null check (priority between 1 and 5),
  professional_notes text null check (professional_notes is null or char_length(professional_notes) <= 4000),
  active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (id, user_id),
  constraint doctors_reference_city_fk foreign key (reference_city_id, user_id)
    references public.cities(id, user_id) on delete restrict,
  constraint doctors_crm_pair_check check ((crm is null and crm_state is null) or (crm is not null and crm_state is not null))
);

create unique index doctors_owner_crm_uidx
  on public.doctors (user_id, upper(btrim(crm)), crm_state)
  where crm is not null;
create index doctors_owner_name_idx on public.doctors (user_id, lower(full_name));
create index doctors_reference_city_idx on public.doctors (reference_city_id);

create table public.practice_locations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  doctor_id uuid not null,
  city_id uuid not null,
  name text not null check (char_length(btrim(name)) between 2 and 180),
  neighborhood text null check (neighborhood is null or char_length(btrim(neighborhood)) <= 120),
  full_address text null check (full_address is null or char_length(btrim(full_address)) <= 500),
  postal_code text null check (postal_code is null or postal_code ~ '^\d{5}-?\d{3}$'),
  latitude numeric(9,6) null check (latitude between -90 and 90),
  longitude numeric(9,6) null check (longitude between -180 and 180),
  access_notes text null check (access_notes is null or char_length(access_notes) <= 2000),
  phone text null check (phone is null or char_length(phone) <= 40),
  scheduled_status text null check (scheduled_status is null or char_length(scheduled_status) <= 120),
  active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (id, user_id),
  constraint practice_locations_doctor_fk foreign key (doctor_id, user_id)
    references public.doctors(id, user_id) on delete cascade,
  constraint practice_locations_city_fk foreign key (city_id, user_id)
    references public.cities(id, user_id) on delete restrict,
  constraint practice_locations_coordinates_check check ((latitude is null) = (longitude is null))
);

create index practice_locations_owner_idx on public.practice_locations (user_id);
create index practice_locations_doctor_idx on public.practice_locations (doctor_id);
create index practice_locations_city_idx on public.practice_locations (city_id);

create table public.office_hours (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  practice_location_id uuid not null,
  weekday smallint not null check (weekday between 1 and 7),
  starts_at time null,
  ends_at time null,
  original_label text null check (original_label is null or char_length(original_label) <= 120),
  availability_notes text null check (availability_notes is null or char_length(availability_notes) <= 1000),
  active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (id, user_id),
  constraint office_hours_location_fk foreign key (practice_location_id, user_id)
    references public.practice_locations(id, user_id) on delete cascade,
  constraint office_hours_value_check check (starts_at is not null or nullif(btrim(original_label), '') is not null),
  constraint office_hours_range_check check (ends_at is null or (starts_at is not null and ends_at >= starts_at))
);

create index office_hours_owner_idx on public.office_hours (user_id);
create index office_hours_location_weekday_idx on public.office_hours (practice_location_id, weekday, starts_at);
create index office_hours_owner_weekday_idx on public.office_hours (user_id, weekday, starts_at);

create table public.visit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  doctor_id uuid not null,
  practice_location_id uuid null,
  visited_on date not null,
  status text not null check (status in ('pending', 'completed', 'doctor_absent', 'not_seen', 'rescheduled')),
  notes text null check (notes is null or char_length(notes) <= 4000),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (id, user_id),
  constraint visit_logs_doctor_fk foreign key (doctor_id, user_id)
    references public.doctors(id, user_id) on delete restrict,
  constraint visit_logs_location_fk foreign key (practice_location_id, user_id)
    references public.practice_locations(id, user_id) on delete restrict
);

create index visit_logs_owner_date_idx on public.visit_logs (user_id, visited_on desc);
create index visit_logs_doctor_idx on public.visit_logs (doctor_id);

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (user_id) values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

create trigger profiles_set_updated_at before update on public.profiles
  for each row execute function private.set_updated_at();
create trigger cities_set_updated_at before update on public.cities
  for each row execute function private.set_updated_at();
create trigger doctors_set_updated_at before update on public.doctors
  for each row execute function private.set_updated_at();
create trigger practice_locations_set_updated_at before update on public.practice_locations
  for each row execute function private.set_updated_at();
create trigger office_hours_set_updated_at before update on public.office_hours
  for each row execute function private.set_updated_at();
create trigger visit_logs_set_updated_at before update on public.visit_logs
  for each row execute function private.set_updated_at();

alter table public.profiles enable row level security;
alter table public.cities enable row level security;
alter table public.doctors enable row level security;
alter table public.practice_locations enable row level security;
alter table public.office_hours enable row level security;
alter table public.visit_logs enable row level security;

revoke all on table public.profiles, public.cities, public.doctors,
  public.practice_locations, public.office_hours, public.visit_logs from anon, authenticated;
grant select, insert, update, delete on table public.profiles, public.cities, public.doctors,
  public.practice_locations, public.office_hours, public.visit_logs to authenticated;

create policy profiles_select_own on public.profiles for select to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy profiles_insert_own on public.profiles for insert to authenticated
  with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy profiles_update_own on public.profiles for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy profiles_delete_own on public.profiles for delete to authenticated
  using ((select auth.uid()) = user_id);

create policy cities_select_own on public.cities for select to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy cities_insert_own on public.cities for insert to authenticated
  with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy cities_update_own on public.cities for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy cities_delete_own on public.cities for delete to authenticated
  using ((select auth.uid()) = user_id);

create policy doctors_select_own on public.doctors for select to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy doctors_insert_own on public.doctors for insert to authenticated
  with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy doctors_update_own on public.doctors for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy doctors_delete_own on public.doctors for delete to authenticated
  using ((select auth.uid()) = user_id);

create policy practice_locations_select_own on public.practice_locations for select to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy practice_locations_insert_own on public.practice_locations for insert to authenticated
  with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy practice_locations_update_own on public.practice_locations for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy practice_locations_delete_own on public.practice_locations for delete to authenticated
  using ((select auth.uid()) = user_id);

create policy office_hours_select_own on public.office_hours for select to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy office_hours_insert_own on public.office_hours for insert to authenticated
  with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy office_hours_update_own on public.office_hours for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy office_hours_delete_own on public.office_hours for delete to authenticated
  using ((select auth.uid()) = user_id);

create policy visit_logs_select_own on public.visit_logs for select to authenticated
  using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy visit_logs_insert_own on public.visit_logs for insert to authenticated
  with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy visit_logs_update_own on public.visit_logs for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy visit_logs_delete_own on public.visit_logs for delete to authenticated
  using ((select auth.uid()) = user_id);

-- Cidades iniciais são inseridas por usuário após o primeiro login. Não há dados globais públicos.
