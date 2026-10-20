-- REVIEW ONLY: run in the exact Ghumne development SQL Editor, never a project list.
-- Catalog queries only. This does not apply a migration or enable an extension.
begin read only;
select current_database() as database_name, current_user as migration_role,
  current_setting('server_version') as postgres_version,
  current_setting('server_version_num')::integer>=170000 as postgres_17_or_later;
select to_regclass('auth.users') is not null as auth_users_available,
  to_regprocedure('auth.uid()') is not null as auth_uid_available,
  has_schema_privilege(current_user,'public','CREATE') as can_create_public_objects;
select rolname, rolbypassrls from pg_catalog.pg_roles
where rolname in ('anon','authenticated','service_role');
select nspname from pg_catalog.pg_namespace where nspname='private';
-- An empty result is required for the new application schema.
select n.nspname as schema_name,c.relname as existing_relation
from pg_catalog.pg_class c join pg_catalog.pg_namespace n on n.oid=c.relnamespace
where n.nspname in ('public','private') and c.relkind in ('r','p','v','m','f')
order by n.nspname,c.relname;
select e.extname,e.extversion,n.nspname as installed_schema
from pg_catalog.pg_extension e join pg_catalog.pg_namespace n on n.oid=e.extnamespace
where e.extname in ('btree_gist','pgtap');
select name,default_version,installed_version from pg_catalog.pg_available_extensions
where name in ('btree_gist','pgtap');
select to_regclass('supabase_migrations.schema_migrations') is not null as migration_history_exists;
-- Database name/role alone do NOT establish the Supabase project reference.
rollback;
