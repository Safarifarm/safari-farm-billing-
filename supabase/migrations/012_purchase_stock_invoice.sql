-- Third invoice system: purchases increase stock; sales reduce stock.
alter table public.sfh_invoices add column if not exists profit_total numeric(14,2) not null default 0;
alter table public.sfh_invoice_items add column if not exists profit_line_total numeric(14,2) not null default 0;

create or replace function public.sfh_create_invoice(p_invoice jsonb,p_items jsonb) returns uuid language plpgsql security definer set search_path=public as $$
declare nid uuid:=gen_random_uuid();it jsonb;b numeric;pid uuid;is_purchase boolean:=coalesce(p_invoice->>'invoice_type','')='Purchase/Stock Invoice';
begin
 insert into sfh_invoices(id,invoice_type,pricing_mode,invoice_no,process_no,inquiry_no,customer_id,customer_snapshot,invoice_date,buy_total,stand_total,selling_total,discount_total,without_stand_total,profit_total,extra_total,subtotal,tax_total,grand_total,amount_paid,payment_status,notes)
 values(nid,coalesce(p_invoice->>'invoice_type','Proforma Invoice'),coalesce(p_invoice->>'pricing_mode','Simple Selling'),sfh_number_for('SFH','sfh_invoice_seq'),sfh_number_for('PR','sfh_process_seq'),sfh_number_for('INQ','sfh_inquiry_seq'),nullif(p_invoice->>'customer_id','')::uuid,p_invoice->'customer_snapshot',(p_invoice->>'invoice_date')::date,coalesce((p_invoice->>'buy_total')::numeric,0),coalesce((p_invoice->>'stand_total')::numeric,0),coalesce((p_invoice->>'selling_total')::numeric,0),coalesce((p_invoice->>'discount_total')::numeric,0),coalesce((p_invoice->>'without_stand_total')::numeric,0),coalesce((p_invoice->>'profit_total')::numeric,0),coalesce((p_invoice->>'stand_total')::numeric,0),(p_invoice->>'subtotal')::numeric,(p_invoice->>'tax_total')::numeric,(p_invoice->>'grand_total')::numeric,(p_invoice->>'amount_paid')::numeric,p_invoice->>'payment_status',p_invoice->>'notes');
 for it in select * from jsonb_array_elements(p_items) loop
  pid:=nullif(it->>'product_id','')::uuid;b:=null;
  if pid is not null then
   if is_purchase then
    update sfh_products set current_stock=current_stock+(it->>'quantity')::numeric where id=pid returning current_stock into b;
   else
    update sfh_products set current_stock=current_stock-(it->>'quantity')::numeric where id=pid and current_stock>=(it->>'quantity')::numeric returning current_stock into b;
   end if;
   if b is null then raise exception 'Insufficient stock or product missing for %',it->>'description';end if;
   insert into sfh_stock_movements(product_id,movement_type,quantity,balance_after,reason,invoice_id) values(pid,case when is_purchase then 'ADD' else 'SALE' end,case when is_purchase then (it->>'quantity')::numeric else -(it->>'quantity')::numeric end,b,case when is_purchase then 'Purchase invoice stock received' else 'Invoice sale' end,nid);
  end if;
  insert into sfh_invoice_items(invoice_id,product_id,image_url,description,hsn,quantity,unit,purchase_rate,stand_rate,selling_rate,discount_rate,without_stand_rate,extra_rate,rate,discount,gst_rate,tax_amount,buy_line_total,stand_line_total,selling_line_total,discount_line_total,without_stand_line_total,profit_line_total,extra_line_total,line_total)
  values(nid,pid,it->>'image_url',it->>'description',it->>'hsn',(it->>'quantity')::numeric,it->>'unit',coalesce((it->>'purchase_rate')::numeric,0),coalesce((it->>'stand_rate')::numeric,0),coalesce((it->>'selling_rate')::numeric,0),coalesce((it->>'discount_rate')::numeric,0),coalesce((it->>'without_stand_rate')::numeric,0),coalesce((it->>'stand_rate')::numeric,0),(it->>'rate')::numeric,coalesce((it->>'discount')::numeric,0),(it->>'gst_rate')::numeric,(it->>'tax_amount')::numeric,coalesce((it->>'buy_line_total')::numeric,0),coalesce((it->>'stand_line_total')::numeric,0),coalesce((it->>'selling_line_total')::numeric,0),coalesce((it->>'discount_line_total')::numeric,0),coalesce((it->>'without_stand_line_total')::numeric,0),coalesce((it->>'profit_line_total')::numeric,0),coalesce((it->>'stand_line_total')::numeric,0),(it->>'line_total')::numeric);
 end loop;return nid;
end $$;

revoke all on function public.sfh_create_invoice(jsonb,jsonb) from public,anon;
grant execute on function public.sfh_create_invoice(jsonb,jsonb) to authenticated;
