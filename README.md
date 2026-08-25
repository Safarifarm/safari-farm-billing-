# Safari Farm & Hatchery — Invoice & Stock Management

A complete responsive React/Vite application for customers, products, stock, invoicing, payments and print-ready A4 proforma invoices. It opens with sample data until Supabase is connected.

## What is included

- Dashboard with sales, dues, stock and low-stock alerts
- GST / Non-GST customers with add, edit, delete and search
- Products with price, HSN, GST, unit and low-stock threshold
- Manual stock add/remove and a permanent stock movement log
- Atomic invoice creation: invoice and items save together, stock reduces automatically, and the whole action rolls back if stock is insufficient
- Automatic invoice, process and inquiry numbers
- Paid, partial and unpaid status with balance due
- Farm, bank, UPI, logo and signature settings
- Responsive screen UI and print-friendly A4 proforma invoice

## 1. Connect your existing Supabase project

1. Open your Supabase dashboard and select the existing project.
2. Open **SQL Editor → New query**.
3. Copy all of `supabase/migrations/002_clean_sfh_schema.sql`, paste it into an empty query, and click **Run** once. Its unique `sfh_` names do not conflict with older tables. Then run migrations `003` through `008` once, in numeric order.
4. Open **Project Settings → API** (or **Connect**) and copy the **Project URL** and **publishable/anon key**. Never use the service-role or secret key in this website.
5. In this project folder, make a copy of `.env.example` named `.env`.
6. Replace the two example values in `.env` with your Project URL and publishable/anon key.

If old tables already exist with different names, this migration leaves them untouched.

## 2. Run on your computer

Install Node.js 20 or newer. Open Terminal/Command Prompt inside this folder and run:

```bash
npm install
npm run dev
```

Open the local address shown in the terminal (usually `http://localhost:5173`). Stop it with `Ctrl+C`.

## 3. First-time setup inside the app

1. Open **Farm Settings** and enter the farm address, GSTIN and bank details.
2. Optional: add public HTTPS image URLs for the logo and signature.
3. Add customers and products.
4. Use **Stock → Adjust stock** to enter opening quantities.
5. Create an invoice. Use **Print / Save PDF** on the finished invoice.

## 4. Push to GitHub

Create a new empty repository on GitHub. In this project folder run:

```bash
git init
git add .
git commit -m "Safari Farm billing system"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
git push -u origin main
```

The `.env` file is ignored and will not be uploaded.

## 5. Deploy with Vercel

1. Sign in at Vercel and choose **Add New → Project**.
2. Import the GitHub repository.
3. Framework preset should be **Vite**. Build command: `npm run build`; output directory: `dist`.
4. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` under **Environment Variables**.
5. Click **Deploy**.

For Netlify, import the same repository, use `npm run build` and publish `dist`, then add the same environment variables.

## 6. Connect a custom domain

In Vercel open **Project → Settings → Domains**, enter the domain, and follow the shown DNS instructions at your domain provider. Usually this means adding one A record or CNAME. HTTPS is issued automatically after DNS verification.

## Important security note

The supplied policies are intentionally simple for one private business. Before sharing the app publicly, add Supabase Authentication and restrict policies to signed-in staff. Do not store a Supabase secret/service-role key in `.env` or browser code.

## Production build

```bash
npm run build
npm run preview
```

## Final business upgrade (required once)

Supabase **SQL Editor → New query** mein in files ko number order mein poora run karein:

1. `supabase/migrations/013_business_payment_details.sql`
2. `supabase/migrations/014_edit_purchase_and_sale_invoice.sql`

Is upgrade ke baad Customer/Sale invoice stock ghataata hai, Self/Purchase invoice stock badhaata hai, saved invoices safely edit hote hain, aur payment method/reference/due-date cloud mein save hote hain.
