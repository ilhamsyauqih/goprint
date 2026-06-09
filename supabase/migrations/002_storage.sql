-- supabase/migrations/002_storage.sql

-- 1. Create Buckets
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values 
  ('order-files', 'order-files', false, 20971520, '{"application/pdf", "image/png", "image/jpeg", "image/jpg", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"}'),
  ('payment-proofs', 'payment-proofs', false, 5242880, '{"image/png", "image/jpeg", "image/jpg"}'),
  ('shop-photos', 'shop-photos', true, null, null),
  ('templates', 'templates', true, null, null),
  ('avatars', 'avatars', true, 2097152, '{"image/png", "image/jpeg", "image/jpg"}')
on conflict (id) do update 
set public = excluded.public, 
    file_size_limit = excluded.file_size_limit, 
    allowed_mime_types = excluded.allowed_mime_types;

-- Ensure RLS is enabled on storage.objects (Enabled by default, commenting out to avoid owner permission error in SQL Editor)
-- alter table storage.objects enable row level security;


-- 2. Policies for order-files (Private, 20MB)
-- RLS: Owner (uploader) and shop owners who handle the order containing the file
create policy "Allow users to upload order files to their folder" on storage.objects
  for insert with check (
    bucket_id = 'order-files' 
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Allow owner to select their own order files" on storage.objects
  for select using (
    bucket_id = 'order-files' 
    and auth.role() = 'authenticated'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or exists (
        select 1 from public.order_items oi
        join public.orders o on oi.order_id = o.id
        join public.shops s on o.shop_id = s.id
        where s.owner_id = auth.uid() 
        and oi.file_url like '%' || name
      )
    )
  );

create policy "Allow owners to delete their order files" on storage.objects
  for delete using (
    bucket_id = 'order-files' 
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );


-- 3. Policies for payment-proofs (Private, 5MB)
-- RLS: Owner and shop owner
create policy "Allow users to upload payment proofs" on storage.objects
  for insert with check (
    bucket_id = 'payment-proofs'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Allow owner and shop admin to select payment proofs" on storage.objects
  for select using (
    bucket_id = 'payment-proofs'
    and auth.role() = 'authenticated'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or exists (
        select 1 from public.orders o
        join public.shops s on o.shop_id = s.id
        where s.owner_id = auth.uid() 
        and o.payment_proof_url like '%' || name
      )
    )
  );


-- 4. Policies for avatars (Public read, Owner write)
create policy "Allow public to read avatars" on storage.objects
  for select using (bucket_id = 'avatars');

create policy "Allow users to upload their own avatar" on storage.objects
  for insert with check (
    bucket_id = 'avatars'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Allow users to update their own avatar" on storage.objects
  for update using (
    bucket_id = 'avatars'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Allow users to delete their own avatar" on storage.objects
  for delete using (
    bucket_id = 'avatars'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );


-- 5. Policies for shop-photos (Public read, Shop Owner write)
create policy "Allow public to read shop photos" on storage.objects
  for select using (bucket_id = 'shop-photos');

create policy "Allow shop owner to upload shop photos" on storage.objects
  for insert with check (
    bucket_id = 'shop-photos'
    and auth.role() = 'authenticated'
    and exists (
      select 1 from public.shops
      where owner_id = auth.uid()
    )
  );

create policy "Allow shop owner to delete shop photos" on storage.objects
  for delete using (
    bucket_id = 'shop-photos'
    and auth.role() = 'authenticated'
    and exists (
      select 1 from public.shops
      where owner_id = auth.uid()
    )
  );


-- 6. Policies for templates (Public read, Admin write)
create policy "Allow public to read templates" on storage.objects
  for select using (bucket_id = 'templates');

create policy "Allow admins to upload templates" on storage.objects
  for insert with check (
    bucket_id = 'templates'
    and auth.role() = 'authenticated'
    and exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

create policy "Allow admins to delete templates" on storage.objects
  for delete using (
    bucket_id = 'templates'
    and auth.role() = 'authenticated'
    and exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );
