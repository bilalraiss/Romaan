-- Run AFTER schema.sql, in a staging project first. Untested against a live database.

-- 1. Close gaps in schema.sql: these tables had no RLS, and Supabase exposes every public table through its API.
alter table tenants enable row level security;
alter table memberships enable row level security;
alter table subscription_plans enable row level security;
create policy own_tenant on tenants for select using (id = current_tenant());
create policy own_membership on memberships for select using (user_id = auth.uid());
create policy plans_read on subscription_plans for select to authenticated using (true);
-- (no insert/update policies on tenants or memberships: they change only through the functions below)

-- 2. Bridge table: stores the demo app's whole state per lab so the existing UI works across devices after sign-in.
-- Every member of a lab can read and write all of it. This is for demos with fictional data, NOT real patient records.
create table app_state(tenant_id uuid primary key references tenants on delete cascade, state jsonb not null, updated_by uuid, updated_at timestamptz default now());
alter table app_state enable row level security;
create policy app_state_rw on app_state using (tenant_id = current_tenant()) with check (tenant_id = current_tenant());

-- 3. Functions the page calls
create function my_tenant() returns uuid language sql stable security definer set search_path = public as $$ select current_tenant() $$;
create function bootstrap_tenant(lab_name text) returns uuid language plpgsql security definer set search_path = public as $$
declare t uuid;
begin
  if auth.uid() is null then raise exception 'Not signed in'; end if;
  if exists (select 1 from memberships where user_id = auth.uid()) then raise exception 'You already belong to a workspace'; end if;
  insert into tenants(name) values (left(lab_name, 60)) returning id into t;
  insert into memberships(user_id, tenant_id, role) values (auth.uid(), t, 'owner');
  return t;
end $$;
revoke all on function bootstrap_tenant(text), my_tenant() from public, anon;
grant execute on function bootstrap_tenant(text), my_tenant() to authenticated;
