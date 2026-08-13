-- Safari Farm legacy database compatibility fix. Safe to run repeatedly.
alter table public.products add column if not exists owner_id uuid default auth.uid(), add column if not exists description text, add column if not exists hsn_sac text, add column if not exists unit text default 'Nos', add column if not exists rate numeric(14,2) default 0, add column if not exists gst_rate numeric(6,2) default 0, add column if not exists stock_qty numeric(14,3) default 0, add column if not exists low_stock_level numeric(14,3) default 10, add column if not exists updated_at timestamptz default now();
alter table public.customers add column if not exists owner_id uuid default auth.uid(), add column if not exists customer_type text default 'NON-GST', add column if not exists email text, add column if not exists gstin text, add column if not exists address text, add column if not exists state text, add column if not exists district text, add column if not exists pincode text, add column if not exists updated_at timestamptz default now();
alter table public.invoices add column if not exists owner_id uuid default auth.uid(), add column if not exists invoice_type text default 'TAX INVOICE', add column if not exists process_no text, add column if not exists enquiry_no text, add column if not exists valid_till date, add column if not exists ref_no text, add column if not exists freight numeric(14,2) default 0, add column if not exists status text default 'ISSUED', add column if not exists customer_name text, add column if not exists customer_type text, add column if not exists customer_gstin text, add column if not exists customer_phone text, add column if not exists customer_address text, add column if not exists customer_state text, add column if not exists customer_district text, add column if not exists customer_pincode text, add column if not exists subtotal numeric(14,2) default 0, add column if not exists tax_total numeric(14,2) default 0, add column if not exists grand_total numeric(14,2) default 0, add column if not exists notes text, add column if not exists updated_at timestamptz default now();

do $$
declare v_table text;
begin
  foreach v_table in array array['products','customers','invoices','farm_settings','stock_adjustments'] loop
    if exists(select 1 from information_schema.columns c where c.table_schema='public' and c.table_name=v_table and c.column_name='user_id') then
      execute format('alter table public.%I alter column user_id set default auth.uid()',v_table);
    end if;
  end loop;
end $$;

notify pgrst, 'reload schema';

do $$
declare v_table text;
begin
  foreach v_table in array array['invoices','invoice_items','stock_adjustments'] loop
    if exists(select 1 from information_schema.columns c where c.table_schema='public' and c.table_name=v_table and c.column_name='user_id') then
      execute format('alter table public.%I alter column user_id set default auth.uid()',v_table);
    end if;
  end loop;
end $$;
