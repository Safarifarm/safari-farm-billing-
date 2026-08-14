-- Safari Farm & Hatchery: complete Supabase schema
create extension if not exists pgcrypto;

create table if not exists public.customers (
 id uuid primary key default gen_random_uuid(), name text not null, customer_type text not null default 'Non-GST' check (customer_type in ('GST','Non-GST')),
 phone text, email text, gstin text, address text, state text, state_code text, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(), name text not null, sku text not null unique, hsn text, unit text not null default 'Nos', sale_price numeric(12,2) not null default 0 check(sale_price>=0),
 gst_rate numeric(5,2) not null default 0, current_stock numeric(14,3) not null default 0, low_stock_threshold numeric(14,3) not null default 0, active boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.invoices (
 id uuid primary key default gen_random_uuid(), invoice_no text unique, process_no text unique, inquiry_no text unique, customer_id uuid not null references public.customers(id), invoice_date date not null default current_date,
 subtotal numeric(14,2) not null default 0, tax_total numeric(14,2) not null default 0, grand_total numeric(14,2) not null default 0, amount_paid numeric(14,2) not null default 0,
 payment_status text not null default 'Unpaid' check(payment_status in ('Paid','Partial','Unpaid')), notes text, created_at timestamptz not null default now()
);
create table if not exists public.invoice_items (
 id uuid primary key default gen_random_uuid(), invoice_id uuid not null references public.invoices(id) on delete cascade, product_id uuid references public.products(id), description text not null,
 hsn text, quantity numeric(14,3) not null check(quantity>0), unit text, rate numeric(14,2) not null, discount numeric(5,2) not null default 0, gst_rate numeric(5,2) not null default 0, tax_amount numeric(14,2) not null default 0, line_total numeric(14,2) not null
);
create table if not exists public.stock_movements (
 id uuid primary key default gen_random_uuid(), product_id uuid not null references public.products(id), movement_type text not null check(movement_type in ('ADD','REMOVE','SALE','ADJUSTMENT')),
 quantity numeric(14,3) not null, balance_after numeric(14,3) not null, reason text, invoice_id uuid references public.invoices(id), created_at timestamptz not null default now()
);
create table if not exists public.farm_settings (
 id uuid primary key default gen_random_uuid(), business_name text not null default 'SAFARI FARM & HATCHERY', tagline text, address text, phone text, email text, gstin text,
 bank_name text, account_name text, account_no text, ifsc text, branch text, upi_id text, logo_url text, signature_url text, notes text, terms text, updated_at timestamptz not null default now()
);
-- Compatibility for a farm_settings table created by an older setup.
alter table public.farm_settings add column if not exists business_name text default 'SAFARI FARM & HATCHERY';
alter table public.farm_settings add column if not exists tagline text;
alter table public.farm_settings add column if not exists address text;
alter table public.farm_settings add column if not exists phone text;
alter table public.farm_settings add column if not exists email text;
alter table public.farm_settings add column if not exists gstin text;
alter table public.farm_settings add column if not exists bank_name text;
alter table public.farm_settings add column if not exists account_name text;
alter table public.farm_settings add column if not exists account_no text;
alter table public.farm_settings add column if not exists ifsc text;
alter table public.farm_settings add column if not exists branch text;
alter table public.farm_settings add column if not exists upi_id text;
alter table public.farm_settings add column if not exists logo_url text;
alter table public.farm_settings add column if not exists signature_url text;
alter table public.farm_settings add column if not exists notes text;
alter table public.farm_settings add column if not exists terms text;
alter table public.farm_settings add column if not exists updated_at timestamptz default now();
insert into public.farm_settings(business_name)
select 'SAFARI FARM & HATCHERY'
where not exists (select 1 from public.farm_settings);
create index if not exists customers_name_idx on public.customers(name);
create index if not exists products_name_idx on public.products(name);
create index if not exists invoices_date_idx on public.invoices(invoice_date desc);
create index if not exists stock_product_idx on public.stock_movements(product_id,created_at desc);

create sequence if not exists public.invoice_seq start 1;
create sequence if not exists public.process_seq start 1;
create sequence if not exists public.inquiry_seq start 1;
create or replace function public.number_for(prefix text, seq_name text) returns text language plpgsql security definer set search_path=public as $$
declare n bigint; begin execute format('select nextval(%L)',seq_name) into n; return prefix||'-'||extract(year from current_date)::int||'-'||lpad(n::text,4,'0'); end $$;

create or replace function public.adjust_stock(p_product_id uuid,p_quantity numeric,p_reason text default 'Manual adjustment') returns void language plpgsql security definer set search_path=public as $$
declare new_balance numeric; begin
 update products set current_stock=current_stock+p_quantity,updated_at=now() where id=p_product_id and current_stock+p_quantity>=0 returning current_stock into new_balance;
 if new_balance is null then raise exception 'Not enough stock or product not found'; end if;
 insert into stock_movements(product_id,movement_type,quantity,balance_after,reason) values(p_product_id,case when p_quantity>=0 then 'ADD' else 'REMOVE' end,p_quantity,new_balance,p_reason);
end $$;

create or replace function public.create_invoice(p_invoice jsonb,p_items jsonb) returns uuid language plpgsql security definer set search_path=public as $$
declare new_id uuid:=gen_random_uuid(); item jsonb; bal numeric; begin
 insert into invoices(id,invoice_no,process_no,inquiry_no,customer_id,invoice_date,subtotal,tax_total,grand_total,amount_paid,payment_status,notes)
 values(new_id,number_for('SFH','public.invoice_seq'),number_for('PR','public.process_seq'),number_for('INQ','public.inquiry_seq'),(p_invoice->>'customer_id')::uuid,(p_invoice->>'invoice_date')::date,(p_invoice->>'subtotal')::numeric,(p_invoice->>'tax_total')::numeric,(p_invoice->>'grand_total')::numeric,(p_invoice->>'amount_paid')::numeric,p_invoice->>'payment_status',p_invoice->>'notes');
 for item in select * from jsonb_array_elements(p_items) loop
  update products set current_stock=current_stock-(item->>'quantity')::numeric,updated_at=now() where id=(item->>'product_id')::uuid and current_stock>=(item->>'quantity')::numeric returning current_stock into bal;
  if bal is null then raise exception 'Insufficient stock for %',item->>'description'; end if;
  insert into invoice_items(invoice_id,product_id,description,hsn,quantity,unit,rate,discount,gst_rate,tax_amount,line_total) values(new_id,(item->>'product_id')::uuid,item->>'description',item->>'hsn',(item->>'quantity')::numeric,item->>'unit',(item->>'rate')::numeric,(item->>'discount')::numeric,(item->>'gst_rate')::numeric,(item->>'tax_amount')::numeric,(item->>'line_total')::numeric);
  insert into stock_movements(product_id,movement_type,quantity,balance_after,reason,invoice_id) values((item->>'product_id')::uuid,'SALE',-(item->>'quantity')::numeric,bal,'Invoice sale',new_id);
 end loop; return new_id;
end $$;

alter table public.customers enable row level security; alter table public.products enable row level security; alter table public.invoices enable row level security; alter table public.invoice_items enable row level security; alter table public.stock_movements enable row level security; alter table public.farm_settings enable row level security;
-- Beginner single-business policy. Add Supabase Auth before exposing this publicly to multiple users.
create policy "anon customers" on public.customers for all to anon using(true) with check(true);
create policy "anon products" on public.products for all to anon using(true) with check(true);
create policy "anon invoices" on public.invoices for all to anon using(true) with check(true);
create policy "anon invoice_items" on public.invoice_items for all to anon using(true) with check(true);
create policy "anon stock" on public.stock_movements for all to anon using(true) with check(true);
create policy "anon settings" on public.farm_settings for all to anon using(true) with check(true);
grant execute on function public.adjust_stock(uuid,numeric,text) to anon,authenticated;
grant execute on function public.create_invoice(jsonb,jsonb) to anon,authenticated;
