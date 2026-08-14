-- Run once to add the customer address fields shown on the reference invoice.
alter table public.sfh_customers add column if not exists district_city text;
alter table public.sfh_customers add column if not exists pincode text;
