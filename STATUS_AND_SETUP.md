# ROMAN: status against the original brief, and cloud setup

## Status
| Brief item | State |
|---|---|
| Role views (admin, doctor, technician, rider) | Done, via a demo role switch. Not real access control |
| Dashboard, cases (table and Kanban with drag), case detail, FDI tooth chart with per-tooth types | Done |
| Technician timer and productivity, dispatch with proof of delivery, simple invoices and part-payments | Done (simple rules) |
| Payroll with approval and audit log, attendance | Done as a demo of the calculation. Not a payroll system |
| Analytics with defined formulas and clinic/technician filters | Done (date and category filters not yet) |
| Mobile layout, light and dark | Done in this version (bottom tab bar on phones) |
| Sign-in and shared cloud data | Built, **untested**: needs your Supabase project (below) |
| Real tenant isolation | Tenant level only. Role rules inside a lab are NOT enforced in cloud mode yet |
| File uploads (STL, PLY, photos), signed URLs | Not built |
| Doctor notifications (email or WhatsApp), real GPS, expenses screen, doctor statements | Not built |
| Configurable workflows per lab, multi-currency, subscriptions | Schema only |

## Turn on cloud mode (about 15 minutes)
1. Create a free project at supabase.com.
2. SQL Editor: run `supabase/schema.sql`, then `supabase/002_cloud_bridge.sql`. Fix any errors it reports before continuing.
3. Authentication, Providers: email is on by default. For Google, create an OAuth client in Google Cloud and paste its ID and secret.
4. Authentication, URL Configuration: set Site URL and a redirect URL to your page, e.g. `https://bilalraiss.github.io/Romaan/`.
5. Project Settings, API: copy the Project URL and the anon (publishable) key into `config.js`. Never use the service_role key.
6. Commit `config.js` and `index.html`. After deploy, the page shows a sign-in screen. First sign-in asks for a lab name and creates your workspace with the demo data.

## What to do with the schema
- `schema.sql` is the **target design**: normalised tables with tenant isolation and role policies. The running app does not use most of it yet.
- `app_state` is a **temporary bridge** that lets today's UI save to the cloud. Every member of a lab can read all of it, so use fictional data only.
- Migrate one entity at a time into the real tables, in this order: cases and units, then clinics and doctors, then invoices and payments, then files, then payroll. After each one, delete that part from `app_state`. Add automated tests for the RLS policies (a doctor must not see another clinic's case).
- Before any real patient data: finish role enforcement in the database, private file bucket with signed URLs, backups, and a privacy review. Do not claim HIPAA or similar compliance without a formal assessment.
