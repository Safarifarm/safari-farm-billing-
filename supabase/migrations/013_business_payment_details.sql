-- Enterprise-style payment tracking for sale and self/purchase invoices.
alter table public.sfh_invoices add column if not exists payment_method text not null default 'Cash';
alter table public.sfh_invoices add column if not exists payment_reference text;
alter table public.sfh_invoices add column if not exists payment_notes text;
alter table public.sfh_invoices add column if not exists due_date date;
create index if not exists sfh_invoices_due_date_idx on public.sfh_invoices(due_date) where payment_status <> 'Paid';
