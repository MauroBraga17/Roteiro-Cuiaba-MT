begin;

select plan(19);

select tests.create_supabase_user('roteiro_user_1', 'roteiro-user-1@example.invalid');
select tests.create_supabase_user('roteiro_user_2', 'roteiro-user-2@example.invalid');

select tests.rls_enabled('public', 'profiles');
select tests.rls_enabled('public', 'cities');
select tests.rls_enabled('public', 'doctors');
select tests.rls_enabled('public', 'practice_locations');
select tests.rls_enabled('public', 'office_hours');
select tests.rls_enabled('public', 'visit_logs');

select tests.authenticate_as_service_role();

insert into public.cities (id, user_id, name, state) values
  ('10000000-0000-0000-0000-000000000001', tests.get_supabase_uid('roteiro_user_1'), 'Cidade Teste 1', 'MT'),
  ('20000000-0000-0000-0000-000000000002', tests.get_supabase_uid('roteiro_user_2'), 'Cidade Teste 2', 'MT');

insert into public.doctors (id, user_id, full_name, reference_city_id) values
  ('11000000-0000-0000-0000-000000000001', tests.get_supabase_uid('roteiro_user_1'), 'Médico Teste 1', '10000000-0000-0000-0000-000000000001'),
  ('22000000-0000-0000-0000-000000000002', tests.get_supabase_uid('roteiro_user_2'), 'Médico Teste 2', '20000000-0000-0000-0000-000000000002');

insert into public.practice_locations (id, user_id, doctor_id, city_id, name) values
  ('12000000-0000-0000-0000-000000000001', tests.get_supabase_uid('roteiro_user_1'), '11000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'Clínica Teste 1'),
  ('23000000-0000-0000-0000-000000000002', tests.get_supabase_uid('roteiro_user_2'), '22000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', 'Clínica Teste 2');

insert into public.office_hours (user_id, practice_location_id, weekday, starts_at) values
  (tests.get_supabase_uid('roteiro_user_1'), '12000000-0000-0000-0000-000000000001', 1, '07:00'),
  (tests.get_supabase_uid('roteiro_user_2'), '23000000-0000-0000-0000-000000000002', 2, '08:00');

insert into public.visit_logs (user_id, doctor_id, practice_location_id, visited_on, status) values
  (tests.get_supabase_uid('roteiro_user_1'), '11000000-0000-0000-0000-000000000001', '12000000-0000-0000-0000-000000000001', current_date, 'pending'),
  (tests.get_supabase_uid('roteiro_user_2'), '22000000-0000-0000-0000-000000000002', '23000000-0000-0000-0000-000000000002', current_date, 'pending');

select tests.authenticate_as('roteiro_user_1');
select results_eq('select count(*) from public.doctors', array[1::bigint], 'Usuário 1 vê somente seu médico');
select results_eq('select count(*) from public.cities', array[1::bigint], 'Usuário 1 vê somente sua cidade');
select results_eq('select count(*) from public.practice_locations', array[1::bigint], 'Usuário 1 vê somente seu local');
select results_eq('select count(*) from public.office_hours', array[1::bigint], 'Usuário 1 vê somente seu horário');
select results_eq('select count(*) from public.visit_logs', array[1::bigint], 'Usuário 1 vê somente sua visita');
select lives_ok(
  $$insert into public.doctors (full_name) values ('Novo Médico do Usuário 1')$$,
  'Usuário 1 inclui registro próprio'
);
select throws_ok(
  format('insert into public.doctors (user_id, full_name) values (%L, %L)', tests.get_supabase_uid('roteiro_user_2'), 'Tentativa cruzada'),
  '42501', null, 'Usuário 1 não inclui registro para usuário 2'
);
select is_empty(
  $$update public.doctors set full_name = 'Alterado indevidamente' where id = '22000000-0000-0000-0000-000000000002' returning id$$,
  'Usuário 1 não altera médico do usuário 2'
);
select is_empty(
  $$delete from public.doctors where id = '22000000-0000-0000-0000-000000000002' returning id$$,
  'Usuário 1 não exclui médico do usuário 2'
);
select throws_ok(
  $$insert into public.practice_locations (doctor_id, city_id, name) values ('22000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'Local inválido')$$,
  '23503', null, 'Chave estrangeira impede cruzar proprietário'
);

select tests.authenticate_as('roteiro_user_2');
select results_eq('select count(*) from public.doctors', array[1::bigint], 'Usuário 2 vê somente seu médico');
select results_eq(
  $$select full_name from public.doctors where id = '22000000-0000-0000-0000-000000000002'$$,
  array['Médico Teste 2'::text], 'Registro do usuário 2 permaneceu intacto'
);

set local role anon;
select throws_ok(
  'select * from public.doctors', '42501', null,
  'Visitante sem login não consulta médicos'
);

select * from finish();
rollback;
