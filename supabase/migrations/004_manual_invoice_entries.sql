-- Enables one-time manual customers and products directly on an invoice.
alter table public.sfh_invoices alter column customer_id drop not null;
alter table public.sfh_invoices add column if not exists customer_snapshot jsonb;

create or replace function public.sfh_create_invoice(p_invoice jsonb,p_items jsonb) returns uuid language plpgsql security definer set search_path=public as $$
declare nid uuid:=gen_random_uuid();it jsonb;b numeric;pid uuid;
begin
 insert into sfh_invoices(id,invoice_no,process_no,inquiry_no,customer_id,customer_snapshot,invoice_date,subtotal,tax_total,grand_total,amount_paid,payment_status,notes)
 values(nid,sfh_number_for('SFH','sfh_invoice_seq'),sfh_number_for('PR','sfh_process_seq'),sfh_number_for('INQ','sfh_inquiry_seq'),nullif(p_invoice->>'customer_id','')::uuid,p_invoice->'customer_snapshot',(p_invoice->>'invoice_date')::date,(p_invoice->>'subtotal')::numeric,(p_invoice->>'tax_total')::numeric,(p_invoice->>'grand_total')::numeric,(p_invoice->>'amount_paid')::numeric,p_invoice->>'payment_status',p_invoice->>'notes');
 for it in select * from jsonb_array_elements(p_items) loop
  pid:=nullif(it->>'product_id','')::uuid;
  if pid is not null then
   update sfh_products set current_stock=current_stock-(it->>'quantity')::numeric where id=pid and current_stock>=(it->>'quantity')::numeric returning current_stock into b;
   if b is null then raise exception 'Insufficient stock for %',it->>'description';end if;
   insert into sfh_stock_movements(product_id,movement_type,quantity,balance_after,reason,invoice_id) values(pid,'SALE',-(it->>'quantity')::numeric,b,'Invoice sale',nid);
  end if;
  insert into sfh_invoice_items(invoice_id,product_id,description,hsn,quantity,unit,rate,discount,gst_rate,tax_amount,line_total)
  values(nid,pid,it->>'description',it->>'hsn',(it->>'quantity')::numeric,it->>'unit',(it->>'rate')::numeric,(it->>'discount')::numeric,(it->>'gst_rate')::numeric,(it->>'tax_amount')::numeric,(it->>'line_total')::numeric);
 end loop;return nid;
end $$;
grant execute on function public.sfh_create_invoice(jsonb,jsonb) to anon,authenticated;
