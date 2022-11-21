--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5 (Debian 14.5-1.pgdg110+1)
-- Dumped by pg_dump version 14.5 (Debian 14.5-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA "auth";


ALTER SCHEMA "auth" OWNER TO "supabase_admin";

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "extensions";


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA "graphql_public";


ALTER SCHEMA "graphql_public" OWNER TO "supabase_admin";

--
-- Name: pgsodium; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";


--
-- Name: postgis; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "postgis";


ALTER SCHEMA "postgis" OWNER TO "postgres";

--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA "realtime";


ALTER SCHEMA "realtime" OWNER TO "supabase_admin";

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA "storage";


ALTER SCHEMA "storage" OWNER TO "supabase_admin";

--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA "public";


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE "realtime"."action" AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE "realtime"."action" OWNER TO "supabase_admin";

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE "realtime"."equality_op" AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte'
);


ALTER TYPE "realtime"."equality_op" OWNER TO "supabase_admin";

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE "realtime"."user_defined_filter" AS (
	"column_name" "text",
	"op" "realtime"."equality_op",
	"value" "text"
);


ALTER TYPE "realtime"."user_defined_filter" OWNER TO "supabase_admin";

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE "realtime"."wal_column" AS (
	"name" "text",
	"type_name" "text",
	"type_oid" "oid",
	"value" "jsonb",
	"is_pkey" boolean,
	"is_selectable" boolean
);


ALTER TYPE "realtime"."wal_column" OWNER TO "supabase_admin";

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE "realtime"."wal_rls" AS (
	"wal" "jsonb",
	"is_rls_enabled" boolean,
	"subscription_ids" "uuid"[],
	"errors" "text"[]
);


ALTER TYPE "realtime"."wal_rls" OWNER TO "supabase_admin";

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION "auth"."email"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.email', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
	)::text
$$;


ALTER FUNCTION "auth"."email"() OWNER TO "supabase_auth_admin";

--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION "auth"."jwt"() RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION "auth"."jwt"() OWNER TO "supabase_auth_admin";

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION "auth"."role"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.role', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
	)::text
$$;


ALTER FUNCTION "auth"."role"() OWNER TO "supabase_auth_admin";

--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION "auth"."uid"() RETURNS "uuid"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.sub', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
	)::uuid
$$;


ALTER FUNCTION "auth"."uid"() OWNER TO "supabase_auth_admin";

SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."products" (
    "id" bigint NOT NULL,
    "title" character varying,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "user_id" "uuid",
    "status" character varying DEFAULT 'draft'::character varying,
    "images" character varying[],
    "drop_point" "public"."geography",
    "drop_time" character varying[],
    "category" character varying DEFAULT 'non-food'::character varying,
    "listed_at" timestamp without time zone DEFAULT "now"(),
    "expired_at" "date",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "used_since" character varying
);


ALTER TABLE "public"."products" OWNER TO "postgres";

