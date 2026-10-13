create or replace function private.seed_initial_cities()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.cities (user_id, name, state) values
    (new.user_id, 'Cuiabá', 'MT'),
    (new.user_id, 'Várzea Grande', 'MT'),
    (new.user_id, 'Sinop', 'MT'),
    (new.user_id, 'Sorriso', 'MT'),
    (new.user_id, 'Lucas do Rio Verde', 'MT'),
    (new.user_id, 'Rondonópolis', 'MT'),
    (new.user_id, 'Tangará da Serra', 'MT'),
    (new.user_id, 'Alta Floresta', 'MT'),
    (new.user_id, 'Juína', 'MT')
  on conflict do nothing;
  return new;
end;
$$;

create trigger on_profile_created_seed_cities
  after insert on public.profiles
  for each row execute function private.seed_initial_cities();

insert into public.cities (user_id, name, state)
select profile.user_id, city.name, 'MT'
from public.profiles profile
cross join (values
  ('Cuiabá'), ('Várzea Grande'), ('Sinop'), ('Sorriso'),
  ('Lucas do Rio Verde'), ('Rondonópolis'), ('Tangará da Serra'),
  ('Alta Floresta'), ('Juína')
) as city(name)
on conflict do nothing;
