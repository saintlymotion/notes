-- Хранилище картинок. Выполните целиком в Supabase → SQL Editor → New query → Run.
-- Картинки приватные: каждый пользователь видит только файлы в своей папке.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('images', 'images', false, 5242880, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do nothing;

drop policy if exists "own images select" on storage.objects;
drop policy if exists "own images insert" on storage.objects;
drop policy if exists "own images update" on storage.objects;
drop policy if exists "own images delete" on storage.objects;

create policy "own images select" on storage.objects for select to authenticated
  using (bucket_id = 'images' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "own images insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'images' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "own images update" on storage.objects for update to authenticated
  using (bucket_id = 'images' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "own images delete" on storage.objects for delete to authenticated
  using (bucket_id = 'images' and (storage.foldername(name))[1] = auth.uid()::text);