--
-- Name: create_product("json"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."create_product"("product" "json") RETURNS SETOF "public"."products"
    LANGUAGE "plpgsql"
    AS $$
  declare
    product_id int8;
    tag int8;
  begin
    insert into products (user_id, title, description, images, drop_point, drop_time, category, used_since, expired_at)
    values (auth.uid(), product->>'title', product->>'description', product->'images', (product->>'drop_point')::geography, product->'drop_time', product->>'category', product->>'used_since', product->'expired_at')
    returning id into product_id; 

    foreach tag in array product->'tags' loop
      insert into product_tags (product_id, tag_id)
      values (product_id, tag);
    end loop;

    return query 
      select * from products where id = product_id;
  end
$$;


ALTER FUNCTION "public"."create_product"("product" "json") OWNER TO "postgres";

--
-- Name: create_product("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."create_product"("product_raw" "text") RETURNS SETOF "public"."products"
    LANGUAGE "plpgsql"
    AS $$
  declare
    product json;
    product_id int8;
    tag int8;
  begin
    product := (product_raw)::json;

    insert into products (user_id, title, description, images, drop_point, drop_time, category, used_since, expired_at)
    values (auth.uid(), product->>'title', product->>'description', (product->'images')::varying[], (product->>'drop_point')::geography, (product->'drop_time')::varying[], product->>'category', product->>'used_since', product->'expired_at')
    returning id into product_id;

    foreach tag in array product->'tags' loop
      insert into product_tags (product_id, tag_id)
      values (product_id, tag);
    end loop;

    return query 
      select * from products where id = product_id;
  end
$$;


ALTER FUNCTION "public"."create_product"("product_raw" "text") OWNER TO "postgres";

--
-- Name: create_product("text", "text"[], "text"[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."create_product"("product_raw" "text", "images" "text"[], "drop_time" "text"[]) RETURNS SETOF "public"."products"
    LANGUAGE "plpgsql"
    AS $$
  declare
    product json;
    product_id int8;
    tag int8;
  begin
    product := (product_raw)::json;

    insert into products (user_id, title, description, images, drop_point, drop_time, category, used_since, expired_at)
    values (auth.uid(), product->>'title', product->>'description', images, (product->>'drop_point')::geography, drop_time, product->>'category', product->>'used_since', product->'expired_at')
    returning id into product_id;

    foreach tag in array product->'tags' loop
      insert into product_tags (product_id, tag_id)
      values (product_id, tag);
    end loop;

    return query 
      select * from products where id = product_id;
  end
$$;


ALTER FUNCTION "public"."create_product"("product_raw" "text", "images" "text"[], "drop_time" "text"[]) OWNER TO "postgres";

--
-- Name: get_neighbor_count(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."get_neighbor_count"("radius" integer) RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
declare
  user_location geography;
begin
  select location as user_location from profiles where auth.uid() = user_id into user_location;

  return (select COUNT(*)::int from profiles where ST_DWithin(location, (user_location)::geometry, radius) and auth.uid() <> user_id);
end
$$;


ALTER FUNCTION "public"."get_neighbor_count"("radius" integer) OWNER TO "postgres";

--
-- Name: get_neighbor_count(integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."get_neighbor_count"("radius" integer, "point" "text") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
begin
  return (select COUNT(*)::int from profiles where ST_DWithin(location, (point)::geometry, radius));
end
$$;


ALTER FUNCTION "public"."get_neighbor_count"("radius" integer, "point" "text") OWNER TO "postgres";

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into public.profiles (user_id, avatar_url, full_name)
  values (new.id, new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'full_name');
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

--
-- Name: apply_rls("jsonb", integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer DEFAULT (1024 * 1024)) RETURNS SETOF "realtime"."wal_rls"
    LANGUAGE "plpgsql"
    AS $$
      declare
          -- Regclass of the table e.g. public.notes
          entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

          -- I, U, D, T: insert, update ...
          action realtime.action = (
              case wal ->> 'action'
                  when 'I' then 'INSERT'
                  when 'U' then 'UPDATE'
                  when 'D' then 'DELETE'
                  else 'ERROR'
              end
          );

          -- Is row level security enabled for the table
          is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

          subscriptions realtime.subscription[] = array_agg(subs)
              from
                  realtime.subscription subs
              where
                  subs.entity = entity_;

          -- Subscription vars
          roles regrole[] = array_agg(distinct us.claims_role)
              from
                  unnest(subscriptions) us;

          working_role regrole;
          claimed_role regrole;
          claims jsonb;

          subscription_id uuid;
          subscription_has_access bool;
          visible_to_subscription_ids uuid[] = '{}';

          -- structured info for wal's columns
          columns realtime.wal_column[];
          -- previous identity values for update/delete
          old_columns realtime.wal_column[];

          error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

          -- Primary jsonb output for record
          output jsonb;

      begin
          perform set_config('role', null, true);

          columns =
              array_agg(
                  (
                      x->>'name',
                      x->>'type',
                      x->>'typeoid',
                      realtime.cast(
                          (x->'value') #>> '{}',
                          coalesce(
                              (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                              (x->>'type')::regtype
                          )
                      ),
                      (pks ->> 'name') is not null,
                      true
                  )::realtime.wal_column
              )
              from
                  jsonb_array_elements(wal -> 'columns') x
                  left join jsonb_array_elements(wal -> 'pk') pks
                      on (x ->> 'name') = (pks ->> 'name');

          old_columns =
              array_agg(
                  (
                      x->>'name',
                      x->>'type',
                      x->>'typeoid',
                      realtime.cast(
                          (x->'value') #>> '{}',
                          coalesce(
                              (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                              (x->>'type')::regtype
                          )
                      ),
                      (pks ->> 'name') is not null,
                      true
                  )::realtime.wal_column
              )
              from
                  jsonb_array_elements(wal -> 'identity') x
                  left join jsonb_array_elements(wal -> 'pk') pks
                      on (x ->> 'name') = (pks ->> 'name');

          for working_role in select * from unnest(roles) loop

              -- Update `is_selectable` for columns and old_columns
              columns =
                  array_agg(
                      (
                          c.name,
                          c.type_name,
                          c.type_oid,
                          c.value,
                          c.is_pkey,
                          pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                      )::realtime.wal_column
                  )
                  from
                      unnest(columns) c;

              old_columns =
                      array_agg(
                          (
                              c.name,
                              c.type_name,
                              c.type_oid,
                              c.value,
                              c.is_pkey,
                              pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                          )::realtime.wal_column
                      )
                      from
                          unnest(old_columns) c;

              if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
                  return next (
                      jsonb_build_object(
                          'schema', wal ->> 'schema',
                          'table', wal ->> 'table',
                          'type', action
                      ),
                      is_rls_enabled,
                      -- subscriptions is already filtered by entity
                      (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
                      array['Error 400: Bad Request, no primary key']
                  )::realtime.wal_rls;

              -- The claims role does not have SELECT permission to the primary key of entity
              elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
                  return next (
                      jsonb_build_object(
                          'schema', wal ->> 'schema',
                          'table', wal ->> 'table',
                          'type', action
                      ),
                      is_rls_enabled,
                      (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
                      array['Error 401: Unauthorized']
                  )::realtime.wal_rls;

              else
                  output = jsonb_build_object(
                      'schema', wal ->> 'schema',
                      'table', wal ->> 'table',
                      'type', action,
                      'commit_timestamp', to_char(
                          (wal ->> 'timestamp')::timestamptz,
                          'YYYY-MM-DD"T"HH24:MI:SS"Z"'
                      ),
                      'columns', (
                          select
                              jsonb_agg(
                                  jsonb_build_object(
                                      'name', pa.attname,
                                      'type', pt.typname
                                  )
                                  order by pa.attnum asc
                              )
                          from
                              pg_attribute pa
                              join pg_type pt
                                  on pa.atttypid = pt.oid
                          where
                              attrelid = entity_
                              and attnum > 0
                              and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
                      )
                  )
                  -- Add "record" key for insert and update
                  || case
                      when action in ('INSERT', 'UPDATE') then
                          case
                              when error_record_exceeds_max_size then
                                  jsonb_build_object(
                                      'record',
                                      (
                                          select jsonb_object_agg((c).name, (c).value)
                                          from unnest(columns) c
                                          where (c).is_selectable and (octet_length((c).value::text) <= 64)
                                      )
                                  )
                              else
                                  jsonb_build_object(
                                      'record',
                                      (select jsonb_object_agg((c).name, (c).value) from unnest(columns) c where (c).is_selectable)
                                  )
                          end
                      else '{}'::jsonb
                  end
                  -- Add "old_record" key for update and delete
                  || case
                      when action in ('UPDATE', 'DELETE') then
                          case
                              when error_record_exceeds_max_size then
                                  jsonb_build_object(
                                      'old_record',
                                      (
                                          select jsonb_object_agg((c).name, (c).value)
                                          from unnest(old_columns) c
                                          where (c).is_selectable and (octet_length((c).value::text) <= 64)
                                      )
                                  )
                              else
                                  jsonb_build_object(
                                      'old_record',
                                      (select jsonb_object_agg((c).name, (c).value) from unnest(old_columns) c where (c).is_selectable)
                                  )
                          end
                      else '{}'::jsonb
                  end;

                  -- Create the prepared statement
                  if is_rls_enabled and action <> 'DELETE' then
                      if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                          deallocate walrus_rls_stmt;
                      end if;
                      execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
                  end if;

                  visible_to_subscription_ids = '{}';

                  for subscription_id, claims in (
                          select
                              subs.subscription_id,
                              subs.claims
                          from
                              unnest(subscriptions) subs
                          where
                              subs.entity = entity_
                              and subs.claims_role = working_role
                              and realtime.is_visible_through_filters(columns, subs.filters)
                  ) loop

                      if not is_rls_enabled or action = 'DELETE' then
                          visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                      else
                          -- Check if RLS allows the role to see the record
                          perform
                              set_config('role', working_role::text, true),
                              set_config('request.jwt.claims', claims::text, true);

                          execute 'execute walrus_rls_stmt' into subscription_has_access;

                          if subscription_has_access then
                              visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                          end if;
                      end if;
                  end loop;

                  perform set_config('role', null, true);

                  return next (
                      output,
                      is_rls_enabled,
                      visible_to_subscription_ids,
                      case
                          when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                          else '{}'
                      end
                  )::realtime.wal_rls;

              end if;
          end loop;

          perform set_config('role', null, true);
      end;
    $$;


ALTER FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer) OWNER TO "supabase_admin";

--
-- Name: build_prepared_statement_sql("text", "regclass", "realtime"."wal_column"[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) RETURNS "text"
    LANGUAGE "sql"
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) OWNER TO "supabase_admin";

--
-- Name: cast("text", "regtype"); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") RETURNS "jsonb"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") OWNER TO "supabase_admin";

--
-- Name: check_equality_op("realtime"."equality_op", "regtype", "text", "text"); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") RETURNS boolean
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
    /*
    Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
    */
    declare
      op_symbol text = (
        case
          when op = 'eq' then '='
          when op = 'neq' then '!='
          when op = 'lt' then '<'
          when op = 'lte' then '<='
          when op = 'gt' then '>'
          when op = 'gte' then '>='
          else 'UNKNOWN OP'
        end
      );
      res boolean;
    begin
      execute format('select %L::'|| type_::text || ' ' || op_symbol || ' %L::'|| type_::text, val_1, val_2) into res;
      return res;
    end;
    $$;


ALTER FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") OWNER TO "supabase_admin";

--
-- Name: is_visible_through_filters("realtime"."wal_column"[], "realtime"."user_defined_filter"[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) RETURNS boolean
    LANGUAGE "sql" IMMUTABLE
    AS $$
        /*
        Should the record be visible (true) or filtered out (false) after *filters* are applied
        */
            select
                -- Default to allowed when no filters present
                coalesce(
                    sum(
                        realtime.check_equality_op(
                            op:=f.op,
                            type_:=coalesce(
                                col.type_oid::regtype, -- null when wal2json version <= 2.4
                                col.type_name::regtype
                            ),
                            -- cast jsonb to text
                            val_1:=col.value #>> '{}',
                            val_2:=f.value
                        )::int
                    ) = count(1),
                    true
                )
            from
                unnest(filters) f
                join unnest(columns) col
                    on f.column_name = col.name;
        $$;


ALTER FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) OWNER TO "supabase_admin";

--
-- Name: quote_wal2json("regclass"); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION "realtime"."quote_wal2json"("entity" "regclass") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION "realtime"."quote_wal2json"("entity" "regclass") OWNER TO "supabase_admin";

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION "realtime"."subscription_check_filters"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
      col_names text[] = coalesce(
        array_agg(c.column_name order by c.ordinal_position),
        '{}'::text[]
      )
      from
        information_schema.columns c
      where
        format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
        and pg_catalog.has_column_privilege(
          (new.claims ->> 'role'),
          format('%I.%I', c.table_schema, c.table_name)::regclass,
          c.column_name,
          'SELECT'
        );
      filter realtime.user_defined_filter;
      col_type regtype;
    begin
      for filter in select * from unnest(new.filters) loop
        -- Filtered column is valid
        if not filter.column_name = any(col_names) then
          raise exception 'invalid column for filter %', filter.column_name;
        end if;

        -- Type is sanitized and safe for string interpolation
        col_type = (
          select atttypid::regtype
          from pg_catalog.pg_attribute
          where attrelid = new.entity
            and attname = filter.column_name
        );
        if col_type is null then
          raise exception 'failed to lookup type for column %', filter.column_name;
        end if;
        -- raises an exception if value is not coercable to type
        perform realtime.cast(filter.value, col_type);
      end loop;

      -- Apply consistent order to filters so the unique constraint on
      -- (subscription_id, entity, filters) can't be tricked by a different filter order
      new.filters = coalesce(
        array_agg(f order by f.column_name, f.op, f.value),
        '{}'
      ) from unnest(new.filters) f;

    return new;
  end;
  $$;


ALTER FUNCTION "realtime"."subscription_check_filters"() OWNER TO "supabase_admin";

--
-- Name: to_regrole("text"); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION "realtime"."to_regrole"("role_name" "text") RETURNS "regrole"
    LANGUAGE "sql" IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION "realtime"."to_regrole"("role_name" "text") OWNER TO "supabase_admin";

--
-- Name: extension("text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION "storage"."extension"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return split_part(_filename, '.', 2);
END
$$;


ALTER FUNCTION "storage"."extension"("name" "text") OWNER TO "supabase_storage_admin";

--
-- Name: filename("text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION "storage"."filename"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION "storage"."filename"("name" "text") OWNER TO "supabase_storage_admin";

--
-- Name: foldername("text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION "storage"."foldername"("name" "text") RETURNS "text"[]
    LANGUAGE "plpgsql"
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


ALTER FUNCTION "storage"."foldername"("name" "text") OWNER TO "supabase_storage_admin";

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION "storage"."get_size_by_bucket"() RETURNS TABLE("size" bigint, "bucket_id" "text")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION "storage"."get_size_by_bucket"() OWNER TO "supabase_storage_admin";

--
-- Name: search("text", "text", integer, integer, integer, "text", "text", "text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(regexp_split_to_array(objects.name, ''/''), 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(regexp_split_to_array(objects.name, ''/''), 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text") OWNER TO "supabase_storage_admin";

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION "storage"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION "storage"."update_updated_at_column"() OWNER TO "supabase_storage_admin";

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE "auth"."audit_log_entries" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "payload" "json",
    "created_at" timestamp with time zone,
    "ip_address" character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE "auth"."audit_log_entries" OWNER TO "supabase_auth_admin";

--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE "auth"."identities" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "identity_data" "jsonb" NOT NULL,
    "provider" "text" NOT NULL,
    "last_sign_in_at" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "auth"."identities" OWNER TO "supabase_auth_admin";

--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE "auth"."instances" (
    "id" "uuid" NOT NULL,
    "uuid" "uuid",
    "raw_base_config" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "auth"."instances" OWNER TO "supabase_auth_admin";

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE "auth"."refresh_tokens" (
    "instance_id" "uuid",
    "id" bigint NOT NULL,
    "token" character varying(255),
    "user_id" character varying(255),
    "revoked" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "parent" character varying(255),
    "session_id" "uuid"
);


ALTER TABLE "auth"."refresh_tokens" OWNER TO "supabase_auth_admin";

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE "auth"."refresh_tokens_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "auth"."refresh_tokens_id_seq" OWNER TO "supabase_auth_admin";

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE "auth"."refresh_tokens_id_seq" OWNED BY "auth"."refresh_tokens"."id";


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE "auth"."schema_migrations" (
    "version" character varying(255) NOT NULL
);


ALTER TABLE "auth"."schema_migrations" OWNER TO "supabase_auth_admin";

--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE "auth"."sessions" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "auth"."sessions" OWNER TO "supabase_auth_admin";

--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE "auth"."users" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "aud" character varying(255),
    "role" character varying(255),
    "email" character varying(255),
    "encrypted_password" character varying(255),
    "email_confirmed_at" timestamp with time zone,
    "invited_at" timestamp with time zone,
    "confirmation_token" character varying(255),
    "confirmation_sent_at" timestamp with time zone,
    "recovery_token" character varying(255),
    "recovery_sent_at" timestamp with time zone,
    "email_change_token_new" character varying(255),
    "email_change" character varying(255),
    "email_change_sent_at" timestamp with time zone,
    "last_sign_in_at" timestamp with time zone,
    "raw_app_meta_data" "jsonb",
    "raw_user_meta_data" "jsonb",
    "is_super_admin" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "phone" character varying(15) DEFAULT NULL::character varying,
    "phone_confirmed_at" timestamp with time zone,
    "phone_change" character varying(15) DEFAULT ''::character varying,
    "phone_change_token" character varying(255) DEFAULT ''::character varying,
    "phone_change_sent_at" timestamp with time zone,
    "confirmed_at" timestamp with time zone GENERATED ALWAYS AS (LEAST("email_confirmed_at", "phone_confirmed_at")) STORED,
    "email_change_token_current" character varying(255) DEFAULT ''::character varying,
    "email_change_confirm_status" smallint DEFAULT 0,
    "banned_until" timestamp with time zone,
    "reauthentication_token" character varying(255) DEFAULT ''::character varying,
    "reauthentication_sent_at" timestamp with time zone,
    CONSTRAINT "users_email_change_confirm_status_check" CHECK ((("email_change_confirm_status" >= 0) AND ("email_change_confirm_status" <= 2)))
);


ALTER TABLE "auth"."users" OWNER TO "supabase_auth_admin";

--
-- Name: likes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."likes" (
    "id" bigint NOT NULL,
    "user_id" "uuid",
    "product_id" bigint,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."likes" OWNER TO "postgres";

--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."likes" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."likes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."product_tags" (
    "id" bigint NOT NULL,
    "product_id" bigint,
    "tag_id" bigint
);


ALTER TABLE "public"."product_tags" OWNER TO "postgres";

--
-- Name: product_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_tags" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."product_tags_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."products" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."products_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."profiles" (
    "id" bigint NOT NULL,
    "full_name" character varying,
    "phone" character varying,
    "address" "text",
    "avatar_url" character varying,
    "status" character varying DEFAULT 'unverified'::character varying,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "user_id" "uuid",
    "location" "public"."geography",
    "rating" real DEFAULT '0'::real
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";

--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."profiles" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."profiles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."tags" (
    "id" bigint NOT NULL,
    "name" character varying,
    "description" "text",
    "disabled" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."tags" OWNER TO "postgres";

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."tags" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."tags_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."transactions" (
    "id" bigint NOT NULL,
    "user_id" "uuid",
    "owner_id" "uuid",
    "product_id" bigint,
    "status" character varying,
    "rating" real,
    "comment" "text",
    "confirm_at" timestamp without time zone,
    "boked_at" timestamp without time zone,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."transactions" OWNER TO "postgres";

--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."transactions" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."transactions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE "realtime"."schema_migrations" (
    "version" bigint NOT NULL,
    "inserted_at" timestamp(0) without time zone
);


ALTER TABLE "realtime"."schema_migrations" OWNER TO "supabase_admin";

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE "realtime"."subscription" (
    "id" bigint NOT NULL,
    "subscription_id" "uuid" NOT NULL,
    "entity" "regclass" NOT NULL,
    "filters" "realtime"."user_defined_filter"[] DEFAULT '{}'::"realtime"."user_defined_filter"[] NOT NULL,
    "claims" "jsonb" NOT NULL,
    "claims_role" "regrole" GENERATED ALWAYS AS ("realtime"."to_regrole"(("claims" ->> 'role'::"text"))) STORED NOT NULL,
    "created_at" timestamp without time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "realtime"."subscription" OWNER TO "supabase_admin";

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE "realtime"."subscription" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "realtime"."subscription_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE "storage"."buckets" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "public" boolean DEFAULT false
);


ALTER TABLE "storage"."buckets" OWNER TO "supabase_storage_admin";

--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE "storage"."migrations" (
    "id" integer NOT NULL,
    "name" character varying(100) NOT NULL,
    "hash" character varying(40) NOT NULL,
    "executed_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "storage"."migrations" OWNER TO "supabase_storage_admin";

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE "storage"."objects" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "bucket_id" "text",
    "name" "text",
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "last_accessed_at" timestamp with time zone DEFAULT "now"(),
    "metadata" "jsonb",
    "path_tokens" "text"[] GENERATED ALWAYS AS ("string_to_array"("name", '/'::"text")) STORED
);


ALTER TABLE "storage"."objects" OWNER TO "supabase_storage_admin";

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."refresh_tokens" ALTER COLUMN "id" SET DEFAULT "nextval"('"auth"."refresh_tokens_id_seq"'::"regclass");


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '03b81abe-6187-4b6e-805b-15989ef18021', '{"action":"user_invited","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","log_type":"team","traits":{"user_email":"ryandevstudio@gmail.com","user_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45"}}', '2022-11-01 15:25:35.401932+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'a2f18a2d-6742-4a2d-814e-f1329c609059', '{"action":"user_signedup","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_username":"ryandevstudio@gmail.com","log_type":"team"}', '2022-11-01 15:26:15.58295+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '35da86f8-1d2c-4978-8a77-9a62fdd7f087', '{"action":"user_invited","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","log_type":"team","traits":{"user_email":"wildanaunur@gmail.com","user_id":"878224c8-cec0-4aa1-90a4-776217b8abc4"}}', '2022-11-01 15:26:51.756902+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '40ecbeda-dc64-4ae6-a10a-da7886a275f9', '{"action":"user_signedup","actor_id":"878224c8-cec0-4aa1-90a4-776217b8abc4","actor_username":"wildanaunur@gmail.com","log_type":"team"}', '2022-11-01 15:27:01.777914+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'cd06509e-9efa-419b-8db8-b1be6826a0e0', '{"action":"user_repeated_signup","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_username":"ryandevstudio@gmail.com","log_type":"user","traits":{"provider":"email"}}', '2022-11-03 08:17:58.416244+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '8efccc08-f0ce-4a71-8d54-ed4e2e7f479b', '{"action":"user_repeated_signup","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_username":"ryandevstudio@gmail.com","log_type":"user","traits":{"provider":"email"}}', '2022-11-03 08:52:56.596538+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '0b576133-9729-42eb-944a-3c6b0f424611', '{"action":"user_repeated_signup","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_username":"ryandevstudio@gmail.com","log_type":"user","traits":{"provider":"email"}}', '2022-11-03 08:53:31.499199+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '874a10fe-a9d0-4480-ac89-84ad9ffad26f', '{"action":"user_repeated_signup","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_username":"ryandevstudio@gmail.com","log_type":"user","traits":{"provider":"email"}}', '2022-11-03 08:53:52.787828+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'd490e6e5-c448-432f-b2ea-696138e2bb0b', '{"action":"user_repeated_signup","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_username":"ryandevstudio@gmail.com","log_type":"user","traits":{"provider":"email"}}', '2022-11-03 08:54:07.739427+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '0031abc8-68d2-4027-8916-b7ea39108c76', '{"action":"user_repeated_signup","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_username":"ryandevstudio@gmail.com","log_type":"user","traits":{"provider":"email"}}', '2022-11-03 08:54:11.758713+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '5a490863-9613-4949-94c8-e398bdf7cd46', '{"action":"user_repeated_signup","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_username":"ryandevstudio@gmail.com","log_type":"user","traits":{"provider":"email"}}', '2022-11-03 08:54:24.80586+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'aa2d69ae-477b-4e28-b60c-d64446fe037e', '{"action":"user_repeated_signup","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_username":"ryandevstudio@gmail.com","log_type":"user","traits":{"provider":"email"}}', '2022-11-03 08:54:34.448005+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'f44e2e2c-22b6-4aaf-aec5-8de5971d49c3', '{"action":"user_signedup","actor_id":"e7d0e7e6-ecac-46a1-8009-bd4f8b6e66b2","actor_username":"ryanaunur@gmail.com","log_type":"team","traits":{"provider":"email"}}', '2022-11-03 08:54:56.902824+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'ffcbb014-a18e-404e-80f0-29ca81e909db', '{"action":"login","actor_id":"e7d0e7e6-ecac-46a1-8009-bd4f8b6e66b2","actor_username":"ryanaunur@gmail.com","log_type":"account","traits":{"provider":"email"}}', '2022-11-03 08:54:56.906649+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '6b8f1106-aa41-46b8-9505-264aa0aab0ee', '{"action":"token_refreshed","actor_id":"e7d0e7e6-ecac-46a1-8009-bd4f8b6e66b2","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 09:54:46.998415+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'b9f92c40-85dd-43d8-863a-89455ae12387', '{"action":"token_revoked","actor_id":"e7d0e7e6-ecac-46a1-8009-bd4f8b6e66b2","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 09:54:46.999274+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '6dd50456-86f3-43d6-a053-72464d641800', '{"action":"token_refreshed","actor_id":"e7d0e7e6-ecac-46a1-8009-bd4f8b6e66b2","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 09:54:47.02152+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'b23b57e0-f90c-441c-8ca6-24a4ba3c7673', '{"action":"token_revoked","actor_id":"e7d0e7e6-ecac-46a1-8009-bd4f8b6e66b2","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 09:54:47.022494+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'fc1507bd-09a9-4acb-b54a-597cbaefe043', '{"action":"token_refreshed","actor_id":"e7d0e7e6-ecac-46a1-8009-bd4f8b6e66b2","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 10:54:38.016309+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '7783ac97-e401-4695-b3c1-0a9d42390d85', '{"action":"token_revoked","actor_id":"e7d0e7e6-ecac-46a1-8009-bd4f8b6e66b2","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 10:54:38.017538+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '72f0b440-6a79-4bb5-9a1b-83d3c5960647', '{"action":"token_refreshed","actor_id":"e7d0e7e6-ecac-46a1-8009-bd4f8b6e66b2","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 10:54:38.040277+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '3b921091-8477-41d2-96dd-aee8a5748bc5', '{"action":"token_revoked","actor_id":"e7d0e7e6-ecac-46a1-8009-bd4f8b6e66b2","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 10:54:38.041105+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '30153d5c-0d69-4894-afee-0f83392e416a', '{"action":"user_signedup","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"team","traits":{"provider":"email"}}', '2022-11-03 11:55:01.69273+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'd5ad44e3-517d-4f3a-ab0d-b42d376640d0', '{"action":"login","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"account","traits":{"provider":"email"}}', '2022-11-03 11:55:01.69918+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'ffa6795d-ba8d-405a-a5d3-d5771ca14f73', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 12:54:51.599073+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '1d29273c-bb5b-4a99-8b2d-2f9194f7a630', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 12:54:51.599992+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '56fa0396-ea6b-4d65-b7a8-0d5895a514f2', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 12:54:51.620025+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'b93c1877-1e78-4c9f-9910-a581643ae089', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 12:54:51.62082+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '88233c10-3927-4941-a81e-cfbe1f0443d2', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 13:54:42.010481+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '6b826653-2a8b-49ed-9fb4-8ac4152f1f4e', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 13:54:42.011808+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'd6567bcd-ae6d-4e14-9070-e844ba35542f', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 13:54:42.032168+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '187327a7-4774-4f2c-852f-609f233e22eb', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 13:54:42.033198+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '41062ea9-5a40-4b9c-8967-80d8736fb9cc', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 13:54:42.403446+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '0dfd50f0-c482-40b4-bd61-5363e6d0bdb5', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 13:54:42.404498+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'c56fe73f-0ec1-4104-9d9c-915d6db43b46', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 14:54:32.513567+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '012e5e98-8f80-4f8d-883c-ae8c7b5f5137', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 14:54:32.514498+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '96142837-c86d-4e69-82a2-f32b5b0ffca7', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 14:54:32.533926+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'ff0d3bf4-42cf-45ea-9c31-ab0ff4cfb98c', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 14:54:32.534965+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '6da45dae-6e58-4b58-94a9-fb1713f888c5', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 14:54:32.99078+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '500d52f3-eece-49f5-80b6-415d22e0b808', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 14:54:32.991435+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'fde0a2a2-90ce-4098-a70e-3062965ee5ef', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 15:54:22.835663+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'fb0724fb-b38d-485e-a25c-795393b040be', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 15:54:22.838493+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'f3ee3905-4eb6-4eac-9d08-50d023f09605', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 15:54:22.858705+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '1d4d52b2-1368-4588-b602-c7f8e2c4d08c', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 15:54:22.859723+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '341b239f-35f5-4602-aeda-e4ad18222bd1', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 15:54:22.992739+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '77242d5f-464b-40d3-a5bf-9a8ae09384bd', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-03 15:54:22.993472+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '95fd52bf-a51e-4cc6-b5cb-3ffb4a14ccb8', '{"action":"login","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"account","traits":{"provider":"email"}}', '2022-11-03 16:54:06.725886+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'c35604e7-44b2-44b7-9eac-a7289f0e7e15', '{"action":"logout","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"account"}', '2022-11-03 16:54:10.293749+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '2e9e770b-5be8-4838-81c5-66761aa6cf80', '{"action":"login","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"account","traits":{"provider":"email"}}', '2022-11-03 16:54:46.53277+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '94a142d9-6936-45b7-ab12-1f81fcfc9761', '{"action":"logout","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"account"}', '2022-11-03 16:54:47.565426+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '24b428f6-b351-468d-b032-9c84c50b8211', '{"action":"login","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_username":"ryandevstudio@gmail.com","log_type":"account","traits":{"provider":"google"}}', '2022-11-03 16:56:57.016322+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '9e7315d7-4666-40f5-a9f1-389272855297', '{"action":"logout","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_username":"ryandevstudio@gmail.com","log_type":"account"}', '2022-11-03 16:58:01.053143+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'a7f406e9-73c6-459a-ac50-b03389b7f8de', '{"action":"login","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"account","traits":{"provider":"email"}}', '2022-11-03 16:58:06.829116+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '1860895e-c081-4e4a-ba85-dff85a32e228', '{"action":"token_refreshed","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-04 02:02:18.299101+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'd5b7d73f-f4ad-446d-9399-be884856d5ef', '{"action":"token_revoked","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"token"}', '2022-11-04 02:02:18.301509+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '2004bbd3-34ab-4d76-a529-a5a6846633ca', '{"action":"logout","actor_id":"00dee371-59e1-4ec3-85fd-811fde999b42","actor_username":"ryanaunur@gmail.com","log_type":"account"}', '2022-11-04 02:03:05.070742+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'c8f36737-3ae1-4043-bfd0-4d95b354c424', '{"action":"user_signedup","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"team","traits":{"provider":"google"}}', '2022-11-04 03:08:03.776872+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'fc4b7a31-7ee5-41fb-a1f8-48c0b64d767c', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 04:07:55.007491+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'fbf9a79d-822b-461a-94d9-59cae910352c', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 04:07:55.011648+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'cf0cdcb2-c847-4d5e-bc81-52adcf0b3928', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 04:07:55.035672+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'c17f23b5-6af9-4407-ae61-dc1162b14fe3', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 04:07:55.036531+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'ae2b7438-65b4-4858-b7d2-9872e14eb288', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 05:07:46.003844+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'e59d1f30-a677-4daf-94a8-0a80b05caac3', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 05:07:46.005692+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '4c884395-5b86-4948-8997-de4d8fb9bfe5', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 05:07:46.024964+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '87191bd9-ce66-4398-a201-a3435f96c630', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 05:07:46.025715+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '78a12775-023c-40ba-bbf0-9ec5ad1a9a8c', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 06:07:37.037406+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'd6c48743-32f5-4206-aa4a-9d99346a397d', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 06:07:37.040698+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '7d064361-7b78-44f7-b9cf-0877e4be15e9', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 06:07:37.071766+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '1318aedc-28dd-4bee-9b12-968ce226506a', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 06:07:37.072564+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '84900306-ec39-4caf-9dcc-dd9e87194e49', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 07:07:27.990876+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'f0faea61-5900-40cf-bd55-641d6a7ade7a', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 07:07:28.000764+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'fce6522d-f9f5-4e5c-80d4-5efaa21786a9', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 07:07:28.031758+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '709f5224-0944-430c-8885-4d47dc03ae9b', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 07:07:28.032501+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '1a7c1fb6-4e6d-456e-be90-cb0acfd3997c', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 08:07:18.017031+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '11d5ace8-fc66-41c8-9f77-3707936b6c01', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 08:07:18.020921+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '2c6a4f73-b8a9-445d-bff4-e26b29e5e8b5', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 08:07:18.043148+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '5f175ccc-92be-446b-9222-39dc92dc3083', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 08:07:18.044144+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '5900a111-a9f7-4a2b-958f-fe3e64744d4a', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 09:07:08.006221+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'b382dbf0-9c49-46fa-ad92-ca9b26d2433a', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 09:07:08.009594+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '7f42c822-419a-47ea-816a-1b36900bd06a', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 09:07:08.032213+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '06391585-7c3e-4a39-8c9b-af40789ded27', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-04 09:07:08.032986+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '2df45e66-da6f-412d-ab90-8a2ee6e4dce5', '{"action":"token_refreshed","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-08 06:51:48.913236+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'afb76900-9c14-4d71-be5d-e0c2fb085910', '{"action":"token_revoked","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"token"}', '2022-11-08 06:51:48.919665+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '8fe9a2a2-ed55-422b-a8bd-7ce45e31854e', '{"action":"logout","actor_id":"7f2fb521-4443-4622-ad33-e655fea23ad6","actor_name":"Ryan Aunur Rassyid","actor_username":"ryanaunur58@gmail.com","log_type":"account"}', '2022-11-08 06:51:53.153669+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '2d92cc30-0b25-440c-8578-060ead753489', '{"action":"login","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_name":"Ryan Aunur Rassyid","actor_username":"ryandevstudio@gmail.com","log_type":"account","traits":{"provider":"google"}}', '2022-11-08 06:52:13.043363+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', 'd27872e0-8b17-4084-abaf-1694f8094051', '{"action":"token_refreshed","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_name":"Ryan Aunur Rassyid","actor_username":"ryandevstudio@gmail.com","log_type":"token"}', '2022-11-09 03:30:27.068777+00', '');
INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES ('00000000-0000-0000-0000-000000000000', '33a5264d-9cec-4c27-a4bc-8eabc964c863', '{"action":"token_revoked","actor_id":"e943dd4f-01ce-4d91-9340-7a1f7f9c9f45","actor_name":"Ryan Aunur Rassyid","actor_username":"ryandevstudio@gmail.com","log_type":"token"}', '2022-11-09 03:30:27.072696+00', '');


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at") VALUES ('00dee371-59e1-4ec3-85fd-811fde999b42', '00dee371-59e1-4ec3-85fd-811fde999b42', '{"sub": "00dee371-59e1-4ec3-85fd-811fde999b42"}', 'email', '2022-11-03 11:55:01.690739+00', '2022-11-03 11:55:01.690824+00', '2022-11-03 11:55:01.690832+00');
INSERT INTO "auth"."identities" ("id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at") VALUES ('118398044005142189101', '7f2fb521-4443-4622-ad33-e655fea23ad6', '{"iss": "https://www.googleapis.com/userinfo/v2/me", "sub": "118398044005142189101", "name": "Ryan Aunur Rassyid", "email": "ryanaunur58@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ALm5wu3z4pcWb9EcxWrXBrOuSjUzv_os7CQeGrJCqIvANg=s96-c", "full_name": "Ryan Aunur Rassyid", "avatar_url": "https://lh3.googleusercontent.com/a/ALm5wu3z4pcWb9EcxWrXBrOuSjUzv_os7CQeGrJCqIvANg=s96-c", "provider_id": "118398044005142189101", "email_verified": true}', 'google', '2022-11-04 03:08:03.772165+00', '2022-11-04 03:08:03.772259+00', '2022-11-04 03:08:03.772267+00');
INSERT INTO "auth"."identities" ("id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at") VALUES ('107502789920980403676', 'e943dd4f-01ce-4d91-9340-7a1f7f9c9f45', '{"iss": "https://www.googleapis.com/userinfo/v2/me", "sub": "107502789920980403676", "name": "Ryan Aunur Rassyid", "email": "ryandevstudio@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ALm5wu3jNDyOO1klRc5hvaS1ol48tRiiumEFhW9zZBwrvjk=s96-c", "full_name": "Ryan Aunur Rassyid", "avatar_url": "https://lh3.googleusercontent.com/a/ALm5wu3jNDyOO1klRc5hvaS1ol48tRiiumEFhW9zZBwrvjk=s96-c", "provider_id": "107502789920980403676", "email_verified": true}', 'google', '2022-11-03 16:56:57.009905+00', '2022-11-03 16:56:57.009997+00', '2022-11-08 06:52:13.039343+00');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES ('00000000-0000-0000-0000-000000000000', 2, 'foAyT08RRqbFmG7KzAj-fg', '878224c8-cec0-4aa1-90a4-776217b8abc4', false, '2022-11-01 15:27:01.783075+00', '2022-11-01 15:27:01.78308+00', NULL, 'a28b2c14-a458-4533-ae54-fe91a8fde642');
INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES ('00000000-0000-0000-0000-000000000000', 39, 'DnXzu81lOIo_E7yibn8zJg', 'e943dd4f-01ce-4d91-9340-7a1f7f9c9f45', true, '2022-11-08 06:52:13.04649+00', '2022-11-09 03:30:27.073946+00', NULL, '0e235958-b37f-4354-9285-8318c2e804c1');
INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES ('00000000-0000-0000-0000-000000000000', 40, 'keD3zebmeWPEic1KKF9Gmg', 'e943dd4f-01ce-4d91-9340-7a1f7f9c9f45', false, '2022-11-09 03:30:27.07521+00', '2022-11-09 03:30:27.07522+00', 'DnXzu81lOIo_E7yibn8zJg', '0e235958-b37f-4354-9285-8318c2e804c1');


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20171026211738');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20171026211808');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20171026211834');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20180103212743');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20180108183307');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20180119214651');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20180125194653');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('00');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20210710035447');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20210722035447');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20210730183235');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20210909172000');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20210927181326');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20211122151130');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20211124214934');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20211202183645');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20220114185221');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20220114185340');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20220224000811');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20220323170000');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20220429102000');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20220531120530');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20220614074223');
INSERT INTO "auth"."schema_migrations" ("version") VALUES ('20220811173540');


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at") VALUES ('a28b2c14-a458-4533-ae54-fe91a8fde642', '878224c8-cec0-4aa1-90a4-776217b8abc4', '2022-11-01 15:27:01.78194+00', '2022-11-01 15:27:01.781947+00');
INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at") VALUES ('0e235958-b37f-4354-9285-8318c2e804c1', 'e943dd4f-01ce-4d91-9340-7a1f7f9c9f45', '2022-11-08 06:52:13.044104+00', '2022-11-08 06:52:13.044109+00');


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at") VALUES ('00000000-0000-0000-0000-000000000000', '878224c8-cec0-4aa1-90a4-776217b8abc4', 'authenticated', 'authenticated', 'wildanaunur@gmail.com', '$2a$10$jSoKf/ofgryQCSsHCjdE7ugiisFDJPY4zIRXySROP0aFj3Mt4./Eu', '2022-11-01 15:27:01.778633+00', '2022-11-01 15:26:51.758634+00', '', '2022-11-01 15:26:51.758634+00', '', NULL, '', '', NULL, '2022-11-01 15:27:01.781868+00', '{"provider": "email", "providers": ["email"]}', '{}', NULL, '2022-11-01 15:26:51.751871+00', '2022-11-01 15:27:01.784595+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL);
INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at") VALUES ('00000000-0000-0000-0000-000000000000', '00dee371-59e1-4ec3-85fd-811fde999b42', 'authenticated', 'authenticated', 'ryanaunur@gmail.com', '$2a$10$7E.1qnB9FrrzHMPMBBccPeYuFlmeD8f/m9AgI4Wv8RXR5uPM2tQwe', '2022-11-03 11:55:01.694003+00', NULL, '', NULL, '', NULL, '', '', NULL, '2022-11-03 16:58:06.830134+00', '{"provider": "email", "providers": ["email"]}', '{"name": "Ryan Aunur Rassyid", "phone": "+6285755504990"}', NULL, '2022-11-03 11:55:01.686312+00', '2022-11-04 02:02:18.308627+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL);
INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at") VALUES ('00000000-0000-0000-0000-000000000000', '7f2fb521-4443-4622-ad33-e655fea23ad6', 'authenticated', 'authenticated', 'ryanaunur58@gmail.com', '', '2022-11-04 03:08:03.777659+00', NULL, '', NULL, '', NULL, '', '', NULL, '2022-11-04 03:08:03.778717+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://www.googleapis.com/userinfo/v2/me", "sub": "118398044005142189101", "name": "Ryan Aunur Rassyid", "email": "ryanaunur58@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ALm5wu3z4pcWb9EcxWrXBrOuSjUzv_os7CQeGrJCqIvANg=s96-c", "full_name": "Ryan Aunur Rassyid", "avatar_url": "https://lh3.googleusercontent.com/a/ALm5wu3z4pcWb9EcxWrXBrOuSjUzv_os7CQeGrJCqIvANg=s96-c", "provider_id": "118398044005142189101", "email_verified": true}', NULL, '2022-11-04 03:08:03.766107+00', '2022-11-08 06:51:48.92718+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL);
INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at") VALUES ('00000000-0000-0000-0000-000000000000', 'e943dd4f-01ce-4d91-9340-7a1f7f9c9f45', 'authenticated', 'authenticated', 'ryandevstudio@gmail.com', '$2a$10$OMJMkcAtxSwPqH2LdHqJtu37PLE/jtUP7tt27vVCXYtKD3pTMzR4O', '2022-11-01 15:26:15.583932+00', '2022-11-01 15:25:35.403913+00', '', '2022-11-01 15:25:35.403913+00', '', NULL, '', '', NULL, '2022-11-08 06:52:13.044051+00', '{"provider": "email", "providers": ["google"]}', '{"iss": "https://www.googleapis.com/userinfo/v2/me", "sub": "107502789920980403676", "name": "Ryan Aunur Rassyid", "email": "ryandevstudio@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ALm5wu3jNDyOO1klRc5hvaS1ol48tRiiumEFhW9zZBwrvjk=s96-c", "full_name": "Ryan Aunur Rassyid", "avatar_url": "https://lh3.googleusercontent.com/a/ALm5wu3jNDyOO1klRc5hvaS1ol48tRiiumEFhW9zZBwrvjk=s96-c", "provider_id": "107502789920980403676", "email_verified": true}', NULL, '2022-11-01 15:25:35.394124+00', '2022-11-09 03:30:27.079249+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL);


