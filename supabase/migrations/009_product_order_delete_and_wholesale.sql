-- Product display order and safe deletion of records already used on invoices.
alter table public.sfh_products add column if not exists sort_order integer not null default 0;

with ranked as (
 select id,row_number() over(order by created_at,id)-1 as position from public.sfh_products
)
update public.sfh_products p set sort_order=ranked.position from ranked where ranked.id=p.id;

alter table public.sfh_invoices drop constraint if exists sfh_invoices_customer_id_fkey;
alter table public.sfh_invoices add constraint sfh_invoices_customer_id_fkey foreign key(customer_id) references public.sfh_customers(id) on delete set null;

alter table public.sfh_invoice_items drop constraint if exists sfh_invoice_items_product_id_fkey;
alter table public.sfh_invoice_items add constraint sfh_invoice_items_product_id_fkey foreign key(product_id) references public.sfh_products(id) on delete set null;

alter table public.sfh_stock_movements drop constraint if exists sfh_stock_movements_product_id_fkey;
alter table public.sfh_stock_movements add constraint sfh_stock_movements_product_id_fkey foreign key(product_id) references public.sfh_products(id) on delete cascade;
