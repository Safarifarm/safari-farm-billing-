-- Supplier invoice upload archive for OCR-assisted purchase entry.
-- Run after 014_edit_purchase_and_sale_invoice.sql.

create extension if not exists pgcrypto;

create table if not exists public.sfh_purchase_uploads (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references public.sfh_invoices(id) on delete cascade,
  supplier_name text not null,
  supplier_invoice_no text,
  supplier_invoice_date date,
  file_url text,
  original_file_name text,
  extracted_text text,
  extraction_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists sfh_purchase_uploads_invoice_id_idx
  on public.sfh_purchase_uploads(invoice_id);

alter table public.sfh_purchase_uploads enable row level security;

drop policy if exists "authenticated purchase uploads" on public.sfh_purchase_uploads;
create policy "authenticated purchase uploads"
  on public.sfh_purchase_uploads
  for all
  to authenticated
  using (true)
  with check (true);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'supplier-invoices',
  'supplier-invoices',
  false,
  10485760,
  array['application/pdf', 'image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "authenticated supplier invoice insert" on storage.objects;
create policy "authenticated supplier invoice insert"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'supplier-invoices');

drop policy if exists "authenticated supplier invoice update" on storage.objects;
create policy "authenticated supplier invoice update"
  on storage.objects for update to authenticated
  using (bucket_id = 'supplier-invoices')
  with check (bucket_id = 'supplier-invoices');

drop policy if exists "authenticated supplier invoice delete" on storage.objects;
create policy "authenticated supplier invoice delete"
  on storage.objects for delete to authenticated
  using (bucket_id = 'supplier-invoices');

drop policy if exists "authenticated supplier invoice read" on storage.objects;
create policy "authenticated supplier invoice read"
  on storage.objects for select to authenticated
  using (bucket_id = 'supplier-invoices');