--
-- Data for Name: likes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: product_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."product_tags" ("id", "product_id", "tag_id") VALUES (1, 1, 1);
INSERT INTO "public"."product_tags" ("id", "product_id", "tag_id") VALUES (2, 1, 2);
INSERT INTO "public"."product_tags" ("id", "product_id", "tag_id") VALUES (3, 2, 1);
INSERT INTO "public"."product_tags" ("id", "product_id", "tag_id") VALUES (4, 3, 2);
INSERT INTO "public"."product_tags" ("id", "product_id", "tag_id") VALUES (5, 4, 2);
INSERT INTO "public"."product_tags" ("id", "product_id", "tag_id") VALUES (6, 5, 2);
INSERT INTO "public"."product_tags" ("id", "product_id", "tag_id") VALUES (7, 6, 2);
INSERT INTO "public"."product_tags" ("id", "product_id", "tag_id") VALUES (8, 7, 1);
INSERT INTO "public"."product_tags" ("id", "product_id", "tag_id") VALUES (9, 7, 2);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."products" ("id", "title", "description", "created_at", "user_id", "status", "images", "drop_point", "drop_time", "category", "listed_at", "expired_at", "updated_at", "used_since") VALUES (2, 'Ini Produk', 'it should description', '2022-11-01 14:24:25.080511+00', 'e943dd4f-01ce-4d91-9340-7a1f7f9c9f45', 'listed:expired', NULL, NULL, NULL, 'non-food', '2022-11-08 11:01:58.786395', NULL, '2022-11-08 11:01:59.151833+00', NULL);
INSERT INTO "public"."products" ("id", "title", "description", "created_at", "user_id", "status", "images", "drop_point", "drop_time", "category", "listed_at", "expired_at", "updated_at", "used_since") VALUES (1, 'Product A', 'This is product A', '2022-11-01 10:25:30+00', 'e943dd4f-01ce-4d91-9340-7a1f7f9c9f45', 'listed:active', NULL, NULL, NULL, 'non-food', '2022-11-08 11:01:58.786395', NULL, '2022-11-08 11:01:59.151833+00', NULL);
INSERT INTO "public"."products" ("id", "title", "description", "created_at", "user_id", "status", "images", "drop_point", "drop_time", "category", "listed_at", "expired_at", "updated_at", "used_since") VALUES (3, 'Ini Produk C', 'it should description', '2022-11-01 14:24:53.486994+00', 'e943dd4f-01ce-4d91-9340-7a1f7f9c9f45', 'draft', NULL, NULL, NULL, 'non-food', '2022-11-08 11:01:58.786395', NULL, '2022-11-08 11:01:59.151833+00', NULL);
INSERT INTO "public"."products" ("id", "title", "description", "created_at", "user_id", "status", "images", "drop_point", "drop_time", "category", "listed_at", "expired_at", "updated_at", "used_since") VALUES (4, 'Ini Produk C', 'it should description', '2022-11-01 14:25:24.394386+00', '878224c8-cec0-4aa1-90a4-776217b8abc4', 'deleted', NULL, NULL, NULL, 'non-food', '2022-11-08 11:01:58.786395', NULL, '2022-11-08 11:01:59.151833+00', NULL);
INSERT INTO "public"."products" ("id", "title", "description", "created_at", "user_id", "status", "images", "drop_point", "drop_time", "category", "listed_at", "expired_at", "updated_at", "used_since") VALUES (5, 'Ini Produk C', 'it should description', '2022-11-01 15:41:04.621056+00', NULL, 'draft', NULL, NULL, NULL, 'non-food', '2022-11-08 11:01:58.786395', NULL, '2022-11-08 11:01:59.151833+00', NULL);
INSERT INTO "public"."products" ("id", "title", "description", "created_at", "user_id", "status", "images", "drop_point", "drop_time", "category", "listed_at", "expired_at", "updated_at", "used_since") VALUES (6, 'Ini Produk C', 'it should description', '2022-11-01 15:42:01.98244+00', NULL, 'draft', NULL, NULL, NULL, 'non-food', '2022-11-08 11:01:58.786395', NULL, '2022-11-08 11:01:59.151833+00', NULL);
INSERT INTO "public"."products" ("id", "title", "description", "created_at", "user_id", "status", "images", "drop_point", "drop_time", "category", "listed_at", "expired_at", "updated_at", "used_since") VALUES (7, 'Ini judul produk', 'Ini deskripsi produknya', '2022-11-03 15:34:09.201819+00', '00dee371-59e1-4ec3-85fd-811fde999b42', 'draft', '{images/302dd22b-8479-40f2-a5d9-2158510a7dda.png}', NULL, NULL, 'non-food', '2022-11-08 11:01:58.786395', NULL, '2022-11-08 11:01:59.151833+00', NULL);


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profiles" ("id", "full_name", "phone", "address", "avatar_url", "status", "created_at", "user_id", "location", "rating") VALUES (1, 'Ryan Aunur Rassyid', NULL, NULL, 'https://lh3.googleusercontent.com/a/ALm5wu3z4pcWb9EcxWrXBrOuSjUzv_os7CQeGrJCqIvANg=s96-c', 'inactive', '2022-11-04 03:08:03.667078+00', '7f2fb521-4443-4622-ad33-e655fea23ad6', NULL, 0);


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."tags" ("id", "name", "description", "disabled", "created_at") VALUES (1, 'Halal', 'Halal Products', false, '2022-11-01 10:26:01+00');
INSERT INTO "public"."tags" ("id", "name", "description", "disabled", "created_at") VALUES (2, 'Food', NULL, false, '2022-11-01 10:27:02+00');


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211116024918, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211116045059, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211116050929, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211116051442, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211116212300, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211116213355, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211116213934, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211116214523, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211122062447, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211124070109, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211202204204, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211202204605, '2022-04-14 09:42:55');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211210212804, '2022-04-14 09:42:56');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20211228014915, '2022-04-14 09:42:56');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20220107221237, '2022-04-14 09:42:56');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20220228202821, '2022-04-14 09:42:56');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20220312004840, '2022-04-14 09:42:56');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20220603231003, '2022-08-23 04:55:52');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20220603232444, '2022-08-23 04:55:52');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20220615214548, '2022-08-23 04:55:52');
INSERT INTO "realtime"."schema_migrations" ("version", "inserted_at") VALUES (20220712093339, '2022-08-23 04:55:52');


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--



--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public") VALUES ('avatars', 'avatars', NULL, '2022-11-03 14:42:12.721362+00', '2022-11-03 14:42:12.721362+00', false);
INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public") VALUES ('products', 'products', NULL, '2022-11-03 15:15:18.876578+00', '2022-11-03 15:15:18.876578+00', true);


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."migrations" ("id", "name", "hash", "executed_at") VALUES (0, 'create-migrations-table', 'e18db593bcde2aca2a408c4d1100f6abba2195df', '2022-04-14 09:42:54.573289');
INSERT INTO "storage"."migrations" ("id", "name", "hash", "executed_at") VALUES (1, 'initialmigration', '6ab16121fbaa08bbd11b712d05f358f9b555d777', '2022-04-14 09:42:54.630614');
INSERT INTO "storage"."migrations" ("id", "name", "hash", "executed_at") VALUES (2, 'pathtoken-column', '49756be03be4c17bb85fe70d4a861f27de7e49ad', '2022-04-14 09:42:54.676128');
INSERT INTO "storage"."migrations" ("id", "name", "hash", "executed_at") VALUES (3, 'add-migrations-rls', 'bb5d124c53d68635a883e399426c6a5a25fc893d', '2022-04-14 09:42:55.036044');
INSERT INTO "storage"."migrations" ("id", "name", "hash", "executed_at") VALUES (4, 'add-size-functions', '6d79007d04f5acd288c9c250c42d2d5fd286c54d', '2022-04-14 09:42:55.072341');
INSERT INTO "storage"."migrations" ("id", "name", "hash", "executed_at") VALUES (5, 'change-column-name-in-get-size', 'fd65688505d2ffa9fbdc58a944348dd8604d688c', '2022-04-14 09:42:55.102122');
INSERT INTO "storage"."migrations" ("id", "name", "hash", "executed_at") VALUES (6, 'add-rls-to-buckets', '63e2bab75a2040fee8e3fb3f15a0d26f3380e9b6', '2022-04-14 09:42:55.139121');
INSERT INTO "storage"."migrations" ("id", "name", "hash", "executed_at") VALUES (7, 'add-public-to-buckets', '82568934f8a4d9e0a85f126f6fb483ad8214c418', '2022-04-14 09:42:55.179168');
INSERT INTO "storage"."migrations" ("id", "name", "hash", "executed_at") VALUES (8, 'fix-search-function', '1a43a40eddb525f2e2f26efd709e6c06e58e059c', '2022-04-14 09:42:55.218331');
INSERT INTO "storage"."migrations" ("id", "name", "hash", "executed_at") VALUES (9, 'search-files-search-function', '34c096597eb8b9d077fdfdde9878c88501b2fafc', '2022-08-23 04:56:00.165176');
INSERT INTO "storage"."migrations" ("id", "name", "hash", "executed_at") VALUES (10, 'add-trigger-to-auto-update-updated_at-column', '37d6bb964a70a822e6d37f22f457b9bca7885928', '2022-08-23 04:56:00.176673');


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata") VALUES ('285287f1-0169-42bb-abe9-f7b6d074b230', 'products', 'images/302dd22b-8479-40f2-a5d9-2158510a7dda.png', '00dee371-59e1-4ec3-85fd-811fde999b42', '2022-11-03 15:15:34.817783+00', '2022-11-03 15:15:34.849632+00', '2022-11-03 15:15:34.817783+00', '{"size": 315628, "mimetype": "image/png", "cacheControl": "max-age=3600"}');
INSERT INTO "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata") VALUES ('4cb619bc-4438-4f0e-8cc9-f0dcb3e4e9fb', 'products', 'images/17bf8007-582e-4ca9-861a-cf00ec95f867.png', '00dee371-59e1-4ec3-85fd-811fde999b42', '2022-11-03 15:20:49.621244+00', '2022-11-03 15:20:49.643314+00', '2022-11-03 15:20:49.621244+00', '{"size": 46283, "mimetype": "image/png", "cacheControl": "max-age=3600"}');


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 40, true);


--
-- Name: likes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."likes_id_seq"', 1, false);


--
-- Name: product_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."product_tags_id_seq"', 9, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."products_id_seq"', 7, true);


--
-- Name: profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."profiles_id_seq"', 1, true);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."tags_id_seq"', 2, true);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."transactions_id_seq"', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('"realtime"."subscription_id_seq"', 1, false);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."audit_log_entries"
    ADD CONSTRAINT "audit_log_entries_pkey" PRIMARY KEY ("id");


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_pkey" PRIMARY KEY ("provider", "id");


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."instances"
    ADD CONSTRAINT "instances_pkey" PRIMARY KEY ("id");


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id");


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_token_unique" UNIQUE ("token");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_pkey" PRIMARY KEY ("id");


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_phone_key" UNIQUE ("phone");


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");


--
-- Name: likes likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."likes"
    ADD CONSTRAINT "likes_pkey" PRIMARY KEY ("id");


--
-- Name: product_tags product_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_tags"
    ADD CONSTRAINT "product_tags_pkey" PRIMARY KEY ("id");


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_pkey" PRIMARY KEY ("id");


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_pkey" PRIMARY KEY ("id");


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."subscription"
    ADD CONSTRAINT "pk_subscription" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."buckets"
    ADD CONSTRAINT "buckets_pkey" PRIMARY KEY ("id");


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_name_key" UNIQUE ("name");


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_pkey" PRIMARY KEY ("id");


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_pkey" PRIMARY KEY ("id");


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "audit_logs_instance_id_idx" ON "auth"."audit_log_entries" USING "btree" ("instance_id");


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "confirmation_token_idx" ON "auth"."users" USING "btree" ("confirmation_token") WHERE (("confirmation_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "email_change_token_current_idx" ON "auth"."users" USING "btree" ("email_change_token_current") WHERE (("email_change_token_current")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "email_change_token_new_idx" ON "auth"."users" USING "btree" ("email_change_token_new") WHERE (("email_change_token_new")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "identities_user_id_idx" ON "auth"."identities" USING "btree" ("user_id");


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "reauthentication_token_idx" ON "auth"."users" USING "btree" ("reauthentication_token") WHERE (("reauthentication_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "recovery_token_idx" ON "auth"."users" USING "btree" ("recovery_token") WHERE (("recovery_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "refresh_tokens_instance_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id");


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "refresh_tokens_instance_id_user_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id", "user_id");


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "refresh_tokens_parent_idx" ON "auth"."refresh_tokens" USING "btree" ("parent");


--
-- Name: refresh_tokens_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "refresh_tokens_token_idx" ON "auth"."refresh_tokens" USING "btree" ("token");


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "users_instance_id_email_idx" ON "auth"."users" USING "btree" ("instance_id", "lower"(("email")::"text"));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "users_instance_id_idx" ON "auth"."users" USING "btree" ("instance_id");


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX "ix_realtime_subscription_entity" ON "realtime"."subscription" USING "hash" ("entity");


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX "subscription_subscription_id_entity_filters_key" ON "realtime"."subscription" USING "btree" ("subscription_id", "entity", "filters");


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX "bname" ON "storage"."buckets" USING "btree" ("name");


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX "bucketid_objname" ON "storage"."objects" USING "btree" ("bucket_id", "name");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX "name_prefix_search" ON "storage"."objects" USING "btree" ("name" "text_pattern_ops");


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER "on_auth_user_created" AFTER INSERT ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_user"();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER "tr_check_filters" BEFORE INSERT OR UPDATE ON "realtime"."subscription" FOR EACH ROW EXECUTE FUNCTION "realtime"."subscription_check_filters"();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER "update_objects_updated_at" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."update_updated_at_column"();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_parent_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_parent_fkey" FOREIGN KEY ("parent") REFERENCES "auth"."refresh_tokens"("token");


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: likes likes_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."likes"
    ADD CONSTRAINT "likes_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: likes likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."likes"
    ADD CONSTRAINT "likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: product_tags product_tags_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_tags"
    ADD CONSTRAINT "product_tags_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: product_tags product_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_tags"
    ADD CONSTRAINT "product_tags_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "public"."tags"("id");


--
-- Name: products products_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: transactions transactions_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id");


--
-- Name: transactions transactions_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: transactions transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: buckets buckets_owner_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."buckets"
    ADD CONSTRAINT "buckets_owner_fkey" FOREIGN KEY ("owner") REFERENCES "auth"."users"("id");


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: objects objects_owner_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_owner_fkey" FOREIGN KEY ("owner") REFERENCES "auth"."users"("id");


--
-- Name: profiles Allow functions insert access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow functions insert access" ON "public"."profiles" FOR INSERT TO "supabase_functions_admin" WITH CHECK (true);


--
-- Name: likes Enable insert for authenticated user; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated user" ON "public"."likes" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: product_tags Enable insert for authenticated user; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated user" ON "public"."product_tags" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: products Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."products" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: products Enable read access for all authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all authenticated users" ON "public"."products" FOR SELECT TO "authenticated" USING (true);


--
-- Name: profiles Enable update for profiles based on user-id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for profiles based on user-id" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: products Enable update for users based on own products; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on own products" ON "public"."products" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: product_tags Enable update for users based on product owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on product owner" ON "public"."product_tags" FOR UPDATE TO "authenticated" USING (("auth"."uid"() IN ( SELECT "products"."user_id"
   FROM "public"."products"
  WHERE ("product_tags"."product_id" = "products"."id")))) WITH CHECK (("auth"."uid"() IN ( SELECT "products"."user_id"
   FROM "public"."products"
  WHERE ("product_tags"."product_id" = "products"."id"))));


