# Safari Farm & Hatchery — Fresh Billing App

This folder is the complete clean version. Do not mix old JavaScript or SQL files with it.

## One-time Supabase setup

1. Open Supabase > SQL Editor > New query.
2. Copy all text from `supabase-setup.sql`, paste it, then press **Run** once.
3. Authentication > Users: keep/create your email user and password.

The fresh database uses only tables starting with `sf_`, so old broken tables do not conflict.

## GitHub Pages deployment

1. Delete the old files from your local GitHub repository folder.
2. Copy only these files into the repository root: `.nojekyll`, `index.html`, `styles.css`, `app.js`, `config.js`, `logo.png`, `sw.js`, `supabase-setup.sql`, `README.md`.
3. In GitHub Desktop: commit, then **Push origin**.
4. GitHub Settings > Pages: `main` and `/(root)`.
5. Open `https://safarifarm.github.io/safari-farm-billing-/` in a new Incognito window.

No service worker is included, so the previous continuous reload/cache problem cannot be caused by this version.

## Product modes

- **Saved stock product:** selected from product master; issuing invoice automatically reduces stock.
- **Custom/non-stock item:** type product/service name, HSN, quantity, rate and GST directly on the invoice; it does not affect stock.

Cancelling an issued invoice restores only its saved-stock items. Custom items never change stock.
