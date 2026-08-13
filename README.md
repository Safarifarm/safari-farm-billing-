# Safari Farm & Hatchery Billing + Stock

Private, mobile-friendly billing, customer and inventory app. Data is stored in Supabase and stays synced between PC and phone. Invoice issuing, editing and cancelling are atomic database operations, so stock stays correct even if a request fails.

## 1. Set up Supabase (one time)

1. Open your Supabase project: `fwzsrjatdoviiyggtpgt`.
2. Go to **SQL Editor → New query**.
3. Copy all of `supabase-migration.sql`, paste it and press **Run**. It is designed to preserve existing tables and add missing fields.
4. Go to **Authentication → Users → Add user**. Create the single email/password account you will use.
5. Do not put a secret or service-role key in this project. `config.js` contains only the browser-safe publishable key; Row Level Security protects every record by logged-in owner.

For a database created by an older Safari Farm version, also run `FINAL-DATABASE-FIX.sql` once after the main migration.

If your Supabase URL/key changes, edit only `config.js`.

## 2. Test locally

Opening `index.html` directly can block service-worker features. Run any simple static web server in this folder, then open its local address. Sign in using the Supabase user created above.

Before real use, verify this sequence: add a product with stock 10 → issue quantity 2 → stock becomes 8 → edit to quantity 3 → stock becomes 7 → cancel → stock returns to 10.

## 3. Publish on GitHub Pages

1. Open the GitHub repository `safari-farm-billing-` (or create `safari-farm-billing`).
2. Upload the contents of this folder to the repository root. Upload the files themselves, not the containing folder.
3. Commit to `main`.
4. Open **Settings → Pages**.
5. Select **Deploy from a branch**, branch **main**, folder **/(root)**, then **Save**.
6. Wait for the green deployment confirmation and open the Pages address.

The repository may be public because no database password or privileged Supabase key is included. The app itself remains protected by Supabase sign-in and owner-only database policies. If your GitHub plan supports Pages from a private repository, keeping the repository private is preferable.

## 4. Custom domain

### Subdomain (recommended)

For `billing.yourdomain.com`:

1. Rename `CNAME.example` to `CNAME` and put only `billing.yourdomain.com` inside.
2. At your domain provider, create a CNAME record: name `billing`, value `YOUR-GITHUB-USERNAME.github.io`.
3. In GitHub **Settings → Pages → Custom domain**, enter the same subdomain.
4. After DNS is verified, enable **Enforce HTTPS**.

### Main/root domain

Put the root domain in `CNAME`, add GitHub Pages' current official apex-domain DNS records at your DNS provider, then enter the domain in GitHub Pages settings. Check GitHub's current documentation before setting these records because hosting addresses can change.

## Daily use

- Add products with HSN/SAC, unit, GST, rate, opening stock and low-stock level.
- Use **Adjust** for purchases, mortality, correction or other manual changes; always enter the reason.
- Add GST or non-GST customers.
- Create and issue an invoice. Stock is reduced only when the invoice saves successfully.
- Editing first restores the old quantities, validates the revised lines, then applies them in one transaction.
- Cancelling restores all invoice stock and keeps the invoice as an audit record.
- Open an invoice and use **Print / Save PDF**. Browser print uses the same A4 HTML/CSS template shown in preview.
- The supplied Safari Farm logo is embedded in the invoice as `logo-source.png`; it is clipped from the exact provided reference so the crest and wording remain unchanged.

## Important safeguards

- Never share your Supabase password.
- Never add a Supabase `service_role` or secret key to `config.js`.
- Do not manually edit issued invoice rows in Supabase; use the app so stock history remains correct.
- Export periodic database backups from Supabase.