--
-- Name: likes Read access for authenticated only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read access for authenticated only" ON "public"."likes" FOR SELECT TO "authenticated" USING (true);


--
-- Name: product_tags Read access for authenticated only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read access for authenticated only" ON "public"."product_tags" FOR SELECT TO "authenticated" USING (true);


--
-- Name: profiles Read access for authenticated only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read access for authenticated only" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);


--
-- Name: tags Read access for authenticated only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read access for authenticated only" ON "public"."tags" FOR SELECT TO "authenticated" USING (true);


--
-- Name: transactions Read access for getter or owner only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read access for getter or owner only" ON "public"."transactions" FOR SELECT TO "authenticated" USING ((("auth"."uid"() = "user_id") OR ("auth"."uid"() = "owner_id")));


--
-- Name: likes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."likes" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_tags; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_tags" ENABLE ROW LEVEL SECURITY;

--
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: tags; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."tags" ENABLE ROW LEVEL SECURITY;

--
-- Name: transactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."transactions" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects Anyone can update their own avatar.; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Anyone can update their own avatar." ON "storage"."objects" FOR UPDATE USING (("auth"."uid"() = "owner")) WITH CHECK (("bucket_id" = 'avatars'::"text"));


--
-- Name: objects Anyone can update their own product.; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Anyone can update their own product." ON "storage"."objects" FOR UPDATE USING (("auth"."uid"() = "owner")) WITH CHECK (("bucket_id" = 'products'::"text"));


--
-- Name: objects Anyone can upload an avatar.; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Anyone can upload an avatar." ON "storage"."objects" FOR INSERT WITH CHECK (("bucket_id" = 'avatars'::"text"));


--
-- Name: objects Anyone can upload an product.; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Anyone can upload an product." ON "storage"."objects" FOR INSERT TO "authenticated" WITH CHECK (("bucket_id" = 'products'::"text"));


--
-- Name: objects Avatar images are publicly accessible.; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Avatar images are publicly accessible." ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'avatars'::"text"));


--
-- Name: objects Products images are publicly accessible.; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Products images are publicly accessible." ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'products'::"text"));


--
-- Name: objects Public Access; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Public Access" ON "storage"."objects" FOR SELECT USING (("bucket_id" = 'products'::"text"));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE "storage"."buckets" ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE "storage"."migrations" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE "storage"."objects" ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA "auth"; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA "auth" TO "anon";
GRANT USAGE ON SCHEMA "auth" TO "authenticated";
GRANT USAGE ON SCHEMA "auth" TO "service_role";
GRANT ALL ON SCHEMA "auth" TO "supabase_auth_admin";
GRANT ALL ON SCHEMA "auth" TO "dashboard_user";
GRANT ALL ON SCHEMA "auth" TO "postgres";


--
-- Name: SCHEMA "graphql_public"; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA "graphql_public" TO "postgres";
GRANT USAGE ON SCHEMA "graphql_public" TO "anon";
GRANT USAGE ON SCHEMA "graphql_public" TO "authenticated";
GRANT USAGE ON SCHEMA "graphql_public" TO "service_role";


--
-- Name: SCHEMA "public"; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";


--
-- Name: SCHEMA "realtime"; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA "realtime" TO "postgres";


--
-- Name: SCHEMA "storage"; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT ALL ON SCHEMA "storage" TO "postgres";
GRANT USAGE ON SCHEMA "storage" TO "anon";
GRANT USAGE ON SCHEMA "storage" TO "authenticated";
GRANT USAGE ON SCHEMA "storage" TO "service_role";
GRANT ALL ON SCHEMA "storage" TO "supabase_storage_admin";
GRANT ALL ON SCHEMA "storage" TO "dashboard_user";


