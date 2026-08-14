-- Three price levels, three invoice totals, and product image uploads.
alter table public.sfh_products add column if not exists purchase_price numeric(14,2) not null default 0;
alter table public.sfh_products add column if not exists extra_price numeric(14,2) not null default 0;
alter table public.sfh_products add column if not exists image_url text;
alter table public.sfh_invoices add column if not exists buy_total numeric(14,2) not null default 0;
alter table public.sfh_invoices add column if not exists selling_total numeric(14,2) not null default 0;
alter table public.sfh_invoices add column if not exists extra_total numeric(14,2) not null default 0;
alter table public.sfh_invoice_items add column if not exists purchase_rate numeric(14,2) not null default 0;
alter table public.sfh_invoice_items add column if not exists selling_rate numeric(14,2) not null default 0;
alter table public.sfh_invoice_items add column if not exists extra_rate numeric(14,2) not null default 0;
alter table public.sfh_invoice_items add column if not exists buy_line_total numeric(14,2) not null default 0;
alter table public.sfh_invoice_items add column if not exists selling_line_total numeric(14,2) not null default 0;
alter table public.sfh_invoice_items add column if not exists extra_line_total numeric(14,2) not null default 0;

insert into storage.buckets(id,name,public) values('product-images','product-images',true) on conflict(id) do update set public=true;
drop policy if exists "sfh product images read" on storage.objects;
drop policy if exists "sfh product images upload" on storage.objects;
drop policy if exists "sfh product images update" on storage.objects;
drop policy if exists "sfh product images delete" on storage.objects;
create policy "sfh product images read" on storage.objects for select to public using(bucket_id='product-images');
create policy "sfh product images upload" on storage.objects for insert to anon,authenticated with check(bucket_id='product-images');
create policy "sfh product images update" on storage.objects for update to anon,authenticated using(bucket_id='product-images') with check(bucket_id='product-images');
create policy "sfh product images delete" on storage.objects for delete to anon,authenticated using(bucket_id='product-images');

create or replace function public.sfh_create_invoice(p_invoice jsonb,p_items jsonb) returns uuid language plpgsql security definer set search_path=public as $$
declare nid uuid:=gen_random_uuid();it jsonb;b numeric;pid uuid;
begin
 insert into sfh_invoices(id,invoice_type,invoice_no,process_no,inquiry_no,customer_id,customer_snapshot,invoice_date,buy_total,selling_total,extra_total,subtotal,tax_total,grand_total,amount_paid,payment_status,notes)
 values(nid,coalesce(p_invoice->>'invoice_type','Proforma Invoice'),sfh_number_for('SFH','sfh_invoice_seq'),sfh_number_for('PR','sfh_process_seq'),sfh_number_for('INQ','sfh_inquiry_seq'),nullif(p_invoice->>'customer_id','')::uuid,p_invoice->'customer_snapshot',(p_invoice->>'invoice_date')::date,coalesce((p_invoice->>'buy_total')::numeric,0),coalesce((p_invoice->>'selling_total')::numeric,0),coalesce((p_invoice->>'extra_total')::numeric,0),(p_invoice->>'subtotal')::numeric,(p_invoice->>'tax_total')::numeric,(p_invoice->>'grand_total')::numeric,(p_invoice->>'amount_paid')::numeric,p_invoice->>'payment_status',p_invoice->>'notes');
 for it in select * from jsonb_array_elements(p_items) loop
  pid:=nullif(it->>'product_id','')::uuid;
  if pid is not null then
   update sfh_products set current_stock=current_stock-(it->>'quantity')::numeric where id=pid and current_stock>=(it->>'quantity')::numeric returning current_stock into b;
   if b is null then raise exception 'Insufficient stock for %',it->>'description';end if;
   insert into sfh_stock_movements(product_id,movement_type,quantity,balance_after,reason,invoice_id) values(pid,'SALE',-(it->>'quantity')::numeric,b,'Invoice sale',nid);
  end if;
  insert into sfh_invoice_items(invoice_id,product_id,description,hsn,quantity,unit,purchase_rate,selling_rate,extra_rate,rate,discount,gst_rate,tax_amount,buy_line_total,selling_line_total,extra_line_total,line_total)
  values(nid,pid,it->>'description',it->>'hsn',(it->>'quantity')::numeric,it->>'unit',coalesce((it->>'purchase_rate')::numeric,0),coalesce((it->>'selling_rate')::numeric,0),coalesce((it->>'extra_rate')::numeric,0),(it->>'rate')::numeric,(it->>'discount')::numeric,(it->>'gst_rate')::numeric,(it->>'tax_amount')::numeric,coalesce((it->>'buy_line_total')::numeric,0),coalesce((it->>'selling_line_total')::numeric,0),coalesce((it->>'extra_line_total')::numeric,0),(it->>'line_total')::numeric);
 end loop;return nid;
end $$;
grant execute on function public.sfh_create_invoice(jsonb,jsonb) to anon,authenticated;
