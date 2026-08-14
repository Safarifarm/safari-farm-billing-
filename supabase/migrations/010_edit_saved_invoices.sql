-- Edit a saved invoice while restoring old stock and applying the new item quantities.
create or replace function public.sfh_update_invoice(p_invoice_id uuid,p_invoice jsonb,p_items jsonb)
returns uuid language plpgsql security definer set search_path=public as $$
declare it jsonb; old_item record; pid uuid; balance numeric;
begin
 for old_item in select product_id,quantity from sfh_invoice_items where invoice_id=p_invoice_id and product_id is not null loop
  update sfh_products set current_stock=current_stock+old_item.quantity where id=old_item.product_id;
 end loop;
 delete from sfh_stock_movements where invoice_id=p_invoice_id;
 delete from sfh_invoice_items where invoice_id=p_invoice_id;

 update sfh_invoices set
  invoice_type=coalesce(p_invoice->>'invoice_type','Proforma Invoice'),
  pricing_mode=coalesce(p_invoice->>'pricing_mode','Simple Selling'),
  customer_id=nullif(p_invoice->>'customer_id','')::uuid,
  customer_snapshot=p_invoice->'customer_snapshot',
  invoice_date=(p_invoice->>'invoice_date')::date,
  buy_total=coalesce((p_invoice->>'buy_total')::numeric,0),
  stand_total=coalesce((p_invoice->>'stand_total')::numeric,0),
  selling_total=coalesce((p_invoice->>'selling_total')::numeric,0),
  discount_total=coalesce((p_invoice->>'discount_total')::numeric,0),
  without_stand_total=coalesce((p_invoice->>'without_stand_total')::numeric,0),
  extra_total=coalesce((p_invoice->>'stand_total')::numeric,0),
  subtotal=(p_invoice->>'subtotal')::numeric,
  tax_total=(p_invoice->>'tax_total')::numeric,
  grand_total=(p_invoice->>'grand_total')::numeric,
  amount_paid=(p_invoice->>'amount_paid')::numeric,
  payment_status=p_invoice->>'payment_status',notes=p_invoice->>'notes'
 where id=p_invoice_id;
 if not found then raise exception 'Invoice not found'; end if;

 for it in select * from jsonb_array_elements(p_items) loop
  pid=nullif(it->>'product_id','')::uuid;
  if pid is not null then
   balance=null;
   update sfh_products set current_stock=current_stock-(it->>'quantity')::numeric
    where id=pid and current_stock>=(it->>'quantity')::numeric returning current_stock into balance;
   if balance is null then raise exception 'Insufficient stock for %',it->>'description'; end if;
  end if;
  insert into sfh_invoice_items(invoice_id,product_id,image_url,description,hsn,quantity,unit,purchase_rate,stand_rate,selling_rate,discount_rate,without_stand_rate,extra_rate,rate,discount,gst_rate,tax_amount,buy_line_total,stand_line_total,selling_line_total,discount_line_total,without_stand_line_total,extra_line_total,line_total)
  values(p_invoice_id,pid,it->>'image_url',it->>'description',it->>'hsn',(it->>'quantity')::numeric,it->>'unit',coalesce((it->>'purchase_rate')::numeric,0),coalesce((it->>'stand_rate')::numeric,0),coalesce((it->>'selling_rate')::numeric,0),coalesce((it->>'discount_rate')::numeric,0),coalesce((it->>'without_stand_rate')::numeric,0),coalesce((it->>'stand_rate')::numeric,0),(it->>'rate')::numeric,coalesce((it->>'discount')::numeric,0),(it->>'gst_rate')::numeric,(it->>'tax_amount')::numeric,coalesce((it->>'buy_line_total')::numeric,0),coalesce((it->>'stand_line_total')::numeric,0),coalesce((it->>'selling_line_total')::numeric,0),coalesce((it->>'discount_line_total')::numeric,0),coalesce((it->>'without_stand_line_total')::numeric,0),coalesce((it->>'stand_line_total')::numeric,0),(it->>'line_total')::numeric);
  if pid is not null then
   insert into sfh_stock_movements(product_id,movement_type,quantity,balance_after,reason,invoice_id)
   values(pid,'SALE',-(it->>'quantity')::numeric,balance,'Edited invoice sale',p_invoice_id);
  end if;
 end loop;
 return p_invoice_id;
end $$;

grant execute on function public.sfh_update_invoice(uuid,jsonb,jsonb) to anon,authenticated;
