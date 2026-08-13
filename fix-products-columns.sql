-- Run this once in Supabase SQL Editor for an older products table.
alter table public.products
  add column if not exists owner_id uuid default auth.uid(),
  add column if not exists description text,
  add column if not exists hsn_sac text,
  add column if not exists unit text default 'Nos',
  add column if not exists rate numeric(14,2) default 0,
  add column if not exists gst_rate numeric(6,2) default 0,
  add column if not exists stock_qty numeric(14,3) default 0,
  add column if not exists low_stock_level numeric(14,3) default 10,
  add column if not exists updated_at timestamptz default now();

notify pgrst, 'reload schema';
