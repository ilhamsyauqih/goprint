-- supabase/migrations/001_schema.sql

-- Enable UUID extension if not enabled
create extension if not exists "uuid-ossp";

-- 1. Profiles Table
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  name text not null,
  phone text,
  avatar_url text,
  role text not null check (role in ('user', 'admin', 'superadmin')) default 'user',
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- 2. Addresses Table
create table public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  label text not null, -- e.g., 'Rumah', 'Kos'
  full_address text not null,
  is_default boolean default false not null,
  created_at timestamptz default now() not null
);

-- 3. Shops Table
create table public.shops (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references public.profiles(id) on delete set null not null,
  name text not null,
  description text,
  address text not null,
  lat numeric not null,
  lng numeric not null,
  photo_urls jsonb default '[]'::jsonb not null,
  operating_hours jsonb default '{}'::jsonb not null,
  is_open boolean default true not null,
  rating numeric default 0 not null,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- 4. Services Table
create table public.services (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid references public.shops(id) on delete cascade not null,
  name text not null,
  type text not null, -- e.g., 'print', 'photocopy', 'binding', 'laminating', 'scan'
  base_price numeric not null,
  is_active boolean default true not null,
  options jsonb default '{}'::jsonb not null, -- for paper size, color prices, etc.
  created_at timestamptz default now() not null
);

-- 5. Templates Table
create table public.templates (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null, -- e.g., 'surat_izin', 'cover_laporan'
  thumbnail_url text,
  file_url text not null,
  download_count int default 0 not null,
  created_at timestamptz default now() not null
);

-- 6. Orders Table
create table public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  shop_id uuid references public.shops(id) on delete set null,
  status text not null check (status in ('pending', 'confirmed', 'processing', 'ready', 'completed', 'cancelled')) default 'pending',
  delivery_type text not null check (delivery_type in ('pickup', 'delivery')),
  address_id uuid references public.addresses(id) on delete set null,
  total_price numeric not null,
  payment_method text not null,
  payment_proof_url text,
  payment_status text not null check (payment_status in ('pending', 'verified', 'rejected')) default 'pending',
  note text,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- 7. Order Items Table
create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references public.orders(id) on delete cascade not null,
  service_id uuid references public.services(id) on delete set null,
  file_url text not null,
  file_name text not null,
  pages int not null,
  copies int default 1 not null,
  color_mode text not null check (color_mode in ('bw', 'color')),
  paper_size text not null check (paper_size in ('A4', 'A3', 'F4')),
  finishing text,
  is_double_sided boolean default false not null,
  subtotal numeric not null
);

-- 8. Reviews Table
create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references public.orders(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  shop_id uuid references public.shops(id) on delete cascade not null,
  rating int not null check (rating between 1 and 5),
  comment text,
  is_anonymous boolean default false not null,
  created_at timestamptz default now() not null
);

-- 9. Notifications Table
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  body text not null,
  type text not null, -- e.g., 'order_update', 'payment', 'system'
  is_read boolean default false not null,
  created_at timestamptz default now() not null
);

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.addresses enable row level security;
alter table public.shops enable row level security;
alter table public.services enable row level security;
alter table public.templates enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.reviews enable row level security;
alter table public.notifications enable row level security;


--- RLS POLICIES ---

-- Profiles
create policy "Allow public read access to profiles" on public.profiles
  for select using (true);

create policy "Allow users to update their own profile" on public.profiles
  for update using (auth.uid() = id);

-- Addresses
create policy "Allow users to view their own addresses" on public.addresses
  for select using (auth.uid() = user_id);

create policy "Allow users to insert their own addresses" on public.addresses
  for insert with check (auth.uid() = user_id);

create policy "Allow users to update their own addresses" on public.addresses
  for update using (auth.uid() = user_id);

create policy "Allow users to delete their own addresses" on public.addresses
  for delete using (auth.uid() = user_id);

-- Shops
create policy "Allow public read access to shops" on public.shops
  for select using (true);

create policy "Allow owners to update their own shop" on public.shops
  for update using (auth.uid() = owner_id);

create policy "Allow owners to insert their own shop" on public.shops
  for insert with check (auth.uid() = owner_id);

-- Services
create policy "Allow public read access to services" on public.services
  for select using (true);

create policy "Allow owners to insert services" on public.services
  for insert with check (
    exists (
      select 1 from public.shops
      where id = shop_id and owner_id = auth.uid()
    )
  );

create policy "Allow owners to update services" on public.services
  for update using (
    exists (
      select 1 from public.shops
      where id = shop_id and owner_id = auth.uid()
    )
  );

create policy "Allow owners to delete services" on public.services
  for delete using (
    exists (
      select 1 from public.shops
      where id = shop_id and owner_id = auth.uid()
    )
  );

-- Templates
create policy "Allow public read access to templates" on public.templates
  for select using (true);

create policy "Allow admins to modify templates" on public.templates
  for all using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- Orders
create policy "Allow users to view their own orders" on public.orders
  for select using (auth.uid() = user_id);

create policy "Allow shop owners to view orders for their shop" on public.orders
  for select using (
    exists (
      select 1 from public.shops
      where id = shop_id and owner_id = auth.uid()
    )
  );

create policy "Allow users to create their own orders" on public.orders
  for insert with check (auth.uid() = user_id);

create policy "Allow users to update their own pending orders" on public.orders
  for update using (auth.uid() = user_id);

create policy "Allow shop owners to update orders for their shop" on public.orders
  for update using (
    exists (
      select 1 from public.shops
      where id = shop_id and owner_id = auth.uid()
    )
  );

-- Order Items
create policy "Allow users to view items for their orders" on public.order_items
  for select using (
    exists (
      select 1 from public.orders
      where id = order_id and user_id = auth.uid()
    )
  );

create policy "Allow shop owners to view items for their shop orders" on public.order_items
  for select using (
    exists (
      select 1 from public.orders o
      join public.shops s on o.shop_id = s.id
      where o.id = order_id and s.owner_id = auth.uid()
    )
  );

create policy "Allow users to insert order items" on public.order_items
  for insert with check (
    exists (
      select 1 from public.orders
      where id = order_id and user_id = auth.uid()
    )
  );

-- Reviews
create policy "Allow public read access to reviews" on public.reviews
  for select using (true);

create policy "Allow users to insert reviews for their own orders" on public.reviews
  for insert with check (auth.uid() = user_id);

-- Notifications
create policy "Allow users to view their own notifications" on public.notifications
  for select using (auth.uid() = user_id);

create policy "Allow users to update their own notifications" on public.notifications
  for update using (auth.uid() = user_id);

create policy "Allow authenticated users to insert notifications" on public.notifications
  for insert with check (auth.role() = 'authenticated');


--- TRIGGERS AND FUNCTIONS ---

-- Trigger: auto-create profile on auth.users sign up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name, phone, avatar_url, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'phone', new.raw_user_meta_data->>'phone_number'),
    new.raw_user_meta_data->>'avatar_url',
    coalesce(new.raw_user_meta_data->>'role', 'user')
  );
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Trigger: auto-update updated_at for tables
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create or replace trigger on_orders_updated
  before update on public.orders
  for each row execute procedure public.handle_updated_at();

create or replace trigger on_profiles_updated
  before update on public.profiles
  for each row execute procedure public.handle_updated_at();

create or replace trigger on_shops_updated
  before update on public.shops
  for each row execute procedure public.handle_updated_at();