--
-- Name: FUNCTION "box2d_in"("cstring"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box2d_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."box2d_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2d_in"("cstring") TO "service_role";


--
-- Name: FUNCTION "box2d_out"("public"."box2d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box2d_out"("public"."box2d") TO "anon";
GRANT ALL ON FUNCTION "public"."box2d_out"("public"."box2d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2d_out"("public"."box2d") TO "service_role";


--
-- Name: FUNCTION "box2df_in"("cstring"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box2df_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."box2df_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2df_in"("cstring") TO "service_role";


--
-- Name: FUNCTION "box2df_out"("public"."box2df"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box2df_out"("public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."box2df_out"("public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2df_out"("public"."box2df") TO "service_role";


--
-- Name: FUNCTION "box3d_in"("cstring"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box3d_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."box3d_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box3d_in"("cstring") TO "service_role";


--
-- Name: FUNCTION "box3d_out"("public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box3d_out"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."box3d_out"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box3d_out"("public"."box3d") TO "service_role";


--
-- Name: FUNCTION "geography_analyze"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_analyze"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_analyze"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_analyze"("internal") TO "service_role";


--
-- Name: FUNCTION "geography_in"("cstring", "oid", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_in"("cstring", "oid", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_in"("cstring", "oid", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_in"("cstring", "oid", integer) TO "service_role";


--
-- Name: FUNCTION "geography_out"("public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_out"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_out"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_out"("public"."geography") TO "service_role";


--
-- Name: FUNCTION "geography_recv"("internal", "oid", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_recv"("internal", "oid", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_recv"("internal", "oid", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_recv"("internal", "oid", integer) TO "service_role";


--
-- Name: FUNCTION "geography_send"("public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_send"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_send"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_send"("public"."geography") TO "service_role";


--
-- Name: FUNCTION "geography_typmod_in"("cstring"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_typmod_in"("cstring"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_typmod_in"("cstring"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_typmod_in"("cstring"[]) TO "service_role";


--
-- Name: FUNCTION "geography_typmod_out"(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_typmod_out"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_typmod_out"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_typmod_out"(integer) TO "service_role";


--
-- Name: FUNCTION "geometry_analyze"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_analyze"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_analyze"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_analyze"("internal") TO "service_role";


--
-- Name: FUNCTION "geometry_in"("cstring"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_in"("cstring") TO "service_role";


--
-- Name: FUNCTION "geometry_out"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_out"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_out"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_out"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_recv"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_recv"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_recv"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_recv"("internal") TO "service_role";


--
-- Name: FUNCTION "geometry_send"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_send"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_send"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_send"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_typmod_in"("cstring"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_typmod_in"("cstring"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_typmod_in"("cstring"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_typmod_in"("cstring"[]) TO "service_role";


--
-- Name: FUNCTION "geometry_typmod_out"(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_typmod_out"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_typmod_out"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_typmod_out"(integer) TO "service_role";


--
-- Name: FUNCTION "gidx_in"("cstring"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gidx_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."gidx_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gidx_in"("cstring") TO "service_role";


--
-- Name: FUNCTION "gidx_out"("public"."gidx"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gidx_out"("public"."gidx") TO "anon";
GRANT ALL ON FUNCTION "public"."gidx_out"("public"."gidx") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gidx_out"("public"."gidx") TO "service_role";


--
-- Name: FUNCTION "spheroid_in"("cstring"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."spheroid_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."spheroid_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."spheroid_in"("cstring") TO "service_role";


--
-- Name: FUNCTION "spheroid_out"("public"."spheroid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."spheroid_out"("public"."spheroid") TO "anon";
GRANT ALL ON FUNCTION "public"."spheroid_out"("public"."spheroid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."spheroid_out"("public"."spheroid") TO "service_role";


--
-- Name: FUNCTION "box3d"("public"."box2d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box3d"("public"."box2d") TO "anon";
GRANT ALL ON FUNCTION "public"."box3d"("public"."box2d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box3d"("public"."box2d") TO "service_role";


--
-- Name: FUNCTION "geometry"("public"."box2d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry"("public"."box2d") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("public"."box2d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("public"."box2d") TO "service_role";


--
-- Name: FUNCTION "box"("public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."box"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box"("public"."box3d") TO "service_role";


--
-- Name: FUNCTION "box2d"("public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box2d"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."box2d"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2d"("public"."box3d") TO "service_role";


--
-- Name: FUNCTION "geometry"("public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("public"."box3d") TO "service_role";


--
-- Name: FUNCTION "geography"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."geography"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography"("bytea") TO "service_role";


--
-- Name: FUNCTION "geometry"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("bytea") TO "service_role";


--
-- Name: FUNCTION "bytea"("public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."bytea"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."bytea"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bytea"("public"."geography") TO "service_role";


--
-- Name: FUNCTION "geography"("public"."geography", integer, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography"("public"."geography", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."geography"("public"."geography", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography"("public"."geography", integer, boolean) TO "service_role";


--
-- Name: FUNCTION "geometry"("public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("public"."geography") TO "service_role";


--
-- Name: FUNCTION "box"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."box"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "box2d"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box2d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."box2d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2d"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "box3d"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box3d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."box3d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box3d"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "bytea"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."bytea"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."bytea"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bytea"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geography"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geography"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry"("public"."geometry", integer, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry"("public"."geometry", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("public"."geometry", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("public"."geometry", integer, boolean) TO "service_role";


--
-- Name: FUNCTION "json"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."json"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."json"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."json"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "jsonb"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."jsonb"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."jsonb"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."jsonb"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "path"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."path"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."path"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."path"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "point"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."point"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."point"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."point"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "polygon"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."polygon"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."polygon"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."polygon"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "text"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."text"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."text"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."text"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry"("path"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry"("path") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("path") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("path") TO "service_role";


--
-- Name: FUNCTION "geometry"("point"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry"("point") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("point") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("point") TO "service_role";


--
-- Name: FUNCTION "geometry"("polygon"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry"("polygon") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("polygon") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("polygon") TO "service_role";


--
-- Name: FUNCTION "geometry"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("text") TO "service_role";


--
-- Name: FUNCTION "email"(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION "auth"."email"() TO "dashboard_user";


--
-- Name: FUNCTION "jwt"(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION "auth"."jwt"() TO "postgres";
GRANT ALL ON FUNCTION "auth"."jwt"() TO "dashboard_user";


--
-- Name: FUNCTION "role"(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION "auth"."role"() TO "dashboard_user";


--
-- Name: FUNCTION "uid"(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION "auth"."uid"() TO "dashboard_user";


--
-- Name: FUNCTION "algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "armor"("bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."armor"("bytea") TO "dashboard_user";


--
-- Name: FUNCTION "armor"("bytea", "text"[], "text"[]); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) TO "dashboard_user";


--
-- Name: FUNCTION "crypt"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."crypt"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "dearmor"("text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."dearmor"("text") TO "dashboard_user";


--
-- Name: FUNCTION "decrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "decrypt_iv"("bytea", "bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "digest"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."digest"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "digest"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."digest"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "encrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "encrypt_iv"("bytea", "bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "gen_random_bytes"(integer); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) TO "dashboard_user";


--
-- Name: FUNCTION "gen_random_uuid"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_random_uuid"() TO "dashboard_user";


--
-- Name: FUNCTION "gen_salt"("text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_salt"("text") TO "dashboard_user";


--
-- Name: FUNCTION "gen_salt"("text", integer); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_salt"("text", integer) TO "dashboard_user";


--
-- Name: FUNCTION "hmac"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "hmac"("text", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric) TO "dashboard_user";


--
-- Name: FUNCTION "pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) TO "dashboard_user";


--
-- Name: FUNCTION "pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) TO "dashboard_user";


--
-- Name: FUNCTION "pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_key_id"("bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt"("text", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt"("text", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt_bytea"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt_bytea"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt_bytea"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt_bytea"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt"("text", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt_bytea"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt_bytea"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "sign"("payload" "json", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "try_cast_double"("inp" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") TO "dashboard_user";


--
-- Name: FUNCTION "url_decode"("data" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."url_decode"("data" "text") TO "dashboard_user";


--
-- Name: FUNCTION "url_encode"("data" "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v1"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v1mc"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v3"("namespace" "uuid", "name" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v4"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v4"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v5"("namespace" "uuid", "name" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_nil"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_nil"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_dns"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_dns"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_oid"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_oid"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_url"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_url"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_x500"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_x500"() TO "dashboard_user";


--
-- Name: FUNCTION "verify"("token" "text", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "get_built_schema_version"(); Type: ACL; Schema: graphql; Owner: postgres
--

GRANT ALL ON FUNCTION "graphql"."get_built_schema_version"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."get_built_schema_version"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."get_built_schema_version"() TO "service_role";


--
-- Name: FUNCTION "rebuild_on_ddl"(); Type: ACL; Schema: graphql; Owner: postgres
--

GRANT ALL ON FUNCTION "graphql"."rebuild_on_ddl"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."rebuild_on_ddl"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."rebuild_on_ddl"() TO "service_role";


--
-- Name: FUNCTION "rebuild_on_drop"(); Type: ACL; Schema: graphql; Owner: postgres
--

GRANT ALL ON FUNCTION "graphql"."rebuild_on_drop"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."rebuild_on_drop"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."rebuild_on_drop"() TO "service_role";


--
-- Name: FUNCTION "rebuild_schema"(); Type: ACL; Schema: graphql; Owner: postgres
--

GRANT ALL ON FUNCTION "graphql"."rebuild_schema"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."rebuild_schema"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."rebuild_schema"() TO "service_role";


--
-- Name: FUNCTION "variable_definitions_sort"("variable_definitions" "jsonb"); Type: ACL; Schema: graphql; Owner: postgres
--

GRANT ALL ON FUNCTION "graphql"."variable_definitions_sort"("variable_definitions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."variable_definitions_sort"("variable_definitions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."variable_definitions_sort"("variable_definitions" "jsonb") TO "service_role";


--
-- Name: SEQUENCE "key_key_id_seq"; Type: ACL; Schema: pgsodium; Owner: postgres
--

GRANT ALL ON SEQUENCE "pgsodium"."key_key_id_seq" TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "_postgis_deprecate"("oldname" "text", "newname" "text", "version" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_postgis_deprecate"("oldname" "text", "newname" "text", "version" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_deprecate"("oldname" "text", "newname" "text", "version" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_deprecate"("oldname" "text", "newname" "text", "version" "text") TO "service_role";


--
-- Name: FUNCTION "_postgis_index_extent"("tbl" "regclass", "col" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_postgis_index_extent"("tbl" "regclass", "col" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_index_extent"("tbl" "regclass", "col" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_index_extent"("tbl" "regclass", "col" "text") TO "service_role";


--
-- Name: FUNCTION "_postgis_join_selectivity"("regclass", "text", "regclass", "text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_postgis_join_selectivity"("regclass", "text", "regclass", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_join_selectivity"("regclass", "text", "regclass", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_join_selectivity"("regclass", "text", "regclass", "text", "text") TO "service_role";


--
-- Name: FUNCTION "_postgis_pgsql_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_postgis_pgsql_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_pgsql_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_pgsql_version"() TO "service_role";


--
-- Name: FUNCTION "_postgis_scripts_pgsql_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_postgis_scripts_pgsql_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_scripts_pgsql_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_scripts_pgsql_version"() TO "service_role";


--
-- Name: FUNCTION "_postgis_selectivity"("tbl" "regclass", "att_name" "text", "geom" "public"."geometry", "mode" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_postgis_selectivity"("tbl" "regclass", "att_name" "text", "geom" "public"."geometry", "mode" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_selectivity"("tbl" "regclass", "att_name" "text", "geom" "public"."geometry", "mode" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_selectivity"("tbl" "regclass", "att_name" "text", "geom" "public"."geometry", "mode" "text") TO "service_role";


--
-- Name: FUNCTION "_postgis_stats"("tbl" "regclass", "att_name" "text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_postgis_stats"("tbl" "regclass", "att_name" "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_stats"("tbl" "regclass", "att_name" "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_stats"("tbl" "regclass", "att_name" "text", "text") TO "service_role";


--
-- Name: FUNCTION "_st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "_st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "_st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_asgml"(integer, "public"."geometry", integer, integer, "text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_asgml"(integer, "public"."geometry", integer, integer, "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_asgml"(integer, "public"."geometry", integer, integer, "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_asgml"(integer, "public"."geometry", integer, integer, "text", "text") TO "service_role";


--
-- Name: FUNCTION "_st_asx3d"(integer, "public"."geometry", integer, integer, "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_asx3d"(integer, "public"."geometry", integer, integer, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_asx3d"(integer, "public"."geometry", integer, integer, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_asx3d"(integer, "public"."geometry", integer, integer, "text") TO "service_role";


--
-- Name: FUNCTION "_st_bestsrid"("public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography") TO "service_role";


--
-- Name: FUNCTION "_st_bestsrid"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "_st_concavehull"("param_inputgeom" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_concavehull"("param_inputgeom" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_concavehull"("param_inputgeom" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_concavehull"("param_inputgeom" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";


--
-- Name: FUNCTION "_st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_covers"("geog1" "public"."geography", "geog2" "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";


--
-- Name: FUNCTION "_st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "_st_distancetree"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "_st_distancetree"("public"."geography", "public"."geography", double precision, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography", double precision, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography", double precision, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography", double precision, boolean) TO "service_role";


--
-- Name: FUNCTION "_st_distanceuncached"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "_st_distanceuncached"("public"."geography", "public"."geography", boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", boolean) TO "service_role";


--
-- Name: FUNCTION "_st_distanceuncached"("public"."geography", "public"."geography", double precision, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", double precision, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", double precision, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", double precision, boolean) TO "service_role";


--
-- Name: FUNCTION "_st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "_st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "service_role";


--
-- Name: FUNCTION "_st_dwithinuncached"("public"."geography", "public"."geography", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision) TO "service_role";


--
-- Name: FUNCTION "_st_dwithinuncached"("public"."geography", "public"."geography", double precision, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision, boolean) TO "service_role";


--
-- Name: FUNCTION "_st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_expand"("public"."geography", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_expand"("public"."geography", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_expand"("public"."geography", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_expand"("public"."geography", double precision) TO "service_role";


--
-- Name: FUNCTION "_st_geomfromgml"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_geomfromgml"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_geomfromgml"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_geomfromgml"("text", integer) TO "service_role";


--
-- Name: FUNCTION "_st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_pointoutside"("public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_pointoutside"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_pointoutside"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_pointoutside"("public"."geography") TO "service_role";


--
-- Name: FUNCTION "_st_sortablehash"("geom" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_sortablehash"("geom" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_sortablehash"("geom" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_sortablehash"("geom" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "_st_voronoi"("g1" "public"."geometry", "clip" "public"."geometry", "tolerance" double precision, "return_polygons" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_voronoi"("g1" "public"."geometry", "clip" "public"."geometry", "tolerance" double precision, "return_polygons" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_voronoi"("g1" "public"."geometry", "clip" "public"."geometry", "tolerance" double precision, "return_polygons" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_voronoi"("g1" "public"."geometry", "clip" "public"."geometry", "tolerance" double precision, "return_polygons" boolean) TO "service_role";


--
-- Name: FUNCTION "_st_within"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."_st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "addauth"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."addauth"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."addauth"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."addauth"("text") TO "service_role";


--
-- Name: FUNCTION "addgeometrycolumn"("table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "service_role";


--
-- Name: FUNCTION "addgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "service_role";


--
-- Name: FUNCTION "addgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "service_role";


--
-- Name: FUNCTION "box3dtobox"("public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."box3dtobox"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."box3dtobox"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box3dtobox"("public"."box3d") TO "service_role";


--
-- Name: FUNCTION "checkauth"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."checkauth"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."checkauth"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."checkauth"("text", "text") TO "service_role";


--
-- Name: FUNCTION "checkauth"("text", "text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."checkauth"("text", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."checkauth"("text", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."checkauth"("text", "text", "text") TO "service_role";


--
-- Name: FUNCTION "checkauthtrigger"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."checkauthtrigger"() TO "anon";
GRANT ALL ON FUNCTION "public"."checkauthtrigger"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."checkauthtrigger"() TO "service_role";


--
-- Name: FUNCTION "contains_2d"("public"."box2df", "public"."box2df"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."box2df") TO "service_role";


--
-- Name: FUNCTION "contains_2d"("public"."box2df", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "contains_2d"("public"."geometry", "public"."box2df"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."contains_2d"("public"."geometry", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."geometry", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."geometry", "public"."box2df") TO "service_role";


--
-- Name: TABLE "products"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";


--
-- Name: FUNCTION "create_product"("product" "json"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."create_product"("product" "json") TO "anon";
GRANT ALL ON FUNCTION "public"."create_product"("product" "json") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_product"("product" "json") TO "service_role";


--
-- Name: FUNCTION "create_product"("product_raw" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."create_product"("product_raw" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_product"("product_raw" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_product"("product_raw" "text") TO "service_role";


--
-- Name: FUNCTION "create_product"("product_raw" "text", "images" "text"[], "drop_time" "text"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."create_product"("product_raw" "text", "images" "text"[], "drop_time" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."create_product"("product_raw" "text", "images" "text"[], "drop_time" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_product"("product_raw" "text", "images" "text"[], "drop_time" "text"[]) TO "service_role";


--
-- Name: FUNCTION "disablelongtransactions"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."disablelongtransactions"() TO "anon";
GRANT ALL ON FUNCTION "public"."disablelongtransactions"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."disablelongtransactions"() TO "service_role";


--
-- Name: FUNCTION "dropgeometrycolumn"("table_name" character varying, "column_name" character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("table_name" character varying, "column_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("table_name" character varying, "column_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("table_name" character varying, "column_name" character varying) TO "service_role";


--
-- Name: FUNCTION "dropgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "service_role";


--
-- Name: FUNCTION "dropgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "service_role";


--
-- Name: FUNCTION "dropgeometrytable"("table_name" character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."dropgeometrytable"("table_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("table_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("table_name" character varying) TO "service_role";


--
-- Name: FUNCTION "dropgeometrytable"("schema_name" character varying, "table_name" character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."dropgeometrytable"("schema_name" character varying, "table_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("schema_name" character varying, "table_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("schema_name" character varying, "table_name" character varying) TO "service_role";


--
-- Name: FUNCTION "dropgeometrytable"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."dropgeometrytable"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying) TO "service_role";


--
-- Name: FUNCTION "enablelongtransactions"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."enablelongtransactions"() TO "anon";
GRANT ALL ON FUNCTION "public"."enablelongtransactions"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enablelongtransactions"() TO "service_role";


--
-- Name: FUNCTION "equals"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "find_srid"(character varying, character varying, character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."find_srid"(character varying, character varying, character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."find_srid"(character varying, character varying, character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."find_srid"(character varying, character varying, character varying) TO "service_role";


--
-- Name: FUNCTION "geog_brin_inclusion_add_value"("internal", "internal", "internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geog_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geog_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geog_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geography_cmp"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_cmp"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_cmp"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_cmp"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "geography_distance_knn"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_distance_knn"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_distance_knn"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_distance_knn"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "geography_eq"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_eq"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_eq"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_eq"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "geography_ge"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_ge"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_ge"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_ge"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "geography_gist_compress"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_gist_compress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_compress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_compress"("internal") TO "service_role";


--
-- Name: FUNCTION "geography_gist_consistent"("internal", "public"."geography", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_gist_consistent"("internal", "public"."geography", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_consistent"("internal", "public"."geography", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_consistent"("internal", "public"."geography", integer) TO "service_role";


--
-- Name: FUNCTION "geography_gist_decompress"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_gist_decompress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_decompress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_decompress"("internal") TO "service_role";


--
-- Name: FUNCTION "geography_gist_distance"("internal", "public"."geography", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_gist_distance"("internal", "public"."geography", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_distance"("internal", "public"."geography", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_distance"("internal", "public"."geography", integer) TO "service_role";


--
-- Name: FUNCTION "geography_gist_penalty"("internal", "internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_gist_penalty"("internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_penalty"("internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_penalty"("internal", "internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geography_gist_picksplit"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_gist_picksplit"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_picksplit"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_picksplit"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geography_gist_same"("public"."box2d", "public"."box2d", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_gist_same"("public"."box2d", "public"."box2d", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_same"("public"."box2d", "public"."box2d", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_same"("public"."box2d", "public"."box2d", "internal") TO "service_role";


--
-- Name: FUNCTION "geography_gist_union"("bytea", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_gist_union"("bytea", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_union"("bytea", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_union"("bytea", "internal") TO "service_role";


--
-- Name: FUNCTION "geography_gt"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_gt"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gt"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gt"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "geography_le"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_le"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_le"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_le"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "geography_lt"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_lt"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_lt"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_lt"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "geography_overlaps"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_overlaps"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_overlaps"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_overlaps"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "geography_spgist_choose_nd"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_spgist_choose_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_choose_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_choose_nd"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geography_spgist_compress_nd"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_spgist_compress_nd"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_compress_nd"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_compress_nd"("internal") TO "service_role";


--
-- Name: FUNCTION "geography_spgist_config_nd"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_spgist_config_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_config_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_config_nd"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geography_spgist_inner_consistent_nd"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_spgist_inner_consistent_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_inner_consistent_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_inner_consistent_nd"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geography_spgist_leaf_consistent_nd"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_spgist_leaf_consistent_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_leaf_consistent_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_leaf_consistent_nd"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geography_spgist_picksplit_nd"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geography_spgist_picksplit_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_picksplit_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_picksplit_nd"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geom2d_brin_inclusion_add_value"("internal", "internal", "internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geom2d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geom2d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geom2d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geom3d_brin_inclusion_add_value"("internal", "internal", "internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geom3d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geom3d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geom3d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geom4d_brin_inclusion_add_value"("internal", "internal", "internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geom4d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geom4d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geom4d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_above"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_above"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_above"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_above"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_below"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_below"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_below"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_below"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_cmp"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_cmp"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_cmp"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_cmp"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_contained_3d"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_contained_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_contained_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_contained_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_contains"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_contains_3d"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_contains_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_contains_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_contains_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_contains_nd"("public"."geometry", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_contains_nd"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_contains_nd"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_contains_nd"("public"."geometry", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_distance_box"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_distance_box"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_distance_box"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_distance_box"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_distance_centroid"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_distance_centroid"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_distance_centroid"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_distance_centroid"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_distance_centroid_nd"("public"."geometry", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_distance_centroid_nd"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_distance_centroid_nd"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_distance_centroid_nd"("public"."geometry", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_distance_cpa"("public"."geometry", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_distance_cpa"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_distance_cpa"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_distance_cpa"("public"."geometry", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_eq"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_eq"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_eq"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_eq"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_ge"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_ge"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_ge"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_ge"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_compress_2d"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_compress_2d"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_compress_2d"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_compress_2d"("internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_compress_nd"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_compress_nd"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_compress_nd"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_compress_nd"("internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_consistent_2d"("internal", "public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_2d"("internal", "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_2d"("internal", "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_2d"("internal", "public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "geometry_gist_consistent_nd"("internal", "public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_nd"("internal", "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_nd"("internal", "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_nd"("internal", "public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "geometry_gist_decompress_2d"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_2d"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_2d"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_2d"("internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_decompress_nd"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_nd"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_nd"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_nd"("internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_distance_2d"("internal", "public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_distance_2d"("internal", "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_distance_2d"("internal", "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_distance_2d"("internal", "public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "geometry_gist_distance_nd"("internal", "public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_distance_nd"("internal", "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_distance_nd"("internal", "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_distance_nd"("internal", "public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "geometry_gist_penalty_2d"("internal", "internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_2d"("internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_2d"("internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_2d"("internal", "internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_penalty_nd"("internal", "internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_nd"("internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_nd"("internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_nd"("internal", "internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_picksplit_2d"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_2d"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_picksplit_nd"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_nd"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_same_2d"("geom1" "public"."geometry", "geom2" "public"."geometry", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_same_2d"("geom1" "public"."geometry", "geom2" "public"."geometry", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_same_2d"("geom1" "public"."geometry", "geom2" "public"."geometry", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_same_2d"("geom1" "public"."geometry", "geom2" "public"."geometry", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_same_nd"("public"."geometry", "public"."geometry", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_same_nd"("public"."geometry", "public"."geometry", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_same_nd"("public"."geometry", "public"."geometry", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_same_nd"("public"."geometry", "public"."geometry", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_union_2d"("bytea", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_union_2d"("bytea", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_union_2d"("bytea", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_union_2d"("bytea", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gist_union_nd"("bytea", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gist_union_nd"("bytea", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_union_nd"("bytea", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_union_nd"("bytea", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_gt"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_gt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_hash"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_hash"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_hash"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_hash"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_le"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_le"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_le"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_le"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_left"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_left"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_left"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_left"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_lt"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_lt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_lt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_lt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_overabove"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_overabove"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overabove"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overabove"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_overbelow"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_overbelow"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overbelow"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overbelow"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_overlaps_3d"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_overlaps_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overlaps_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overlaps_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_overlaps_nd"("public"."geometry", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_overlaps_nd"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overlaps_nd"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overlaps_nd"("public"."geometry", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_overleft"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_overleft"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overleft"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overleft"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_overright"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_overright"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overright"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overright"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_right"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_right"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_right"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_right"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_same"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_same"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_same"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_same"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_same_3d"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_same_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_same_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_same_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_same_nd"("public"."geometry", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_same_nd"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_same_nd"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_same_nd"("public"."geometry", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_sortsupport"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_sortsupport"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_sortsupport"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_sortsupport"("internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_choose_2d"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_2d"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_choose_3d"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_3d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_3d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_3d"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_choose_nd"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_nd"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_compress_2d"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_2d"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_2d"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_2d"("internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_compress_3d"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_3d"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_3d"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_3d"("internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_compress_nd"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_nd"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_nd"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_nd"("internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_config_2d"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_config_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_2d"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_config_3d"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_config_3d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_3d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_3d"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_config_nd"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_config_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_nd"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_inner_consistent_2d"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_2d"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_inner_consistent_3d"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_3d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_3d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_3d"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_inner_consistent_nd"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_nd"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_leaf_consistent_2d"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_2d"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_leaf_consistent_3d"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_3d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_3d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_3d"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_leaf_consistent_nd"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_nd"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_picksplit_2d"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_2d"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_picksplit_3d"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_3d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_3d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_3d"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_spgist_picksplit_nd"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_nd"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "geometry_within"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometry_within_nd"("public"."geometry", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometry_within_nd"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_within_nd"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_within_nd"("public"."geometry", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geometrytype"("public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geography") TO "service_role";


--
-- Name: FUNCTION "geometrytype"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "geomfromewkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geomfromewkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."geomfromewkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geomfromewkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "geomfromewkt"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."geomfromewkt"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."geomfromewkt"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geomfromewkt"("text") TO "service_role";


--
-- Name: FUNCTION "get_neighbor_count"("radius" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_neighbor_count"("radius" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_neighbor_count"("radius" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_neighbor_count"("radius" integer) TO "service_role";


--
-- Name: FUNCTION "get_neighbor_count"("radius" integer, "point" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_neighbor_count"("radius" integer, "point" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_neighbor_count"("radius" integer, "point" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_neighbor_count"("radius" integer, "point" "text") TO "service_role";


--
-- Name: FUNCTION "get_proj4_from_srid"(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_proj4_from_srid"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_proj4_from_srid"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_proj4_from_srid"(integer) TO "service_role";


--
-- Name: FUNCTION "gettransactionid"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gettransactionid"() TO "anon";
GRANT ALL ON FUNCTION "public"."gettransactionid"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."gettransactionid"() TO "service_role";


--
-- Name: FUNCTION "gserialized_gist_joinsel_2d"("internal", "oid", "internal", smallint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_2d"("internal", "oid", "internal", smallint) TO "anon";
GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_2d"("internal", "oid", "internal", smallint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_2d"("internal", "oid", "internal", smallint) TO "service_role";


--
-- Name: FUNCTION "gserialized_gist_joinsel_nd"("internal", "oid", "internal", smallint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_nd"("internal", "oid", "internal", smallint) TO "anon";
GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_nd"("internal", "oid", "internal", smallint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_nd"("internal", "oid", "internal", smallint) TO "service_role";


--
-- Name: FUNCTION "gserialized_gist_sel_2d"("internal", "oid", "internal", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_2d"("internal", "oid", "internal", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_2d"("internal", "oid", "internal", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_2d"("internal", "oid", "internal", integer) TO "service_role";


--
-- Name: FUNCTION "gserialized_gist_sel_nd"("internal", "oid", "internal", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_nd"("internal", "oid", "internal", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_nd"("internal", "oid", "internal", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_nd"("internal", "oid", "internal", integer) TO "service_role";


--
-- Name: FUNCTION "handle_new_user"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";


--
-- Name: FUNCTION "is_contained_2d"("public"."box2df", "public"."box2df"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."box2df") TO "service_role";


--
-- Name: FUNCTION "is_contained_2d"("public"."box2df", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "is_contained_2d"("public"."geometry", "public"."box2df"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."geometry", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."geometry", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."geometry", "public"."box2df") TO "service_role";


--
-- Name: FUNCTION "lockrow"("text", "text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text") TO "service_role";


--
-- Name: FUNCTION "lockrow"("text", "text", "text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text") TO "service_role";


--
-- Name: FUNCTION "lockrow"("text", "text", "text", timestamp without time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", timestamp without time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", timestamp without time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", timestamp without time zone) TO "service_role";


--
-- Name: FUNCTION "lockrow"("text", "text", "text", "text", timestamp without time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text", timestamp without time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text", timestamp without time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text", timestamp without time zone) TO "service_role";


--
-- Name: FUNCTION "longtransactionsenabled"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."longtransactionsenabled"() TO "anon";
GRANT ALL ON FUNCTION "public"."longtransactionsenabled"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."longtransactionsenabled"() TO "service_role";


--
-- Name: FUNCTION "overlaps_2d"("public"."box2df", "public"."box2df"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."box2df") TO "service_role";


--
-- Name: FUNCTION "overlaps_2d"("public"."box2df", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "overlaps_2d"("public"."geometry", "public"."box2df"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."geometry", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."geometry", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."geometry", "public"."box2df") TO "service_role";


--
-- Name: FUNCTION "overlaps_geog"("public"."geography", "public"."gidx"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."geography", "public"."gidx") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."geography", "public"."gidx") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."geography", "public"."gidx") TO "service_role";


--
-- Name: FUNCTION "overlaps_geog"("public"."gidx", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "overlaps_geog"("public"."gidx", "public"."gidx"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."gidx") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."gidx") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."gidx") TO "service_role";


--
-- Name: FUNCTION "overlaps_nd"("public"."geometry", "public"."gidx"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."geometry", "public"."gidx") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."geometry", "public"."gidx") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."geometry", "public"."gidx") TO "service_role";


--
-- Name: FUNCTION "overlaps_nd"("public"."gidx", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "overlaps_nd"("public"."gidx", "public"."gidx"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."gidx") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."gidx") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."gidx") TO "service_role";


--
-- Name: FUNCTION "pgis_asgeobuf_finalfn"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_finalfn"("internal") TO "service_role";


--
-- Name: FUNCTION "pgis_asgeobuf_transfn"("internal", "anyelement"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement") TO "service_role";


--
-- Name: FUNCTION "pgis_asgeobuf_transfn"("internal", "anyelement", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement", "text") TO "service_role";


--
-- Name: FUNCTION "pgis_asmvt_combinefn"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asmvt_combinefn"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_combinefn"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_combinefn"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "pgis_asmvt_deserialfn"("bytea", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asmvt_deserialfn"("bytea", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_deserialfn"("bytea", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_deserialfn"("bytea", "internal") TO "service_role";


--
-- Name: FUNCTION "pgis_asmvt_finalfn"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asmvt_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_finalfn"("internal") TO "service_role";


--
-- Name: FUNCTION "pgis_asmvt_serialfn"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asmvt_serialfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_serialfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_serialfn"("internal") TO "service_role";


--
-- Name: FUNCTION "pgis_asmvt_transfn"("internal", "anyelement"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement") TO "service_role";


--
-- Name: FUNCTION "pgis_asmvt_transfn"("internal", "anyelement", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text") TO "service_role";


--
-- Name: FUNCTION "pgis_asmvt_transfn"("internal", "anyelement", "text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer) TO "service_role";


--
-- Name: FUNCTION "pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text") TO "service_role";


--
-- Name: FUNCTION "pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text", "text") TO "service_role";


--
-- Name: FUNCTION "pgis_geometry_accum_transfn"("internal", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision, integer) TO "service_role";


--
-- Name: FUNCTION "pgis_geometry_clusterintersecting_finalfn"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterintersecting_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterintersecting_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterintersecting_finalfn"("internal") TO "service_role";


--
-- Name: FUNCTION "pgis_geometry_clusterwithin_finalfn"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterwithin_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterwithin_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterwithin_finalfn"("internal") TO "service_role";


--
-- Name: FUNCTION "pgis_geometry_collect_finalfn"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_geometry_collect_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_collect_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_collect_finalfn"("internal") TO "service_role";


--
-- Name: FUNCTION "pgis_geometry_makeline_finalfn"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_geometry_makeline_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_makeline_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_makeline_finalfn"("internal") TO "service_role";


--
-- Name: FUNCTION "pgis_geometry_polygonize_finalfn"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_geometry_polygonize_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_polygonize_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_polygonize_finalfn"("internal") TO "service_role";


--
-- Name: FUNCTION "pgis_geometry_union_finalfn"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."pgis_geometry_union_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_finalfn"("internal") TO "service_role";


--
-- Name: FUNCTION "populate_geometry_columns"("use_typmod" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("use_typmod" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("use_typmod" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("use_typmod" boolean) TO "service_role";


--
-- Name: FUNCTION "populate_geometry_columns"("tbl_oid" "oid", "use_typmod" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("tbl_oid" "oid", "use_typmod" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("tbl_oid" "oid", "use_typmod" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("tbl_oid" "oid", "use_typmod" boolean) TO "service_role";


--
-- Name: FUNCTION "postgis_addbbox"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_addbbox"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_addbbox"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_addbbox"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "postgis_cache_bbox"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_cache_bbox"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_cache_bbox"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_cache_bbox"() TO "service_role";


--
-- Name: FUNCTION "postgis_constraint_dims"("geomschema" "text", "geomtable" "text", "geomcolumn" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_constraint_dims"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_constraint_dims"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_constraint_dims"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "service_role";


--
-- Name: FUNCTION "postgis_constraint_srid"("geomschema" "text", "geomtable" "text", "geomcolumn" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_constraint_srid"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_constraint_srid"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_constraint_srid"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "service_role";


--
-- Name: FUNCTION "postgis_constraint_type"("geomschema" "text", "geomtable" "text", "geomcolumn" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_constraint_type"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_constraint_type"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_constraint_type"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "service_role";


--
-- Name: FUNCTION "postgis_dropbbox"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_dropbbox"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_dropbbox"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_dropbbox"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "postgis_extensions_upgrade"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_extensions_upgrade"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_extensions_upgrade"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_extensions_upgrade"() TO "service_role";


--
-- Name: FUNCTION "postgis_full_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_full_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_full_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_full_version"() TO "service_role";


--
-- Name: FUNCTION "postgis_geos_noop"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_geos_noop"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_geos_noop"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_geos_noop"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "postgis_geos_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_geos_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_geos_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_geos_version"() TO "service_role";


--
-- Name: FUNCTION "postgis_getbbox"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_getbbox"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_getbbox"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_getbbox"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "postgis_hasbbox"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_hasbbox"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_hasbbox"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_hasbbox"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "postgis_index_supportfn"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_index_supportfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_index_supportfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_index_supportfn"("internal") TO "service_role";


--
-- Name: FUNCTION "postgis_lib_build_date"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_lib_build_date"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_lib_build_date"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_lib_build_date"() TO "service_role";


--
-- Name: FUNCTION "postgis_lib_revision"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_lib_revision"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_lib_revision"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_lib_revision"() TO "service_role";


--
-- Name: FUNCTION "postgis_lib_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_lib_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_lib_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_lib_version"() TO "service_role";


--
-- Name: FUNCTION "postgis_libjson_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_libjson_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_libjson_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_libjson_version"() TO "service_role";


--
-- Name: FUNCTION "postgis_liblwgeom_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_liblwgeom_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_liblwgeom_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_liblwgeom_version"() TO "service_role";


--
-- Name: FUNCTION "postgis_libprotobuf_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_libprotobuf_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_libprotobuf_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_libprotobuf_version"() TO "service_role";


--
-- Name: FUNCTION "postgis_libxml_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_libxml_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_libxml_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_libxml_version"() TO "service_role";


--
-- Name: FUNCTION "postgis_noop"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_noop"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_noop"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_noop"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "postgis_proj_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_proj_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_proj_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_proj_version"() TO "service_role";


--
-- Name: FUNCTION "postgis_scripts_build_date"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_scripts_build_date"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_scripts_build_date"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_scripts_build_date"() TO "service_role";


--
-- Name: FUNCTION "postgis_scripts_installed"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_scripts_installed"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_scripts_installed"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_scripts_installed"() TO "service_role";


--
-- Name: FUNCTION "postgis_scripts_released"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_scripts_released"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_scripts_released"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_scripts_released"() TO "service_role";


--
-- Name: FUNCTION "postgis_svn_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_svn_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_svn_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_svn_version"() TO "service_role";


--
-- Name: FUNCTION "postgis_transform_geometry"("geom" "public"."geometry", "text", "text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_transform_geometry"("geom" "public"."geometry", "text", "text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_transform_geometry"("geom" "public"."geometry", "text", "text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_transform_geometry"("geom" "public"."geometry", "text", "text", integer) TO "service_role";


--
-- Name: FUNCTION "postgis_type_name"("geomname" character varying, "coord_dimension" integer, "use_new_name" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_type_name"("geomname" character varying, "coord_dimension" integer, "use_new_name" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_type_name"("geomname" character varying, "coord_dimension" integer, "use_new_name" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_type_name"("geomname" character varying, "coord_dimension" integer, "use_new_name" boolean) TO "service_role";


--
-- Name: FUNCTION "postgis_typmod_dims"(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_typmod_dims"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_typmod_dims"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_typmod_dims"(integer) TO "service_role";


--
-- Name: FUNCTION "postgis_typmod_srid"(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_typmod_srid"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_typmod_srid"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_typmod_srid"(integer) TO "service_role";


--
-- Name: FUNCTION "postgis_typmod_type"(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_typmod_type"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_typmod_type"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_typmod_type"(integer) TO "service_role";


--
-- Name: FUNCTION "postgis_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_version"() TO "service_role";


--
-- Name: FUNCTION "postgis_wagyu_version"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."postgis_wagyu_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_wagyu_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_wagyu_version"() TO "service_role";


--
-- Name: FUNCTION "st_3dclosestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3dclosestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dclosestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dclosestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_3ddistance"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3ddistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3ddistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3ddistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_3dlength"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3dlength"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dlength"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dlength"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_3dlineinterpolatepoint"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3dlineinterpolatepoint"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dlineinterpolatepoint"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dlineinterpolatepoint"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_3dlongestline"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3dlongestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dlongestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dlongestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_3dmakebox"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3dmakebox"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dmakebox"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dmakebox"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_3dmaxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3dmaxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dmaxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dmaxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_3dperimeter"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3dperimeter"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dperimeter"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dperimeter"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_3dshortestline"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3dshortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dshortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dshortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_addmeasure"("public"."geometry", double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_addmeasure"("public"."geometry", double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_addmeasure"("public"."geometry", double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_addmeasure"("public"."geometry", double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_angle"("line1" "public"."geometry", "line2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_angle"("line1" "public"."geometry", "line2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_angle"("line1" "public"."geometry", "line2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_angle"("line1" "public"."geometry", "line2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_angle"("pt1" "public"."geometry", "pt2" "public"."geometry", "pt3" "public"."geometry", "pt4" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_angle"("pt1" "public"."geometry", "pt2" "public"."geometry", "pt3" "public"."geometry", "pt4" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_angle"("pt1" "public"."geometry", "pt2" "public"."geometry", "pt3" "public"."geometry", "pt4" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_angle"("pt1" "public"."geometry", "pt2" "public"."geometry", "pt3" "public"."geometry", "pt4" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_area"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_area"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_area"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_area"("text") TO "service_role";


--
-- Name: FUNCTION "st_area"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_area"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_area"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_area"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_area"("geog" "public"."geography", "use_spheroid" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_area"("geog" "public"."geography", "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_area"("geog" "public"."geography", "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_area"("geog" "public"."geography", "use_spheroid" boolean) TO "service_role";


--
-- Name: FUNCTION "st_area2d"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_area2d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_area2d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_area2d"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_asbinary"("public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography") TO "service_role";


--
-- Name: FUNCTION "st_asbinary"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_asbinary"("public"."geography", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography", "text") TO "service_role";


--
-- Name: FUNCTION "st_asbinary"("public"."geometry", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry", "text") TO "service_role";


--
-- Name: FUNCTION "st_asencodedpolyline"("geom" "public"."geometry", "nprecision" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asencodedpolyline"("geom" "public"."geometry", "nprecision" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asencodedpolyline"("geom" "public"."geometry", "nprecision" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asencodedpolyline"("geom" "public"."geometry", "nprecision" integer) TO "service_role";


--
-- Name: FUNCTION "st_asewkb"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_asewkb"("public"."geometry", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry", "text") TO "service_role";


--
-- Name: FUNCTION "st_asewkt"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asewkt"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkt"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkt"("text") TO "service_role";


--
-- Name: FUNCTION "st_asewkt"("public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography") TO "service_role";


--
-- Name: FUNCTION "st_asewkt"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_asewkt"("public"."geography", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography", integer) TO "service_role";


--
-- Name: FUNCTION "st_asewkt"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_asgeojson"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asgeojson"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("text") TO "service_role";


--
-- Name: FUNCTION "st_asgeojson"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asgeojson"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer) TO "service_role";


--
-- Name: FUNCTION "st_asgeojson"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asgeojson"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "service_role";


--
-- Name: FUNCTION "st_asgeojson"("r" "record", "geom_column" "text", "maxdecimaldigits" integer, "pretty_bool" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asgeojson"("r" "record", "geom_column" "text", "maxdecimaldigits" integer, "pretty_bool" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("r" "record", "geom_column" "text", "maxdecimaldigits" integer, "pretty_bool" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("r" "record", "geom_column" "text", "maxdecimaldigits" integer, "pretty_bool" boolean) TO "service_role";


--
-- Name: FUNCTION "st_asgml"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asgml"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgml"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgml"("text") TO "service_role";


--
-- Name: FUNCTION "st_asgml"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asgml"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgml"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgml"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "service_role";


--
-- Name: FUNCTION "st_asgml"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asgml"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgml"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgml"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "service_role";


--
-- Name: FUNCTION "st_asgml"("version" integer, "geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "service_role";


--
-- Name: FUNCTION "st_asgml"("version" integer, "geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "service_role";


--
-- Name: FUNCTION "st_ashexewkb"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_ashexewkb"("public"."geometry", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry", "text") TO "service_role";


--
-- Name: FUNCTION "st_askml"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_askml"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_askml"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_askml"("text") TO "service_role";


--
-- Name: FUNCTION "st_askml"("geog" "public"."geography", "maxdecimaldigits" integer, "nprefix" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_askml"("geog" "public"."geography", "maxdecimaldigits" integer, "nprefix" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_askml"("geog" "public"."geography", "maxdecimaldigits" integer, "nprefix" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_askml"("geog" "public"."geography", "maxdecimaldigits" integer, "nprefix" "text") TO "service_role";


--
-- Name: FUNCTION "st_askml"("geom" "public"."geometry", "maxdecimaldigits" integer, "nprefix" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_askml"("geom" "public"."geometry", "maxdecimaldigits" integer, "nprefix" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_askml"("geom" "public"."geometry", "maxdecimaldigits" integer, "nprefix" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_askml"("geom" "public"."geometry", "maxdecimaldigits" integer, "nprefix" "text") TO "service_role";


--
-- Name: FUNCTION "st_aslatlontext"("geom" "public"."geometry", "tmpl" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_aslatlontext"("geom" "public"."geometry", "tmpl" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_aslatlontext"("geom" "public"."geometry", "tmpl" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_aslatlontext"("geom" "public"."geometry", "tmpl" "text") TO "service_role";


--
-- Name: FUNCTION "st_asmvtgeom"("geom" "public"."geometry", "bounds" "public"."box2d", "extent" integer, "buffer" integer, "clip_geom" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asmvtgeom"("geom" "public"."geometry", "bounds" "public"."box2d", "extent" integer, "buffer" integer, "clip_geom" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvtgeom"("geom" "public"."geometry", "bounds" "public"."box2d", "extent" integer, "buffer" integer, "clip_geom" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvtgeom"("geom" "public"."geometry", "bounds" "public"."box2d", "extent" integer, "buffer" integer, "clip_geom" boolean) TO "service_role";


--
-- Name: FUNCTION "st_assvg"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_assvg"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_assvg"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_assvg"("text") TO "service_role";


--
-- Name: FUNCTION "st_assvg"("geog" "public"."geography", "rel" integer, "maxdecimaldigits" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_assvg"("geog" "public"."geography", "rel" integer, "maxdecimaldigits" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_assvg"("geog" "public"."geography", "rel" integer, "maxdecimaldigits" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_assvg"("geog" "public"."geography", "rel" integer, "maxdecimaldigits" integer) TO "service_role";


--
-- Name: FUNCTION "st_assvg"("geom" "public"."geometry", "rel" integer, "maxdecimaldigits" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_assvg"("geom" "public"."geometry", "rel" integer, "maxdecimaldigits" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_assvg"("geom" "public"."geometry", "rel" integer, "maxdecimaldigits" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_assvg"("geom" "public"."geometry", "rel" integer, "maxdecimaldigits" integer) TO "service_role";


--
-- Name: FUNCTION "st_astext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_astext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_astext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astext"("text") TO "service_role";


--
-- Name: FUNCTION "st_astext"("public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography") TO "service_role";


--
-- Name: FUNCTION "st_astext"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_astext"("public"."geography", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography", integer) TO "service_role";


--
-- Name: FUNCTION "st_astext"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_astwkb"("geom" "public"."geometry", "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry", "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry", "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry", "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "service_role";


--
-- Name: FUNCTION "st_astwkb"("geom" "public"."geometry"[], "ids" bigint[], "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry"[], "ids" bigint[], "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry"[], "ids" bigint[], "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry"[], "ids" bigint[], "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "service_role";


--
-- Name: FUNCTION "st_asx3d"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asx3d"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asx3d"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asx3d"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "service_role";


--
-- Name: FUNCTION "st_azimuth"("geog1" "public"."geography", "geog2" "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_azimuth"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_azimuth"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_azimuth"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";


--
-- Name: FUNCTION "st_azimuth"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_azimuth"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_azimuth"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_azimuth"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_bdmpolyfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_bdmpolyfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_bdmpolyfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_bdmpolyfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_bdpolyfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_bdpolyfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_bdpolyfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_bdpolyfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_boundary"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_boundary"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_boundary"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_boundary"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_boundingdiagonal"("geom" "public"."geometry", "fits" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_boundingdiagonal"("geom" "public"."geometry", "fits" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_boundingdiagonal"("geom" "public"."geometry", "fits" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_boundingdiagonal"("geom" "public"."geometry", "fits" boolean) TO "service_role";


--
-- Name: FUNCTION "st_box2dfromgeohash"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_box2dfromgeohash"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_box2dfromgeohash"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_box2dfromgeohash"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_buffer"("text", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision) TO "service_role";


--
-- Name: FUNCTION "st_buffer"("public"."geography", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision) TO "service_role";


--
-- Name: FUNCTION "st_buffer"("text", double precision, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, integer) TO "service_role";


--
-- Name: FUNCTION "st_buffer"("text", double precision, "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, "text") TO "service_role";


--
-- Name: FUNCTION "st_buffer"("public"."geography", double precision, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, integer) TO "service_role";


--
-- Name: FUNCTION "st_buffer"("public"."geography", double precision, "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, "text") TO "service_role";


--
-- Name: FUNCTION "st_buffer"("geom" "public"."geometry", "radius" double precision, "quadsegs" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "quadsegs" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "quadsegs" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "quadsegs" integer) TO "service_role";


--
-- Name: FUNCTION "st_buffer"("geom" "public"."geometry", "radius" double precision, "options" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "options" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "options" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "options" "text") TO "service_role";


--
-- Name: FUNCTION "st_buildarea"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_buildarea"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_buildarea"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buildarea"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_centroid"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_centroid"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_centroid"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_centroid"("text") TO "service_role";


--
-- Name: FUNCTION "st_centroid"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_centroid"("public"."geography", "use_spheroid" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geography", "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geography", "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geography", "use_spheroid" boolean) TO "service_role";


--
-- Name: FUNCTION "st_chaikinsmoothing"("public"."geometry", integer, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_chaikinsmoothing"("public"."geometry", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_chaikinsmoothing"("public"."geometry", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_chaikinsmoothing"("public"."geometry", integer, boolean) TO "service_role";


--
-- Name: FUNCTION "st_cleangeometry"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_cleangeometry"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_cleangeometry"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_cleangeometry"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_clipbybox2d"("geom" "public"."geometry", "box" "public"."box2d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_clipbybox2d"("geom" "public"."geometry", "box" "public"."box2d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_clipbybox2d"("geom" "public"."geometry", "box" "public"."box2d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clipbybox2d"("geom" "public"."geometry", "box" "public"."box2d") TO "service_role";


--
-- Name: FUNCTION "st_closestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_closestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_closestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_closestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_closestpointofapproach"("public"."geometry", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_closestpointofapproach"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_closestpointofapproach"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_closestpointofapproach"("public"."geometry", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_clusterdbscan"("public"."geometry", "eps" double precision, "minpoints" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_clusterdbscan"("public"."geometry", "eps" double precision, "minpoints" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterdbscan"("public"."geometry", "eps" double precision, "minpoints" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterdbscan"("public"."geometry", "eps" double precision, "minpoints" integer) TO "service_role";


--
-- Name: FUNCTION "st_clusterintersecting"("public"."geometry"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry"[]) TO "service_role";


--
-- Name: FUNCTION "st_clusterkmeans"("geom" "public"."geometry", "k" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_clusterkmeans"("geom" "public"."geometry", "k" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterkmeans"("geom" "public"."geometry", "k" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterkmeans"("geom" "public"."geometry", "k" integer) TO "service_role";


--
-- Name: FUNCTION "st_clusterwithin"("public"."geometry"[], double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry"[], double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry"[], double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry"[], double precision) TO "service_role";


--
-- Name: FUNCTION "st_collect"("public"."geometry"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry"[]) TO "service_role";


--
-- Name: FUNCTION "st_collect"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_collect"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_collect"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collect"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_collectionextract"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_collectionextract"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_collectionhomogenize"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_collectionhomogenize"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_collectionhomogenize"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collectionhomogenize"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_combinebbox"("public"."box2d", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box2d", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box2d", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box2d", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_combinebbox"("public"."box3d", "public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."box3d") TO "service_role";


--
-- Name: FUNCTION "st_combinebbox"("public"."box3d", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_concavehull"("param_geom" "public"."geometry", "param_pctconvex" double precision, "param_allow_holes" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_concavehull"("param_geom" "public"."geometry", "param_pctconvex" double precision, "param_allow_holes" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_concavehull"("param_geom" "public"."geometry", "param_pctconvex" double precision, "param_allow_holes" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_concavehull"("param_geom" "public"."geometry", "param_pctconvex" double precision, "param_allow_holes" boolean) TO "service_role";


--
-- Name: FUNCTION "st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_convexhull"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_convexhull"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_convexhull"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_convexhull"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_coorddim"("geometry" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_coorddim"("geometry" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_coorddim"("geometry" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_coorddim"("geometry" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_coveredby"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_coveredby"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_coveredby"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_coveredby"("text", "text") TO "service_role";


--
-- Name: FUNCTION "st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";


--
-- Name: FUNCTION "st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_covers"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_covers"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_covers"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_covers"("text", "text") TO "service_role";


--
-- Name: FUNCTION "st_covers"("geog1" "public"."geography", "geog2" "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";


--
-- Name: FUNCTION "st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_cpawithin"("public"."geometry", "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_cpawithin"("public"."geometry", "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_cpawithin"("public"."geometry", "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_cpawithin"("public"."geometry", "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_curvetoline"("geom" "public"."geometry", "tol" double precision, "toltype" integer, "flags" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_curvetoline"("geom" "public"."geometry", "tol" double precision, "toltype" integer, "flags" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_curvetoline"("geom" "public"."geometry", "tol" double precision, "toltype" integer, "flags" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_curvetoline"("geom" "public"."geometry", "tol" double precision, "toltype" integer, "flags" integer) TO "service_role";


--
-- Name: FUNCTION "st_delaunaytriangles"("g1" "public"."geometry", "tolerance" double precision, "flags" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_delaunaytriangles"("g1" "public"."geometry", "tolerance" double precision, "flags" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_delaunaytriangles"("g1" "public"."geometry", "tolerance" double precision, "flags" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_delaunaytriangles"("g1" "public"."geometry", "tolerance" double precision, "flags" integer) TO "service_role";


--
-- Name: FUNCTION "st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_difference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_difference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_difference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_difference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "service_role";


--
-- Name: FUNCTION "st_dimension"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_dimension"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_dimension"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dimension"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_disjoint"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_disjoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_disjoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_disjoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_distance"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_distance"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_distance"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distance"("text", "text") TO "service_role";


--
-- Name: FUNCTION "st_distance"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_distance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_distance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_distance"("geog1" "public"."geography", "geog2" "public"."geography", "use_spheroid" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_distance"("geog1" "public"."geography", "geog2" "public"."geography", "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_distance"("geog1" "public"."geography", "geog2" "public"."geography", "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distance"("geog1" "public"."geography", "geog2" "public"."geography", "use_spheroid" boolean) TO "service_role";


--
-- Name: FUNCTION "st_distancecpa"("public"."geometry", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_distancecpa"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_distancecpa"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distancecpa"("public"."geometry", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry", "public"."spheroid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry", "public"."spheroid") TO "anon";
GRANT ALL ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry", "public"."spheroid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry", "public"."spheroid") TO "service_role";


--
-- Name: FUNCTION "st_dump"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_dump"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_dump"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dump"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_dumppoints"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_dumppoints"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_dumppoints"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dumppoints"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_dumprings"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_dumprings"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_dumprings"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dumprings"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_dwithin"("text", "text", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_dwithin"("text", "text", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_dwithin"("text", "text", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dwithin"("text", "text", double precision) TO "service_role";


--
-- Name: FUNCTION "st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "service_role";


--
-- Name: FUNCTION "st_endpoint"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_endpoint"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_endpoint"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_endpoint"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_envelope"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_envelope"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_envelope"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_envelope"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_estimatedextent"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text") TO "service_role";


--
-- Name: FUNCTION "st_estimatedextent"("text", "text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text") TO "service_role";


--
-- Name: FUNCTION "st_estimatedextent"("text", "text", "text", boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text", boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text", boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text", boolean) TO "service_role";


--
-- Name: FUNCTION "st_expand"("public"."box2d", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_expand"("public"."box2d", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."box2d", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."box2d", double precision) TO "service_role";


--
-- Name: FUNCTION "st_expand"("public"."box3d", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_expand"("public"."box3d", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."box3d", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."box3d", double precision) TO "service_role";


--
-- Name: FUNCTION "st_expand"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_expand"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_expand"("box" "public"."box2d", "dx" double precision, "dy" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box2d", "dx" double precision, "dy" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box2d", "dx" double precision, "dy" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box2d", "dx" double precision, "dy" double precision) TO "service_role";


--
-- Name: FUNCTION "st_expand"("box" "public"."box3d", "dx" double precision, "dy" double precision, "dz" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box3d", "dx" double precision, "dy" double precision, "dz" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box3d", "dx" double precision, "dy" double precision, "dz" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box3d", "dx" double precision, "dy" double precision, "dz" double precision) TO "service_role";


--
-- Name: FUNCTION "st_expand"("geom" "public"."geometry", "dx" double precision, "dy" double precision, "dz" double precision, "dm" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_expand"("geom" "public"."geometry", "dx" double precision, "dy" double precision, "dz" double precision, "dm" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("geom" "public"."geometry", "dx" double precision, "dy" double precision, "dz" double precision, "dm" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("geom" "public"."geometry", "dx" double precision, "dy" double precision, "dz" double precision, "dm" double precision) TO "service_role";


--
-- Name: FUNCTION "st_exteriorring"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_exteriorring"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_exteriorring"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_exteriorring"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_filterbym"("public"."geometry", double precision, double precision, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_filterbym"("public"."geometry", double precision, double precision, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_filterbym"("public"."geometry", double precision, double precision, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_filterbym"("public"."geometry", double precision, double precision, boolean) TO "service_role";


--
-- Name: FUNCTION "st_findextent"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text") TO "service_role";


--
-- Name: FUNCTION "st_findextent"("text", "text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text", "text") TO "service_role";


--
-- Name: FUNCTION "st_flipcoordinates"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_flipcoordinates"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_flipcoordinates"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_flipcoordinates"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_force2d"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_force2d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_force2d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_force2d"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_force3d"("geom" "public"."geometry", "zvalue" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_force3d"("geom" "public"."geometry", "zvalue" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_force3d"("geom" "public"."geometry", "zvalue" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_force3d"("geom" "public"."geometry", "zvalue" double precision) TO "service_role";


--
-- Name: FUNCTION "st_force3dm"("geom" "public"."geometry", "mvalue" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_force3dm"("geom" "public"."geometry", "mvalue" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_force3dm"("geom" "public"."geometry", "mvalue" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_force3dm"("geom" "public"."geometry", "mvalue" double precision) TO "service_role";


--
-- Name: FUNCTION "st_force3dz"("geom" "public"."geometry", "zvalue" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_force3dz"("geom" "public"."geometry", "zvalue" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_force3dz"("geom" "public"."geometry", "zvalue" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_force3dz"("geom" "public"."geometry", "zvalue" double precision) TO "service_role";


--
-- Name: FUNCTION "st_force4d"("geom" "public"."geometry", "zvalue" double precision, "mvalue" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_force4d"("geom" "public"."geometry", "zvalue" double precision, "mvalue" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_force4d"("geom" "public"."geometry", "zvalue" double precision, "mvalue" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_force4d"("geom" "public"."geometry", "zvalue" double precision, "mvalue" double precision) TO "service_role";


--
-- Name: FUNCTION "st_forcecollection"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_forcecollection"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcecollection"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcecollection"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_forcecurve"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_forcecurve"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcecurve"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcecurve"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_forcepolygonccw"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_forcepolygonccw"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcepolygonccw"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcepolygonccw"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_forcepolygoncw"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_forcepolygoncw"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcepolygoncw"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcepolygoncw"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_forcerhr"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_forcerhr"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcerhr"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcerhr"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_forcesfs"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_forcesfs"("public"."geometry", "version" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry", "version" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry", "version" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry", "version" "text") TO "service_role";


--
-- Name: FUNCTION "st_frechetdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_frechetdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_frechetdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_frechetdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_generatepoints"("area" "public"."geometry", "npoints" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer) TO "service_role";


--
-- Name: FUNCTION "st_generatepoints"("area" "public"."geometry", "npoints" integer, "seed" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer, "seed" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer, "seed" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer, "seed" integer) TO "service_role";


--
-- Name: FUNCTION "st_geogfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geogfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geogfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geogfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_geogfromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geogfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geogfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geogfromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_geographyfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geographyfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geographyfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geographyfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_geohash"("geog" "public"."geography", "maxchars" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geohash"("geog" "public"."geography", "maxchars" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geohash"("geog" "public"."geography", "maxchars" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geohash"("geog" "public"."geography", "maxchars" integer) TO "service_role";


--
-- Name: FUNCTION "st_geohash"("geom" "public"."geometry", "maxchars" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geohash"("geom" "public"."geometry", "maxchars" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geohash"("geom" "public"."geometry", "maxchars" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geohash"("geom" "public"."geometry", "maxchars" integer) TO "service_role";


--
-- Name: FUNCTION "st_geomcollfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_geomcollfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_geomcollfromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_geomcollfromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_geometricmedian"("g" "public"."geometry", "tolerance" double precision, "max_iter" integer, "fail_if_not_converged" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geometricmedian"("g" "public"."geometry", "tolerance" double precision, "max_iter" integer, "fail_if_not_converged" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geometricmedian"("g" "public"."geometry", "tolerance" double precision, "max_iter" integer, "fail_if_not_converged" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geometricmedian"("g" "public"."geometry", "tolerance" double precision, "max_iter" integer, "fail_if_not_converged" boolean) TO "service_role";


--
-- Name: FUNCTION "st_geometryfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_geometryfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_geometryn"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geometryn"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geometryn"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geometryn"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_geometrytype"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geometrytype"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geometrytype"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geometrytype"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_geomfromewkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromewkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromewkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromewkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_geomfromewkt"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromewkt"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromewkt"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromewkt"("text") TO "service_role";


--
-- Name: FUNCTION "st_geomfromgeohash"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromgeohash"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgeohash"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgeohash"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_geomfromgeojson"("json"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("json") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("json") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("json") TO "service_role";


--
-- Name: FUNCTION "st_geomfromgeojson"("jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("jsonb") TO "service_role";


--
-- Name: FUNCTION "st_geomfromgeojson"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("text") TO "service_role";


--
-- Name: FUNCTION "st_geomfromgml"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text") TO "service_role";


--
-- Name: FUNCTION "st_geomfromgml"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_geomfromkml"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromkml"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromkml"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromkml"("text") TO "service_role";


--
-- Name: FUNCTION "st_geomfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_geomfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_geomfromtwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromtwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromtwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromtwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_geomfromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_geomfromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_gmltosql"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_gmltosql"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_gmltosql"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_gmltosql"("text") TO "service_role";


--
-- Name: FUNCTION "st_gmltosql"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_gmltosql"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_gmltosql"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_gmltosql"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_hasarc"("geometry" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_hasarc"("geometry" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_hasarc"("geometry" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_hasarc"("geometry" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_hexagon"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_hexagon"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_hexagon"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_hexagon"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_hexagongrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_hexagongrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_hexagongrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_hexagongrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "service_role";


--
-- Name: FUNCTION "st_interiorringn"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_interiorringn"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_interiorringn"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_interiorringn"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_interpolatepoint"("line" "public"."geometry", "point" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_interpolatepoint"("line" "public"."geometry", "point" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_interpolatepoint"("line" "public"."geometry", "point" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_interpolatepoint"("line" "public"."geometry", "point" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_intersection"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_intersection"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersection"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersection"("text", "text") TO "service_role";


--
-- Name: FUNCTION "st_intersection"("public"."geography", "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_intersection"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersection"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersection"("public"."geography", "public"."geography") TO "service_role";


--
-- Name: FUNCTION "st_intersection"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_intersection"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersection"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersection"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "service_role";


--
-- Name: FUNCTION "st_intersects"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_intersects"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersects"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersects"("text", "text") TO "service_role";


--
-- Name: FUNCTION "st_intersects"("geog1" "public"."geography", "geog2" "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_intersects"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersects"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersects"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";


--
-- Name: FUNCTION "st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_isclosed"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_isclosed"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isclosed"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isclosed"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_iscollection"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_iscollection"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_iscollection"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_iscollection"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_isempty"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_isempty"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isempty"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isempty"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_ispolygonccw"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_ispolygonccw"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ispolygonccw"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ispolygonccw"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_ispolygoncw"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_ispolygoncw"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ispolygoncw"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ispolygoncw"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_isring"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_isring"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isring"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isring"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_issimple"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_issimple"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_issimple"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_issimple"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_isvalid"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_isvalid"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_isvaliddetail"("geom" "public"."geometry", "flags" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_isvaliddetail"("geom" "public"."geometry", "flags" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvaliddetail"("geom" "public"."geometry", "flags" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvaliddetail"("geom" "public"."geometry", "flags" integer) TO "service_role";


--
-- Name: FUNCTION "st_isvalidreason"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_isvalidreason"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_isvalidtrajectory"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_isvalidtrajectory"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvalidtrajectory"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvalidtrajectory"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_length"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_length"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_length"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_length"("text") TO "service_role";


--
-- Name: FUNCTION "st_length"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_length"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_length"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_length"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_length"("geog" "public"."geography", "use_spheroid" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_length"("geog" "public"."geography", "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_length"("geog" "public"."geography", "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_length"("geog" "public"."geography", "use_spheroid" boolean) TO "service_role";


--
-- Name: FUNCTION "st_length2d"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_length2d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_length2d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_length2d"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_length2dspheroid"("public"."geometry", "public"."spheroid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_length2dspheroid"("public"."geometry", "public"."spheroid") TO "anon";
GRANT ALL ON FUNCTION "public"."st_length2dspheroid"("public"."geometry", "public"."spheroid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_length2dspheroid"("public"."geometry", "public"."spheroid") TO "service_role";


--
-- Name: FUNCTION "st_lengthspheroid"("public"."geometry", "public"."spheroid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_lengthspheroid"("public"."geometry", "public"."spheroid") TO "anon";
GRANT ALL ON FUNCTION "public"."st_lengthspheroid"("public"."geometry", "public"."spheroid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_lengthspheroid"("public"."geometry", "public"."spheroid") TO "service_role";


--
-- Name: FUNCTION "st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_linefromencodedpolyline"("txtin" "text", "nprecision" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linefromencodedpolyline"("txtin" "text", "nprecision" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefromencodedpolyline"("txtin" "text", "nprecision" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefromencodedpolyline"("txtin" "text", "nprecision" integer) TO "service_role";


--
-- Name: FUNCTION "st_linefrommultipoint"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linefrommultipoint"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefrommultipoint"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefrommultipoint"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_linefromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linefromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_linefromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linefromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_linefromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_linefromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_lineinterpolatepoint"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoint"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoint"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoint"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_lineinterpolatepoints"("public"."geometry", double precision, "repeat" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoints"("public"."geometry", double precision, "repeat" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoints"("public"."geometry", double precision, "repeat" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoints"("public"."geometry", double precision, "repeat" boolean) TO "service_role";


--
-- Name: FUNCTION "st_linelocatepoint"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linelocatepoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linelocatepoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linelocatepoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_linemerge"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linemerge"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linemerge"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linemerge"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_linestringfromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_linestringfromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_linesubstring"("public"."geometry", double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linesubstring"("public"."geometry", double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_linesubstring"("public"."geometry", double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linesubstring"("public"."geometry", double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_linetocurve"("geometry" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_linetocurve"("geometry" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linetocurve"("geometry" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linetocurve"("geometry" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_locatealong"("geometry" "public"."geometry", "measure" double precision, "leftrightoffset" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_locatealong"("geometry" "public"."geometry", "measure" double precision, "leftrightoffset" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_locatealong"("geometry" "public"."geometry", "measure" double precision, "leftrightoffset" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_locatealong"("geometry" "public"."geometry", "measure" double precision, "leftrightoffset" double precision) TO "service_role";


--
-- Name: FUNCTION "st_locatebetween"("geometry" "public"."geometry", "frommeasure" double precision, "tomeasure" double precision, "leftrightoffset" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_locatebetween"("geometry" "public"."geometry", "frommeasure" double precision, "tomeasure" double precision, "leftrightoffset" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_locatebetween"("geometry" "public"."geometry", "frommeasure" double precision, "tomeasure" double precision, "leftrightoffset" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_locatebetween"("geometry" "public"."geometry", "frommeasure" double precision, "tomeasure" double precision, "leftrightoffset" double precision) TO "service_role";


--
-- Name: FUNCTION "st_locatebetweenelevations"("geometry" "public"."geometry", "fromelevation" double precision, "toelevation" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_locatebetweenelevations"("geometry" "public"."geometry", "fromelevation" double precision, "toelevation" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_locatebetweenelevations"("geometry" "public"."geometry", "fromelevation" double precision, "toelevation" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_locatebetweenelevations"("geometry" "public"."geometry", "fromelevation" double precision, "toelevation" double precision) TO "service_role";


--
-- Name: FUNCTION "st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_m"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_m"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_m"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_m"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_makebox2d"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makebox2d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_makebox2d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makebox2d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_makeenvelope"(double precision, double precision, double precision, double precision, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makeenvelope"(double precision, double precision, double precision, double precision, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makeenvelope"(double precision, double precision, double precision, double precision, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makeenvelope"(double precision, double precision, double precision, double precision, integer) TO "service_role";


--
-- Name: FUNCTION "st_makeline"("public"."geometry"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry"[]) TO "service_role";


--
-- Name: FUNCTION "st_makeline"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makeline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_makeline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makeline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_makepoint"(double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_makepoint"(double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_makepoint"(double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_makepointm"(double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makepointm"(double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepointm"(double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepointm"(double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_makepolygon"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_makepolygon"("public"."geometry", "public"."geometry"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry", "public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry", "public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry", "public"."geometry"[]) TO "service_role";


--
-- Name: FUNCTION "st_makevalid"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makevalid"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_makevalid"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makevalid"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_maximuminscribedcircle"("public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_maximuminscribedcircle"("public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_maximuminscribedcircle"("public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_maximuminscribedcircle"("public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" double precision) TO "service_role";


--
-- Name: FUNCTION "st_memsize"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_memsize"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_memsize"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_memsize"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_minimumboundingcircle"("inputgeom" "public"."geometry", "segs_per_quarter" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_minimumboundingcircle"("inputgeom" "public"."geometry", "segs_per_quarter" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_minimumboundingcircle"("inputgeom" "public"."geometry", "segs_per_quarter" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_minimumboundingcircle"("inputgeom" "public"."geometry", "segs_per_quarter" integer) TO "service_role";


--
-- Name: FUNCTION "st_minimumboundingradius"("public"."geometry", OUT "center" "public"."geometry", OUT "radius" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_minimumboundingradius"("public"."geometry", OUT "center" "public"."geometry", OUT "radius" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_minimumboundingradius"("public"."geometry", OUT "center" "public"."geometry", OUT "radius" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_minimumboundingradius"("public"."geometry", OUT "center" "public"."geometry", OUT "radius" double precision) TO "service_role";


--
-- Name: FUNCTION "st_minimumclearance"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_minimumclearance"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_minimumclearance"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_minimumclearance"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_minimumclearanceline"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_minimumclearanceline"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_minimumclearanceline"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_minimumclearanceline"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_mlinefromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_mlinefromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_mlinefromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_mlinefromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_mpointfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_mpointfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_mpointfromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_mpointfromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_mpolyfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_mpolyfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_mpolyfromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_mpolyfromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_multi"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_multi"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multi"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multi"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_multilinefromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_multilinefromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multilinefromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multilinefromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_multilinestringfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_multilinestringfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_multipointfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_multipointfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipointfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipointfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_multipointfromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_multipointfromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_multipolyfromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_multipolyfromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_multipolygonfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_multipolygonfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_ndims"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_ndims"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ndims"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ndims"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_node"("g" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_node"("g" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_node"("g" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_node"("g" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_normalize"("geom" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_normalize"("geom" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_normalize"("geom" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_normalize"("geom" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_npoints"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_npoints"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_npoints"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_npoints"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_nrings"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_nrings"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_nrings"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_nrings"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_numgeometries"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_numgeometries"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_numgeometries"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_numgeometries"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_numinteriorring"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_numinteriorring"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_numinteriorring"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_numinteriorring"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_numinteriorrings"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_numinteriorrings"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_numinteriorrings"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_numinteriorrings"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_numpatches"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_numpatches"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_numpatches"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_numpatches"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_numpoints"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_numpoints"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_numpoints"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_numpoints"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_offsetcurve"("line" "public"."geometry", "distance" double precision, "params" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_offsetcurve"("line" "public"."geometry", "distance" double precision, "params" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_offsetcurve"("line" "public"."geometry", "distance" double precision, "params" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_offsetcurve"("line" "public"."geometry", "distance" double precision, "params" "text") TO "service_role";


--
-- Name: FUNCTION "st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_orientedenvelope"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_orientedenvelope"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_orientedenvelope"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_orientedenvelope"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_patchn"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_patchn"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_patchn"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_patchn"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_perimeter"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_perimeter"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_perimeter"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_perimeter"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_perimeter"("geog" "public"."geography", "use_spheroid" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_perimeter"("geog" "public"."geography", "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_perimeter"("geog" "public"."geography", "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_perimeter"("geog" "public"."geography", "use_spheroid" boolean) TO "service_role";


--
-- Name: FUNCTION "st_perimeter2d"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_perimeter2d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_perimeter2d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_perimeter2d"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_point"(double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_point"(double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_point"(double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_point"(double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_pointfromgeohash"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_pointfromgeohash"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointfromgeohash"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointfromgeohash"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_pointfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_pointfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_pointfromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_pointfromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_pointinsidecircle"("public"."geometry", double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_pointinsidecircle"("public"."geometry", double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointinsidecircle"("public"."geometry", double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointinsidecircle"("public"."geometry", double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_pointn"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_pointn"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointn"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointn"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_pointonsurface"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_pointonsurface"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointonsurface"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointonsurface"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_points"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_points"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_points"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_points"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_polyfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_polyfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_polyfromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_polyfromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_polygon"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_polygon"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygon"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygon"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_polygonfromtext"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text") TO "service_role";


--
-- Name: FUNCTION "st_polygonfromtext"("text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text", integer) TO "service_role";


--
-- Name: FUNCTION "st_polygonfromwkb"("bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea") TO "service_role";


--
-- Name: FUNCTION "st_polygonfromwkb"("bytea", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea", integer) TO "service_role";


--
-- Name: FUNCTION "st_polygonize"("public"."geometry"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry"[]) TO "service_role";


--
-- Name: FUNCTION "st_project"("geog" "public"."geography", "distance" double precision, "azimuth" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_project"("geog" "public"."geography", "distance" double precision, "azimuth" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_project"("geog" "public"."geography", "distance" double precision, "azimuth" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_project"("geog" "public"."geography", "distance" double precision, "azimuth" double precision) TO "service_role";


--
-- Name: FUNCTION "st_quantizecoordinates"("g" "public"."geometry", "prec_x" integer, "prec_y" integer, "prec_z" integer, "prec_m" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_quantizecoordinates"("g" "public"."geometry", "prec_x" integer, "prec_y" integer, "prec_z" integer, "prec_m" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_quantizecoordinates"("g" "public"."geometry", "prec_x" integer, "prec_y" integer, "prec_z" integer, "prec_m" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_quantizecoordinates"("g" "public"."geometry", "prec_x" integer, "prec_y" integer, "prec_z" integer, "prec_m" integer) TO "service_role";


--
-- Name: FUNCTION "st_reduceprecision"("geom" "public"."geometry", "gridsize" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_reduceprecision"("geom" "public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_reduceprecision"("geom" "public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_reduceprecision"("geom" "public"."geometry", "gridsize" double precision) TO "service_role";


--
-- Name: FUNCTION "st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", "text") TO "service_role";


--
-- Name: FUNCTION "st_relatematch"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_relatematch"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_relatematch"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_relatematch"("text", "text") TO "service_role";


--
-- Name: FUNCTION "st_removepoint"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_removepoint"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_removepoint"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_removepoint"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_removerepeatedpoints"("geom" "public"."geometry", "tolerance" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_removerepeatedpoints"("geom" "public"."geometry", "tolerance" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_removerepeatedpoints"("geom" "public"."geometry", "tolerance" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_removerepeatedpoints"("geom" "public"."geometry", "tolerance" double precision) TO "service_role";


--
-- Name: FUNCTION "st_reverse"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_reverse"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_reverse"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_reverse"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_rotate"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_rotate"("public"."geometry", double precision, "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_rotate"("public"."geometry", double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_rotatex"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_rotatex"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotatex"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotatex"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_rotatey"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_rotatey"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotatey"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotatey"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_rotatez"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_rotatez"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotatez"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotatez"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_scale"("public"."geometry", "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_scale"("public"."geometry", double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_scale"("public"."geometry", "public"."geometry", "origin" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry", "origin" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry", "origin" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry", "origin" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_scale"("public"."geometry", double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_segmentize"("geog" "public"."geography", "max_segment_length" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_segmentize"("geog" "public"."geography", "max_segment_length" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_segmentize"("geog" "public"."geography", "max_segment_length" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_segmentize"("geog" "public"."geography", "max_segment_length" double precision) TO "service_role";


--
-- Name: FUNCTION "st_segmentize"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_segmentize"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_segmentize"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_segmentize"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_seteffectivearea"("public"."geometry", double precision, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_seteffectivearea"("public"."geometry", double precision, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_seteffectivearea"("public"."geometry", double precision, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_seteffectivearea"("public"."geometry", double precision, integer) TO "service_role";


--
-- Name: FUNCTION "st_setpoint"("public"."geometry", integer, "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_setpoint"("public"."geometry", integer, "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_setpoint"("public"."geometry", integer, "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_setpoint"("public"."geometry", integer, "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_setsrid"("geog" "public"."geography", "srid" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_setsrid"("geog" "public"."geography", "srid" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_setsrid"("geog" "public"."geography", "srid" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_setsrid"("geog" "public"."geography", "srid" integer) TO "service_role";


--
-- Name: FUNCTION "st_setsrid"("geom" "public"."geometry", "srid" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_setsrid"("geom" "public"."geometry", "srid" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_setsrid"("geom" "public"."geometry", "srid" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_setsrid"("geom" "public"."geometry", "srid" integer) TO "service_role";


--
-- Name: FUNCTION "st_sharedpaths"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_sharedpaths"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_sharedpaths"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_sharedpaths"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_shiftlongitude"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_shiftlongitude"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_shiftlongitude"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_shiftlongitude"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_shortestline"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_shortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_shortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_shortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_simplify"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_simplify"("public"."geometry", double precision, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision, boolean) TO "service_role";


--
-- Name: FUNCTION "st_simplifypreservetopology"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_simplifypreservetopology"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_simplifypreservetopology"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_simplifypreservetopology"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_simplifyvw"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_simplifyvw"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_simplifyvw"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_simplifyvw"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_snap"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_snap"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_snap"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_snap"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_snaptogrid"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_snaptogrid"("public"."geometry", double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_snaptogrid"("public"."geometry", double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_snaptogrid"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_snaptogrid"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision, double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_split"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_split"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_split"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_split"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_square"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_square"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_square"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_square"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_squaregrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_squaregrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_squaregrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_squaregrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "service_role";


--
-- Name: FUNCTION "st_srid"("geog" "public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_srid"("geog" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_srid"("geog" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_srid"("geog" "public"."geography") TO "service_role";


--
-- Name: FUNCTION "st_srid"("geom" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_srid"("geom" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_srid"("geom" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_srid"("geom" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_startpoint"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_startpoint"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_startpoint"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_startpoint"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_subdivide"("geom" "public"."geometry", "maxvertices" integer, "gridsize" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_subdivide"("geom" "public"."geometry", "maxvertices" integer, "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_subdivide"("geom" "public"."geometry", "maxvertices" integer, "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_subdivide"("geom" "public"."geometry", "maxvertices" integer, "gridsize" double precision) TO "service_role";


--
-- Name: FUNCTION "st_summary"("public"."geography"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_summary"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_summary"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_summary"("public"."geography") TO "service_role";


--
-- Name: FUNCTION "st_summary"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_summary"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_summary"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_summary"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_swapordinates"("geom" "public"."geometry", "ords" "cstring"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_swapordinates"("geom" "public"."geometry", "ords" "cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."st_swapordinates"("geom" "public"."geometry", "ords" "cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_swapordinates"("geom" "public"."geometry", "ords" "cstring") TO "service_role";


--
-- Name: FUNCTION "st_symdifference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_symdifference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_symdifference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_symdifference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "service_role";


--
-- Name: FUNCTION "st_symmetricdifference"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_symmetricdifference"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_symmetricdifference"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_symmetricdifference"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_tileenvelope"("zoom" integer, "x" integer, "y" integer, "bounds" "public"."geometry", "margin" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_tileenvelope"("zoom" integer, "x" integer, "y" integer, "bounds" "public"."geometry", "margin" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_tileenvelope"("zoom" integer, "x" integer, "y" integer, "bounds" "public"."geometry", "margin" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_tileenvelope"("zoom" integer, "x" integer, "y" integer, "bounds" "public"."geometry", "margin" double precision) TO "service_role";


--
-- Name: FUNCTION "st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_transform"("public"."geometry", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_transform"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_transform"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_transform"("public"."geometry", integer) TO "service_role";


--
-- Name: FUNCTION "st_transform"("geom" "public"."geometry", "to_proj" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "to_proj" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "to_proj" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "to_proj" "text") TO "service_role";


--
-- Name: FUNCTION "st_transform"("geom" "public"."geometry", "from_proj" "text", "to_srid" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_srid" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_srid" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_srid" integer) TO "service_role";


--
-- Name: FUNCTION "st_transform"("geom" "public"."geometry", "from_proj" "text", "to_proj" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_proj" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_proj" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_proj" "text") TO "service_role";


--
-- Name: FUNCTION "st_translate"("public"."geometry", double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_translate"("public"."geometry", double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_transscale"("public"."geometry", double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_transscale"("public"."geometry", double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_transscale"("public"."geometry", double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_transscale"("public"."geometry", double precision, double precision, double precision, double precision) TO "service_role";


--
-- Name: FUNCTION "st_unaryunion"("public"."geometry", "gridsize" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_unaryunion"("public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_unaryunion"("public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_unaryunion"("public"."geometry", "gridsize" double precision) TO "service_role";


--
-- Name: FUNCTION "st_union"("public"."geometry"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry"[]) TO "service_role";


--
-- Name: FUNCTION "st_union"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_union"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "service_role";


--
-- Name: FUNCTION "st_voronoilines"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_voronoilines"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_voronoilines"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_voronoilines"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_voronoipolygons"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_voronoipolygons"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_voronoipolygons"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_voronoipolygons"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_within"("geom1" "public"."geometry", "geom2" "public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_wkbtosql"("wkb" "bytea"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_wkbtosql"("wkb" "bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_wkbtosql"("wkb" "bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_wkbtosql"("wkb" "bytea") TO "service_role";


--
-- Name: FUNCTION "st_wkttosql"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_wkttosql"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_wkttosql"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_wkttosql"("text") TO "service_role";


--
-- Name: FUNCTION "st_wrapx"("geom" "public"."geometry", "wrap" double precision, "move" double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_wrapx"("geom" "public"."geometry", "wrap" double precision, "move" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_wrapx"("geom" "public"."geometry", "wrap" double precision, "move" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_wrapx"("geom" "public"."geometry", "wrap" double precision, "move" double precision) TO "service_role";


--
-- Name: FUNCTION "st_x"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_x"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_x"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_x"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_xmax"("public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_xmax"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_xmax"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_xmax"("public"."box3d") TO "service_role";


--
-- Name: FUNCTION "st_xmin"("public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_xmin"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_xmin"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_xmin"("public"."box3d") TO "service_role";


--
-- Name: FUNCTION "st_y"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_y"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_y"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_y"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_ymax"("public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_ymax"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ymax"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ymax"("public"."box3d") TO "service_role";


--
-- Name: FUNCTION "st_ymin"("public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_ymin"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ymin"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ymin"("public"."box3d") TO "service_role";


--
-- Name: FUNCTION "st_z"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_z"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_z"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_z"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_zmax"("public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_zmax"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_zmax"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_zmax"("public"."box3d") TO "service_role";


--
-- Name: FUNCTION "st_zmflag"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_zmflag"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_zmflag"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_zmflag"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_zmin"("public"."box3d"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_zmin"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_zmin"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_zmin"("public"."box3d") TO "service_role";


--
-- Name: FUNCTION "unlockrows"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."unlockrows"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."unlockrows"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."unlockrows"("text") TO "service_role";


--
-- Name: FUNCTION "updategeometrysrid"(character varying, character varying, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, integer) TO "service_role";


--
-- Name: FUNCTION "updategeometrysrid"(character varying, character varying, character varying, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, character varying, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, character varying, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, character varying, integer) TO "service_role";


--
-- Name: FUNCTION "updategeometrysrid"("catalogn_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."updategeometrysrid"("catalogn_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"("catalogn_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"("catalogn_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer) TO "service_role";


--
-- Name: FUNCTION "apply_rls"("wal" "jsonb", "max_record_bytes" integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer) TO "postgres";
GRANT ALL ON FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer) TO "dashboard_user";


--
-- Name: FUNCTION "build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) TO "postgres";
GRANT ALL ON FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) TO "dashboard_user";


--
-- Name: FUNCTION "cast"("val" "text", "type_" "regtype"); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") TO "postgres";
GRANT ALL ON FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") TO "dashboard_user";


--
-- Name: FUNCTION "check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text"); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") TO "postgres";
GRANT ALL ON FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") TO "dashboard_user";


--
-- Name: FUNCTION "is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) TO "postgres";
GRANT ALL ON FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) TO "dashboard_user";


--
-- Name: FUNCTION "quote_wal2json"("entity" "regclass"); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."quote_wal2json"("entity" "regclass") TO "postgres";
GRANT ALL ON FUNCTION "realtime"."quote_wal2json"("entity" "regclass") TO "dashboard_user";


--
-- Name: FUNCTION "subscription_check_filters"(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."subscription_check_filters"() TO "postgres";
GRANT ALL ON FUNCTION "realtime"."subscription_check_filters"() TO "dashboard_user";


--
-- Name: FUNCTION "to_regrole"("role_name" "text"); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."to_regrole"("role_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "realtime"."to_regrole"("role_name" "text") TO "dashboard_user";


--
-- Name: FUNCTION "extension"("name" "text"); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION "storage"."extension"("name" "text") TO "anon";
GRANT ALL ON FUNCTION "storage"."extension"("name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "storage"."extension"("name" "text") TO "service_role";
GRANT ALL ON FUNCTION "storage"."extension"("name" "text") TO "dashboard_user";
GRANT ALL ON FUNCTION "storage"."extension"("name" "text") TO "postgres";


--
-- Name: FUNCTION "filename"("name" "text"); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION "storage"."filename"("name" "text") TO "anon";
GRANT ALL ON FUNCTION "storage"."filename"("name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "storage"."filename"("name" "text") TO "service_role";
GRANT ALL ON FUNCTION "storage"."filename"("name" "text") TO "dashboard_user";
GRANT ALL ON FUNCTION "storage"."filename"("name" "text") TO "postgres";


--
-- Name: FUNCTION "foldername"("name" "text"); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION "storage"."foldername"("name" "text") TO "anon";
GRANT ALL ON FUNCTION "storage"."foldername"("name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "storage"."foldername"("name" "text") TO "service_role";
GRANT ALL ON FUNCTION "storage"."foldername"("name" "text") TO "dashboard_user";
GRANT ALL ON FUNCTION "storage"."foldername"("name" "text") TO "postgres";


--
-- Name: FUNCTION "st_3dextent"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_3dextent"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dextent"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dextent"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_asgeobuf"("anyelement"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement") TO "service_role";


--
-- Name: FUNCTION "st_asgeobuf"("anyelement", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement", "text") TO "service_role";


--
-- Name: FUNCTION "st_asmvt"("anyelement"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement") TO "service_role";


--
-- Name: FUNCTION "st_asmvt"("anyelement", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text") TO "service_role";


--
-- Name: FUNCTION "st_asmvt"("anyelement", "text", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer) TO "service_role";


--
-- Name: FUNCTION "st_asmvt"("anyelement", "text", integer, "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text") TO "service_role";


--
-- Name: FUNCTION "st_asmvt"("anyelement", "text", integer, "text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text", "text") TO "service_role";


--
-- Name: FUNCTION "st_clusterintersecting"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_clusterwithin"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry", double precision) TO "service_role";


--
-- Name: FUNCTION "st_collect"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_extent"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_extent"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_extent"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_extent"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_makeline"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_memcollect"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_memcollect"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_memcollect"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_memcollect"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_memunion"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_memunion"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_memunion"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_memunion"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_polygonize"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_union"("public"."geometry"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry") TO "service_role";


--
-- Name: FUNCTION "st_union"("public"."geometry", double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry", double precision) TO "service_role";


--
-- Name: TABLE "audit_log_entries"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."audit_log_entries" TO "dashboard_user";
GRANT ALL ON TABLE "auth"."audit_log_entries" TO "postgres";


--
-- Name: TABLE "identities"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."identities" TO "postgres";
GRANT ALL ON TABLE "auth"."identities" TO "dashboard_user";


--
-- Name: TABLE "instances"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."instances" TO "dashboard_user";
GRANT ALL ON TABLE "auth"."instances" TO "postgres";


--
-- Name: TABLE "refresh_tokens"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."refresh_tokens" TO "dashboard_user";
GRANT ALL ON TABLE "auth"."refresh_tokens" TO "postgres";


--
-- Name: SEQUENCE "refresh_tokens_id_seq"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE "auth"."refresh_tokens_id_seq" TO "dashboard_user";
GRANT ALL ON SEQUENCE "auth"."refresh_tokens_id_seq" TO "postgres";


--
-- Name: TABLE "schema_migrations"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."schema_migrations" TO "dashboard_user";
GRANT ALL ON TABLE "auth"."schema_migrations" TO "postgres";


--
-- Name: TABLE "sessions"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."sessions" TO "postgres";
GRANT ALL ON TABLE "auth"."sessions" TO "dashboard_user";


--
-- Name: TABLE "users"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."users" TO "dashboard_user";
GRANT ALL ON TABLE "auth"."users" TO "postgres";


--
-- Name: TABLE "pg_stat_statements"; Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON TABLE "extensions"."pg_stat_statements" TO "dashboard_user";


--
-- Name: TABLE "pg_stat_statements_info"; Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON TABLE "extensions"."pg_stat_statements_info" TO "dashboard_user";


--
-- Name: TABLE "schema_version"; Type: ACL; Schema: graphql; Owner: postgres
--

GRANT ALL ON TABLE "graphql"."schema_version" TO "anon";
GRANT ALL ON TABLE "graphql"."schema_version" TO "authenticated";
GRANT ALL ON TABLE "graphql"."schema_version" TO "service_role";


--
-- Name: SEQUENCE "seq_schema_version"; Type: ACL; Schema: graphql; Owner: postgres
--

GRANT ALL ON SEQUENCE "graphql"."seq_schema_version" TO "anon";
GRANT ALL ON SEQUENCE "graphql"."seq_schema_version" TO "authenticated";
GRANT ALL ON SEQUENCE "graphql"."seq_schema_version" TO "service_role";


--
-- Name: TABLE "valid_key"; Type: ACL; Schema: pgsodium; Owner: postgres
--

GRANT ALL ON TABLE "pgsodium"."valid_key" TO "pgsodium_keyiduser";


--
-- Name: TABLE "likes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."likes" TO "anon";
GRANT ALL ON TABLE "public"."likes" TO "authenticated";
GRANT ALL ON TABLE "public"."likes" TO "service_role";


--
-- Name: SEQUENCE "likes_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."likes_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."likes_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."likes_id_seq" TO "service_role";


--
-- Name: TABLE "product_tags"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_tags" TO "anon";
GRANT ALL ON TABLE "public"."product_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."product_tags" TO "service_role";


--
-- Name: SEQUENCE "product_tags_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."product_tags_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."product_tags_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."product_tags_id_seq" TO "service_role";


--
-- Name: SEQUENCE "products_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "service_role";


--
-- Name: TABLE "profiles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";


--
-- Name: SEQUENCE "profiles_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."profiles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."profiles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."profiles_id_seq" TO "service_role";


--
-- Name: TABLE "tags"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."tags" TO "anon";
GRANT ALL ON TABLE "public"."tags" TO "authenticated";
GRANT ALL ON TABLE "public"."tags" TO "service_role";


--
-- Name: SEQUENCE "tags_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."tags_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."tags_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."tags_id_seq" TO "service_role";


--
-- Name: TABLE "transactions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."transactions" TO "anon";
GRANT ALL ON TABLE "public"."transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions" TO "service_role";


--
-- Name: SEQUENCE "transactions_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."transactions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."transactions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."transactions_id_seq" TO "service_role";


--
-- Name: TABLE "schema_migrations"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE "realtime"."schema_migrations" TO "postgres";
GRANT ALL ON TABLE "realtime"."schema_migrations" TO "dashboard_user";


--
-- Name: TABLE "subscription"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE "realtime"."subscription" TO "postgres";
GRANT ALL ON TABLE "realtime"."subscription" TO "dashboard_user";


--
-- Name: SEQUENCE "subscription_id_seq"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE "realtime"."subscription_id_seq" TO "postgres";
GRANT ALL ON SEQUENCE "realtime"."subscription_id_seq" TO "dashboard_user";


--
-- Name: TABLE "buckets"; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE "storage"."buckets" TO "anon";
GRANT ALL ON TABLE "storage"."buckets" TO "authenticated";
GRANT ALL ON TABLE "storage"."buckets" TO "service_role";
GRANT ALL ON TABLE "storage"."buckets" TO "postgres";


--
-- Name: TABLE "migrations"; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE "storage"."migrations" TO "anon";
GRANT ALL ON TABLE "storage"."migrations" TO "authenticated";
GRANT ALL ON TABLE "storage"."migrations" TO "service_role";
GRANT ALL ON TABLE "storage"."migrations" TO "postgres";


--
-- Name: TABLE "objects"; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE "storage"."objects" TO "anon";
GRANT ALL ON TABLE "storage"."objects" TO "authenticated";
GRANT ALL ON TABLE "storage"."objects" TO "service_role";
GRANT ALL ON TABLE "storage"."objects" TO "postgres";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON SEQUENCES  TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON FUNCTIONS  TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON TABLES  TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "graphql" GRANT ALL ON TABLES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON TABLES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON SEQUENCES  TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON FUNCTIONS  TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON TABLES  TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES  TO "service_role";


--
-- PostgreSQL database dump complete
--

RESET ALL;
