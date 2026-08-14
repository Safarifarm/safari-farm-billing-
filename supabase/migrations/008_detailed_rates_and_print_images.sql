-- Keeps a product image snapshot on invoice items for reliable printing.
alter table public.sfh_invoice_items add column if not exists image_url text;

create or replace function public.sfh_copy_invoice_product_image() returns trigger
language plpgsql security definer set search_path=public as $$
begin
 if new.image_url is null and new.product_id is not null then
  select image_url into new.image_url from public.sfh_products where id=new.product_id;
 end if;
 return new;
end $$;

drop trigger if exists sfh_invoice_item_image_snapshot on public.sfh_invoice_items;
create trigger sfh_invoice_item_image_snapshot before insert on public.sfh_invoice_items
for each row execute function public.sfh_copy_invoice_product_image();
