# ROMAN: the dental lab operating system (demo)

A static demo. No server, no build step. All data is fictional and lives in your browser (localStorage). It is not a secure system for real patient records.

## Files
- `index.html` is the whole app (HTML, CSS and JavaScript, no dependencies except Google Fonts)
- `supabase/schema.sql` is the production database design with Row-Level Security (untested against a live database)
- `.github/workflows/pages.yml` deploys to GitHub Pages on every push to `main`

## Run locally
Open `index.html` in a browser, or run `python3 -m http.server 8000` and visit http://localhost:8000.

## Create a new repo and deploy
1. Create an empty repo on GitHub (any name).
2. Put these files in a folder, then:
   ```
   git init && git add . && git commit -m "ROMAN demo"
   git branch -M main
   git remote add origin https://github.com/<you>/<repo>.git
   git push -u origin main
   ```
3. In the repo go to Settings, then Pages, and set Source to "GitHub Actions". The workflow publishes to `https://<you>.github.io/<repo>/`.
4. Page refresh works because the app uses `#/` routes. No base path is needed.

## Test checklist (about 5 minutes)
1. Admin: Dashboard numbers match Cases, Invoices and Payroll pages.
2. New case: tap teeth with different restoration types, submit, open the case, assign a technician, advance stages.
3. Cases, Kanban view: drag a card one stage forward.
4. Technician role: Start, Pause, Finish stage.
5. Advance a case to Ready for dispatch, then switch to Rider and confirm pickup and delivery with a receiver name.
6. Admin, Invoices: generate an invoice from a case, then record a partial payment.
7. Admin, Payroll: mark attendance, add an adjustment (the approval resets), approve, check the audit log.
8. Sidebar: switch light or dark, then Reset demo data.

## What the backend adds (and the demo cannot do)
| Need | Demo today | With Supabase |
|---|---|---|
| Sign-in | Role dropdown | Email and Google sign-in, one membership per user |
| Data isolation | None | Row-Level Security on `tenant_id`, role-restricted policies (see schema) |
| Persistence | One browser | Shared, backed-up Postgres |
| Dental files | None | Private storage bucket, signed URLs, size and type checks |
| Rules enforced | In the page | Database policies, triggers and server functions |
| Notifications | On-screen text | Email or WhatsApp from server functions |
| Audit trail | In-memory list | Insert-only `audit_logs` |

Suggested order: (1) Supabase project, run `schema.sql`, seed one tenant; (2) swap `save()` and the state loaders for Supabase calls, one entity at a time, starting with cases; (3) file uploads; (4) invoices and payments; (5) payroll and rider GPS (only with consent).

## Honest limits
Payroll and invoicing are simple demo rules, not accounting. Mock GPS is simulated. Do not claim HIPAA or similar compliance without a real assessment. Never put real patient data in this public static repo.
