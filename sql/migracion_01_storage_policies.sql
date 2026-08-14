-- =========================================================
-- MIGRACIÓN 01: Políticas de Storage para el bucket fotos-familia
-- =========================================================
-- Por qué es necesaria:
-- Aunque el bucket "fotos-familia" se cree como Public bucket,
-- Supabase protege por defecto la tabla interna storage.objects
-- (donde se registra cada archivo subido). Sin estas políticas,
-- cualquier intento de subir o leer una imagen falla con el error:
--   "new row violates row-level security policy"
--
-- Cuándo ejecutar esto:
-- DESPUÉS de haber creado el bucket "fotos-familia" manualmente
-- desde Storage > New bucket (con Public bucket activado).
-- =========================================================

create policy "Lectura publica fotos-familia"
on storage.objects for select
using (bucket_id = 'fotos-familia');

create policy "Subida publica fotos-familia"
on storage.objects for insert
with check (bucket_id = 'fotos-familia');

create policy "Actualizacion publica fotos-familia"
on storage.objects for update
using (bucket_id = 'fotos-familia');

-- Nota para fase 2 (login + roles):
-- Cuando se active Supabase Auth, estas políticas se pueden
-- endurecer exigiendo auth.uid(), por ejemplo:
--   with check (bucket_id = 'fotos-familia' and auth.uid() is not null);
