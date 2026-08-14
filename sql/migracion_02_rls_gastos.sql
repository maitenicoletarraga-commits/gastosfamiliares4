-- =========================================================
-- MIGRACIÓN 02: Login, roles y RLS real
-- =========================================================
-- Ejecutar DESPUÉS de haber probado que el login (Supabase Auth)
-- funciona y que app.js ya envía usuario_id al guardar un gasto.
--
-- Antes de correr este script:
-- 1. Ve a Authentication > Settings y desactiva "Confirm email"
--    (los estudiantes usan correos tipo estudiante@colegio.edu,
--    sin bandeja real).
-- =========================================================

-- ---------------------------------------------------------
-- 1. Trigger: crea automáticamente una fila en "perfiles"
--    cada vez que alguien se registra con Supabase Auth.
-- ---------------------------------------------------------
create or replace function crear_perfil_automatico()
returns trigger as $$
begin
  insert into perfiles (id, nombre, rol)
  values (new.id, new.email, 'sin_asignar');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function crear_perfil_automatico();

-- ---------------------------------------------------------
-- 2. RLS real sobre la tabla "gastos"
--    Cada usuario solo puede ver y modificar sus propios gastos.
-- ---------------------------------------------------------
alter table gastos enable row level security;

create policy "usuarios ven solo sus gastos"
on gastos for select
using (auth.uid() = usuario_id);

create policy "usuarios insertan sus propios gastos"
on gastos for insert
with check (auth.uid() = usuario_id);

create policy "usuarios editan solo sus gastos"
on gastos for update
using (auth.uid() = usuario_id);

create policy "usuarios eliminan solo sus gastos"
on gastos for delete
using (auth.uid() = usuario_id);

-- Nota: las 4 políticas (select/insert/update/delete) deben ejecutarse
-- juntas. Si se activa "enable row level security" sin las 4, la tabla
-- queda bloqueada para todos, aunque tenga datos guardados.
