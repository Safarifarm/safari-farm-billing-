-- Require Supabase email/password authentication for all farm data.
drop policy if exists "sfh anon customers" on public.sfh_customers;
drop policy if exists "sfh anon products" on public.sfh_products;
drop policy if exists "sfh anon invoices" on public.sfh_invoices;
drop policy if exists "sfh anon items" on public.sfh_invoice_items;
drop policy if exists "sfh anon stock" on public.sfh_stock_movements;
drop policy if exists "sfh anon settings" on public.sfh_settings;

drop policy if exists "sfh authenticated customers" on public.sfh_customers;
drop policy if exists "sfh authenticated products" on public.sfh_products;
drop policy if exists "sfh authenticated invoices" on public.sfh_invoices;
drop policy if exists "sfh authenticated items" on public.sfh_invoice_items;
drop policy if exists "sfh authenticated stock" on public.sfh_stock_movements;
drop policy if exists "sfh authenticated settings" on public.sfh_settings;

create policy "sfh authenticated customers" on public.sfh_customers for all to authenticated using(true) with check(true);
create policy "sfh authenticated products" on public.sfh_products for all to authenticated using(true) with check(true);
create policy "sfh authenticated invoices" on public.sfh_invoices for all to authenticated using(true) with check(true);
create policy "sfh authenticated items" on public.sfh_invoice_items for all to authenticated using(true) with check(true);
create policy "sfh authenticated stock" on public.sfh_stock_movements for all to authenticated using(true) with check(true);
create policy "sfh authenticated settings" on public.sfh_settings for all to authenticated using(true) with check(true);

revoke all on function public.sfh_adjust_stock(uuid,numeric,text) from public,anon;
revoke all on function public.sfh_create_invoice(jsonb,jsonb) from public,anon;
revoke all on function public.sfh_update_invoice(uuid,jsonb,jsonb) from public,anon;
grant execute on function public.sfh_adjust_stock(uuid,numeric,text) to authenticated;
grant execute on function public.sfh_create_invoice(jsonb,jsonb) to authenticated;
grant execute on function public.sfh_update_invoice(uuid,jsonb,jsonb) to authenticated;

drop policy if exists "sfh product images upload" on storage.objects;
drop policy if exists "sfh product images update" on storage.objects;
drop policy if exists "sfh product images delete" on storage.objects;
create policy "sfh product images upload" on storage.objects for insert to authenticated with check(bucket_id='product-images');
create policy "sfh product images update" on storage.objects for update to authenticated using(bucket_id='product-images') with check(bucket_id='product-images');
create policy "sfh product images delete" on storage.objects for delete to authenticated using(bucket_id='product-images');
