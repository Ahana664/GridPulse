--
-- PostgreSQL database dump
--

\restrict NkThzyU0zAdAQVxNSwtkgG2IK9exSauKW1wsRspqinZ7xsUTeRjeLL8ECkOTH8W

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data (Community Edition)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: telemetry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telemetry (
    observed_at timestamp with time zone NOT NULL,
    node_id text NOT NULL,
    load_mw double precision NOT NULL,
    voltage_kv double precision NOT NULL,
    load_percent double precision NOT NULL,
    status text NOT NULL,
    source text DEFAULT 'simulator'::text NOT NULL
);


--
-- Name: _hyper_1_1_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: -
--

CREATE TABLE _timescaledb_internal._hyper_1_1_chunk (
    CONSTRAINT constraint_1 CHECK (((observed_at >= '2026-10-29 06:00:00+06'::timestamp with time zone) AND (observed_at < '2026-11-05 06:00:00+06'::timestamp with time zone)))
)
INHERITS (public.telemetry);


--
-- Name: grid_node_readings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grid_node_readings (
    observed_at timestamp with time zone NOT NULL,
    node_id text NOT NULL,
    source text NOT NULL,
    generation_mw double precision,
    demand_mw double precision,
    gas_mw double precision,
    coal_mw double precision,
    solar_mw double precision,
    hydro_mw double precision,
    wind_mw double precision,
    imports_mw double precision,
    voltage_kv double precision,
    load_percent double precision,
    capacity_mw double precision,
    status text
);


--
-- Name: grid_nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grid_nodes (
    node_id text NOT NULL,
    name text NOT NULL,
    tier text NOT NULL,
    parent_node_id text,
    division_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    distribution_weight double precision,
    CONSTRAINT grid_nodes_check CHECK ((((tier = 'national'::text) AND (parent_node_id IS NULL)) OR ((tier <> 'national'::text) AND (parent_node_id IS NOT NULL)))),
    CONSTRAINT grid_nodes_tier_check CHECK ((tier = ANY (ARRAY['national'::text, 'division'::text, 'district'::text, 'feeder'::text])))
);


--
-- Name: national_grid_readings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.national_grid_readings (
    observed_at timestamp with time zone NOT NULL,
    source text NOT NULL,
    generation_mw double precision,
    demand_mw double precision,
    gas_mw double precision,
    coal_mw double precision,
    solar_mw double precision,
    hydro_mw double precision,
    wind_mw double precision,
    imports_mw double precision
);


--
-- Name: _hyper_1_1_chunk source; Type: DEFAULT; Schema: _timescaledb_internal; Owner: -
--

ALTER TABLE ONLY _timescaledb_internal._hyper_1_1_chunk ALTER COLUMN source SET DEFAULT 'simulator'::text;


--
-- Data for Name: hypertable; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.hypertable (id, schema_name, table_name, associated_schema_name, associated_table_prefix, num_dimensions, chunk_sizing_func_schema, chunk_sizing_func_name, chunk_target_size, compression_state, compressed_hypertable_id, status) FROM stdin;
1	public	telemetry	_timescaledb_internal	_hyper_1	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
2	public	national_grid_readings	_timescaledb_internal	_hyper_2	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
3	public	grid_node_readings	_timescaledb_internal	_hyper_3	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
\.


--
-- Data for Name: bgw_job; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.bgw_job (id, application_name, schedule_interval, max_runtime, max_retries, retry_period, proc_schema, proc_name, owner, scheduled, fixed_schedule, initial_start, hypertable_id, config, check_schema, check_name, timezone) FROM stdin;
\.


--
-- Data for Name: chunk; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.chunk (id, relid, hypertable_id, status, osm_chunk, creation_time) FROM stdin;
1	_timescaledb_internal._hyper_1_1_chunk	1	0	f	2026-11-01 05:27:27.179524+06
\.


--
-- Data for Name: chunk_column_stats; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.chunk_column_stats (id, hypertable_id, chunk_id, column_name, range_start, range_end, valid) FROM stdin;
\.


--
-- Data for Name: compression_chunk_size; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.compression_chunk_size (chunk_id, compressed_chunk_id, uncompressed_heap_size, uncompressed_toast_size, uncompressed_index_size, compressed_heap_size, compressed_toast_size, compressed_index_size, numrows_pre_compression, numrows_post_compression, numrows_frozen_immediately) FROM stdin;
\.


--
-- Data for Name: compression_settings; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.compression_settings (relid, compress_relid, segmentby, orderby, orderby_desc, orderby_nullsfirst, index) FROM stdin;
\.


--
-- Data for Name: continuous_agg; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.continuous_agg (mat_hypertable_id, raw_hypertable_id, parent_mat_hypertable_id, user_view_schema, user_view_name, partial_view_schema, partial_view_name, direct_view_schema, direct_view_name, materialized_only, schema_change_timestamp) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_bucket_function; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.continuous_aggs_bucket_function (mat_hypertable_id, bucket_func, bucket_width, bucket_origin, bucket_offset, bucket_timezone, bucket_fixed_width) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_hypertable_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.continuous_aggs_hypertable_invalidation_log (hypertable_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_invalidation_threshold; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.continuous_aggs_invalidation_threshold (hypertable_id, watermark) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_jobs_refresh_ranges; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.continuous_aggs_jobs_refresh_ranges (materialization_id, start_range, end_range, pid, job_id, created_at) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_materialization_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.continuous_aggs_materialization_invalidation_log (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_materialization_ranges; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.continuous_aggs_materialization_ranges (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_tenant_tracking; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.continuous_aggs_tenant_tracking (hypertable_id, tenant_id, min_timestamp, max_timestamp, seqnum) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_watermark; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.continuous_aggs_watermark (mat_hypertable_id, watermark) FROM stdin;
\.


--
-- Data for Name: dimension; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.dimension (id, hypertable_id, column_name, column_type, aligned, num_slices, partitioning_func_schema, partitioning_func, interval_length, compress_interval_length, integer_now_func_schema, integer_now_func) FROM stdin;
1	1	observed_at	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
2	2	observed_at	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
3	3	observed_at	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
\.


--
-- Data for Name: dimension_slice; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.dimension_slice (id, chunk_id, dimension_id, range_start, range_end) FROM stdin;
1	1	1	1793232000000000	1793836800000000
\.


--
-- Data for Name: hypertable_cagg_settings; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.hypertable_cagg_settings (hypertable_id, granular_refresh_column, granular_refresh_start_offset, granular_refresh_end_offset) FROM stdin;
\.


--
-- Data for Name: metadata; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.metadata (key, value, include_in_telemetry) FROM stdin;
install_timestamp	2026-11-01 05:27:17.201909+06	t
timescaledb_version	2.29.2	f
exported_uuid	643bc830-a530-4034-8c9b-2186e6553f6f	t
\.


--
-- Data for Name: tablespace; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: -
--

COPY _timescaledb_catalog.tablespace (id, hypertable_id, tablespace_name) FROM stdin;
\.


--
-- Data for Name: _hyper_1_1_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: -
--

COPY _timescaledb_internal._hyper_1_1_chunk (observed_at, node_id, load_mw, voltage_kv, load_percent, status, source) FROM stdin;
2026-10-30 06:00:00+06	GEN-N1	1002	230.27	79	normal	simulator
2026-10-30 06:00:00+06	SUB-N1	839.1	230.63	62.8	normal	simulator
2026-10-30 06:00:00+06	LOAD-N1	499.1	131.3	80.5	normal	simulator
2026-10-30 06:00:00+06	LOAD-N2	344.6	132.43	71.8	normal	simulator
2026-10-30 06:00:00+06	GEN-E1	843.3	229.55	79.7	normal	simulator
2026-10-30 06:00:00+06	SUB-E1	782.4	229.56	65.5	normal	simulator
2026-10-30 06:00:00+06	LOAD-E1	462.8	131.9	81.2	normal	simulator
2026-10-30 06:00:00+06	LOAD-E2	301.5	131.46	67	normal	simulator
2026-10-30 06:00:00+06	GEN-C1	1046.3	229.36	80.9	normal	simulator
2026-10-30 06:00:00+06	SUB-C1	956.2	230.62	70.3	normal	simulator
2026-10-30 06:00:00+06	LOAD-C1	655.1	130.8	86.2	warning	simulator
2026-10-30 06:00:00+06	LOAD-C2	292.9	131.76	75.1	normal	simulator
2026-10-30 06:00:00+06	GEN-W1	697	230.12	79	normal	simulator
2026-10-30 06:00:00+06	SUB-W1	828.7	229.89	68.1	normal	simulator
2026-10-30 06:00:00+06	LOAD-W1	407.7	132.17	75.5	normal	simulator
2026-10-30 06:00:00+06	LOAD-W2	434.7	131.97	83.6	normal	simulator
2026-10-30 06:00:00+06	GEN-S1	1135.4	230.1	79.3	normal	simulator
2026-10-30 06:00:00+06	SUB-S1	830.9	230.44	69.9	normal	simulator
2026-10-30 06:00:00+06	LOAD-S1	482.5	132.55	79.1	normal	simulator
2026-10-30 06:00:00+06	LOAD-S2	336.5	131.53	71.6	normal	simulator
2026-10-30 07:00:00+06	GEN-N1	959.2	230.33	80.6	normal	simulator
2026-10-30 07:00:00+06	SUB-N1	843.7	229.99	60.5	normal	simulator
2026-10-30 07:00:00+06	LOAD-N1	495.4	131.71	79.9	normal	simulator
2026-10-30 07:00:00+06	LOAD-N2	337.9	131.78	70.4	normal	simulator
2026-10-30 07:00:00+06	GEN-E1	852.4	229.87	80.4	normal	simulator
2026-10-30 07:00:00+06	SUB-E1	764.3	230.48	66.7	normal	simulator
2026-10-30 07:00:00+06	LOAD-E1	457.7	132.64	80.3	normal	simulator
2026-10-30 07:00:00+06	LOAD-E2	313.6	132.01	69.7	normal	simulator
2026-10-30 07:00:00+06	GEN-C1	1076.7	229.67	79.4	normal	simulator
2026-10-30 07:00:00+06	SUB-C1	948	229.55	70.7	normal	simulator
2026-10-30 07:00:00+06	LOAD-C1	655.9	131.59	86.3	warning	simulator
2026-10-30 07:00:00+06	LOAD-C2	293.7	132.67	75.3	normal	simulator
2026-10-30 07:00:00+06	GEN-W1	680.2	229.95	80.1	normal	simulator
2026-10-30 07:00:00+06	SUB-W1	842.4	230.11	67.4	normal	simulator
2026-10-30 07:00:00+06	LOAD-W1	418.5	132.15	77.5	normal	simulator
2026-10-30 07:00:00+06	LOAD-W2	424.3	132.34	81.6	normal	simulator
2026-10-30 07:00:00+06	GEN-S1	1198.3	230.11	79.1	normal	simulator
2026-10-30 07:00:00+06	SUB-S1	819	230.69	69.8	normal	simulator
2026-10-30 07:00:00+06	LOAD-S1	477	131.57	78.2	normal	simulator
2026-10-30 07:00:00+06	LOAD-S2	332.8	132.64	70.8	normal	simulator
2026-10-30 08:00:00+06	GEN-N1	969.5	230.26	79.9	normal	simulator
2026-10-30 08:00:00+06	SUB-N1	833.3	229.67	62.3	normal	simulator
2026-10-30 08:00:00+06	LOAD-N1	498.5	131.92	80.4	normal	simulator
2026-10-30 08:00:00+06	LOAD-N2	339.4	132.08	70.7	normal	simulator
2026-10-30 08:00:00+06	GEN-E1	855.7	230.63	79.1	normal	simulator
2026-10-30 08:00:00+06	SUB-E1	771.3	230.5	64.4	normal	simulator
2026-10-30 08:00:00+06	LOAD-E1	475.9	132.12	83.5	normal	simulator
2026-10-30 08:00:00+06	LOAD-E2	300.1	131.43	66.7	normal	simulator
2026-10-30 08:00:00+06	GEN-C1	1067.5	229.57	80.6	normal	simulator
2026-10-30 08:00:00+06	SUB-C1	949.6	229.57	70.7	normal	simulator
2026-10-30 08:00:00+06	LOAD-C1	658.9	130.68	86.7	warning	simulator
2026-10-30 08:00:00+06	LOAD-C2	290.9	132.18	74.6	normal	simulator
2026-10-30 08:00:00+06	GEN-W1	723.1	229.83	80.8	normal	simulator
2026-10-30 08:00:00+06	SUB-W1	842.8	229.45	66.9	normal	simulator
2026-10-30 08:00:00+06	LOAD-W1	411.5	131.65	76.2	normal	simulator
2026-10-30 08:00:00+06	LOAD-W2	436.3	131.97	83.9	normal	simulator
2026-10-30 08:00:00+06	GEN-S1	1179.2	229.56	80.7	normal	simulator
2026-10-30 08:00:00+06	SUB-S1	809.8	230.52	69.9	normal	simulator
2026-10-30 08:00:00+06	LOAD-S1	486.2	131.36	79.7	normal	simulator
2026-10-30 08:00:00+06	LOAD-S2	344.5	131.84	73.3	normal	simulator
2026-10-30 09:00:00+06	GEN-N1	953.7	230.55	79.3	normal	simulator
2026-10-30 09:00:00+06	SUB-N1	837.9	230.33	62.8	normal	simulator
2026-10-30 09:00:00+06	LOAD-N1	478.6	131.6	77.2	normal	simulator
2026-10-30 09:00:00+06	LOAD-N2	348	132.05	72.5	normal	simulator
2026-10-30 09:00:00+06	GEN-E1	842.8	230.55	78.6	normal	simulator
2026-10-30 09:00:00+06	SUB-E1	776	230.48	64.9	normal	simulator
2026-10-30 09:00:00+06	LOAD-E1	462.3	132.49	81.1	normal	simulator
2026-10-30 09:00:00+06	LOAD-E2	308.2	131.76	68.5	normal	simulator
2026-10-30 09:00:00+06	GEN-C1	1077.7	230.39	78.7	normal	simulator
2026-10-30 09:00:00+06	SUB-C1	949.8	229.65	70.9	normal	simulator
2026-10-30 09:00:00+06	LOAD-C1	666.5	131.18	87.7	warning	simulator
2026-10-30 09:00:00+06	LOAD-C2	285.1	132.18	73.1	normal	simulator
2026-10-30 09:00:00+06	GEN-W1	695.3	229.96	81.8	normal	simulator
2026-10-30 09:00:00+06	SUB-W1	847.8	230.65	65.4	normal	simulator
2026-10-30 09:00:00+06	LOAD-W1	405	132.08	75	normal	simulator
2026-10-30 09:00:00+06	LOAD-W2	432.6	132.2	83.2	normal	simulator
2026-10-30 09:00:00+06	GEN-S1	1168.1	229.41	80.1	normal	simulator
2026-10-30 09:00:00+06	SUB-S1	830.7	229.82	71.3	normal	simulator
2026-10-30 09:00:00+06	LOAD-S1	498.4	132.27	81.7	normal	simulator
2026-10-30 09:00:00+06	LOAD-S2	338.9	132.62	72.1	normal	simulator
2026-10-30 10:00:00+06	GEN-N1	953.4	230.65	79.8	normal	simulator
2026-10-30 10:00:00+06	SUB-N1	826.6	229.96	63.7	normal	simulator
2026-10-30 10:00:00+06	LOAD-N1	492.3	131.37	79.4	normal	simulator
2026-10-30 10:00:00+06	LOAD-N2	333.1	132.65	69.4	normal	simulator
2026-10-30 10:00:00+06	GEN-E1	875.5	230.64	79.6	normal	simulator
2026-10-30 10:00:00+06	SUB-E1	770.5	230.41	66	normal	simulator
2026-10-30 10:00:00+06	LOAD-E1	477.7	131.11	83.8	normal	simulator
2026-10-30 10:00:00+06	LOAD-E2	298.4	131.37	66.3	normal	simulator
2026-10-30 10:00:00+06	GEN-C1	1080.6	229.84	80.1	normal	simulator
2026-10-30 10:00:00+06	SUB-C1	951.6	230.11	70.8	normal	simulator
2026-10-30 10:00:00+06	LOAD-C1	674.1	130.95	88.7	warning	simulator
2026-10-30 10:00:00+06	LOAD-C2	292.5	131.35	75	normal	simulator
2026-10-30 10:00:00+06	GEN-W1	686.9	229.35	79.2	normal	simulator
2026-10-30 10:00:00+06	SUB-W1	837.6	230.42	68.3	normal	simulator
2026-10-30 10:00:00+06	LOAD-W1	407.2	132.34	75.4	normal	simulator
2026-10-30 10:00:00+06	LOAD-W2	438.9	132.09	84.4	normal	simulator
2026-10-30 10:00:00+06	GEN-S1	1191.3	230.53	81.2	normal	simulator
2026-10-30 10:00:00+06	SUB-S1	837.3	230.39	71.1	normal	simulator
2026-10-30 10:00:00+06	LOAD-S1	491.7	132.53	80.6	normal	simulator
2026-10-30 10:00:00+06	LOAD-S2	341.7	132.56	72.7	normal	simulator
2026-10-30 11:00:00+06	GEN-N1	952.8	230.31	81.6	normal	simulator
2026-10-30 11:00:00+06	SUB-N1	825.4	230.57	63.1	normal	simulator
2026-10-30 11:00:00+06	LOAD-N1	491	131.77	79.2	normal	simulator
2026-10-30 11:00:00+06	LOAD-N2	332.2	132.62	69.2	normal	simulator
2026-10-30 11:00:00+06	GEN-E1	852.3	229.76	81.3	normal	simulator
2026-10-30 11:00:00+06	SUB-E1	776.1	230.13	65	normal	simulator
2026-10-30 11:00:00+06	LOAD-E1	477.1	132.26	83.7	normal	simulator
2026-10-30 11:00:00+06	LOAD-E2	303.8	132.01	67.5	normal	simulator
2026-10-30 11:00:00+06	GEN-C1	1068.6	229.69	80.5	normal	simulator
2026-10-30 11:00:00+06	SUB-C1	966.6	229.75	73.3	normal	simulator
2026-10-30 11:00:00+06	LOAD-C1	677.9	131.15	89.2	warning	simulator
2026-10-30 11:00:00+06	LOAD-C2	285.1	131.34	73.1	normal	simulator
2026-10-30 11:00:00+06	GEN-W1	688.4	230.31	81.2	normal	simulator
2026-10-30 11:00:00+06	SUB-W1	846.1	230.57	67.2	normal	simulator
2026-10-30 11:00:00+06	LOAD-W1	413.1	131.79	76.5	normal	simulator
2026-10-30 11:00:00+06	LOAD-W2	431.6	131.04	83	normal	simulator
2026-10-30 11:00:00+06	GEN-S1	1201.5	229.7	78.6	normal	simulator
2026-10-30 11:00:00+06	SUB-S1	833.4	229.56	69.3	normal	simulator
2026-10-30 11:00:00+06	LOAD-S1	486.8	131.65	79.8	normal	simulator
2026-10-30 11:00:00+06	LOAD-S2	342.6	131.57	72.9	normal	simulator
2026-10-30 12:00:00+06	GEN-N1	973.7	229.56	78.6	normal	simulator
2026-10-30 12:00:00+06	SUB-N1	823.2	229.44	60.7	normal	simulator
2026-10-30 12:00:00+06	LOAD-N1	490.4	132.51	79.1	normal	simulator
2026-10-30 12:00:00+06	LOAD-N2	343.7	131.38	71.6	normal	simulator
2026-10-30 12:00:00+06	GEN-E1	881.3	229.9	80.8	normal	simulator
2026-10-30 12:00:00+06	SUB-E1	780.9	230.66	64.8	normal	simulator
2026-10-30 12:00:00+06	LOAD-E1	461.7	132.39	81	normal	simulator
2026-10-30 12:00:00+06	LOAD-E2	299.7	131.76	66.6	normal	simulator
2026-10-30 12:00:00+06	GEN-C1	1066.2	229.31	79.4	normal	simulator
2026-10-30 12:00:00+06	SUB-C1	963	230.13	71.1	normal	simulator
2026-10-30 12:00:00+06	LOAD-C1	673.4	131.67	88.6	warning	simulator
2026-10-30 12:00:00+06	LOAD-C2	288.6	131.63	74	normal	simulator
2026-10-30 12:00:00+06	GEN-W1	681.2	229.52	78.5	normal	simulator
2026-10-30 12:00:00+06	SUB-W1	844.7	229.32	65.6	normal	simulator
2026-10-30 12:00:00+06	LOAD-W1	413.6	131.84	76.6	normal	simulator
2026-10-30 12:00:00+06	LOAD-W2	438.4	132.14	84.3	normal	simulator
2026-10-30 12:00:00+06	GEN-S1	1149.8	229.3	79.6	normal	simulator
2026-10-30 12:00:00+06	SUB-S1	829.4	229.53	68.6	normal	simulator
2026-10-30 12:00:00+06	LOAD-S1	495.9	131.16	81.3	normal	simulator
2026-10-30 12:00:00+06	LOAD-S2	339.3	132.16	72.2	normal	simulator
2026-10-30 13:00:00+06	GEN-N1	983.8	230.43	78.9	normal	simulator
2026-10-30 13:00:00+06	SUB-N1	834.1	230.45	60.9	normal	simulator
2026-10-30 13:00:00+06	LOAD-N1	495.4	132.65	79.9	normal	simulator
2026-10-30 13:00:00+06	LOAD-N2	349	131.85	72.7	normal	simulator
2026-10-30 13:00:00+06	GEN-E1	837.5	229.98	80.7	normal	simulator
2026-10-30 13:00:00+06	SUB-E1	761.4	229.92	64.8	normal	simulator
2026-10-30 13:00:00+06	LOAD-E1	469.7	131.22	82.4	normal	simulator
2026-10-30 13:00:00+06	LOAD-E2	299.2	132.55	66.5	normal	simulator
2026-10-30 13:00:00+06	GEN-C1	1029.4	229.93	79.6	normal	simulator
2026-10-30 13:00:00+06	SUB-C1	962	229.3	70.8	normal	simulator
2026-10-30 13:00:00+06	LOAD-C1	659.7	131.32	86.8	warning	simulator
2026-10-30 13:00:00+06	LOAD-C2	288.6	131.99	74	normal	simulator
2026-10-30 13:00:00+06	GEN-W1	687.1	230.29	81.7	normal	simulator
2026-10-30 13:00:00+06	SUB-W1	852	229.65	66.1	normal	simulator
2026-10-30 13:00:00+06	LOAD-W1	416.9	132.57	77.2	normal	simulator
2026-10-30 13:00:00+06	LOAD-W2	427.4	131.57	82.2	normal	simulator
2026-10-30 13:00:00+06	GEN-S1	1202.3	229.81	81.3	normal	simulator
2026-10-30 13:00:00+06	SUB-S1	835.2	229.62	68.4	normal	simulator
2026-10-30 13:00:00+06	LOAD-S1	478.9	132.28	78.5	normal	simulator
2026-10-30 13:00:00+06	LOAD-S2	341.2	132.31	72.6	normal	simulator
2026-10-30 14:00:00+06	GEN-N1	986.4	229.6	79.5	normal	simulator
2026-10-30 14:00:00+06	SUB-N1	844.4	229.74	62.3	normal	simulator
2026-10-30 14:00:00+06	LOAD-N1	481.1	131.32	77.6	normal	simulator
2026-10-30 14:00:00+06	LOAD-N2	349	132.27	72.7	normal	simulator
2026-10-30 14:00:00+06	GEN-E1	841.3	229.77	80.8	normal	simulator
2026-10-30 14:00:00+06	SUB-E1	768.9	230.4	65.6	normal	simulator
2026-10-30 14:00:00+06	LOAD-E1	469.7	131.64	82.4	normal	simulator
2026-10-30 14:00:00+06	LOAD-E2	311.4	131.84	69.2	normal	simulator
2026-10-30 14:00:00+06	GEN-C1	1030.7	230.2	79.2	normal	simulator
2026-10-30 14:00:00+06	SUB-C1	948.3	230.32	72.8	normal	simulator
2026-10-30 14:00:00+06	LOAD-C1	662.7	130.96	87.2	warning	simulator
2026-10-30 14:00:00+06	LOAD-C2	289	131.8	74.1	normal	simulator
2026-10-30 14:00:00+06	GEN-W1	724.4	229.93	81	normal	simulator
2026-10-30 14:00:00+06	SUB-W1	844.3	230.61	67.7	normal	simulator
2026-10-30 14:00:00+06	LOAD-W1	403.9	131.87	74.8	normal	simulator
2026-10-30 14:00:00+06	LOAD-W2	440.4	130.79	84.7	normal	simulator
2026-10-30 14:00:00+06	GEN-S1	1147.2	229.62	78.5	normal	simulator
2026-10-30 14:00:00+06	SUB-S1	820.1	229.72	71.5	normal	simulator
2026-10-30 14:00:00+06	LOAD-S1	494.1	131.41	81	normal	simulator
2026-10-30 14:00:00+06	LOAD-S2	336.1	132.53	71.5	normal	simulator
2026-10-30 15:00:00+06	GEN-N1	962	229.38	78.3	normal	simulator
2026-10-30 15:00:00+06	SUB-N1	830.1	230.02	61.7	normal	simulator
2026-10-30 15:00:00+06	LOAD-N1	497.2	132.2	80.2	normal	simulator
2026-10-30 15:00:00+06	LOAD-N2	348	131.44	72.5	normal	simulator
2026-10-30 15:00:00+06	GEN-E1	832.1	229.34	79.2	normal	simulator
2026-10-30 15:00:00+06	SUB-E1	781.1	229.42	66.4	normal	simulator
2026-10-30 15:00:00+06	LOAD-E1	457.7	132.62	80.3	normal	simulator
2026-10-30 15:00:00+06	LOAD-E2	302.4	131.36	67.2	normal	simulator
2026-10-30 15:00:00+06	GEN-C1	1086.7	230.09	80.7	normal	simulator
2026-10-30 15:00:00+06	SUB-C1	951.7	229.45	73.7	normal	simulator
2026-10-30 15:00:00+06	LOAD-C1	658.9	130.76	86.7	warning	simulator
2026-10-30 15:00:00+06	LOAD-C2	287	131.96	73.6	normal	simulator
2026-10-30 15:00:00+06	GEN-W1	723.7	230.68	78.3	normal	simulator
2026-10-30 15:00:00+06	SUB-W1	844.3	229.64	68.5	normal	simulator
2026-10-30 15:00:00+06	LOAD-W1	403.9	131.83	74.8	normal	simulator
2026-10-30 15:00:00+06	LOAD-W2	425.9	131.55	81.9	normal	simulator
2026-10-30 15:00:00+06	GEN-S1	1160.6	230.33	81.2	normal	simulator
2026-10-30 15:00:00+06	SUB-S1	830.2	230.22	69.8	normal	simulator
2026-10-30 15:00:00+06	LOAD-S1	482.5	132.22	79.1	normal	simulator
2026-10-30 15:00:00+06	LOAD-S2	330.9	131.47	70.4	normal	simulator
2026-10-30 16:00:00+06	GEN-N1	978.2	229.84	78.9	normal	simulator
2026-10-30 16:00:00+06	SUB-N1	845.2	229.95	63.8	normal	simulator
2026-10-30 16:00:00+06	LOAD-N1	485.5	132.31	78.3	normal	simulator
2026-10-30 16:00:00+06	LOAD-N2	345.1	132.15	71.9	normal	simulator
2026-10-30 16:00:00+06	GEN-E1	877.4	230.48	81.6	normal	simulator
2026-10-30 16:00:00+06	SUB-E1	760.1	230.13	66.5	normal	simulator
2026-10-30 16:00:00+06	LOAD-E1	468.5	131.14	82.2	normal	simulator
2026-10-30 16:00:00+06	LOAD-E2	299.2	132.22	66.5	normal	simulator
2026-10-30 16:00:00+06	GEN-C1	1039.9	229.88	80.4	normal	simulator
2026-10-30 16:00:00+06	SUB-C1	945.9	230.69	73.6	normal	simulator
2026-10-30 16:00:00+06	LOAD-C1	658.9	131.87	86.7	warning	simulator
2026-10-30 16:00:00+06	LOAD-C2	282	131.42	72.3	normal	simulator
2026-10-30 16:00:00+06	GEN-W1	721.5	230.28	79.3	normal	simulator
2026-10-30 16:00:00+06	SUB-W1	829.8	230.09	68.1	normal	simulator
2026-10-30 16:00:00+06	LOAD-W1	402.3	131.39	74.5	normal	simulator
2026-10-30 16:00:00+06	LOAD-W2	438.9	131.09	84.4	normal	simulator
2026-10-30 16:00:00+06	GEN-S1	1188.3	229.45	80.7	normal	simulator
2026-10-30 16:00:00+06	SUB-S1	813.4	229.56	69.2	normal	simulator
2026-10-30 16:00:00+06	LOAD-S1	480.7	132.22	78.8	normal	simulator
2026-10-30 16:00:00+06	LOAD-S2	338.9	131.56	72.1	normal	simulator
2026-10-30 17:00:00+06	GEN-N1	965.5	230.4	80.6	normal	simulator
2026-10-30 17:00:00+06	SUB-N1	830.6	230.69	62.3	normal	simulator
2026-10-30 17:00:00+06	LOAD-N1	484.8	132.68	78.2	normal	simulator
2026-10-30 17:00:00+06	LOAD-N2	336	132.04	70	normal	simulator
2026-10-30 17:00:00+06	GEN-E1	831.8	229.39	79.6	normal	simulator
2026-10-30 17:00:00+06	SUB-E1	767.7	230.27	66	normal	simulator
2026-10-30 17:00:00+06	LOAD-E1	475.4	132.16	83.4	normal	simulator
2026-10-30 17:00:00+06	LOAD-E2	310.9	131.76	69.1	normal	simulator
2026-10-30 17:00:00+06	GEN-C1	1059.1	230.66	78.7	normal	simulator
2026-10-30 17:00:00+06	SUB-C1	940.9	230.36	73.5	normal	simulator
2026-10-30 17:00:00+06	LOAD-C1	656.6	131.07	86.4	warning	simulator
2026-10-30 17:00:00+06	LOAD-C2	285.1	131.79	73.1	normal	simulator
2026-10-30 17:00:00+06	GEN-W1	684.3	229.87	81.6	normal	simulator
2026-10-30 17:00:00+06	SUB-W1	841.2	230.48	67.5	normal	simulator
2026-10-30 17:00:00+06	LOAD-W1	413.1	132.47	76.5	normal	simulator
2026-10-30 17:00:00+06	LOAD-W2	434.2	131.14	83.5	normal	simulator
2026-10-30 17:00:00+06	GEN-S1	1184.4	230.45	80.3	normal	simulator
2026-10-30 17:00:00+06	SUB-S1	819.6	230.16	70.7	normal	simulator
2026-10-30 17:00:00+06	LOAD-S1	488.6	131.68	80.1	normal	simulator
2026-10-30 17:00:00+06	LOAD-S2	345	132.47	73.4	normal	simulator
2026-10-30 18:00:00+06	GEN-N1	996.3	229.44	79.3	normal	simulator
2026-10-30 18:00:00+06	SUB-N1	820.8	229.55	61.3	normal	simulator
2026-10-30 18:00:00+06	LOAD-N1	483	131.72	77.9	normal	simulator
2026-10-30 18:00:00+06	LOAD-N2	341.3	131.35	71.1	normal	simulator
2026-10-30 18:00:00+06	GEN-E1	882.4	230.07	80.7	normal	simulator
2026-10-30 18:00:00+06	SUB-E1	786.3	229.35	64	normal	simulator
2026-10-30 18:00:00+06	LOAD-E1	471.4	131.91	82.7	normal	simulator
2026-10-30 18:00:00+06	LOAD-E2	303.8	131.46	67.5	normal	simulator
2026-10-30 18:00:00+06	GEN-C1	1024.9	230.47	80.7	normal	simulator
2026-10-30 18:00:00+06	SUB-C1	941.7	229.5	70.6	normal	simulator
2026-10-30 18:00:00+06	LOAD-C1	677.2	130.76	89.1	warning	simulator
2026-10-30 18:00:00+06	LOAD-C2	294.1	131.98	75.4	normal	simulator
2026-10-30 18:00:00+06	GEN-W1	690.7	230.51	78.8	normal	simulator
2026-10-30 18:00:00+06	SUB-W1	847.3	230.51	67.4	normal	simulator
2026-10-30 18:00:00+06	LOAD-W1	418.5	131.43	77.5	normal	simulator
2026-10-30 18:00:00+06	LOAD-W2	425.4	131.45	81.8	normal	simulator
2026-10-30 18:00:00+06	GEN-S1	1176.9	229.31	80.6	normal	simulator
2026-10-30 18:00:00+06	SUB-S1	833.6	230.02	68.5	normal	simulator
2026-10-30 18:00:00+06	LOAD-S1	495.9	131.46	81.3	normal	simulator
2026-10-30 18:00:00+06	LOAD-S2	335.6	131.64	71.4	normal	simulator
2026-10-30 19:00:00+06	GEN-N1	981.8	229.45	81.5	normal	simulator
2026-10-30 19:00:00+06	SUB-N1	824.3	230.68	62.9	normal	simulator
2026-10-30 19:00:00+06	LOAD-N1	496.6	132.65	80.1	normal	simulator
2026-10-30 19:00:00+06	LOAD-N2	338.4	131.37	70.5	normal	simulator
2026-10-30 19:00:00+06	GEN-E1	863.7	230.17	81.1	normal	simulator
2026-10-30 19:00:00+06	SUB-E1	775.2	229.57	64.1	normal	simulator
2026-10-30 19:00:00+06	LOAD-E1	463.4	132.29	81.3	normal	simulator
2026-10-30 19:00:00+06	LOAD-E2	304.6	131.42	67.7	normal	simulator
2026-10-30 19:00:00+06	GEN-C1	1031.3	229.94	80.9	normal	simulator
2026-10-30 19:00:00+06	SUB-C1	971.3	229.98	72.2	normal	simulator
2026-10-30 19:00:00+06	LOAD-C1	673.4	131.26	88.6	warning	simulator
2026-10-30 19:00:00+06	LOAD-C2	289.4	131.89	74.2	normal	simulator
2026-10-30 19:00:00+06	GEN-W1	680.7	229.71	78.9	normal	simulator
2026-10-30 19:00:00+06	SUB-W1	843.9	230.52	68.3	normal	simulator
2026-10-30 19:00:00+06	LOAD-W1	413.6	131.43	76.6	normal	simulator
2026-10-30 19:00:00+06	LOAD-W2	432.6	131.72	83.2	normal	simulator
2026-10-30 19:00:00+06	GEN-S1	1198.7	230.43	79.4	normal	simulator
2026-10-30 19:00:00+06	SUB-S1	831.5	229.7	69.4	normal	simulator
2026-10-30 19:00:00+06	LOAD-S1	481.3	132.49	78.9	normal	simulator
2026-10-30 19:00:00+06	LOAD-S2	333.7	132.67	71	normal	simulator
2026-10-30 20:00:00+06	GEN-N1	975.9	229.92	79.7	normal	simulator
2026-10-30 20:00:00+06	SUB-N1	835	230.68	60.3	normal	simulator
2026-10-30 20:00:00+06	LOAD-N1	499.1	131.28	80.5	normal	simulator
2026-10-30 20:00:00+06	LOAD-N2	335.5	131.96	69.9	normal	simulator
2026-10-30 20:00:00+06	GEN-E1	837.7	229.53	78.9	normal	simulator
2026-10-30 20:00:00+06	SUB-E1	768	230.65	66.5	normal	simulator
2026-10-30 20:00:00+06	LOAD-E1	460	132.08	80.7	normal	simulator
2026-10-30 20:00:00+06	LOAD-E2	300.1	132.11	66.7	normal	simulator
2026-10-30 20:00:00+06	GEN-C1	1073.6	229.98	81.6	normal	simulator
2026-10-30 20:00:00+06	SUB-C1	962.8	229.39	70.4	normal	simulator
2026-10-30 20:00:00+06	LOAD-C1	660.4	130.83	86.9	warning	simulator
2026-10-30 20:00:00+06	LOAD-C2	291.7	131.55	74.8	normal	simulator
2026-10-30 20:00:00+06	GEN-W1	686.9	230.01	78.8	normal	simulator
2026-10-30 20:00:00+06	SUB-W1	846.2	229.58	68.3	normal	simulator
2026-10-30 20:00:00+06	LOAD-W1	403.4	132.69	74.7	normal	simulator
2026-10-30 20:00:00+06	LOAD-W2	437.3	131.55	84.1	normal	simulator
2026-10-30 20:00:00+06	GEN-S1	1179	229.76	80.4	normal	simulator
2026-10-30 20:00:00+06	SUB-S1	815	230.4	68.4	normal	simulator
2026-10-30 20:00:00+06	LOAD-S1	481.3	132.48	78.9	normal	simulator
2026-10-30 20:00:00+06	LOAD-S2	332.3	132.49	70.7	normal	simulator
2026-10-30 21:00:00+06	GEN-N1	993.6	229.46	80.8	normal	simulator
2026-10-30 21:00:00+06	SUB-N1	834.6	229.49	63.6	normal	simulator
2026-10-30 21:00:00+06	LOAD-N1	486.1	131.53	78.4	normal	simulator
2026-10-30 21:00:00+06	LOAD-N2	332.6	131.31	69.3	normal	simulator
2026-10-30 21:00:00+06	GEN-E1	885	230.6	78.3	normal	simulator
2026-10-30 21:00:00+06	SUB-E1	760.1	230.07	66.4	normal	simulator
2026-10-30 21:00:00+06	LOAD-E1	460.6	132.55	80.8	normal	simulator
2026-10-30 21:00:00+06	LOAD-E2	301.1	131.65	66.9	normal	simulator
2026-10-30 21:00:00+06	GEN-C1	1064.4	230.42	81.6	normal	simulator
2026-10-30 21:00:00+06	SUB-C1	952.1	229.4	73	normal	simulator
2026-10-30 21:00:00+06	LOAD-C1	665	131.51	87.5	warning	simulator
2026-10-30 21:00:00+06	LOAD-C2	290.6	132.02	74.5	normal	simulator
2026-10-30 21:00:00+06	GEN-W1	700.7	229.46	80	normal	simulator
2026-10-30 21:00:00+06	SUB-W1	840.7	230.4	68.6	normal	simulator
2026-10-30 21:00:00+06	LOAD-W1	405.5	131.33	75.1	normal	simulator
2026-10-30 21:00:00+06	LOAD-W2	423.3	132.38	81.4	normal	simulator
2026-10-30 21:00:00+06	GEN-S1	1144.3	230.42	81.3	normal	simulator
2026-10-30 21:00:00+06	SUB-S1	813.6	229.5	71.7	normal	simulator
2026-10-30 21:00:00+06	LOAD-S1	479.5	131.65	78.6	normal	simulator
2026-10-30 21:00:00+06	LOAD-S2	344.5	132.24	73.3	normal	simulator
2026-10-30 22:00:00+06	GEN-N1	954.6	230.35	80	normal	simulator
2026-10-30 22:00:00+06	SUB-N1	818.7	230.55	62.3	normal	simulator
2026-10-30 22:00:00+06	LOAD-N1	481.7	131.86	77.7	normal	simulator
2026-10-30 22:00:00+06	LOAD-N2	348	132.6	72.5	normal	simulator
2026-10-30 22:00:00+06	GEN-E1	870.1	230.01	78.3	normal	simulator
2026-10-30 22:00:00+06	SUB-E1	761.7	229.86	63.4	normal	simulator
2026-10-30 22:00:00+06	LOAD-E1	462.8	132.22	81.2	normal	simulator
2026-10-30 22:00:00+06	LOAD-E2	303.8	132.51	67.5	normal	simulator
2026-10-30 22:00:00+06	GEN-C1	1084.2	229.39	79.4	normal	simulator
2026-10-30 22:00:00+06	SUB-C1	955.6	229.32	71.5	normal	simulator
2026-10-30 22:00:00+06	LOAD-C1	681	130.34	89.6	warning	simulator
2026-10-30 22:00:00+06	LOAD-C2	284.7	132.44	73	normal	simulator
2026-10-30 22:00:00+06	GEN-W1	681.7	229.47	80.3	normal	simulator
2026-10-30 22:00:00+06	SUB-W1	828.8	230.25	67.2	normal	simulator
2026-10-30 22:00:00+06	LOAD-W1	406.1	131.93	75.2	normal	simulator
2026-10-30 22:00:00+06	LOAD-W2	426.4	131.81	82	normal	simulator
2026-10-30 22:00:00+06	GEN-S1	1171.7	229.96	80.9	normal	simulator
2026-10-30 22:00:00+06	SUB-S1	824	230.16	70.2	normal	simulator
2026-10-30 22:00:00+06	LOAD-S1	486.8	132.57	79.8	normal	simulator
2026-10-30 22:00:00+06	LOAD-S2	331.8	131.95	70.6	normal	simulator
2026-10-30 23:00:00+06	GEN-N1	949.3	229.55	81.2	normal	simulator
2026-10-30 23:00:00+06	SUB-N1	829.7	230.23	60.7	normal	simulator
2026-10-30 23:00:00+06	LOAD-N1	486.1	131.47	78.4	normal	simulator
2026-10-30 23:00:00+06	LOAD-N2	339.8	131.57	70.8	normal	simulator
2026-10-30 23:00:00+06	GEN-E1	864.8	229.31	79.3	normal	simulator
2026-10-30 23:00:00+06	SUB-E1	766.6	230.3	64.4	normal	simulator
2026-10-30 23:00:00+06	LOAD-E1	460.6	132.35	80.8	normal	simulator
2026-10-30 23:00:00+06	LOAD-E2	309.1	132.5	68.7	normal	simulator
2026-10-30 23:00:00+06	GEN-C1	1029.9	229.33	81.6	normal	simulator
2026-10-30 23:00:00+06	SUB-C1	965.7	229.86	72.9	normal	simulator
2026-10-30 23:00:00+06	LOAD-C1	678.7	131.18	89.3	warning	simulator
2026-10-30 23:00:00+06	LOAD-C2	281.6	131.7	72.2	normal	simulator
2026-10-30 23:00:00+06	GEN-W1	683.3	230.36	78.5	normal	simulator
2026-10-30 23:00:00+06	SUB-W1	832.5	230.03	68.3	normal	simulator
2026-10-30 23:00:00+06	LOAD-W1	405.5	132.13	75.1	normal	simulator
2026-10-30 23:00:00+06	LOAD-W2	429.5	131.03	82.6	normal	simulator
2026-10-30 23:00:00+06	GEN-S1	1176	230.15	79.2	normal	simulator
2026-10-30 23:00:00+06	SUB-S1	818.6	230.48	69.2	normal	simulator
2026-10-30 23:00:00+06	LOAD-S1	494.7	131.87	81.1	normal	simulator
2026-10-30 23:00:00+06	LOAD-S2	333.2	131.85	70.9	normal	simulator
2026-10-31 00:00:00+06	GEN-N1	1004.2	230.15	81	normal	simulator
2026-10-31 00:00:00+06	SUB-N1	825.9	230.41	61.1	normal	simulator
2026-10-31 00:00:00+06	LOAD-N1	490.4	132.51	79.1	normal	simulator
2026-10-31 00:00:00+06	LOAD-N2	334.6	132.68	69.7	normal	simulator
2026-10-31 00:00:00+06	GEN-E1	862.8	229.89	80.3	normal	simulator
2026-10-31 00:00:00+06	SUB-E1	769.7	230.45	64.2	normal	simulator
2026-10-31 00:00:00+06	LOAD-E1	457.7	131.78	80.3	normal	simulator
2026-10-31 00:00:00+06	LOAD-E2	311.9	131.6	69.3	normal	simulator
2026-10-31 00:00:00+06	GEN-C1	1062.4	229.49	79.4	normal	simulator
2026-10-31 00:00:00+06	SUB-C1	960.3	230.25	70.9	normal	simulator
2026-10-31 00:00:00+06	LOAD-C1	679.4	130.6	89.4	warning	simulator
2026-10-31 00:00:00+06	LOAD-C2	282.4	132.24	72.4	normal	simulator
2026-10-31 00:00:00+06	GEN-W1	685.6	230.48	80.1	normal	simulator
2026-10-31 00:00:00+06	SUB-W1	835	229.52	66.6	normal	simulator
2026-10-31 00:00:00+06	LOAD-W1	419	132.58	77.6	normal	simulator
2026-10-31 00:00:00+06	LOAD-W2	438.9	131.71	84.4	normal	simulator
2026-10-31 00:00:00+06	GEN-S1	1155.4	229.62	78.6	normal	simulator
2026-10-31 00:00:00+06	SUB-S1	827.9	229.74	71.4	normal	simulator
2026-10-31 00:00:00+06	LOAD-S1	478.2	132.09	78.4	normal	simulator
2026-10-31 00:00:00+06	LOAD-S2	341.7	132.26	72.7	normal	simulator
2026-10-31 01:00:00+06	GEN-N1	953.9	229.16	81.5	normal	simulator
2026-10-31 01:00:00+06	SUB-N1	825	229.7	61.4	normal	simulator
2026-10-31 01:00:00+06	LOAD-N1	483	132.36	77.9	normal	simulator
2026-10-31 01:00:00+06	LOAD-N2	345.6	132.57	72	normal	simulator
2026-10-31 01:00:00+06	GEN-E1	865.8	230.27	78.7	normal	simulator
2026-10-31 01:00:00+06	SUB-E1	769.6	229.53	65.8	normal	simulator
2026-10-31 01:00:00+06	LOAD-E1	458.9	131.67	80.5	normal	simulator
2026-10-31 01:00:00+06	LOAD-E2	303.3	132.4	67.4	normal	simulator
2026-10-31 01:00:00+06	GEN-C1	1037.2	229.81	81.2	normal	simulator
2026-10-31 01:00:00+06	SUB-C1	961.8	230.48	73.5	normal	simulator
2026-10-31 01:00:00+06	LOAD-C1	655.9	131.18	86.3	warning	simulator
2026-10-31 01:00:00+06	LOAD-C2	289.4	132.05	74.2	normal	simulator
2026-10-31 01:00:00+06	GEN-W1	699	229.3	81.5	normal	simulator
2026-10-31 01:00:00+06	SUB-W1	857.9	230.15	67.6	normal	simulator
2026-10-31 01:00:00+06	LOAD-W1	403.4	132.44	74.7	normal	simulator
2026-10-31 01:00:00+06	LOAD-W2	429	132.17	82.5	normal	simulator
2026-10-31 01:00:00+06	GEN-S1	1169.7	230.27	78.6	normal	simulator
2026-10-31 01:00:00+06	SUB-S1	819.9	230.1	71.1	normal	simulator
2026-10-31 01:00:00+06	LOAD-S1	483.1	131.4	79.2	normal	simulator
2026-10-31 01:00:00+06	LOAD-S2	341.7	131.61	72.7	normal	simulator
2026-10-31 02:00:00+06	GEN-N1	1005.7	229.33	81.1	normal	simulator
2026-10-31 02:00:00+06	SUB-N1	828.6	229.65	61.3	normal	simulator
2026-10-31 02:00:00+06	LOAD-N1	489.2	131.57	78.9	normal	simulator
2026-10-31 02:00:00+06	LOAD-N2	338.9	132.24	70.6	normal	simulator
2026-10-31 02:00:00+06	GEN-E1	868.7	229.45	81.1	normal	simulator
2026-10-31 02:00:00+06	SUB-E1	762.2	230.54	63.8	normal	simulator
2026-10-31 02:00:00+06	LOAD-E1	471.4	131.93	82.7	normal	simulator
2026-10-31 02:00:00+06	LOAD-E2	311.4	132.01	69.2	normal	simulator
2026-10-31 02:00:00+06	GEN-C1	1033.9	230.19	78.3	normal	simulator
2026-10-31 02:00:00+06	SUB-C1	945.3	229.88	71.1	normal	simulator
2026-10-31 02:00:00+06	LOAD-C1	671.1	131.05	88.3	warning	simulator
2026-10-31 02:00:00+06	LOAD-C2	289.8	132.67	74.3	normal	simulator
2026-10-31 02:00:00+06	GEN-W1	704.9	229.91	78.4	normal	simulator
2026-10-31 02:00:00+06	SUB-W1	832.4	230.52	67.4	normal	simulator
2026-10-31 02:00:00+06	LOAD-W1	403.9	131.88	74.8	normal	simulator
2026-10-31 02:00:00+06	LOAD-W2	436.8	132.06	84	normal	simulator
2026-10-31 02:00:00+06	GEN-S1	1152.2	230.63	78.6	normal	simulator
2026-10-31 02:00:00+06	SUB-S1	824.8	230.61	68.4	normal	simulator
2026-10-31 02:00:00+06	LOAD-S1	483.7	131.79	79.3	normal	simulator
2026-10-31 02:00:00+06	LOAD-S2	331.4	131.45	70.5	normal	simulator
2026-10-31 03:00:00+06	GEN-N1	953.6	229.87	80.5	normal	simulator
2026-10-31 03:00:00+06	SUB-N1	828.1	230.15	60.4	normal	simulator
2026-10-31 03:00:00+06	LOAD-N1	490.4	132.56	79.1	normal	simulator
2026-10-31 03:00:00+06	LOAD-N2	341.3	132.17	71.1	normal	simulator
2026-10-31 03:00:00+06	GEN-E1	860.1	229.91	79.3	normal	simulator
2026-10-31 03:00:00+06	SUB-E1	782.8	229.68	63.9	normal	simulator
2026-10-31 03:00:00+06	LOAD-E1	460.6	131.46	80.8	normal	simulator
2026-10-31 03:00:00+06	LOAD-E2	312.3	131.91	69.4	normal	simulator
2026-10-31 03:00:00+06	GEN-C1	1024.4	229.32	80.3	normal	simulator
2026-10-31 03:00:00+06	SUB-C1	960.9	229.51	72.9	normal	simulator
2026-10-31 03:00:00+06	LOAD-C1	668.8	131.6	88	warning	simulator
2026-10-31 03:00:00+06	LOAD-C2	294.1	132.51	75.4	normal	simulator
2026-10-31 03:00:00+06	GEN-W1	684.7	230.39	80.8	normal	simulator
2026-10-31 03:00:00+06	SUB-W1	840.7	230.41	66.4	normal	simulator
2026-10-31 03:00:00+06	LOAD-W1	412.6	131.47	76.4	normal	simulator
2026-10-31 03:00:00+06	LOAD-W2	438.4	131.8	84.3	normal	simulator
2026-10-31 03:00:00+06	GEN-S1	1173.9	229.89	79.9	normal	simulator
2026-10-31 03:00:00+06	SUB-S1	815.1	230.14	71	normal	simulator
2026-10-31 03:00:00+06	LOAD-S1	479.5	131.9	78.6	normal	simulator
2026-10-31 03:00:00+06	LOAD-S2	344.5	131.9	73.3	normal	simulator
2026-10-31 04:00:00+06	GEN-N1	996.2	229.4	81.6	normal	simulator
2026-10-31 04:00:00+06	SUB-N1	831.7	230.35	62.6	normal	simulator
2026-10-31 04:00:00+06	LOAD-N1	496	131.89	80	normal	simulator
2026-10-31 04:00:00+06	LOAD-N2	342.7	132.3	71.4	normal	simulator
2026-10-31 04:00:00+06	GEN-E1	868.4	229.45	79.7	normal	simulator
2026-10-31 04:00:00+06	SUB-E1	772.9	230.33	64.6	normal	simulator
2026-10-31 04:00:00+06	LOAD-E1	462.8	131.64	81.2	normal	simulator
2026-10-31 04:00:00+06	LOAD-E2	302.9	131.82	67.3	normal	simulator
2026-10-31 04:00:00+06	GEN-C1	1077.1	229.88	80.9	normal	simulator
2026-10-31 04:00:00+06	SUB-C1	962.9	230.56	72.7	normal	simulator
2026-10-31 04:00:00+06	LOAD-C1	662	131.14	87.1	warning	simulator
2026-10-31 04:00:00+06	LOAD-C2	294.8	131.94	75.6	normal	simulator
2026-10-31 04:00:00+06	GEN-W1	707.3	230.43	80.8	normal	simulator
2026-10-31 04:00:00+06	SUB-W1	851	229.73	67.2	normal	simulator
2026-10-31 04:00:00+06	LOAD-W1	410.9	132.65	76.1	normal	simulator
2026-10-31 04:00:00+06	LOAD-W2	432.1	132.04	83.1	normal	simulator
2026-10-31 04:00:00+06	GEN-S1	1179.8	229.68	81.3	normal	simulator
2026-10-31 04:00:00+06	SUB-S1	824	229.93	71.3	normal	simulator
2026-10-31 04:00:00+06	LOAD-S1	487.4	132.26	79.9	normal	simulator
2026-10-31 04:00:00+06	LOAD-S2	336.1	131.77	71.5	normal	simulator
2026-10-31 05:00:00+06	GEN-N1	951.3	229.47	81.6	normal	simulator
2026-10-31 05:00:00+06	SUB-N1	838.7	229.32	62.4	normal	simulator
2026-10-31 05:00:00+06	LOAD-N1	479.3	131.73	77.3	normal	simulator
2026-10-31 05:00:00+06	LOAD-N2	332.6	131.4	69.3	normal	simulator
2026-10-31 05:00:00+06	GEN-E1	834.7	229.63	81.1	normal	simulator
2026-10-31 05:00:00+06	SUB-E1	765.7	230.29	63.3	normal	simulator
2026-10-31 05:00:00+06	LOAD-E1	473.1	131.43	83	normal	simulator
2026-10-31 05:00:00+06	LOAD-E2	303.3	132.63	67.4	normal	simulator
2026-10-31 05:00:00+06	GEN-C1	1060.9	229.48	81.1	normal	simulator
2026-10-31 05:00:00+06	SUB-C1	956.8	229.51	70.9	normal	simulator
2026-10-31 05:00:00+06	LOAD-C1	656.6	131.8	86.4	warning	simulator
2026-10-31 05:00:00+06	LOAD-C2	281.6	131.71	72.2	normal	simulator
2026-10-31 05:00:00+06	GEN-W1	710.2	229.56	80.3	normal	simulator
2026-10-31 05:00:00+06	SUB-W1	843	230.56	68.7	normal	simulator
2026-10-31 05:00:00+06	LOAD-W1	416.9	131.52	77.2	normal	simulator
2026-10-31 05:00:00+06	LOAD-W2	436.3	131.55	83.9	normal	simulator
2026-10-31 05:00:00+06	GEN-S1	1161.7	229.99	79	normal	simulator
2026-10-31 05:00:00+06	SUB-S1	823.5	230.4	70.3	normal	simulator
2026-10-31 05:00:00+06	LOAD-S1	495.3	131.51	81.2	normal	simulator
2026-10-31 05:00:00+06	LOAD-S2	330.9	131.81	70.4	normal	simulator
2026-10-31 06:00:00+06	GEN-N1	961.4	229.66	80.2	normal	simulator
2026-10-31 06:00:00+06	SUB-N1	811.9	229.37	63.6	normal	simulator
2026-10-31 06:00:00+06	LOAD-N1	487.3	132.33	78.6	normal	simulator
2026-10-31 06:00:00+06	LOAD-N2	335	131.56	69.8	normal	simulator
2026-10-31 06:00:00+06	GEN-E1	857.3	229.36	78.7	normal	simulator
2026-10-31 06:00:00+06	SUB-E1	776.4	229.84	63.9	normal	simulator
2026-10-31 06:00:00+06	LOAD-E1	465.1	131.6	81.6	normal	simulator
2026-10-31 06:00:00+06	LOAD-E2	306	132.15	68	normal	simulator
2026-10-31 06:00:00+06	GEN-C1	1062.6	229.64	81.6	normal	simulator
2026-10-31 06:00:00+06	SUB-C1	938.2	230.66	72.3	normal	simulator
2026-10-31 06:00:00+06	LOAD-C1	673.4	131.53	88.6	warning	simulator
2026-10-31 06:00:00+06	LOAD-C2	287	131.63	73.6	normal	simulator
2026-10-31 06:00:00+06	GEN-W1	699.2	229.85	78.7	normal	simulator
2026-10-31 06:00:00+06	SUB-W1	853.2	230.48	66.4	normal	simulator
2026-10-31 06:00:00+06	LOAD-W1	407.7	131.86	75.5	normal	simulator
2026-10-31 06:00:00+06	LOAD-W2	423.8	132.45	81.5	normal	simulator
2026-10-31 06:00:00+06	GEN-S1	1172.9	229.53	81	normal	simulator
2026-10-31 06:00:00+06	SUB-S1	826.2	229.89	69.7	normal	simulator
2026-10-31 06:00:00+06	LOAD-S1	494.1	132.29	81	normal	simulator
2026-10-31 06:00:00+06	LOAD-S2	338.4	131.3	72	normal	simulator
2026-10-31 07:00:00+06	GEN-N1	966.1	229.63	79	normal	simulator
2026-10-31 07:00:00+06	SUB-N1	822.3	230.41	61.2	normal	simulator
2026-10-31 07:00:00+06	LOAD-N1	501	132.19	80.8	normal	simulator
2026-10-31 07:00:00+06	LOAD-N2	336.5	131.87	70.1	normal	simulator
2026-10-31 07:00:00+06	GEN-E1	841.4	229.26	80.4	normal	simulator
2026-10-31 07:00:00+06	SUB-E1	771.1	230.04	64.4	normal	simulator
2026-10-31 07:00:00+06	LOAD-E1	464	131.8	81.4	normal	simulator
2026-10-31 07:00:00+06	LOAD-E2	300.6	132.24	66.8	normal	simulator
2026-10-31 07:00:00+06	GEN-C1	1019.9	229.38	81.4	normal	simulator
2026-10-31 07:00:00+06	SUB-C1	960.4	229.32	70.3	normal	simulator
2026-10-31 07:00:00+06	LOAD-C1	677.2	131.25	89.1	warning	simulator
2026-10-31 07:00:00+06	LOAD-C2	293.3	131.95	75.2	normal	simulator
2026-10-31 07:00:00+06	GEN-W1	718.5	229.92	79.4	normal	simulator
2026-10-31 07:00:00+06	SUB-W1	831.5	229.8	66	normal	simulator
2026-10-31 07:00:00+06	LOAD-W1	401.8	132.02	74.4	normal	simulator
2026-10-31 07:00:00+06	LOAD-W2	422.2	132.23	81.2	normal	simulator
2026-10-31 07:00:00+06	GEN-S1	1179.6	229.72	79.6	normal	simulator
2026-10-31 07:00:00+06	SUB-S1	832.5	229.77	71	normal	simulator
2026-10-31 07:00:00+06	LOAD-S1	495.3	131.83	81.2	normal	simulator
2026-10-31 07:00:00+06	LOAD-S2	333.7	132.57	71	normal	simulator
2026-10-31 08:00:00+06	GEN-N1	995.9	229.86	81.4	normal	simulator
2026-10-31 08:00:00+06	SUB-N1	837.5	229.94	61.7	normal	simulator
2026-10-31 08:00:00+06	LOAD-N1	494.1	131.59	79.7	normal	simulator
2026-10-31 08:00:00+06	LOAD-N2	344.2	131.61	71.7	normal	simulator
2026-10-31 08:00:00+06	GEN-E1	859.7	230.28	80	normal	simulator
2026-10-31 08:00:00+06	SUB-E1	764.6	229.64	63.6	normal	simulator
2026-10-31 08:00:00+06	LOAD-E1	475.9	132.29	83.5	normal	simulator
2026-10-31 08:00:00+06	LOAD-E2	306	132.5	68	normal	simulator
2026-10-31 08:00:00+06	GEN-C1	1043.2	230.42	80.3	normal	simulator
2026-10-31 08:00:00+06	SUB-C1	970.5	229.41	70.8	normal	simulator
2026-10-31 08:00:00+06	LOAD-C1	665	131.04	87.5	warning	simulator
2026-10-31 08:00:00+06	LOAD-C2	291.7	132.59	74.8	normal	simulator
2026-10-31 08:00:00+06	GEN-W1	712	230.31	80.6	normal	simulator
2026-10-31 08:00:00+06	SUB-W1	824	229.58	68	normal	simulator
2026-10-31 08:00:00+06	LOAD-W1	414.7	132.07	76.8	normal	simulator
2026-10-31 08:00:00+06	LOAD-W2	431.1	131.3	82.9	normal	simulator
2026-10-31 08:00:00+06	GEN-S1	1192.4	230.26	78.8	normal	simulator
2026-10-31 08:00:00+06	SUB-S1	829	230.36	71	normal	simulator
2026-10-31 08:00:00+06	LOAD-S1	478.2	132.27	78.4	normal	simulator
2026-10-31 08:00:00+06	LOAD-S2	343.1	132.43	73	normal	simulator
2026-10-31 09:00:00+06	GEN-N1	980.3	229.25	81.2	normal	simulator
2026-10-31 09:00:00+06	SUB-N1	838.3	230.5	63.2	normal	simulator
2026-10-31 09:00:00+06	LOAD-N1	493.5	131.45	79.6	normal	simulator
2026-10-31 09:00:00+06	LOAD-N2	332.6	132.47	69.3	normal	simulator
2026-10-31 09:00:00+06	GEN-E1	881.5	229.53	81.2	normal	simulator
2026-10-31 09:00:00+06	SUB-E1	781.9	230.67	66.7	normal	simulator
2026-10-31 09:00:00+06	LOAD-E1	475.9	132.12	83.5	normal	simulator
2026-10-31 09:00:00+06	LOAD-E2	310.9	132.39	69.1	normal	simulator
2026-10-31 09:00:00+06	GEN-C1	1048.7	229.88	81.7	normal	simulator
2026-10-31 09:00:00+06	SUB-C1	956.7	230.37	72.2	normal	simulator
2026-10-31 09:00:00+06	LOAD-C1	669.6	131.19	88.1	warning	simulator
2026-10-31 09:00:00+06	LOAD-C2	292.5	132.66	75	normal	simulator
2026-10-31 09:00:00+06	GEN-W1	702.8	230.65	78.8	normal	simulator
2026-10-31 09:00:00+06	SUB-W1	845.8	229.69	65.7	normal	simulator
2026-10-31 09:00:00+06	LOAD-W1	406.6	131.55	75.3	normal	simulator
2026-10-31 09:00:00+06	LOAD-W2	432.1	131.93	83.1	normal	simulator
2026-10-31 09:00:00+06	GEN-S1	1175.3	230.43	81.3	normal	simulator
2026-10-31 09:00:00+06	SUB-S1	821.3	229.42	71.1	normal	simulator
2026-10-31 09:00:00+06	LOAD-S1	483.1	131.96	79.2	normal	simulator
2026-10-31 09:00:00+06	LOAD-S2	334.2	132.52	71.1	normal	simulator
2026-10-31 10:00:00+06	GEN-N1	964.3	230.19	80.7	normal	simulator
2026-10-31 10:00:00+06	SUB-N1	826.1	230.35	63.5	normal	simulator
2026-10-31 10:00:00+06	LOAD-N1	489.8	132.37	79	normal	simulator
2026-10-31 10:00:00+06	LOAD-N2	339.8	131.5	70.8	normal	simulator
2026-10-31 10:00:00+06	GEN-E1	869.8	229.97	78.7	normal	simulator
2026-10-31 10:00:00+06	SUB-E1	786.8	229.71	63.9	normal	simulator
2026-10-31 10:00:00+06	LOAD-E1	469.1	131.13	82.3	normal	simulator
2026-10-31 10:00:00+06	LOAD-E2	301.1	132.3	66.9	normal	simulator
2026-10-31 10:00:00+06	GEN-C1	1051.4	229.53	80.9	normal	simulator
2026-10-31 10:00:00+06	SUB-C1	962.1	230.36	71.6	normal	simulator
2026-10-31 10:00:00+06	LOAD-C1	656.6	131.35	86.4	warning	simulator
2026-10-31 10:00:00+06	LOAD-C2	293.3	131.49	75.2	normal	simulator
2026-10-31 10:00:00+06	GEN-W1	713	229.67	80.6	normal	simulator
2026-10-31 10:00:00+06	SUB-W1	838.7	229.87	68.5	normal	simulator
2026-10-31 10:00:00+06	LOAD-W1	405.5	132.49	75.1	normal	simulator
2026-10-31 10:00:00+06	LOAD-W2	430	131.36	82.7	normal	simulator
2026-10-31 10:00:00+06	GEN-S1	1194	230.29	79.5	normal	simulator
2026-10-31 10:00:00+06	SUB-S1	817.3	229.73	69.7	normal	simulator
2026-10-31 10:00:00+06	LOAD-S1	478.2	131.9	78.4	normal	simulator
2026-10-31 10:00:00+06	LOAD-S2	340.3	131.43	72.4	normal	simulator
2026-10-31 11:00:00+06	GEN-N1	964.6	229.83	79.4	normal	simulator
2026-10-31 11:00:00+06	SUB-N1	829.6	229.86	61.6	normal	simulator
2026-10-31 11:00:00+06	LOAD-N1	500.3	132.56	80.7	normal	simulator
2026-10-31 11:00:00+06	LOAD-N2	337	132.43	70.2	normal	simulator
2026-10-31 11:00:00+06	GEN-E1	853.3	229.69	78.4	normal	simulator
2026-10-31 11:00:00+06	SUB-E1	770.2	230.06	64.2	normal	simulator
2026-10-31 11:00:00+06	LOAD-E1	460	131.89	80.7	normal	simulator
2026-10-31 11:00:00+06	LOAD-E2	304.2	132.35	67.6	normal	simulator
2026-10-31 11:00:00+06	GEN-C1	1021.9	230.23	80.1	normal	simulator
2026-10-31 11:00:00+06	SUB-C1	949.9	230.09	73.5	normal	simulator
2026-10-31 11:00:00+06	LOAD-C1	661.2	131.46	87	warning	simulator
2026-10-31 11:00:00+06	LOAD-C2	292.1	131.48	74.9	normal	simulator
2026-10-31 11:00:00+06	GEN-W1	683.2	230.65	79.3	normal	simulator
2026-10-31 11:00:00+06	SUB-W1	835.5	230.4	68.2	normal	simulator
2026-10-31 11:00:00+06	LOAD-W1	416.3	131.57	77.1	normal	simulator
2026-10-31 11:00:00+06	LOAD-W2	432.1	132.32	83.1	normal	simulator
2026-10-31 11:00:00+06	GEN-S1	1196	229.73	80.4	normal	simulator
2026-10-31 11:00:00+06	SUB-S1	818.5	230.63	71.4	normal	simulator
2026-10-31 11:00:00+06	LOAD-S1	477.6	131.88	78.3	normal	simulator
2026-10-31 11:00:00+06	LOAD-S2	335.6	131.7	71.4	normal	simulator
2026-10-31 12:00:00+06	GEN-N1	988.9	229.52	80.1	normal	simulator
2026-10-31 12:00:00+06	SUB-N1	837.3	230.23	61	normal	simulator
2026-10-31 12:00:00+06	LOAD-N1	486.7	132.44	78.5	normal	simulator
2026-10-31 12:00:00+06	LOAD-N2	349	131.63	72.7	normal	simulator
2026-10-31 12:00:00+06	GEN-E1	875.4	230.4	79.3	normal	simulator
2026-10-31 12:00:00+06	SUB-E1	764.2	230.64	65.2	normal	simulator
2026-10-31 12:00:00+06	LOAD-E1	470.8	131.07	82.6	normal	simulator
2026-10-31 12:00:00+06	LOAD-E2	310.5	132.08	69	normal	simulator
2026-10-31 12:00:00+06	GEN-C1	1065.3	229.4	80.4	normal	simulator
2026-10-31 12:00:00+06	SUB-C1	953.3	229.91	70.7	normal	simulator
2026-10-31 12:00:00+06	LOAD-C1	661.2	131.41	87	warning	simulator
2026-10-31 12:00:00+06	LOAD-C2	289.8	132.33	74.3	normal	simulator
2026-10-31 12:00:00+06	GEN-W1	679.6	230.57	78.8	normal	simulator
2026-10-31 12:00:00+06	SUB-W1	848.4	230.45	67	normal	simulator
2026-10-31 12:00:00+06	LOAD-W1	413.1	132.55	76.5	normal	simulator
2026-10-31 12:00:00+06	LOAD-W2	439.9	132.17	84.6	normal	simulator
2026-10-31 12:00:00+06	GEN-S1	1196.8	230.39	80.4	normal	simulator
2026-10-31 12:00:00+06	SUB-S1	813.2	229.61	69	normal	simulator
2026-10-31 12:00:00+06	LOAD-S1	497.1	131.41	81.5	normal	simulator
2026-10-31 12:00:00+06	LOAD-S2	332.8	132.19	70.8	normal	simulator
2026-10-31 13:00:00+06	GEN-N1	946.2	229.75	79.1	normal	simulator
2026-10-31 13:00:00+06	SUB-N1	835.7	230.26	60.9	normal	simulator
2026-10-31 13:00:00+06	LOAD-N1	491	131.65	79.2	normal	simulator
2026-10-31 13:00:00+06	LOAD-N2	336	132.16	70	normal	simulator
2026-10-31 13:00:00+06	GEN-E1	838.3	230.56	80.6	normal	simulator
2026-10-31 13:00:00+06	SUB-E1	781.3	230.61	66.1	normal	simulator
2026-10-31 13:00:00+06	LOAD-E1	470.2	132.4	82.5	normal	simulator
2026-10-31 13:00:00+06	LOAD-E2	303.8	132.66	67.5	normal	simulator
2026-10-31 13:00:00+06	GEN-C1	1063.8	230.63	78.8	normal	simulator
2026-10-31 13:00:00+06	SUB-C1	951	230.63	71.5	normal	simulator
2026-10-31 13:00:00+06	LOAD-C1	668.8	130.63	88	warning	simulator
2026-10-31 13:00:00+06	LOAD-C2	294.8	132.05	75.6	normal	simulator
2026-10-31 13:00:00+06	GEN-W1	722.4	230.5	79.8	normal	simulator
2026-10-31 13:00:00+06	SUB-W1	853	229.79	66.5	normal	simulator
2026-10-31 13:00:00+06	LOAD-W1	412.6	132.36	76.4	normal	simulator
2026-10-31 13:00:00+06	LOAD-W2	433.7	131.84	83.4	normal	simulator
2026-10-31 13:00:00+06	GEN-S1	1149.9	230.42	81.4	normal	simulator
2026-10-31 13:00:00+06	SUB-S1	829.9	230.44	68.8	normal	simulator
2026-10-31 13:00:00+06	LOAD-S1	495.9	131.33	81.3	normal	simulator
2026-10-31 13:00:00+06	LOAD-S2	331.8	132.39	70.6	normal	simulator
2026-10-31 14:00:00+06	GEN-N1	989	229.33	79.1	normal	simulator
2026-10-31 14:00:00+06	SUB-N1	827	230.18	61.5	normal	simulator
2026-10-31 14:00:00+06	LOAD-N1	499.1	131.3	80.5	normal	simulator
2026-10-31 14:00:00+06	LOAD-N2	340.8	132.36	71	normal	simulator
2026-10-31 14:00:00+06	GEN-E1	856.3	229.68	78.5	normal	simulator
2026-10-31 14:00:00+06	SUB-E1	774	229.77	65.4	normal	simulator
2026-10-31 14:00:00+06	LOAD-E1	462.8	131.24	81.2	normal	simulator
2026-10-31 14:00:00+06	LOAD-E2	302.4	131.48	67.2	normal	simulator
2026-10-31 14:00:00+06	GEN-C1	1056.2	229.46	78.3	normal	simulator
2026-10-31 14:00:00+06	SUB-C1	963.6	230.45	70.8	normal	simulator
2026-10-31 14:00:00+06	LOAD-C1	667.3	131.78	87.8	warning	simulator
2026-10-31 14:00:00+06	LOAD-C2	294.1	132.07	75.4	normal	simulator
2026-10-31 14:00:00+06	GEN-W1	721.8	230.22	79.7	normal	simulator
2026-10-31 14:00:00+06	SUB-W1	846.3	230.2	65.8	normal	simulator
2026-10-31 14:00:00+06	LOAD-W1	411.5	131.98	76.2	normal	simulator
2026-10-31 14:00:00+06	LOAD-W2	426.4	131.09	82	normal	simulator
2026-10-31 14:00:00+06	GEN-S1	1150.7	229.58	80.2	normal	simulator
2026-10-31 14:00:00+06	SUB-S1	827.7	230.4	68.6	normal	simulator
2026-10-31 14:00:00+06	LOAD-S1	478.2	131.79	78.4	normal	simulator
2026-10-31 14:00:00+06	LOAD-S2	345	132.56	73.4	normal	simulator
2026-10-31 15:00:00+06	GEN-N1	966.3	230.05	81.6	normal	simulator
2026-10-31 15:00:00+06	SUB-N1	839.9	229.79	61.8	normal	simulator
2026-10-31 15:00:00+06	LOAD-N1	494.8	131.51	79.8	normal	simulator
2026-10-31 15:00:00+06	LOAD-N2	334.6	131.43	69.7	normal	simulator
2026-10-31 15:00:00+06	GEN-E1	848.6	230.61	79.6	normal	simulator
2026-10-31 15:00:00+06	SUB-E1	765.2	230.38	66.7	normal	simulator
2026-10-31 15:00:00+06	LOAD-E1	475.9	132.05	83.5	normal	simulator
2026-10-31 15:00:00+06	LOAD-E2	308.7	131.67	68.6	normal	simulator
2026-10-31 15:00:00+06	GEN-C1	1021.9	230.65	79.7	normal	simulator
2026-10-31 15:00:00+06	SUB-C1	961.4	229.88	71.8	normal	simulator
2026-10-31 15:00:00+06	LOAD-C1	668	131.64	87.9	warning	simulator
2026-10-31 15:00:00+06	LOAD-C2	290.9	131.75	74.6	normal	simulator
2026-10-31 15:00:00+06	GEN-W1	716.2	229.47	78.5	normal	simulator
2026-10-31 15:00:00+06	SUB-W1	837.9	230.52	66.5	normal	simulator
2026-10-31 15:00:00+06	LOAD-W1	403.9	132.57	74.8	normal	simulator
2026-10-31 15:00:00+06	LOAD-W2	425.9	132.01	81.9	normal	simulator
2026-10-31 15:00:00+06	GEN-S1	1191.8	229.57	81	normal	simulator
2026-10-31 15:00:00+06	SUB-S1	823.2	230.67	71.4	normal	simulator
2026-10-31 15:00:00+06	LOAD-S1	488	132.5	80	normal	simulator
2026-10-31 15:00:00+06	LOAD-S2	333.7	131.95	71	normal	simulator
2026-10-31 16:00:00+06	GEN-N1	977.2	230.07	80.2	normal	simulator
2026-10-31 16:00:00+06	SUB-N1	829.4	229.35	62.8	normal	simulator
2026-10-31 16:00:00+06	LOAD-N1	496	132.19	80	normal	simulator
2026-10-31 16:00:00+06	LOAD-N2	343.7	131.64	71.6	normal	simulator
2026-10-31 16:00:00+06	GEN-E1	845.5	229.52	81.3	normal	simulator
2026-10-31 16:00:00+06	SUB-E1	784.6	229.62	64.5	normal	simulator
2026-10-31 16:00:00+06	LOAD-E1	462.8	132.28	81.2	normal	simulator
2026-10-31 16:00:00+06	LOAD-E2	310.5	131.53	69	normal	simulator
2026-10-31 16:00:00+06	GEN-C1	1076.6	230.28	79.2	normal	simulator
2026-10-31 16:00:00+06	SUB-C1	958.9	230.57	70.6	normal	simulator
2026-10-31 16:00:00+06	LOAD-C1	675.6	131.21	88.9	warning	simulator
2026-10-31 16:00:00+06	LOAD-C2	294.1	132.63	75.4	normal	simulator
2026-10-31 16:00:00+06	GEN-W1	681.9	229.58	81.1	normal	simulator
2026-10-31 16:00:00+06	SUB-W1	829.8	229.44	66.1	normal	simulator
2026-10-31 16:00:00+06	LOAD-W1	416.9	132.4	77.2	normal	simulator
2026-10-31 16:00:00+06	LOAD-W2	426.9	132	82.1	normal	simulator
2026-10-31 16:00:00+06	GEN-S1	1144.6	229.42	79	normal	simulator
2026-10-31 16:00:00+06	SUB-S1	821.7	230.43	71.4	normal	simulator
2026-10-31 16:00:00+06	LOAD-S1	488.6	131.94	80.1	normal	simulator
2026-10-31 16:00:00+06	LOAD-S2	343.6	132.17	73.1	normal	simulator
2026-10-31 17:00:00+06	GEN-N1	966.3	229.64	80	normal	simulator
2026-10-31 17:00:00+06	SUB-N1	839.7	230.47	61.9	normal	simulator
2026-10-31 17:00:00+06	LOAD-N1	487.3	132.18	78.6	normal	simulator
2026-10-31 17:00:00+06	LOAD-N2	335	131.53	69.8	normal	simulator
2026-10-31 17:00:00+06	GEN-E1	871.9	229.37	80.8	normal	simulator
2026-10-31 17:00:00+06	SUB-E1	773.3	229.38	66.1	normal	simulator
2026-10-31 17:00:00+06	LOAD-E1	477.1	131.06	83.7	normal	simulator
2026-10-31 17:00:00+06	LOAD-E2	313.2	132.67	69.6	normal	simulator
2026-10-31 17:00:00+06	GEN-C1	1059.6	229.68	78.6	normal	simulator
2026-10-31 17:00:00+06	SUB-C1	969.7	230.25	72.9	normal	simulator
2026-10-31 17:00:00+06	LOAD-C1	655.9	130.66	86.3	warning	simulator
2026-10-31 17:00:00+06	LOAD-C2	287.8	131.68	73.8	normal	simulator
2026-10-31 17:00:00+06	GEN-W1	715	230.22	80.9	normal	simulator
2026-10-31 17:00:00+06	SUB-W1	843.8	229.56	65.6	normal	simulator
2026-10-31 17:00:00+06	LOAD-W1	418.5	131.68	77.5	normal	simulator
2026-10-31 17:00:00+06	LOAD-W2	439.4	131.92	84.5	normal	simulator
2026-10-31 17:00:00+06	GEN-S1	1190.5	230.46	81.5	normal	simulator
2026-10-31 17:00:00+06	SUB-S1	832.2	230.62	69.2	normal	simulator
2026-10-31 17:00:00+06	LOAD-S1	491.1	131.54	80.5	normal	simulator
2026-10-31 17:00:00+06	LOAD-S2	336.1	131.81	71.5	normal	simulator
2026-10-31 18:00:00+06	GEN-N1	970.9	229.46	81.7	normal	simulator
2026-10-31 18:00:00+06	SUB-N1	822.3	230.14	60.3	normal	simulator
2026-10-31 18:00:00+06	LOAD-N1	499.7	131.35	80.6	normal	simulator
2026-10-31 18:00:00+06	LOAD-N2	336	131.8	70	normal	simulator
2026-10-31 18:00:00+06	GEN-E1	862.8	230.27	80.3	normal	simulator
2026-10-31 18:00:00+06	SUB-E1	790.3	230.27	65.4	normal	simulator
2026-10-31 18:00:00+06	LOAD-E1	461.1	131.25	80.9	normal	simulator
2026-10-31 18:00:00+06	LOAD-E2	302.4	131.59	67.2	normal	simulator
2026-10-31 18:00:00+06	GEN-C1	1071.2	229.48	80.3	normal	simulator
2026-10-31 18:00:00+06	SUB-C1	943.7	229.82	72.9	normal	simulator
2026-10-31 18:00:00+06	LOAD-C1	655.1	130.75	86.2	warning	simulator
2026-10-31 18:00:00+06	LOAD-C2	289	131.76	74.1	normal	simulator
2026-10-31 18:00:00+06	GEN-W1	704.2	230.49	80.5	normal	simulator
2026-10-31 18:00:00+06	SUB-W1	857.9	230.1	65.4	normal	simulator
2026-10-31 18:00:00+06	LOAD-W1	407.7	131.99	75.5	normal	simulator
2026-10-31 18:00:00+06	LOAD-W2	428	131.27	82.3	normal	simulator
2026-10-31 18:00:00+06	GEN-S1	1178.8	229.4	80.2	normal	simulator
2026-10-31 18:00:00+06	SUB-S1	827.2	229.97	71	normal	simulator
2026-10-31 18:00:00+06	LOAD-S1	495.9	131.97	81.3	normal	simulator
2026-10-31 18:00:00+06	LOAD-S2	332.3	132.12	70.7	normal	simulator
2026-10-31 19:00:00+06	GEN-N1	952.2	230.5	80.3	normal	simulator
2026-10-31 19:00:00+06	SUB-N1	835.7	230.13	62.7	normal	simulator
2026-10-31 19:00:00+06	LOAD-N1	481.1	131.95	77.6	normal	simulator
2026-10-31 19:00:00+06	LOAD-N2	345.6	131.42	72	normal	simulator
2026-10-31 19:00:00+06	GEN-E1	850.3	230.52	79.9	normal	simulator
2026-10-31 19:00:00+06	SUB-E1	763.5	229.94	63.3	normal	simulator
2026-10-31 19:00:00+06	LOAD-E1	464	131.96	81.4	normal	simulator
2026-10-31 19:00:00+06	LOAD-E2	311.9	131.76	69.3	normal	simulator
2026-10-31 19:00:00+06	GEN-C1	1047.1	229.61	80.9	normal	simulator
2026-10-31 19:00:00+06	SUB-C1	944.1	230.18	70.5	normal	simulator
2026-10-31 19:00:00+06	LOAD-C1	679.4	131.35	89.4	warning	simulator
2026-10-31 19:00:00+06	LOAD-C2	292.5	131.95	75	normal	simulator
2026-10-31 19:00:00+06	GEN-W1	723.2	229.89	78.9	normal	simulator
2026-10-31 19:00:00+06	SUB-W1	835.7	229.4	68.5	normal	simulator
2026-10-31 19:00:00+06	LOAD-W1	404.5	131.91	74.9	normal	simulator
2026-10-31 19:00:00+06	LOAD-W2	426.4	131.87	82	normal	simulator
2026-10-31 19:00:00+06	GEN-S1	1169	230.01	80	normal	simulator
2026-10-31 19:00:00+06	SUB-S1	828.2	230.14	68.5	normal	simulator
2026-10-31 19:00:00+06	LOAD-S1	478.9	131.8	78.5	normal	simulator
2026-10-31 19:00:00+06	LOAD-S2	333.2	131.76	70.9	normal	simulator
2026-10-31 20:00:00+06	GEN-N1	981	229.43	78.6	normal	simulator
2026-10-31 20:00:00+06	SUB-N1	826.7	230.43	61.2	normal	simulator
2026-10-31 20:00:00+06	LOAD-N1	483.6	131.65	78	normal	simulator
2026-10-31 20:00:00+06	LOAD-N2	340.3	131.53	70.9	normal	simulator
2026-10-31 20:00:00+06	GEN-E1	840.5	229.9	81.2	normal	simulator
2026-10-31 20:00:00+06	SUB-E1	775.9	230.26	63.6	normal	simulator
2026-10-31 20:00:00+06	LOAD-E1	464	132.13	81.4	normal	simulator
2026-10-31 20:00:00+06	LOAD-E2	303.8	132.62	67.5	normal	simulator
2026-10-31 20:00:00+06	GEN-C1	1078.8	229.86	78.3	normal	simulator
2026-10-31 20:00:00+06	SUB-C1	971.9	229.34	70.5	normal	simulator
2026-10-31 20:00:00+06	LOAD-C1	662.7	131.54	87.2	warning	simulator
2026-10-31 20:00:00+06	LOAD-C2	283.9	131.94	72.8	normal	simulator
2026-10-31 20:00:00+06	GEN-W1	703.6	229.69	81.2	normal	simulator
2026-10-31 20:00:00+06	SUB-W1	830.9	230.57	65.9	normal	simulator
2026-10-31 20:00:00+06	LOAD-W1	405	132.45	75	normal	simulator
2026-10-31 20:00:00+06	LOAD-W2	422.2	132.39	81.2	normal	simulator
2026-10-31 20:00:00+06	GEN-S1	1181.3	229.63	78.6	normal	simulator
2026-10-31 20:00:00+06	SUB-S1	812.1	229.78	71.3	normal	simulator
2026-10-31 20:00:00+06	LOAD-S1	478.2	132.59	78.4	normal	simulator
2026-10-31 20:00:00+06	LOAD-S2	333.2	131.64	70.9	normal	simulator
2026-10-31 21:00:00+06	GEN-N1	987.6	229.9	78.4	normal	simulator
2026-10-31 21:00:00+06	SUB-N1	823.9	230.63	61.2	normal	simulator
2026-10-31 21:00:00+06	LOAD-N1	495.4	131.65	79.9	normal	simulator
2026-10-31 21:00:00+06	LOAD-N2	342.7	132.13	71.4	normal	simulator
2026-10-31 21:00:00+06	GEN-E1	844	229.67	80.3	normal	simulator
2026-10-31 21:00:00+06	SUB-E1	767.8	229.75	65.7	normal	simulator
2026-10-31 21:00:00+06	LOAD-E1	477.1	132.15	83.7	normal	simulator
2026-10-31 21:00:00+06	LOAD-E2	312.8	131.41	69.5	normal	simulator
2026-10-31 21:00:00+06	GEN-C1	1074.6	230.61	79.8	normal	simulator
2026-10-31 21:00:00+06	SUB-C1	946.6	230.56	71.4	normal	simulator
2026-10-31 21:00:00+06	LOAD-C1	656.6	130.89	86.4	warning	simulator
2026-10-31 21:00:00+06	LOAD-C2	288.6	132.41	74	normal	simulator
2026-10-31 21:00:00+06	GEN-W1	708.5	230.08	79.6	normal	simulator
2026-10-31 21:00:00+06	SUB-W1	827.2	230.18	67.4	normal	simulator
2026-10-31 21:00:00+06	LOAD-W1	413.1	131.8	76.5	normal	simulator
2026-10-31 21:00:00+06	LOAD-W2	426.9	132.19	82.1	normal	simulator
2026-10-31 21:00:00+06	GEN-S1	1136.7	229.71	80.7	normal	simulator
2026-10-31 21:00:00+06	SUB-S1	811.4	229.65	69.8	normal	simulator
2026-10-31 21:00:00+06	LOAD-S1	478.9	131.71	78.5	normal	simulator
2026-10-31 21:00:00+06	LOAD-S2	338.9	132.56	72.1	normal	simulator
2026-10-31 22:00:00+06	GEN-N1	971.2	230.32	78.7	normal	simulator
2026-10-31 22:00:00+06	SUB-N1	838.1	229.41	62.6	normal	simulator
2026-10-31 22:00:00+06	LOAD-N1	494.8	131.57	79.8	normal	simulator
2026-10-31 22:00:00+06	LOAD-N2	349	132.42	72.7	normal	simulator
2026-10-31 22:00:00+06	GEN-E1	867	229.78	80.9	normal	simulator
2026-10-31 22:00:00+06	SUB-E1	789.9	229.6	63.8	normal	simulator
2026-10-31 22:00:00+06	LOAD-E1	469.1	131.63	82.3	normal	simulator
2026-10-31 22:00:00+06	LOAD-E2	301.5	131.5	67	normal	simulator
2026-10-31 22:00:00+06	GEN-C1	1072	230.24	78.2	normal	simulator
2026-10-31 22:00:00+06	SUB-C1	945.2	229.43	70.6	normal	simulator
2026-10-31 22:00:00+06	LOAD-C1	670.3	130.7	88.2	warning	simulator
2026-10-31 22:00:00+06	LOAD-C2	285.5	131.75	73.2	normal	simulator
2026-10-31 22:00:00+06	GEN-W1	695.5	230.48	78.8	normal	simulator
2026-10-31 22:00:00+06	SUB-W1	840	229.86	65.9	normal	simulator
2026-10-31 22:00:00+06	LOAD-W1	418	132.35	77.4	normal	simulator
2026-10-31 22:00:00+06	LOAD-W2	425.4	131.67	81.8	normal	simulator
2026-10-31 22:00:00+06	GEN-S1	1180.5	230.63	79.7	normal	simulator
2026-10-31 22:00:00+06	SUB-S1	817.8	229.44	71.4	normal	simulator
2026-10-31 22:00:00+06	LOAD-S1	485.6	132.15	79.6	normal	simulator
2026-10-31 22:00:00+06	LOAD-S2	341.7	131.87	72.7	normal	simulator
2026-10-31 23:00:00+06	GEN-N1	998.8	230.12	78.9	normal	simulator
2026-10-31 23:00:00+06	SUB-N1	843.8	229.45	60.4	normal	simulator
2026-10-31 23:00:00+06	LOAD-N1	486.7	132.22	78.5	normal	simulator
2026-10-31 23:00:00+06	LOAD-N2	349	131.44	72.7	normal	simulator
2026-10-31 23:00:00+06	GEN-E1	867.2	230.2	79.1	normal	simulator
2026-10-31 23:00:00+06	SUB-E1	770.6	229.41	65.9	normal	simulator
2026-10-31 23:00:00+06	LOAD-E1	463.4	131.93	81.3	normal	simulator
2026-10-31 23:00:00+06	LOAD-E2	309.1	131.78	68.7	normal	simulator
2026-10-31 23:00:00+06	GEN-C1	1040.5	229.97	78.5	normal	simulator
2026-10-31 23:00:00+06	SUB-C1	955.8	230.18	72.9	normal	simulator
2026-10-31 23:00:00+06	LOAD-C1	665	130.71	87.5	warning	simulator
2026-10-31 23:00:00+06	LOAD-C2	291.7	132.62	74.8	normal	simulator
2026-10-31 23:00:00+06	GEN-W1	683.6	230.23	80.6	normal	simulator
2026-10-31 23:00:00+06	SUB-W1	843.4	230.25	67.2	normal	simulator
2026-10-31 23:00:00+06	LOAD-W1	406.1	132.29	75.2	normal	simulator
2026-10-31 23:00:00+06	LOAD-W2	426.4	131.8	82	normal	simulator
2026-10-31 23:00:00+06	GEN-S1	1180.2	229.2	81.1	normal	simulator
2026-10-31 23:00:00+06	SUB-S1	827.3	229.42	71	normal	simulator
2026-10-31 23:00:00+06	LOAD-S1	481.3	131.54	78.9	normal	simulator
2026-10-31 23:00:00+06	LOAD-S2	342.2	131.34	72.8	normal	simulator
2026-11-01 00:00:00+06	GEN-N1	978.6	229.34	78.8	normal	simulator
2026-11-01 00:00:00+06	SUB-N1	835.7	230.57	61.7	normal	simulator
2026-11-01 00:00:00+06	LOAD-N1	481.7	132.46	77.7	normal	simulator
2026-11-01 00:00:00+06	LOAD-N2	341.8	131.36	71.2	normal	simulator
2026-11-01 00:00:00+06	GEN-E1	873.1	229.94	81.5	normal	simulator
2026-11-01 00:00:00+06	SUB-E1	772.5	229.32	66.1	normal	simulator
2026-11-01 00:00:00+06	LOAD-E1	473.1	131.74	83	normal	simulator
2026-11-01 00:00:00+06	LOAD-E2	307.8	132.14	68.4	normal	simulator
2026-11-01 00:00:00+06	GEN-C1	1085.7	229.75	80.6	normal	simulator
2026-11-01 00:00:00+06	SUB-C1	956.7	230.46	70.7	normal	simulator
2026-11-01 00:00:00+06	LOAD-C1	669.6	130.65	88.1	warning	simulator
2026-11-01 00:00:00+06	LOAD-C2	293.3	131.48	75.2	normal	simulator
2026-11-01 00:00:00+06	GEN-W1	700.9	229.98	80.6	normal	simulator
2026-11-01 00:00:00+06	SUB-W1	832.5	230.4	67.6	normal	simulator
2026-11-01 00:00:00+06	LOAD-W1	412.6	132.6	76.4	normal	simulator
2026-11-01 00:00:00+06	LOAD-W2	428	131.86	82.3	normal	simulator
2026-11-01 00:00:00+06	GEN-S1	1198.7	229.58	78.4	normal	simulator
2026-11-01 00:00:00+06	SUB-S1	823.5	230.13	68.2	normal	simulator
2026-11-01 00:00:00+06	LOAD-S1	478.9	132.54	78.5	normal	simulator
2026-11-01 00:00:00+06	LOAD-S2	346.4	132.23	73.7	normal	simulator
2026-11-01 01:00:00+06	GEN-N1	963.3	229.94	78.9	normal	simulator
2026-11-01 01:00:00+06	SUB-N1	823.5	229.48	61.7	normal	simulator
2026-11-01 01:00:00+06	LOAD-N1	483.6	132.17	78	normal	simulator
2026-11-01 01:00:00+06	LOAD-N2	342.2	131.72	71.3	normal	simulator
2026-11-01 01:00:00+06	GEN-E1	878.4	230.03	78.2	normal	simulator
2026-11-01 01:00:00+06	SUB-E1	780.9	229.9	63.9	normal	simulator
2026-11-01 01:00:00+06	LOAD-E1	468.5	132.06	82.2	normal	simulator
2026-11-01 01:00:00+06	LOAD-E2	307.4	131.37	68.3	normal	simulator
2026-11-01 01:00:00+06	GEN-C1	1028.2	229.74	78.4	normal	simulator
2026-11-01 01:00:00+06	SUB-C1	962.9	229.69	72.6	normal	simulator
2026-11-01 01:00:00+06	LOAD-C1	655.9	131.35	86.3	warning	simulator
2026-11-01 01:00:00+06	LOAD-C2	286.3	132.56	73.4	normal	simulator
2026-11-01 01:00:00+06	GEN-W1	700.8	229.44	80.4	normal	simulator
2026-11-01 01:00:00+06	SUB-W1	840.6	229.42	67.7	normal	simulator
2026-11-01 01:00:00+06	LOAD-W1	409.9	132.07	75.9	normal	simulator
2026-11-01 01:00:00+06	LOAD-W2	434.2	131.42	83.5	normal	simulator
2026-11-01 01:00:00+06	GEN-S1	1200.3	230.17	79.6	normal	simulator
2026-11-01 01:00:00+06	SUB-S1	825.3	230.65	69.7	normal	simulator
2026-11-01 01:00:00+06	LOAD-S1	477.6	131.79	78.3	normal	simulator
2026-11-01 01:00:00+06	LOAD-S2	341.7	132.21	72.7	normal	simulator
2026-11-01 02:00:00+06	GEN-N1	963.5	230.31	79.1	normal	simulator
2026-11-01 02:00:00+06	SUB-N1	825.8	230.15	63.8	normal	simulator
2026-11-01 02:00:00+06	LOAD-N1	490.4	131.33	79.1	normal	simulator
2026-11-01 02:00:00+06	LOAD-N2	339.4	132.12	70.7	normal	simulator
2026-11-01 02:00:00+06	GEN-E1	868	230.64	78.9	normal	simulator
2026-11-01 02:00:00+06	SUB-E1	775.9	230.22	64.9	normal	simulator
2026-11-01 02:00:00+06	LOAD-E1	458.9	131.85	80.5	normal	simulator
2026-11-01 02:00:00+06	LOAD-E2	301.9	132.16	67.1	normal	simulator
2026-11-01 02:00:00+06	GEN-C1	1044.7	229.37	80.7	normal	simulator
2026-11-01 02:00:00+06	SUB-C1	942.2	230.17	72.8	normal	simulator
2026-11-01 02:00:00+06	LOAD-C1	665.8	130.67	87.6	warning	simulator
2026-11-01 02:00:00+06	LOAD-C2	290.9	131.74	74.6	normal	simulator
2026-11-01 02:00:00+06	GEN-W1	719.8	230.2	81.4	normal	simulator
2026-11-01 02:00:00+06	SUB-W1	844.1	230.51	68.5	normal	simulator
2026-11-01 02:00:00+06	LOAD-W1	410.4	132.59	76	normal	simulator
2026-11-01 02:00:00+06	LOAD-W2	431.6	131.4	83	normal	simulator
2026-11-01 02:00:00+06	GEN-S1	1200	229.77	79.6	normal	simulator
2026-11-01 02:00:00+06	SUB-S1	819.3	230.23	69.3	normal	simulator
2026-11-01 02:00:00+06	LOAD-S1	491.7	132.05	80.6	normal	simulator
2026-11-01 02:00:00+06	LOAD-S2	339.8	132.34	72.3	normal	simulator
2026-11-01 03:00:00+06	GEN-N1	944.8	229.42	78.7	normal	simulator
2026-11-01 03:00:00+06	SUB-N1	829.8	229.98	61.8	normal	simulator
2026-11-01 03:00:00+06	LOAD-N1	492.9	132.13	79.5	normal	simulator
2026-11-01 03:00:00+06	LOAD-N2	341.3	131.68	71.1	normal	simulator
2026-11-01 03:00:00+06	GEN-E1	858	230.17	80.3	normal	simulator
2026-11-01 03:00:00+06	SUB-E1	760.8	229.75	66.5	normal	simulator
2026-11-01 03:00:00+06	LOAD-E1	470.8	131.91	82.6	normal	simulator
2026-11-01 03:00:00+06	LOAD-E2	307.8	131.43	68.4	normal	simulator
2026-11-01 03:00:00+06	GEN-C1	1030.5	229.9	79.3	normal	simulator
2026-11-01 03:00:00+06	SUB-C1	956.7	229.62	73.5	normal	simulator
2026-11-01 03:00:00+06	LOAD-C1	668	130.77	87.9	warning	simulator
2026-11-01 03:00:00+06	LOAD-C2	283.1	131.94	72.6	normal	simulator
2026-11-01 03:00:00+06	GEN-W1	713.1	230.31	81.7	normal	simulator
2026-11-01 03:00:00+06	SUB-W1	842	230.48	66.2	normal	simulator
2026-11-01 03:00:00+06	LOAD-W1	417.4	132.65	77.3	normal	simulator
2026-11-01 03:00:00+06	LOAD-W2	428.5	131.07	82.4	normal	simulator
2026-11-01 03:00:00+06	GEN-S1	1182.8	230.33	81.4	normal	simulator
2026-11-01 03:00:00+06	SUB-S1	831.5	230.62	68.5	normal	simulator
2026-11-01 03:00:00+06	LOAD-S1	483.1	132.45	79.2	normal	simulator
2026-11-01 03:00:00+06	LOAD-S2	336.1	131.54	71.5	normal	simulator
2026-11-01 04:00:00+06	GEN-N1	954.1	229.38	78.3	normal	simulator
2026-11-01 04:00:00+06	SUB-N1	834.2	230.21	61	normal	simulator
2026-11-01 04:00:00+06	LOAD-N1	484.2	131.8	78.1	normal	simulator
2026-11-01 04:00:00+06	LOAD-N2	342.7	132.39	71.4	normal	simulator
2026-11-01 04:00:00+06	GEN-E1	881.2	230.01	78.7	normal	simulator
2026-11-01 04:00:00+06	SUB-E1	778.6	229.65	66.7	normal	simulator
2026-11-01 04:00:00+06	LOAD-E1	470.2	131.03	82.5	normal	simulator
2026-11-01 04:00:00+06	LOAD-E2	298.8	132.14	66.4	normal	simulator
2026-11-01 04:00:00+06	GEN-C1	1059.5	230.26	81	normal	simulator
2026-11-01 04:00:00+06	SUB-C1	951.1	230.07	71.8	normal	simulator
2026-11-01 04:00:00+06	LOAD-C1	658.9	131.51	86.7	warning	simulator
2026-11-01 04:00:00+06	LOAD-C2	282.4	131.61	72.4	normal	simulator
2026-11-01 04:00:00+06	GEN-W1	718.5	230.64	79.7	normal	simulator
2026-11-01 04:00:00+06	SUB-W1	845.9	229.34	67.1	normal	simulator
2026-11-01 04:00:00+06	LOAD-W1	405	132.65	75	normal	simulator
2026-11-01 04:00:00+06	LOAD-W2	437.3	131.86	84.1	normal	simulator
2026-11-01 04:00:00+06	GEN-S1	1159.3	230.64	78.5	normal	simulator
2026-11-01 04:00:00+06	SUB-S1	819.2	230.45	68.9	normal	simulator
2026-11-01 04:00:00+06	LOAD-S1	498.4	131.67	81.7	normal	simulator
2026-11-01 04:00:00+06	LOAD-S2	340.8	132.48	72.5	normal	simulator
2026-11-01 05:00:00+06	GEN-N1	986.8	229.35	81.5	normal	simulator
2026-11-01 05:00:00+06	SUB-N1	826.9	229.57	62.7	normal	simulator
2026-11-01 05:00:00+06	LOAD-N1	487.3	132.4	78.6	normal	simulator
2026-11-01 05:00:00+06	LOAD-N2	338.9	131.86	70.6	normal	simulator
2026-11-01 05:00:00+06	GEN-E1	844.8	230.11	81	normal	simulator
2026-11-01 05:00:00+06	SUB-E1	769	230.19	66.8	normal	simulator
2026-11-01 05:00:00+06	LOAD-E1	458.3	132.15	80.4	normal	simulator
2026-11-01 05:00:00+06	LOAD-E2	300.1	132.47	66.7	normal	simulator
2026-11-01 05:00:00+06	GEN-C1	1028.8	230.25	79.2	normal	simulator
2026-11-01 05:00:00+06	SUB-C1	941.3	229.58	72.7	normal	simulator
2026-11-01 05:00:00+06	LOAD-C1	669.6	131.07	88.1	warning	simulator
2026-11-01 05:00:00+06	LOAD-C2	283.5	132.1	72.7	normal	simulator
2026-11-01 05:00:00+06	GEN-W1	683.1	230.23	81.2	normal	simulator
2026-11-01 05:00:00+06	SUB-W1	842.3	230.62	68.1	normal	simulator
2026-11-01 05:00:00+06	LOAD-W1	419	131.47	77.6	normal	simulator
2026-11-01 05:00:00+06	LOAD-W2	429	131.75	82.5	normal	simulator
2026-11-01 05:00:00+06	GEN-S1	1134.1	230.63	80.5	normal	simulator
2026-11-01 05:00:00+06	SUB-S1	839.2	229.84	69.4	normal	simulator
2026-11-01 05:00:00+06	LOAD-S1	497.8	132.31	81.6	normal	simulator
2026-11-01 05:00:00+06	LOAD-S2	340.3	132.3	72.4	normal	simulator
2026-11-01 05:21:18.602954+06	GEN-N1	959.2	230.33	80.6	normal	simulator
2026-11-01 05:21:18.602954+06	SUB-N1	843.7	229.99	60.5	normal	simulator
2026-11-01 05:21:18.602954+06	LOAD-N1	495.4	131.71	79.9	normal	simulator
2026-11-01 05:21:18.602954+06	LOAD-N2	337.9	131.78	70.4	normal	simulator
2026-11-01 05:21:18.602954+06	GEN-E1	852.4	229.87	80.4	normal	simulator
2026-11-01 05:21:18.602954+06	SUB-E1	764.3	230.48	66.7	normal	simulator
2026-11-01 05:21:18.602954+06	LOAD-E1	457.7	132.64	80.3	normal	simulator
2026-11-01 05:21:18.602954+06	LOAD-E2	313.6	132.01	69.7	normal	simulator
2026-11-01 05:21:18.602954+06	GEN-C1	1076.7	229.67	79.4	normal	simulator
2026-11-01 05:21:18.602954+06	SUB-C1	948	229.55	70.7	normal	simulator
2026-11-01 05:21:18.602954+06	LOAD-C1	655.9	131.59	86.3	warning	simulator
2026-11-01 05:21:18.602954+06	LOAD-C2	293.7	132.67	75.3	normal	simulator
2026-11-01 05:21:18.602954+06	GEN-W1	680.2	229.95	80.1	normal	simulator
2026-11-01 05:21:18.602954+06	SUB-W1	842.4	230.11	67.4	normal	simulator
2026-11-01 05:21:18.602954+06	LOAD-W1	418.5	132.15	77.5	normal	simulator
2026-11-01 05:21:18.602954+06	LOAD-W2	424.3	132.34	81.6	normal	simulator
2026-11-01 05:21:18.602954+06	GEN-S1	1198.3	230.11	79.1	normal	simulator
2026-11-01 05:21:18.602954+06	SUB-S1	819	230.69	69.8	normal	simulator
2026-11-01 05:21:18.602954+06	LOAD-S1	477	131.57	78.2	normal	simulator
2026-11-01 05:21:18.602954+06	LOAD-S2	332.8	132.64	70.8	normal	simulator
2026-11-01 05:21:18.611849+06	GEN-N1	271.5	230.26	79.9	normal	simulator
2026-11-01 05:21:18.611849+06	SUB-N1	833.3	229.67	62.3	normal	simulator
2026-11-01 05:21:18.611849+06	LOAD-N1	498.5	131.92	80.4	normal	simulator
2026-11-01 05:21:18.611849+06	LOAD-N2	339.4	132.08	70.7	normal	simulator
2026-11-01 05:21:18.611849+06	GEN-E1	855.7	230.63	79.1	normal	simulator
2026-11-01 05:21:18.611849+06	SUB-E1	771.3	230.5	64.4	normal	simulator
2026-11-01 05:21:18.611849+06	LOAD-E1	475.9	132.12	83.5	normal	simulator
2026-11-01 05:21:18.611849+06	LOAD-E2	300.1	131.43	66.7	normal	simulator
2026-11-01 05:21:18.611849+06	GEN-C1	1067.5	229.57	80.6	normal	simulator
2026-11-01 05:21:18.611849+06	SUB-C1	949.6	229.57	70.7	normal	simulator
2026-11-01 05:21:18.611849+06	LOAD-C1	658.9	130.68	86.7	warning	simulator
2026-11-01 05:21:18.611849+06	LOAD-C2	290.9	132.18	74.6	normal	simulator
2026-11-01 05:21:18.611849+06	GEN-W1	202.5	229.83	80.8	normal	simulator
2026-11-01 05:21:18.611849+06	SUB-W1	842.8	229.45	66.9	normal	simulator
2026-11-01 05:21:18.611849+06	LOAD-W1	411.5	131.65	76.2	normal	simulator
2026-11-01 05:21:18.611849+06	LOAD-W2	436.3	131.97	83.9	normal	simulator
2026-11-01 05:21:18.611849+06	GEN-S1	1179.2	229.56	80.7	normal	simulator
2026-11-01 05:21:18.611849+06	SUB-S1	809.8	230.52	69.9	normal	simulator
2026-11-01 05:21:18.611849+06	LOAD-S1	486.2	131.36	79.7	normal	simulator
2026-11-01 05:21:18.611849+06	LOAD-S2	344.5	131.84	73.3	normal	simulator
2026-11-01 05:21:35.018473+06	GEN-N1	1002	230.27	79	normal	simulator
2026-11-01 05:21:35.018473+06	SUB-N1	839.1	230.63	62.8	normal	simulator
2026-11-01 05:21:35.018473+06	LOAD-N1	499.1	131.3	80.5	normal	simulator
2026-11-01 05:21:35.018473+06	LOAD-N2	344.6	132.43	71.8	normal	simulator
2026-11-01 05:21:35.018473+06	GEN-E1	843.3	229.55	79.7	normal	simulator
2026-11-01 05:21:35.018473+06	SUB-E1	782.4	229.56	65.5	normal	simulator
2026-11-01 05:21:35.018473+06	LOAD-E1	462.8	131.9	81.2	normal	simulator
2026-11-01 05:21:35.018473+06	LOAD-E2	301.5	131.46	67	normal	simulator
2026-11-01 05:21:35.018473+06	GEN-C1	1046.3	229.36	80.9	normal	simulator
2026-11-01 05:21:35.018473+06	SUB-C1	956.2	230.62	70.3	normal	simulator
2026-11-01 05:21:35.018473+06	LOAD-C1	655.1	130.8	86.2	warning	simulator
2026-11-01 05:21:35.018473+06	LOAD-C2	292.9	131.76	75.1	normal	simulator
2026-11-01 05:21:35.018473+06	GEN-W1	697	230.12	79	normal	simulator
2026-11-01 05:21:35.018473+06	SUB-W1	828.7	229.89	68.1	normal	simulator
2026-11-01 05:21:35.018473+06	LOAD-W1	407.7	132.17	75.5	normal	simulator
2026-11-01 05:21:35.018473+06	LOAD-W2	434.7	131.97	83.6	normal	simulator
2026-11-01 05:21:35.018473+06	GEN-S1	1135.4	230.1	79.3	normal	simulator
2026-11-01 05:21:35.018473+06	SUB-S1	830.9	230.44	69.9	normal	simulator
2026-11-01 05:21:35.018473+06	LOAD-S1	482.5	132.55	79.1	normal	simulator
2026-11-01 05:21:35.018473+06	LOAD-S2	336.5	131.53	71.6	normal	simulator
2026-11-01 05:22:35.231577+06	GEN-N1	1005.7	229.33	81.1	normal	simulator
2026-11-01 05:22:35.231577+06	SUB-N1	828.6	229.65	61.3	normal	simulator
2026-11-01 05:22:35.231577+06	LOAD-N1	489.2	131.57	78.9	normal	simulator
2026-11-01 05:22:35.231577+06	LOAD-N2	338.9	132.24	70.6	normal	simulator
2026-11-01 05:22:35.231577+06	GEN-E1	868.7	229.45	81.1	normal	simulator
2026-11-01 05:22:35.231577+06	SUB-E1	762.2	230.54	63.8	normal	simulator
2026-11-01 05:22:35.231577+06	LOAD-E1	471.4	131.93	82.7	normal	simulator
2026-11-01 05:22:35.231577+06	LOAD-E2	311.4	132.01	69.2	normal	simulator
2026-11-01 05:22:35.231577+06	GEN-C1	1033.9	230.19	78.3	normal	simulator
2026-11-01 05:22:35.231577+06	SUB-C1	945.3	229.88	71.1	normal	simulator
2026-11-01 05:22:35.231577+06	LOAD-C1	671.1	131.05	88.3	warning	simulator
2026-11-01 05:22:35.231577+06	LOAD-C2	289.8	132.67	74.3	normal	simulator
2026-11-01 05:22:35.231577+06	GEN-W1	704.9	229.91	78.4	normal	simulator
2026-11-01 05:22:35.231577+06	SUB-W1	832.4	230.52	67.4	normal	simulator
2026-11-01 05:22:35.231577+06	LOAD-W1	403.9	131.88	74.8	normal	simulator
2026-11-01 05:22:35.231577+06	LOAD-W2	436.8	132.06	84	normal	simulator
2026-11-01 05:22:35.231577+06	GEN-S1	1152.2	230.63	78.6	normal	simulator
2026-11-01 05:22:35.231577+06	SUB-S1	824.8	230.61	68.4	normal	simulator
2026-11-01 05:22:35.231577+06	LOAD-S1	483.7	131.79	79.3	normal	simulator
2026-11-01 05:22:35.231577+06	LOAD-S2	331.4	131.45	70.5	normal	simulator
2026-11-01 05:22:57.756767+06	GEN-N1	964.3	230.19	80.7	normal	simulator
2026-11-01 05:22:57.756767+06	SUB-N1	826.1	230.35	63.5	normal	simulator
2026-11-01 05:22:57.756767+06	LOAD-N1	558	131.27	90	warning	simulator
2026-11-01 05:22:57.756767+06	LOAD-N2	392.6	131.31	81.8	normal	simulator
2026-11-01 05:22:57.756767+06	GEN-E1	869.8	229.97	78.7	normal	simulator
2026-11-01 05:22:57.756767+06	SUB-E1	786.8	229.71	63.9	normal	simulator
2026-11-01 05:22:57.756767+06	LOAD-E1	531.8	129.92	93.3	warning	simulator
2026-11-01 05:22:57.756767+06	LOAD-E2	350.6	132.3	77.9	normal	simulator
2026-11-01 05:22:57.756767+06	GEN-C1	1051.4	229.53	80.9	normal	simulator
2026-11-01 05:22:57.756767+06	SUB-C1	962.1	230.36	71.6	normal	simulator
2026-11-01 05:22:57.756767+06	LOAD-C1	740.2	130.14	97.4	critical	simulator
2026-11-01 05:22:57.756767+06	LOAD-C2	336.2	130.81	86.2	warning	simulator
2026-11-01 05:22:57.756767+06	GEN-W1	713	229.67	80.6	normal	simulator
2026-11-01 05:22:57.756767+06	SUB-W1	838.7	229.87	68.5	normal	simulator
2026-11-01 05:22:57.756767+06	LOAD-W1	464.9	131.82	86.1	warning	simulator
2026-11-01 05:22:57.756767+06	LOAD-W2	487.2	130.15	93.7	warning	simulator
2026-11-01 05:22:57.756767+06	GEN-S1	1194	230.29	79.5	normal	simulator
2026-11-01 05:22:57.756767+06	SUB-S1	817.3	229.73	69.7	normal	simulator
2026-11-01 05:22:57.756767+06	LOAD-S1	545.3	130.87	89.4	warning	simulator
2026-11-01 05:22:57.756767+06	LOAD-S2	392	131.06	83.4	normal	simulator
2026-11-01 05:22:57.82347+06	GEN-N1	276.9	229.52	80.1	normal	simulator
2026-11-01 05:22:57.82347+06	SUB-N1	1035.3	230.23	61	normal	simulator
2026-11-01 05:22:57.82347+06	LOAD-N1	486.7	132.44	78.5	normal	simulator
2026-11-01 05:22:57.82347+06	LOAD-N2	349	131.63	72.7	normal	simulator
2026-11-01 05:22:57.82347+06	GEN-E1	875.4	230.4	79.3	normal	simulator
2026-11-01 05:22:57.82347+06	SUB-E1	947.8	230.64	65.2	normal	simulator
2026-11-01 05:22:57.82347+06	LOAD-E1	470.8	131.07	82.6	normal	simulator
2026-11-01 05:22:57.82347+06	LOAD-E2	310.5	132.08	69	normal	simulator
2026-11-01 05:22:57.82347+06	GEN-C1	1065.3	229.4	80.4	normal	simulator
2026-11-01 05:22:57.82347+06	SUB-C1	1122.3	229.91	70.7	normal	simulator
2026-11-01 05:22:57.82347+06	LOAD-C1	661.2	131.41	87	warning	simulator
2026-11-01 05:22:57.82347+06	LOAD-C2	289.8	132.33	74.3	normal	simulator
2026-11-01 05:22:57.82347+06	GEN-W1	190.3	230.57	78.8	normal	simulator
2026-11-01 05:22:57.82347+06	SUB-W1	1033.5	230.45	67	normal	simulator
2026-11-01 05:22:57.82347+06	LOAD-W1	413.1	132.55	76.5	normal	simulator
2026-11-01 05:22:57.82347+06	LOAD-W2	439.9	132.17	84.6	normal	simulator
2026-11-01 05:22:57.82347+06	GEN-S1	1196.8	230.39	80.4	normal	simulator
2026-11-01 05:22:57.82347+06	SUB-S1	1007.6	229.61	69	normal	simulator
2026-11-01 05:22:57.82347+06	LOAD-S1	497.1	131.41	81.5	normal	simulator
2026-11-01 05:22:57.82347+06	LOAD-S2	332.8	132.19	70.8	normal	simulator
2026-11-01 05:22:57.872886+06	GEN-N1	989	229.33	79.1	normal	simulator
2026-11-01 05:22:57.872886+06	SUB-N1	827	230.18	61.5	normal	simulator
2026-11-01 05:22:57.872886+06	LOAD-N1	499.1	131.3	80.5	normal	simulator
2026-11-01 05:22:57.872886+06	LOAD-N2	340.8	132.36	71	normal	simulator
2026-11-01 05:22:57.872886+06	GEN-E1	856.3	229.68	78.5	normal	simulator
2026-11-01 05:22:57.872886+06	SUB-E1	774	229.77	65.4	normal	simulator
2026-11-01 05:22:57.872886+06	LOAD-E1	462.8	131.24	81.2	normal	simulator
2026-11-01 05:22:57.872886+06	LOAD-E2	302.4	131.48	67.2	normal	simulator
2026-11-01 05:22:57.872886+06	GEN-C1	1056.2	229.46	78.3	normal	simulator
2026-11-01 05:22:57.872886+06	SUB-C1	963.6	230.45	70.8	normal	simulator
2026-11-01 05:22:57.872886+06	LOAD-C1	667.3	131.78	87.8	warning	simulator
2026-11-01 05:22:57.872886+06	LOAD-C2	294.1	132.07	75.4	normal	simulator
2026-11-01 05:22:57.872886+06	GEN-W1	721.8	230.22	79.7	normal	simulator
2026-11-01 05:22:57.872886+06	SUB-W1	846.3	230.2	65.8	normal	simulator
2026-11-01 05:22:57.872886+06	LOAD-W1	411.5	131.98	76.2	normal	simulator
2026-11-01 05:22:57.872886+06	LOAD-W2	426.4	131.09	82	normal	simulator
2026-11-01 05:22:57.872886+06	GEN-S1	1150.7	229.58	80.2	normal	simulator
2026-11-01 05:22:57.872886+06	SUB-S1	827.7	230.4	68.6	normal	simulator
2026-11-01 05:22:57.872886+06	LOAD-S1	478.2	131.79	78.4	normal	simulator
2026-11-01 05:22:57.872886+06	LOAD-S2	345	132.56	73.4	normal	simulator
2026-11-01 05:26:36.113357+06	GEN-N1	1002.5	230.44	78.8	normal	simulator
2026-11-01 05:26:36.113357+06	SUB-N1	848.5	230.68	62.4	normal	simulator
2026-11-01 05:26:36.113357+06	LOAD-N1	500.3	131.97	80.7	normal	simulator
2026-11-01 05:26:36.113357+06	LOAD-N2	343.7	131.76	71.6	normal	simulator
2026-11-01 05:26:36.113357+06	GEN-E1	855.1	229.6	78.3	normal	simulator
2026-11-01 05:26:36.113357+06	SUB-E1	767.8	230.14	66.4	normal	simulator
2026-11-01 05:26:36.113357+06	LOAD-E1	461.7	131.28	81	normal	simulator
2026-11-01 05:26:36.113357+06	LOAD-E2	311.4	131.44	69.2	normal	simulator
2026-11-01 05:26:36.113357+06	GEN-C1	1032.6	229.85	80.7	normal	simulator
2026-11-01 05:26:36.113357+06	SUB-C1	967	230.41	71.3	normal	simulator
2026-11-01 05:26:36.113357+06	LOAD-C1	671.8	130.95	88.4	warning	simulator
2026-11-01 05:26:36.113357+06	LOAD-C2	283.1	132.31	72.6	normal	simulator
2026-11-01 05:26:36.113357+06	GEN-W1	704.7	230.06	80.3	normal	simulator
2026-11-01 05:26:36.113357+06	SUB-W1	843.3	229.35	68.1	normal	simulator
2026-11-01 05:26:36.113357+06	LOAD-W1	416.3	132.58	77.1	normal	simulator
2026-11-01 05:26:36.113357+06	LOAD-W2	433.7	132.02	83.4	normal	simulator
2026-11-01 05:26:36.113357+06	GEN-S1	1154.5	230.24	81.5	normal	simulator
2026-11-01 05:26:36.113357+06	SUB-S1	836.3	230.25	69.1	normal	simulator
2026-11-01 05:26:36.113357+06	LOAD-S1	479.5	131.46	78.6	normal	simulator
2026-11-01 05:26:36.113357+06	LOAD-S2	343.6	131.81	73.1	normal	simulator
2026-11-01 05:22:57.794456+06	GEN-N1	964.6	229.83	79.4	normal	simulator
2026-11-01 05:22:57.794456+06	SUB-N1	950.6	229.86	61.6	normal	simulator
2026-11-01 05:22:57.794456+06	LOAD-N1	611.9	130.58	98.7	critical	simulator
2026-11-01 05:22:57.794456+06	LOAD-N2	423.4	131.53	88.2	warning	simulator
2026-11-01 05:22:57.794456+06	GEN-E1	853.3	229.69	78.4	normal	simulator
2026-11-01 05:22:57.794456+06	SUB-E1	882.4	230.06	64.2	normal	simulator
2026-11-01 05:22:57.794456+06	LOAD-E1	562.6	129.91	98.7	critical	simulator
2026-11-01 05:22:57.794456+06	LOAD-E2	385.2	131.73	85.6	warning	simulator
2026-11-01 05:22:57.794456+06	GEN-C1	1021.9	230.23	80.1	normal	simulator
2026-11-01 05:22:57.794456+06	SUB-C1	1076.4	230.09	73.5	normal	simulator
2026-11-01 05:22:57.794456+06	LOAD-C1	760	130.03	100	critical	simulator
2026-11-01 05:22:57.794456+06	LOAD-C2	362.3	130.06	92.9	warning	simulator
2026-11-01 05:22:57.794456+06	GEN-W1	683.2	230.65	79.3	normal	simulator
2026-11-01 05:22:57.794456+06	SUB-W1	952.1	230.4	68.2	normal	simulator
2026-11-01 05:22:57.794456+06	LOAD-W1	513.5	129.91	95.1	critical	simulator
2026-11-01 05:22:57.794456+06	LOAD-W2	520	130.46	100	critical	simulator
2026-11-01 05:22:57.794456+06	GEN-S1	1196	229.73	80.4	normal	simulator
2026-11-01 05:22:57.794456+06	SUB-S1	937.3	230.63	71.4	normal	simulator
2026-11-01 05:22:57.794456+06	LOAD-S1	587.4	130.09	96.3	critical	simulator
2026-11-01 05:22:57.794456+06	LOAD-S2	420.2	130.67	89.4	warning	simulator
2026-11-01 05:22:57.851091+06	GEN-N1	946.2	229.75	79.1	normal	simulator
2026-11-01 05:22:57.851091+06	SUB-N1	835.7	230.26	60.9	normal	simulator
2026-11-01 05:22:57.851091+06	LOAD-N1	491	131.65	79.2	normal	simulator
2026-11-01 05:22:57.851091+06	LOAD-N2	336	132.16	70	normal	simulator
2026-11-01 05:22:57.851091+06	GEN-E1	838.3	230.56	80.6	normal	simulator
2026-11-01 05:22:57.851091+06	SUB-E1	781.3	230.61	66.1	normal	simulator
2026-11-01 05:22:57.851091+06	LOAD-E1	470.2	132.4	82.5	normal	simulator
2026-11-01 05:22:57.851091+06	LOAD-E2	303.8	132.66	67.5	normal	simulator
2026-11-01 05:22:57.851091+06	GEN-C1	1063.8	230.63	78.8	normal	simulator
2026-11-01 05:22:57.851091+06	SUB-C1	0	230.63	71.5	critical	simulator
2026-11-01 05:22:57.851091+06	LOAD-C1	668.8	130.63	88	warning	simulator
2026-11-01 05:22:57.851091+06	LOAD-C2	294.8	132.05	75.6	normal	simulator
2026-11-01 05:22:57.851091+06	GEN-W1	722.4	230.5	79.8	normal	simulator
2026-11-01 05:22:57.851091+06	SUB-W1	853	229.79	66.5	normal	simulator
2026-11-01 05:22:57.851091+06	LOAD-W1	412.6	132.36	76.4	normal	simulator
2026-11-01 05:22:57.851091+06	LOAD-W2	433.7	131.84	83.4	normal	simulator
2026-11-01 05:22:57.851091+06	GEN-S1	1149.9	230.42	81.4	normal	simulator
2026-11-01 05:22:57.851091+06	SUB-S1	829.9	230.44	68.8	normal	simulator
2026-11-01 05:22:57.851091+06	LOAD-S1	495.9	131.33	81.3	normal	simulator
2026-11-01 05:22:57.851091+06	LOAD-S2	331.8	132.39	70.6	normal	simulator
2026-11-01 05:23:35.448552+06	GEN-N1	944.8	229.42	78.7	normal	simulator
2026-11-01 05:23:35.448552+06	SUB-N1	829.8	229.98	61.8	normal	simulator
2026-11-01 05:23:35.448552+06	LOAD-N1	492.9	132.13	79.5	normal	simulator
2026-11-01 05:23:35.448552+06	LOAD-N2	341.3	131.68	71.1	normal	simulator
2026-11-01 05:23:35.448552+06	GEN-E1	858	230.17	80.3	normal	simulator
2026-11-01 05:23:35.448552+06	SUB-E1	760.8	229.75	66.5	normal	simulator
2026-11-01 05:23:35.448552+06	LOAD-E1	470.8	131.91	82.6	normal	simulator
2026-11-01 05:23:35.448552+06	LOAD-E2	307.8	131.43	68.4	normal	simulator
2026-11-01 05:23:35.448552+06	GEN-C1	1030.5	229.9	79.3	normal	simulator
2026-11-01 05:23:35.448552+06	SUB-C1	956.7	229.62	73.5	normal	simulator
2026-11-01 05:23:35.448552+06	LOAD-C1	668	130.77	87.9	warning	simulator
2026-11-01 05:23:35.448552+06	LOAD-C2	283.1	131.94	72.6	normal	simulator
2026-11-01 05:23:35.448552+06	GEN-W1	713.1	230.31	81.7	normal	simulator
2026-11-01 05:23:35.448552+06	SUB-W1	842	230.48	66.2	normal	simulator
2026-11-01 05:23:35.448552+06	LOAD-W1	417.4	132.65	77.3	normal	simulator
2026-11-01 05:23:35.448552+06	LOAD-W2	428.5	131.07	82.4	normal	simulator
2026-11-01 05:23:35.448552+06	GEN-S1	1182.8	230.33	81.4	normal	simulator
2026-11-01 05:23:35.448552+06	SUB-S1	831.5	230.62	68.5	normal	simulator
2026-11-01 05:23:35.448552+06	LOAD-S1	483.1	132.45	79.2	normal	simulator
2026-11-01 05:23:35.448552+06	LOAD-S2	336.1	131.54	71.5	normal	simulator
2026-11-01 05:24:35.660304+06	GEN-N1	946.6	230.61	80.3	normal	simulator
2026-11-01 05:24:35.660304+06	SUB-N1	823.5	230.37	60.6	normal	simulator
2026-11-01 05:24:35.660304+06	LOAD-N1	495.4	132.25	79.9	normal	simulator
2026-11-01 05:24:35.660304+06	LOAD-N2	345.6	131.77	72	normal	simulator
2026-11-01 05:24:35.660304+06	GEN-E1	836.8	229.52	81	normal	simulator
2026-11-01 05:24:35.660304+06	SUB-E1	772.5	230.3	64.2	normal	simulator
2026-11-01 05:24:35.660304+06	LOAD-E1	458.3	131.65	80.4	normal	simulator
2026-11-01 05:24:35.660304+06	LOAD-E2	299.2	131.73	66.5	normal	simulator
2026-11-01 05:24:35.660304+06	GEN-C1	1024	230.09	81	normal	simulator
2026-11-01 05:24:35.660304+06	SUB-C1	951.6	230.11	71.9	normal	simulator
2026-11-01 05:24:35.660304+06	LOAD-C1	673.4	131.69	88.6	warning	simulator
2026-11-01 05:24:35.660304+06	LOAD-C2	286.6	132.61	73.5	normal	simulator
2026-11-01 05:24:35.660304+06	GEN-W1	706.6	229.94	79.8	normal	simulator
2026-11-01 05:24:35.660304+06	SUB-W1	846.3	229.92	65.3	normal	simulator
2026-11-01 05:24:35.660304+06	LOAD-W1	402.8	132.47	74.6	normal	simulator
2026-11-01 05:24:35.660304+06	LOAD-W2	432.1	131.92	83.1	normal	simulator
2026-11-01 05:24:35.660304+06	GEN-S1	1143.7	229.53	78.3	normal	simulator
2026-11-01 05:24:35.660304+06	SUB-S1	828.5	230.54	69.3	normal	simulator
2026-11-01 05:24:35.660304+06	LOAD-S1	487.4	132.54	79.9	normal	simulator
2026-11-01 05:24:35.660304+06	LOAD-S2	343.6	132.34	73.1	normal	simulator
2026-11-01 05:25:23.689899+06	GEN-N1	982.8	229.38	78.8	normal	simulator
2026-11-01 05:25:23.689899+06	SUB-N1	826.5	229.99	62.5	normal	simulator
2026-11-01 05:25:23.689899+06	LOAD-N1	561.1	131.06	90.5	warning	simulator
2026-11-01 05:25:23.689899+06	LOAD-N2	387.4	132.2	80.7	normal	simulator
2026-11-01 05:25:23.689899+06	GEN-E1	835.2	229.89	79.4	normal	simulator
2026-11-01 05:25:23.689899+06	SUB-E1	778.7	230.58	64.8	normal	simulator
2026-11-01 05:25:23.689899+06	LOAD-E1	526.1	131.19	92.3	warning	simulator
2026-11-01 05:25:23.689899+06	LOAD-E2	363.1	132.29	80.7	normal	simulator
2026-11-01 05:25:23.689899+06	GEN-C1	1029.6	230.31	78.3	normal	simulator
2026-11-01 05:25:23.689899+06	SUB-C1	967.3	229.83	73.7	normal	simulator
2026-11-01 05:25:23.689899+06	LOAD-C1	752.4	129.31	99	critical	simulator
2026-11-01 05:25:23.689899+06	LOAD-C2	326	132.17	83.6	normal	simulator
2026-11-01 05:25:23.689899+06	GEN-W1	710.9	229.59	80.8	normal	simulator
2026-11-01 05:25:23.689899+06	SUB-W1	848	229.51	66.4	normal	simulator
2026-11-01 05:25:23.689899+06	LOAD-W1	470.3	131.58	87.1	warning	simulator
2026-11-01 05:25:23.689899+06	LOAD-W2	497.6	130.72	95.7	critical	simulator
2026-11-01 05:25:23.689899+06	GEN-S1	1168.6	229.59	78.4	normal	simulator
2026-11-01 05:25:23.689899+06	SUB-S1	816.1	229.96	69.1	normal	simulator
2026-11-01 05:25:23.689899+06	LOAD-S1	561.8	130.21	92.1	warning	simulator
2026-11-01 05:25:23.689899+06	LOAD-S2	397.1	131.29	84.5	normal	simulator
2026-11-01 05:25:23.747243+06	GEN-N1	264.8	229.16	81.7	normal	simulator
2026-11-01 05:25:23.747243+06	SUB-N1	1035.9	230.24	61.7	normal	simulator
2026-11-01 05:25:23.747243+06	LOAD-N1	487.9	131.67	78.7	normal	simulator
2026-11-01 05:25:23.747243+06	LOAD-N2	342.2	132.42	71.3	normal	simulator
2026-11-01 05:25:23.747243+06	GEN-E1	849.3	229.75	80.2	normal	simulator
2026-11-01 05:25:23.747243+06	SUB-E1	955.6	230.15	66.1	normal	simulator
2026-11-01 05:25:23.747243+06	LOAD-E1	459.4	132.36	80.6	normal	simulator
2026-11-01 05:25:23.747243+06	LOAD-E2	297.9	132.07	66.2	normal	simulator
2026-11-01 05:25:23.747243+06	GEN-C1	1059.9	230.45	81.6	normal	simulator
2026-11-01 05:25:23.747243+06	SUB-C1	1116.9	229.56	71.6	normal	simulator
2026-11-01 05:25:23.747243+06	LOAD-C1	667.3	131.54	87.8	warning	simulator
2026-11-01 05:25:23.747243+06	LOAD-C2	285.1	132.11	73.1	normal	simulator
2026-11-01 05:25:23.747243+06	GEN-W1	201.4	230.13	79.5	normal	simulator
2026-11-01 05:25:23.747243+06	SUB-W1	1021.7	230.65	68.1	normal	simulator
2026-11-01 05:25:23.747243+06	LOAD-W1	405.5	131.95	75.1	normal	simulator
2026-11-01 05:25:23.747243+06	LOAD-W2	426.4	131.91	82	normal	simulator
2026-11-01 05:25:23.747243+06	GEN-S1	1166.7	230.47	79.6	normal	simulator
2026-11-01 05:25:23.747243+06	SUB-S1	1018.2	229.39	70.5	normal	simulator
2026-11-01 05:25:23.747243+06	LOAD-S1	480.1	132.47	78.7	normal	simulator
2026-11-01 05:25:23.747243+06	LOAD-S2	334.2	131.91	71.1	normal	simulator
2026-11-01 05:25:23.800019+06	GEN-N1	998.9	230.22	81.2	normal	simulator
2026-11-01 05:25:23.800019+06	SUB-N1	834.4	230.3	62.8	normal	simulator
2026-11-01 05:25:23.800019+06	LOAD-N1	496	131.63	80	normal	simulator
2026-11-01 05:25:23.800019+06	LOAD-N2	338.9	131.62	70.6	normal	simulator
2026-11-01 05:25:23.800019+06	GEN-E1	881.6	229.98	80.5	normal	simulator
2026-11-01 05:25:23.800019+06	SUB-E1	769.1	230.34	64.4	normal	simulator
2026-11-01 05:25:23.800019+06	LOAD-E1	465.7	131.37	81.7	normal	simulator
2026-11-01 05:25:23.800019+06	LOAD-E2	307.8	131.63	68.4	normal	simulator
2026-11-01 05:25:23.800019+06	GEN-C1	1037.3	230.05	81.2	normal	simulator
2026-11-01 05:25:23.800019+06	SUB-C1	947.3	229.58	71.5	normal	simulator
2026-11-01 05:25:23.800019+06	LOAD-C1	681	130.46	89.6	warning	simulator
2026-11-01 05:25:23.800019+06	LOAD-C2	286.3	131.56	73.4	normal	simulator
2026-11-01 05:25:23.800019+06	GEN-W1	711.7	229.98	78.4	normal	simulator
2026-11-01 05:25:23.800019+06	SUB-W1	842.2	230.32	65.8	normal	simulator
2026-11-01 05:25:23.800019+06	LOAD-W1	413.1	132.68	76.5	normal	simulator
2026-11-01 05:25:23.800019+06	LOAD-W2	428	131.94	82.3	normal	simulator
2026-11-01 05:25:23.800019+06	GEN-S1	1186.3	230.59	80	normal	simulator
2026-11-01 05:25:23.800019+06	SUB-S1	821.5	230.08	68.3	normal	simulator
2026-11-01 05:25:23.800019+06	LOAD-S1	478.2	131.42	78.4	normal	simulator
2026-11-01 05:25:23.800019+06	LOAD-S2	344	132.01	73.2	normal	simulator
2026-11-01 05:25:35.887808+06	GEN-N1	959.3	229.48	79.2	normal	simulator
2026-11-01 05:25:35.887808+06	SUB-N1	844.7	229.52	63.4	normal	simulator
2026-11-01 05:25:35.887808+06	LOAD-N1	496	132.45	80	normal	simulator
2026-11-01 05:25:35.887808+06	LOAD-N2	335.5	132.14	69.9	normal	simulator
2026-11-01 05:25:35.887808+06	GEN-E1	856.7	230.14	79.9	normal	simulator
2026-11-01 05:25:35.887808+06	SUB-E1	774.1	229.36	63.5	normal	simulator
2026-11-01 05:25:35.887808+06	LOAD-E1	468.5	131.21	82.2	normal	simulator
2026-11-01 05:25:35.887808+06	LOAD-E2	308.2	132.47	68.5	normal	simulator
2026-11-01 05:25:35.887808+06	GEN-C1	1043.3	229.2	81.1	normal	simulator
2026-11-01 05:25:35.887808+06	SUB-C1	963.5	230.24	73.4	normal	simulator
2026-11-01 05:25:35.887808+06	LOAD-C1	665	130.85	87.5	warning	simulator
2026-11-01 05:25:35.887808+06	LOAD-C2	295.6	132.11	75.8	normal	simulator
2026-11-01 05:25:35.887808+06	GEN-W1	709.1	229.22	81.8	normal	simulator
2026-11-01 05:25:35.887808+06	SUB-W1	834.8	229.9	66.3	normal	simulator
2026-11-01 05:25:35.887808+06	LOAD-W1	418	132.31	77.4	normal	simulator
2026-11-01 05:25:35.887808+06	LOAD-W2	423.8	131.45	81.5	normal	simulator
2026-11-01 05:25:35.887808+06	GEN-S1	1200	229.75	79.6	normal	simulator
2026-11-01 05:25:35.887808+06	SUB-S1	823.5	229.6	71.4	normal	simulator
2026-11-01 05:25:35.887808+06	LOAD-S1	491.7	132.04	80.6	normal	simulator
2026-11-01 05:25:35.887808+06	LOAD-S2	342.2	132.66	72.8	normal	simulator
2026-11-01 05:25:23.71519+06	GEN-N1	985.1	230.27	79.7	normal	simulator
2026-11-01 05:25:23.71519+06	SUB-N1	948.5	229.74	62.1	normal	simulator
2026-11-01 05:25:23.71519+06	LOAD-N1	603.9	130.52	97.4	critical	simulator
2026-11-01 05:25:23.71519+06	LOAD-N2	432	131.42	90	warning	simulator
2026-11-01 05:25:23.71519+06	GEN-E1	868.5	229.27	80.8	normal	simulator
2026-11-01 05:25:23.71519+06	SUB-E1	889.2	229.68	64.9	normal	simulator
2026-11-01 05:25:23.71519+06	LOAD-E1	570	130.3	100	critical	simulator
2026-11-01 05:25:23.71519+06	LOAD-E2	385.6	131.59	85.7	warning	simulator
2026-11-01 05:25:23.71519+06	GEN-C1	1044.2	230.36	80.7	normal	simulator
2026-11-01 05:25:23.71519+06	SUB-C1	1078.4	230.28	72.1	normal	simulator
2026-11-01 05:25:23.71519+06	LOAD-C1	760	129.51	100	critical	simulator
2026-11-01 05:25:23.71519+06	LOAD-C2	356.9	131.07	91.5	warning	simulator
2026-11-01 05:25:23.71519+06	GEN-W1	716	229.91	80.8	normal	simulator
2026-11-01 05:25:23.71519+06	SUB-W1	967.9	229.35	65.6	normal	simulator
2026-11-01 05:25:23.71519+06	LOAD-W1	501.7	130.06	92.9	warning	simulator
2026-11-01 05:25:23.71519+06	LOAD-W2	520	129.19	100	critical	simulator
2026-11-01 05:25:23.71519+06	GEN-S1	1140.5	229.94	80.3	normal	simulator
2026-11-01 05:25:23.71519+06	SUB-S1	958.9	229.3	68.5	normal	simulator
2026-11-01 05:25:23.71519+06	LOAD-S1	599	130.66	98.2	critical	simulator
2026-11-01 05:25:23.71519+06	LOAD-S2	419.2	131.23	89.2	warning	simulator
2026-11-01 05:25:23.775082+06	GEN-N1	947.4	230.22	80.4	normal	simulator
2026-11-01 05:25:23.775082+06	SUB-N1	830.1	229.7	60.3	normal	simulator
2026-11-01 05:25:23.775082+06	LOAD-N1	494.1	132.17	79.7	normal	simulator
2026-11-01 05:25:23.775082+06	LOAD-N2	340.3	131.74	70.9	normal	simulator
2026-11-01 05:25:23.775082+06	GEN-E1	878	230.25	78.7	normal	simulator
2026-11-01 05:25:23.775082+06	SUB-E1	757.3	230.09	63.3	normal	simulator
2026-11-01 05:25:23.775082+06	LOAD-E1	468.5	131.21	82.2	normal	simulator
2026-11-01 05:25:23.775082+06	LOAD-E2	300.6	132.27	66.8	normal	simulator
2026-11-01 05:25:23.775082+06	GEN-C1	1079.1	230.57	80.1	normal	simulator
2026-11-01 05:25:23.775082+06	SUB-C1	0	229.37	73.5	critical	simulator
2026-11-01 05:25:23.775082+06	LOAD-C1	664.2	130.91	87.4	warning	simulator
2026-11-01 05:25:23.775082+06	LOAD-C2	283.1	132.55	72.6	normal	simulator
2026-11-01 05:25:23.775082+06	GEN-W1	685.8	230.39	81.3	normal	simulator
2026-11-01 05:25:23.775082+06	SUB-W1	831.9	230.18	65.9	normal	simulator
2026-11-01 05:25:23.775082+06	LOAD-W1	402.3	131.64	74.5	normal	simulator
2026-11-01 05:25:23.775082+06	LOAD-W2	439.9	131.54	84.6	normal	simulator
2026-11-01 05:25:23.775082+06	GEN-S1	1144.3	229.51	81.2	normal	simulator
2026-11-01 05:25:23.775082+06	SUB-S1	814.3	229.52	70	normal	simulator
2026-11-01 05:25:23.775082+06	LOAD-S1	478.9	131.64	78.5	normal	simulator
2026-11-01 05:25:23.775082+06	LOAD-S2	342.6	131.59	72.9	normal	simulator
2026-11-01 05:25:45.943874+06	GEN-N1	959.2	230.33	80.6	normal	simulator
2026-11-01 05:25:45.943874+06	SUB-N1	843.7	229.99	60.5	normal	simulator
2026-11-01 05:25:45.943874+06	LOAD-N1	495.4	131.71	79.9	normal	simulator
2026-11-01 05:25:45.943874+06	LOAD-N2	337.9	131.78	70.4	normal	simulator
2026-11-01 05:25:45.943874+06	GEN-E1	852.4	229.87	80.4	normal	simulator
2026-11-01 05:25:45.943874+06	SUB-E1	764.3	230.48	66.7	normal	simulator
2026-11-01 05:25:45.943874+06	LOAD-E1	457.7	132.64	80.3	normal	simulator
2026-11-01 05:25:45.943874+06	LOAD-E2	313.6	132.01	69.7	normal	simulator
2026-11-01 05:25:45.943874+06	GEN-C1	1076.7	229.67	79.4	normal	simulator
2026-11-01 05:25:45.943874+06	SUB-C1	948	229.55	70.7	normal	simulator
2026-11-01 05:25:45.943874+06	LOAD-C1	655.9	131.59	86.3	warning	simulator
2026-11-01 05:25:45.943874+06	LOAD-C2	293.7	132.67	75.3	normal	simulator
2026-11-01 05:25:45.943874+06	GEN-W1	680.2	229.95	80.1	normal	simulator
2026-11-01 05:25:45.943874+06	SUB-W1	842.4	230.11	67.4	normal	simulator
2026-11-01 05:25:45.943874+06	LOAD-W1	418.5	132.15	77.5	normal	simulator
2026-11-01 05:25:45.943874+06	LOAD-W2	424.3	132.34	81.6	normal	simulator
2026-11-01 05:25:45.943874+06	GEN-S1	1198.3	230.11	79.1	normal	simulator
2026-11-01 05:25:45.943874+06	SUB-S1	819	230.69	69.8	normal	simulator
2026-11-01 05:25:45.943874+06	LOAD-S1	477	131.57	78.2	normal	simulator
2026-11-01 05:25:45.943874+06	LOAD-S2	332.8	132.64	70.8	normal	simulator
2026-11-01 05:25:45.954374+06	GEN-N1	271.5	230.26	79.9	normal	simulator
2026-11-01 05:25:45.954374+06	SUB-N1	833.3	229.67	62.3	normal	simulator
2026-11-01 05:25:45.954374+06	LOAD-N1	498.5	131.92	80.4	normal	simulator
2026-11-01 05:25:45.954374+06	LOAD-N2	339.4	132.08	70.7	normal	simulator
2026-11-01 05:25:45.954374+06	GEN-E1	855.7	230.63	79.1	normal	simulator
2026-11-01 05:25:45.954374+06	SUB-E1	771.3	230.5	64.4	normal	simulator
2026-11-01 05:25:45.954374+06	LOAD-E1	475.9	132.12	83.5	normal	simulator
2026-11-01 05:25:45.954374+06	LOAD-E2	300.1	131.43	66.7	normal	simulator
2026-11-01 05:25:45.954374+06	GEN-C1	1067.5	229.57	80.6	normal	simulator
2026-11-01 05:25:45.954374+06	SUB-C1	949.6	229.57	70.7	normal	simulator
2026-11-01 05:25:45.954374+06	LOAD-C1	658.9	130.68	86.7	warning	simulator
2026-11-01 05:25:45.954374+06	LOAD-C2	290.9	132.18	74.6	normal	simulator
2026-11-01 05:25:45.954374+06	GEN-W1	202.5	229.83	80.8	normal	simulator
2026-11-01 05:25:45.954374+06	SUB-W1	842.8	229.45	66.9	normal	simulator
2026-11-01 05:25:45.954374+06	LOAD-W1	411.5	131.65	76.2	normal	simulator
2026-11-01 05:25:45.954374+06	LOAD-W2	436.3	131.97	83.9	normal	simulator
2026-11-01 05:25:45.954374+06	GEN-S1	1179.2	229.56	80.7	normal	simulator
2026-11-01 05:25:45.954374+06	SUB-S1	809.8	230.52	69.9	normal	simulator
2026-11-01 05:25:45.954374+06	LOAD-S1	486.2	131.36	79.7	normal	simulator
2026-11-01 05:25:45.954374+06	LOAD-S2	344.5	131.84	73.3	normal	simulator
2026-11-01 05:28:17.080546+06	GEN-N1	965.5	230.4	80.6	normal	simulator
2026-11-01 05:28:17.080546+06	SUB-N1	830.6	230.69	62.3	normal	simulator
2026-11-01 05:28:17.080546+06	LOAD-N1	553	131.67	89.2	warning	simulator
2026-11-01 05:28:17.080546+06	LOAD-N2	388.8	131.93	81	normal	simulator
2026-11-01 05:28:17.080546+06	GEN-E1	831.8	229.39	79.6	normal	simulator
2026-11-01 05:28:17.080546+06	SUB-E1	767.7	230.27	66	normal	simulator
2026-11-01 05:28:17.080546+06	LOAD-E1	538.1	130.95	94.4	warning	simulator
2026-11-01 05:28:17.080546+06	LOAD-E2	360.4	131.75	80.1	normal	simulator
2026-11-01 05:28:17.080546+06	GEN-C1	1059.1	230.66	78.7	normal	simulator
2026-11-01 05:28:17.080546+06	SUB-C1	940.9	230.36	73.5	normal	simulator
2026-11-01 05:28:17.080546+06	LOAD-C1	740.2	129.86	97.4	critical	simulator
2026-11-01 05:28:17.080546+06	LOAD-C2	328	131.34	84.1	normal	simulator
2026-11-01 05:28:17.080546+06	GEN-W1	684.3	229.87	81.6	normal	simulator
2026-11-01 05:28:17.080546+06	SUB-W1	841.2	230.48	67.5	normal	simulator
2026-11-01 05:28:17.080546+06	LOAD-W1	472.5	131.65	87.5	warning	simulator
2026-11-01 05:28:17.080546+06	LOAD-W2	491.4	129.93	94.5	warning	simulator
2026-11-01 05:28:17.080546+06	GEN-S1	1184.4	230.45	80.3	normal	simulator
2026-11-01 05:28:17.080546+06	SUB-S1	819.6	230.16	70.7	normal	simulator
2026-11-01 05:28:17.080546+06	LOAD-S1	555.7	130.47	91.1	warning	simulator
2026-11-01 05:28:17.080546+06	LOAD-S2	396.7	131.99	84.4	normal	simulator
2026-11-01 05:28:17.11578+06	GEN-N1	996.3	229.44	79.3	normal	simulator
2026-11-01 05:28:17.11578+06	SUB-N1	941.8	229.55	61.3	normal	simulator
2026-11-01 05:28:17.11578+06	LOAD-N1	594.6	129.97	95.9	critical	simulator
2026-11-01 05:28:17.11578+06	LOAD-N2	427.7	130.35	89.1	warning	simulator
2026-11-01 05:28:17.11578+06	GEN-E1	882.4	230.07	80.7	normal	simulator
2026-11-01 05:28:17.11578+06	SUB-E1	898.5	229.35	64	normal	simulator
2026-11-01 05:28:17.11578+06	LOAD-E1	570	130.01	100	critical	simulator
2026-11-01 05:28:17.11578+06	LOAD-E2	384.8	130.86	85.5	warning	simulator
2026-11-01 05:28:17.11578+06	GEN-C1	1024.9	230.47	80.7	normal	simulator
2026-11-01 05:28:17.11578+06	SUB-C1	1068.2	229.5	70.6	normal	simulator
2026-11-01 05:28:17.11578+06	LOAD-C1	760	129.56	100	critical	simulator
2026-11-01 05:28:17.11578+06	LOAD-C2	364.3	130.51	93.4	warning	simulator
2026-11-01 05:28:17.11578+06	GEN-W1	690.7	230.51	78.8	normal	simulator
2026-11-01 05:28:17.11578+06	SUB-W1	963.9	230.51	67.4	normal	simulator
2026-11-01 05:28:17.11578+06	LOAD-W1	515.7	129.72	95.5	critical	simulator
2026-11-01 05:28:17.11578+06	LOAD-W2	519	129.47	99.8	critical	simulator
2026-11-01 05:28:17.11578+06	GEN-S1	1176.9	229.31	80.6	normal	simulator
2026-11-01 05:28:17.11578+06	SUB-S1	952.4	230.02	68.5	normal	simulator
2026-11-01 05:28:17.11578+06	LOAD-S1	605.7	129.48	99.3	critical	simulator
2026-11-01 05:28:17.11578+06	LOAD-S2	420.2	130.6	89.4	warning	simulator
2026-11-01 05:28:17.142957+06	GEN-N1	274.9	229.45	81.5	normal	simulator
2026-11-01 05:28:17.142957+06	SUB-N1	1022.3	230.68	62.9	normal	simulator
2026-11-01 05:28:17.142957+06	LOAD-N1	496.6	132.65	80.1	normal	simulator
2026-11-01 05:28:17.142957+06	LOAD-N2	338.4	131.37	70.5	normal	simulator
2026-11-01 05:28:17.142957+06	GEN-E1	863.7	230.17	81.1	normal	simulator
2026-11-01 05:28:17.142957+06	SUB-E1	954.8	229.57	64.1	normal	simulator
2026-11-01 05:28:17.142957+06	LOAD-E1	463.4	132.29	81.3	normal	simulator
2026-11-01 05:28:17.142957+06	LOAD-E2	304.6	131.42	67.7	normal	simulator
2026-11-01 05:27:45.208246+06	GEN-N1	1002	230.27	79	normal	simulator
2026-11-01 05:27:45.208246+06	SUB-N1	839.1	230.63	62.8	normal	simulator
2026-11-01 05:27:45.208246+06	LOAD-N1	499.1	131.3	80.5	normal	simulator
2026-11-01 05:27:45.208246+06	LOAD-N2	344.6	132.43	71.8	normal	simulator
2026-11-01 05:27:45.208246+06	GEN-E1	843.3	229.55	79.7	normal	simulator
2026-11-01 05:27:45.208246+06	SUB-E1	782.4	229.56	65.5	normal	simulator
2026-11-01 05:27:45.208246+06	LOAD-E1	462.8	131.9	81.2	normal	simulator
2026-11-01 05:27:45.208246+06	LOAD-E2	301.5	131.46	67	normal	simulator
2026-11-01 05:27:45.208246+06	GEN-C1	1046.3	229.36	80.9	normal	simulator
2026-11-01 05:27:45.208246+06	SUB-C1	956.2	230.62	70.3	normal	simulator
2026-11-01 05:27:45.208246+06	LOAD-C1	655.1	130.8	86.2	warning	simulator
2026-11-01 05:27:45.208246+06	LOAD-C2	292.9	131.76	75.1	normal	simulator
2026-11-01 05:27:45.208246+06	GEN-W1	697	230.12	79	normal	simulator
2026-11-01 05:27:45.208246+06	SUB-W1	828.7	229.89	68.1	normal	simulator
2026-11-01 05:27:45.208246+06	LOAD-W1	407.7	132.17	75.5	normal	simulator
2026-11-01 05:27:45.208246+06	LOAD-W2	434.7	131.97	83.6	normal	simulator
2026-11-01 05:27:45.208246+06	GEN-S1	1135.4	230.1	79.3	normal	simulator
2026-11-01 05:27:45.208246+06	SUB-S1	830.9	230.44	69.9	normal	simulator
2026-11-01 05:27:45.208246+06	LOAD-S1	482.5	132.55	79.1	normal	simulator
2026-11-01 05:27:45.208246+06	LOAD-S2	336.5	131.53	71.6	normal	simulator
2026-11-01 05:28:17.142957+06	GEN-C1	1031.3	229.94	80.9	normal	simulator
2026-11-01 05:28:17.142957+06	SUB-C1	1124.3	229.98	72.2	normal	simulator
2026-11-01 05:28:17.142957+06	LOAD-C1	673.4	131.26	88.6	warning	simulator
2026-11-01 05:28:17.142957+06	LOAD-C2	289.4	131.89	74.2	normal	simulator
2026-11-01 05:28:17.142957+06	GEN-W1	190.6	229.71	78.9	normal	simulator
2026-11-01 05:28:17.142957+06	SUB-W1	1034.7	230.52	68.3	normal	simulator
2026-11-01 05:28:17.142957+06	LOAD-W1	413.6	131.43	76.6	normal	simulator
2026-11-01 05:28:17.142957+06	LOAD-W2	432.6	131.72	83.2	normal	simulator
2026-11-01 05:28:17.142957+06	GEN-S1	1198.7	230.43	79.4	normal	simulator
2026-11-01 05:28:17.142957+06	SUB-S1	1025.9	229.7	69.4	normal	simulator
2026-11-01 05:28:17.142957+06	LOAD-S1	481.3	132.49	78.9	normal	simulator
2026-11-01 05:28:17.142957+06	LOAD-S2	333.7	132.67	71	normal	simulator
2026-11-01 05:28:17.165079+06	GEN-N1	975.9	229.92	79.7	normal	simulator
2026-11-01 05:28:17.165079+06	SUB-N1	835	230.68	60.3	normal	simulator
2026-11-01 05:28:17.165079+06	LOAD-N1	499.1	131.28	80.5	normal	simulator
2026-11-01 05:28:17.165079+06	LOAD-N2	335.5	131.96	69.9	normal	simulator
2026-11-01 05:28:17.165079+06	GEN-E1	837.7	229.53	78.9	normal	simulator
2026-11-01 05:28:17.165079+06	SUB-E1	768	230.65	66.5	normal	simulator
2026-11-01 05:28:17.165079+06	LOAD-E1	460	132.08	80.7	normal	simulator
2026-11-01 05:28:17.165079+06	LOAD-E2	300.1	132.11	66.7	normal	simulator
2026-11-01 05:28:17.165079+06	GEN-C1	1073.6	229.98	81.6	normal	simulator
2026-11-01 05:28:17.165079+06	SUB-C1	0	229.39	70.4	critical	simulator
2026-11-01 05:28:17.165079+06	LOAD-C1	660.4	130.83	86.9	warning	simulator
2026-11-01 05:28:17.165079+06	LOAD-C2	291.7	131.55	74.8	normal	simulator
2026-11-01 05:28:17.165079+06	GEN-W1	686.9	230.01	78.8	normal	simulator
2026-11-01 05:28:17.165079+06	SUB-W1	846.2	229.58	68.3	normal	simulator
2026-11-01 05:28:17.165079+06	LOAD-W1	403.4	132.69	74.7	normal	simulator
2026-11-01 05:28:17.165079+06	LOAD-W2	437.3	131.55	84.1	normal	simulator
2026-11-01 05:28:17.165079+06	GEN-S1	1179	229.76	80.4	normal	simulator
2026-11-01 05:28:17.165079+06	SUB-S1	815	230.4	68.4	normal	simulator
2026-11-01 05:28:17.165079+06	LOAD-S1	481.3	132.48	78.9	normal	simulator
2026-11-01 05:28:17.165079+06	LOAD-S2	332.3	132.49	70.7	normal	simulator
2026-11-01 05:28:17.182813+06	GEN-N1	993.6	229.46	80.8	normal	simulator
2026-11-01 05:28:17.182813+06	SUB-N1	834.6	229.49	63.6	normal	simulator
2026-11-01 05:28:17.182813+06	LOAD-N1	486.1	131.53	78.4	normal	simulator
2026-11-01 05:28:17.182813+06	LOAD-N2	332.6	131.31	69.3	normal	simulator
2026-11-01 05:28:17.182813+06	GEN-E1	885	230.6	78.3	normal	simulator
2026-11-01 05:28:17.182813+06	SUB-E1	760.1	230.07	66.4	normal	simulator
2026-11-01 05:28:17.182813+06	LOAD-E1	460.6	132.55	80.8	normal	simulator
2026-11-01 05:28:17.182813+06	LOAD-E2	301.1	131.65	66.9	normal	simulator
2026-11-01 05:28:17.182813+06	GEN-C1	1064.4	230.42	81.6	normal	simulator
2026-11-01 05:28:17.182813+06	SUB-C1	952.1	229.4	73	normal	simulator
2026-11-01 05:28:17.182813+06	LOAD-C1	665	131.51	87.5	warning	simulator
2026-11-01 05:28:17.182813+06	LOAD-C2	290.6	132.02	74.5	normal	simulator
2026-11-01 05:28:17.182813+06	GEN-W1	700.7	229.46	80	normal	simulator
2026-11-01 05:28:17.182813+06	SUB-W1	840.7	230.4	68.6	normal	simulator
2026-11-01 05:28:17.182813+06	LOAD-W1	405.5	131.33	75.1	normal	simulator
2026-11-01 05:28:17.182813+06	LOAD-W2	423.3	132.38	81.4	normal	simulator
2026-11-01 05:28:17.182813+06	GEN-S1	1144.3	230.42	81.3	normal	simulator
2026-11-01 05:28:17.182813+06	SUB-S1	813.6	229.5	71.7	normal	simulator
2026-11-01 05:28:17.182813+06	LOAD-S1	479.5	131.65	78.6	normal	simulator
2026-11-01 05:28:17.182813+06	LOAD-S2	344.5	132.24	73.3	normal	simulator
2026-11-01 05:28:29.561521+06	GEN-N1	959.2	230.33	80.6	normal	simulator
2026-11-01 05:28:29.561521+06	SUB-N1	843.7	229.99	60.5	normal	simulator
2026-11-01 05:28:29.561521+06	LOAD-N1	495.4	131.71	79.9	normal	simulator
2026-11-01 05:28:29.561521+06	LOAD-N2	337.9	131.78	70.4	normal	simulator
2026-11-01 05:28:29.561521+06	GEN-E1	852.4	229.87	80.4	normal	simulator
2026-11-01 05:28:29.561521+06	SUB-E1	764.3	230.48	66.7	normal	simulator
2026-11-01 05:28:29.561521+06	LOAD-E1	457.7	132.64	80.3	normal	simulator
2026-11-01 05:28:29.561521+06	LOAD-E2	313.6	132.01	69.7	normal	simulator
2026-11-01 05:28:29.561521+06	GEN-C1	1076.7	229.67	79.4	normal	simulator
2026-11-01 05:28:29.561521+06	SUB-C1	948	229.55	70.7	normal	simulator
2026-11-01 05:28:29.561521+06	LOAD-C1	655.9	131.59	86.3	warning	simulator
2026-11-01 05:28:29.561521+06	LOAD-C2	293.7	132.67	75.3	normal	simulator
2026-11-01 05:28:29.561521+06	GEN-W1	680.2	229.95	80.1	normal	simulator
2026-11-01 05:28:29.561521+06	SUB-W1	842.4	230.11	67.4	normal	simulator
2026-11-01 05:28:29.561521+06	LOAD-W1	418.5	132.15	77.5	normal	simulator
2026-11-01 05:28:29.561521+06	LOAD-W2	424.3	132.34	81.6	normal	simulator
2026-11-01 05:28:29.561521+06	GEN-S1	1198.3	230.11	79.1	normal	simulator
2026-11-01 05:28:29.561521+06	SUB-S1	819	230.69	69.8	normal	simulator
2026-11-01 05:28:29.561521+06	LOAD-S1	477	131.57	78.2	normal	simulator
2026-11-01 05:28:29.561521+06	LOAD-S2	332.8	132.64	70.8	normal	simulator
2026-11-01 05:28:29.569173+06	GEN-N1	271.5	230.26	79.9	normal	simulator
2026-11-01 05:28:29.569173+06	SUB-N1	833.3	229.67	62.3	normal	simulator
2026-11-01 05:28:29.569173+06	LOAD-N1	498.5	131.92	80.4	normal	simulator
2026-11-01 05:28:29.569173+06	LOAD-N2	339.4	132.08	70.7	normal	simulator
2026-11-01 05:28:29.569173+06	GEN-E1	855.7	230.63	79.1	normal	simulator
2026-11-01 05:28:29.569173+06	SUB-E1	771.3	230.5	64.4	normal	simulator
2026-11-01 05:28:29.569173+06	LOAD-E1	475.9	132.12	83.5	normal	simulator
2026-11-01 05:28:29.569173+06	LOAD-E2	300.1	131.43	66.7	normal	simulator
2026-11-01 05:28:29.569173+06	GEN-C1	1067.5	229.57	80.6	normal	simulator
2026-11-01 05:28:29.569173+06	SUB-C1	949.6	229.57	70.7	normal	simulator
2026-11-01 05:28:29.569173+06	LOAD-C1	658.9	130.68	86.7	warning	simulator
2026-11-01 05:28:29.569173+06	LOAD-C2	290.9	132.18	74.6	normal	simulator
2026-11-01 05:28:29.569173+06	GEN-W1	202.5	229.83	80.8	normal	simulator
2026-11-01 05:28:29.569173+06	SUB-W1	842.8	229.45	66.9	normal	simulator
2026-11-01 05:28:29.569173+06	LOAD-W1	411.5	131.65	76.2	normal	simulator
2026-11-01 05:28:29.569173+06	LOAD-W2	436.3	131.97	83.9	normal	simulator
2026-11-01 05:28:29.569173+06	GEN-S1	1179.2	229.56	80.7	normal	simulator
2026-11-01 05:28:29.569173+06	SUB-S1	809.8	230.52	69.9	normal	simulator
2026-11-01 05:28:29.569173+06	LOAD-S1	486.2	131.36	79.7	normal	simulator
2026-11-01 05:28:29.569173+06	LOAD-S2	344.5	131.84	73.3	normal	simulator
2026-11-01 13:15:07.245128+06	GEN-N1	954.9	229.67	79.6	normal	simulator
2026-11-01 13:15:07.245128+06	SUB-N1	827.2	230.33	63.2	normal	simulator
2026-11-01 13:15:07.245128+06	LOAD-N1	494.8	131.75	79.8	normal	simulator
2026-11-01 13:15:07.245128+06	LOAD-N2	339.8	132.27	70.8	normal	simulator
2026-11-01 13:15:07.245128+06	GEN-E1	857	230.21	78.9	normal	simulator
2026-11-01 13:15:07.245128+06	SUB-E1	787.2	230.46	64	normal	simulator
2026-11-01 13:15:07.245128+06	LOAD-E1	461.1	131.23	80.9	normal	simulator
2026-11-01 13:15:07.245128+06	LOAD-E2	307.8	132.06	68.4	normal	simulator
2026-11-01 13:15:07.245128+06	GEN-C1	1055	229.55	81.6	normal	simulator
2026-11-01 13:15:07.245128+06	SUB-C1	945.5	230.58	72.2	normal	simulator
2026-11-01 13:15:07.245128+06	LOAD-C1	656.6	131.93	86.4	warning	simulator
2026-11-01 13:15:07.245128+06	LOAD-C2	289.4	132.24	74.2	normal	simulator
2026-11-01 13:15:07.245128+06	GEN-W1	710.8	229.9	79.9	normal	simulator
2026-11-01 13:15:07.245128+06	SUB-W1	826.7	229.6	65.7	normal	simulator
2026-11-01 13:15:07.245128+06	LOAD-W1	405.5	132.44	75.1	normal	simulator
2026-11-01 13:15:07.245128+06	LOAD-W2	423.8	131.84	81.5	normal	simulator
2026-11-01 13:15:07.245128+06	GEN-S1	1151.8	229.87	79.5	normal	simulator
2026-11-01 13:15:07.245128+06	SUB-S1	829.8	230	71	normal	simulator
2026-11-01 13:15:07.245128+06	LOAD-S1	492.3	132.18	80.7	normal	simulator
2026-11-01 13:15:07.245128+06	LOAD-S2	335.6	132.23	71.4	normal	simulator
2026-11-01 13:17:07.832725+06	GEN-N1	961.5	229.86	79.5	normal	simulator
2026-11-01 13:17:07.832725+06	SUB-N1	830.4	229.72	62.6	normal	simulator
2026-11-01 13:17:07.832725+06	LOAD-N1	501	132.35	80.8	normal	simulator
2026-11-01 13:17:07.832725+06	LOAD-N2	335.5	131.58	69.9	normal	simulator
2026-11-01 13:17:07.832725+06	GEN-E1	870	229.55	78.8	normal	simulator
2026-11-01 13:17:07.832725+06	SUB-E1	767.8	230.52	64.3	normal	simulator
2026-11-01 13:17:07.832725+06	LOAD-E1	463.4	131.29	81.3	normal	simulator
2026-11-01 13:17:07.832725+06	LOAD-E2	308.2	132.23	68.5	normal	simulator
2026-11-01 13:17:07.832725+06	GEN-C1	1049.9	230.66	80.2	normal	simulator
2026-11-01 13:17:07.832725+06	SUB-C1	963	229.93	70.9	normal	simulator
2026-11-01 13:17:07.832725+06	LOAD-C1	655.1	130.63	86.2	warning	simulator
2026-11-01 13:17:07.832725+06	LOAD-C2	293.7	132.53	75.3	normal	simulator
2026-11-01 13:17:07.832725+06	GEN-W1	680	229.68	81.2	normal	simulator
2026-11-01 13:17:07.832725+06	SUB-W1	839.7	230.44	67.3	normal	simulator
2026-11-01 13:17:07.832725+06	LOAD-W1	411.5	131.35	76.2	normal	simulator
2026-11-01 13:17:07.832725+06	LOAD-W2	433.7	131.99	83.4	normal	simulator
2026-11-01 13:17:07.832725+06	GEN-S1	1161.8	230.02	80.2	normal	simulator
2026-11-01 13:17:07.832725+06	SUB-S1	817.4	230.36	69.9	normal	simulator
2026-11-01 13:17:07.832725+06	LOAD-S1	481.3	132.51	78.9	normal	simulator
2026-11-01 13:17:07.832725+06	LOAD-S2	332.3	131.82	70.7	normal	simulator
2026-11-01 13:27:10.849641+06	GEN-N1	960	230.16	79.2	normal	simulator
2026-11-01 13:27:10.849641+06	SUB-N1	826.9	229.52	62.7	normal	simulator
2026-11-01 13:27:10.849641+06	LOAD-N1	487.9	132.37	78.7	normal	simulator
2026-11-01 13:27:10.849641+06	LOAD-N2	346.6	132.08	72.2	normal	simulator
2026-11-01 13:27:10.849641+06	GEN-E1	857.9	229.47	78.4	normal	simulator
2026-11-01 13:27:10.849641+06	SUB-E1	779.3	230.44	65.5	normal	simulator
2026-11-01 13:27:10.849641+06	LOAD-E1	474.8	131.67	83.3	normal	simulator
2026-11-01 13:27:10.849641+06	LOAD-E2	311.9	131.87	69.3	normal	simulator
2026-11-01 13:27:10.849641+06	GEN-C1	1057.4	229.47	79.8	normal	simulator
2026-11-01 13:27:10.849641+06	SUB-C1	969.7	230.4	71.4	normal	simulator
2026-11-01 13:27:10.849641+06	LOAD-C1	656.6	131.43	86.4	warning	simulator
2026-11-01 13:27:10.849641+06	LOAD-C2	290.2	131.65	74.4	normal	simulator
2026-11-01 13:27:10.849641+06	GEN-W1	685.5	229.86	79.4	normal	simulator
2026-11-01 13:27:10.849641+06	SUB-W1	846.9	230.38	67.7	normal	simulator
2026-11-01 13:27:10.849641+06	LOAD-W1	402.3	132.03	74.5	normal	simulator
2026-11-01 13:27:10.849641+06	LOAD-W2	422.8	131.32	81.3	normal	simulator
2026-11-01 13:27:10.849641+06	GEN-S1	1146.8	229.46	80.9	normal	simulator
2026-11-01 13:27:10.849641+06	SUB-S1	810.3	230.44	70.4	normal	simulator
2026-11-01 13:27:10.849641+06	LOAD-S1	498.4	131.37	81.7	normal	simulator
2026-11-01 13:27:10.849641+06	LOAD-S2	346.4	131.98	73.7	normal	simulator
2026-11-01 13:32:12.910454+06	GEN-N1	984.9	229.75	80.2	normal	simulator
2026-11-01 13:32:12.910454+06	SUB-N1	832.7	229.71	63.5	normal	simulator
2026-11-01 13:32:12.910454+06	LOAD-N1	481.7	132.3	77.7	normal	simulator
2026-11-01 13:32:12.910454+06	LOAD-N2	346.1	131.84	72.1	normal	simulator
2026-11-01 05:28:45.465558+06	GEN-N1	966.1	229.63	79	normal	simulator
2026-11-01 05:28:45.465558+06	SUB-N1	822.3	230.41	61.2	normal	simulator
2026-11-01 05:28:45.465558+06	LOAD-N1	501	132.19	80.8	normal	simulator
2026-11-01 05:28:45.465558+06	LOAD-N2	336.5	131.87	70.1	normal	simulator
2026-11-01 05:28:45.465558+06	GEN-E1	841.4	229.26	80.4	normal	simulator
2026-11-01 05:28:45.465558+06	SUB-E1	771.1	230.04	64.4	normal	simulator
2026-11-01 05:28:45.465558+06	LOAD-E1	464	131.8	81.4	normal	simulator
2026-11-01 05:28:45.465558+06	LOAD-E2	300.6	132.24	66.8	normal	simulator
2026-11-01 05:28:45.465558+06	GEN-C1	1019.9	229.38	81.4	normal	simulator
2026-11-01 05:28:45.465558+06	SUB-C1	960.4	229.32	70.3	normal	simulator
2026-11-01 05:28:45.465558+06	LOAD-C1	677.2	131.25	89.1	warning	simulator
2026-11-01 05:28:45.465558+06	LOAD-C2	293.3	131.95	75.2	normal	simulator
2026-11-01 05:28:45.465558+06	GEN-W1	718.5	229.92	79.4	normal	simulator
2026-11-01 05:28:45.465558+06	SUB-W1	831.5	229.8	66	normal	simulator
2026-11-01 05:28:45.465558+06	LOAD-W1	401.8	132.02	74.4	normal	simulator
2026-11-01 05:28:45.465558+06	LOAD-W2	422.2	132.23	81.2	normal	simulator
2026-11-01 05:28:45.465558+06	GEN-S1	1179.6	229.72	79.6	normal	simulator
2026-11-01 05:28:45.465558+06	SUB-S1	832.5	229.77	71	normal	simulator
2026-11-01 05:28:45.465558+06	LOAD-S1	495.3	131.83	81.2	normal	simulator
2026-11-01 05:28:45.465558+06	LOAD-S2	333.7	132.57	71	normal	simulator
2026-11-01 05:29:45.744787+06	GEN-N1	944.8	229.42	78.7	normal	simulator
2026-11-01 05:29:45.744787+06	SUB-N1	829.8	229.98	61.8	normal	simulator
2026-11-01 05:29:45.744787+06	LOAD-N1	492.9	132.13	79.5	normal	simulator
2026-11-01 05:29:45.744787+06	LOAD-N2	341.3	131.68	71.1	normal	simulator
2026-11-01 05:29:45.744787+06	GEN-E1	858	230.17	80.3	normal	simulator
2026-11-01 05:29:45.744787+06	SUB-E1	760.8	229.75	66.5	normal	simulator
2026-11-01 05:29:45.744787+06	LOAD-E1	470.8	131.91	82.6	normal	simulator
2026-11-01 05:29:45.744787+06	LOAD-E2	307.8	131.43	68.4	normal	simulator
2026-11-01 05:29:45.744787+06	GEN-C1	1030.5	229.9	79.3	normal	simulator
2026-11-01 05:29:45.744787+06	SUB-C1	956.7	229.62	73.5	normal	simulator
2026-11-01 05:29:45.744787+06	LOAD-C1	668	130.77	87.9	warning	simulator
2026-11-01 05:29:45.744787+06	LOAD-C2	283.1	131.94	72.6	normal	simulator
2026-11-01 05:29:45.744787+06	GEN-W1	713.1	230.31	81.7	normal	simulator
2026-11-01 05:29:45.744787+06	SUB-W1	842	230.48	66.2	normal	simulator
2026-11-01 05:29:45.744787+06	LOAD-W1	417.4	132.65	77.3	normal	simulator
2026-11-01 05:29:45.744787+06	LOAD-W2	428.5	131.07	82.4	normal	simulator
2026-11-01 05:29:45.744787+06	GEN-S1	1182.8	230.33	81.4	normal	simulator
2026-11-01 05:29:45.744787+06	SUB-S1	831.5	230.62	68.5	normal	simulator
2026-11-01 05:29:45.744787+06	LOAD-S1	483.1	132.45	79.2	normal	simulator
2026-11-01 05:29:45.744787+06	LOAD-S2	336.1	131.54	71.5	normal	simulator
2026-11-01 05:30:46.053961+06	GEN-N1	946.6	230.61	80.3	normal	simulator
2026-11-01 05:30:46.053961+06	SUB-N1	823.5	230.37	60.6	normal	simulator
2026-11-01 05:30:46.053961+06	LOAD-N1	495.4	132.25	79.9	normal	simulator
2026-11-01 05:30:46.053961+06	LOAD-N2	345.6	131.77	72	normal	simulator
2026-11-01 05:30:46.053961+06	GEN-E1	836.8	229.52	81	normal	simulator
2026-11-01 05:30:46.053961+06	SUB-E1	772.5	230.3	64.2	normal	simulator
2026-11-01 05:30:46.053961+06	LOAD-E1	458.3	131.65	80.4	normal	simulator
2026-11-01 05:30:46.053961+06	LOAD-E2	299.2	131.73	66.5	normal	simulator
2026-11-01 05:30:46.053961+06	GEN-C1	1024	230.09	81	normal	simulator
2026-11-01 05:30:46.053961+06	SUB-C1	951.6	230.11	71.9	normal	simulator
2026-11-01 05:30:46.053961+06	LOAD-C1	673.4	131.69	88.6	warning	simulator
2026-11-01 05:30:46.053961+06	LOAD-C2	286.6	132.61	73.5	normal	simulator
2026-11-01 05:30:46.053961+06	GEN-W1	706.6	229.94	79.8	normal	simulator
2026-11-01 05:30:46.053961+06	SUB-W1	846.3	229.92	65.3	normal	simulator
2026-11-01 05:30:46.053961+06	LOAD-W1	402.8	132.47	74.6	normal	simulator
2026-11-01 05:30:46.053961+06	LOAD-W2	432.1	131.92	83.1	normal	simulator
2026-11-01 05:30:46.053961+06	GEN-S1	1143.7	229.53	78.3	normal	simulator
2026-11-01 05:30:46.053961+06	SUB-S1	828.5	230.54	69.3	normal	simulator
2026-11-01 05:30:46.053961+06	LOAD-S1	487.4	132.54	79.9	normal	simulator
2026-11-01 05:30:46.053961+06	LOAD-S2	343.6	132.34	73.1	normal	simulator
2026-11-01 05:31:46.365115+06	GEN-N1	998.9	230.22	81.2	normal	simulator
2026-11-01 05:31:46.365115+06	SUB-N1	834.4	230.3	62.8	normal	simulator
2026-11-01 05:31:46.365115+06	LOAD-N1	496	131.63	80	normal	simulator
2026-11-01 05:31:46.365115+06	LOAD-N2	338.9	131.62	70.6	normal	simulator
2026-11-01 05:31:46.365115+06	GEN-E1	881.6	229.98	80.5	normal	simulator
2026-11-01 05:31:46.365115+06	SUB-E1	769.1	230.34	64.4	normal	simulator
2026-11-01 05:31:46.365115+06	LOAD-E1	465.7	131.37	81.7	normal	simulator
2026-11-01 05:31:46.365115+06	LOAD-E2	307.8	131.63	68.4	normal	simulator
2026-11-01 05:31:46.365115+06	GEN-C1	1037.3	230.05	81.2	normal	simulator
2026-11-01 05:31:46.365115+06	SUB-C1	947.3	229.58	71.5	normal	simulator
2026-11-01 05:31:46.365115+06	LOAD-C1	681	130.46	89.6	warning	simulator
2026-11-01 05:31:46.365115+06	LOAD-C2	286.3	131.56	73.4	normal	simulator
2026-11-01 05:31:46.365115+06	GEN-W1	711.7	229.98	78.4	normal	simulator
2026-11-01 05:31:46.365115+06	SUB-W1	842.2	230.32	65.8	normal	simulator
2026-11-01 05:31:46.365115+06	LOAD-W1	413.1	132.68	76.5	normal	simulator
2026-11-01 05:31:46.365115+06	LOAD-W2	428	131.94	82.3	normal	simulator
2026-11-01 05:31:46.365115+06	GEN-S1	1186.3	230.59	80	normal	simulator
2026-11-01 05:31:46.365115+06	SUB-S1	821.5	230.08	68.3	normal	simulator
2026-11-01 05:31:46.365115+06	LOAD-S1	478.2	131.42	78.4	normal	simulator
2026-11-01 05:31:46.365115+06	LOAD-S2	344	132.01	73.2	normal	simulator
2026-11-01 05:32:16.795268+06	GEN-N1	986.4	230.63	80.4	normal	simulator
2026-11-01 05:32:16.795268+06	SUB-N1	820.5	230.64	60.4	normal	simulator
2026-11-01 05:32:16.795268+06	LOAD-N1	495.4	131.31	79.9	normal	simulator
2026-11-01 05:32:16.795268+06	LOAD-N2	337.4	132.44	70.3	normal	simulator
2026-11-01 05:32:16.795268+06	GEN-E1	840.8	230.24	80.8	normal	simulator
2026-11-01 05:32:16.795268+06	SUB-E1	774.5	230.56	66.7	normal	simulator
2026-11-01 05:32:16.795268+06	LOAD-E1	465.7	131.28	81.7	normal	simulator
2026-11-01 05:32:16.795268+06	LOAD-E2	306.4	131.4	68.1	normal	simulator
2026-11-01 05:32:16.795268+06	GEN-C1	1044.2	230.66	80.2	normal	simulator
2026-11-01 05:32:16.795268+06	SUB-C1	0	230.54	73.1	critical	simulator
2026-11-01 05:32:16.795268+06	LOAD-C1	670.3	130.52	88.2	warning	simulator
2026-11-01 05:32:16.795268+06	LOAD-C2	294.4	131.45	75.5	normal	simulator
2026-11-01 05:32:16.795268+06	GEN-W1	715.2	230.03	78.2	normal	simulator
2026-11-01 05:32:16.795268+06	SUB-W1	839	230.38	67.2	normal	simulator
2026-11-01 05:32:16.795268+06	LOAD-W1	412	132.61	76.3	normal	simulator
2026-11-01 05:32:16.795268+06	LOAD-W2	422.8	131.95	81.3	normal	simulator
2026-11-01 05:32:16.795268+06	GEN-S1	1169.9	229.84	79.8	normal	simulator
2026-11-01 05:32:16.795268+06	SUB-S1	825.3	230.65	70.5	normal	simulator
2026-11-01 05:32:16.795268+06	LOAD-S1	495.9	131.67	81.3	normal	simulator
2026-11-01 05:32:16.795268+06	LOAD-S2	340.8	132.29	72.5	normal	simulator
2026-11-01 05:32:22.057003+06	GEN-N1	960	230.16	79.2	normal	simulator
2026-11-01 05:32:22.057003+06	SUB-N1	826.9	229.52	62.7	normal	simulator
2026-11-01 05:32:22.057003+06	LOAD-N1	556.1	131.3	89.7	warning	simulator
2026-11-01 05:32:22.057003+06	LOAD-N2	399.4	131.73	83.2	normal	simulator
2026-11-01 05:32:22.057003+06	GEN-E1	857.9	229.47	78.4	normal	simulator
2026-11-01 05:32:22.057003+06	SUB-E1	779.3	230.44	65.5	normal	simulator
2026-11-01 05:32:22.057003+06	LOAD-E1	537.5	130.46	94.3	warning	simulator
2026-11-01 05:32:22.057003+06	LOAD-E2	361.4	131.84	80.3	normal	simulator
2026-11-01 05:32:22.057003+06	GEN-C1	1057.4	229.47	79.8	normal	simulator
2026-11-01 05:32:22.057003+06	SUB-C1	969.7	230.4	71.4	normal	simulator
2026-11-01 05:32:22.057003+06	LOAD-C1	740.2	130.22	97.4	critical	simulator
2026-11-01 05:32:22.057003+06	LOAD-C2	333.1	131.06	85.4	warning	simulator
2026-11-01 05:32:22.057003+06	GEN-W1	685.5	229.86	79.4	normal	simulator
2026-11-01 05:32:22.057003+06	SUB-W1	846.9	230.38	67.7	normal	simulator
2026-11-01 05:32:22.057003+06	LOAD-W1	461.7	131.43	85.5	warning	simulator
2026-11-01 05:32:22.057003+06	LOAD-W2	480	130.11	92.3	warning	simulator
2026-11-01 05:32:22.057003+06	GEN-S1	1146.8	229.46	80.9	normal	simulator
2026-11-01 05:32:22.057003+06	SUB-S1	810.3	230.44	70.4	normal	simulator
2026-11-01 05:32:22.057003+06	LOAD-S1	565.5	130.16	92.7	warning	simulator
2026-11-01 05:32:22.057003+06	LOAD-S2	398.1	131.46	84.7	normal	simulator
2026-11-01 05:32:26.562454+06	GEN-N1	985.2	229.5	81.3	normal	simulator
2026-11-01 05:32:26.562454+06	SUB-N1	960.8	230.02	62.8	normal	simulator
2026-11-01 05:32:26.562454+06	LOAD-N1	603.9	130.26	97.4	critical	simulator
2026-11-01 05:32:26.562454+06	LOAD-N2	422.4	131.24	88	warning	simulator
2026-11-01 05:32:26.562454+06	GEN-E1	848.8	229.42	81.5	normal	simulator
2026-11-01 05:32:26.562454+06	SUB-E1	898.1	229.38	63.8	normal	simulator
2026-11-01 05:32:26.562454+06	LOAD-E1	566.6	129.87	99.4	critical	simulator
2026-11-01 05:32:26.562454+06	LOAD-E2	380.2	132.2	84.5	normal	simulator
2026-11-01 05:32:26.562454+06	GEN-C1	1055.6	230.06	80.6	normal	simulator
2026-11-01 05:32:26.562454+06	SUB-C1	1075.2	230.24	71.8	normal	simulator
2026-11-01 05:32:26.562454+06	LOAD-C1	760	129.2	100	critical	simulator
2026-11-01 05:32:26.562454+06	LOAD-C2	363.9	130.36	93.3	warning	simulator
2026-11-01 05:32:26.562454+06	GEN-W1	721.8	229.96	81	normal	simulator
2026-11-01 05:32:26.562454+06	SUB-W1	964.8	230.42	66.2	normal	simulator
2026-11-01 05:32:26.562454+06	LOAD-W1	508.7	129.76	94.2	warning	simulator
2026-11-01 05:32:26.562454+06	LOAD-W2	520	129.75	100	critical	simulator
2026-11-01 05:32:26.562454+06	GEN-S1	1165.9	230.66	79.8	normal	simulator
2026-11-01 05:32:26.562454+06	SUB-S1	940.9	230.31	69.5	normal	simulator
2026-11-01 05:32:26.562454+06	LOAD-S1	597.8	129.68	98	critical	simulator
2026-11-01 05:32:26.562454+06	LOAD-S2	415.5	131.52	88.4	warning	simulator
2026-11-01 05:32:28.902227+06	GEN-N1	268.2	230.13	80.1	normal	simulator
2026-11-01 05:32:28.902227+06	SUB-N1	1041.1	230.45	61.9	normal	simulator
2026-11-01 05:32:28.902227+06	LOAD-N1	486.7	131.49	78.5	normal	simulator
2026-11-01 05:32:28.902227+06	LOAD-N2	340.8	132	71	normal	simulator
2026-11-01 05:32:28.902227+06	GEN-E1	832.9	230.36	81.6	normal	simulator
2026-11-01 05:32:28.902227+06	SUB-E1	950.7	230.53	65.8	normal	simulator
2026-11-01 05:32:28.902227+06	LOAD-E1	474.2	132.03	83.2	normal	simulator
2026-11-01 05:32:28.902227+06	LOAD-E2	302.4	131.88	67.2	normal	simulator
2026-11-01 05:32:28.902227+06	GEN-C1	1021.1	229.86	78.4	normal	simulator
2026-11-01 05:32:28.902227+06	SUB-C1	1123.5	230.16	73.5	normal	simulator
2026-11-01 05:32:28.902227+06	LOAD-C1	662.7	131.85	87.2	warning	simulator
2026-11-01 05:32:28.902227+06	LOAD-C2	292.5	131.46	75	normal	simulator
2026-11-01 05:32:28.902227+06	GEN-W1	196.1	230.42	81	normal	simulator
2026-11-01 05:32:28.902227+06	SUB-W1	1024.4	229.49	65.6	normal	simulator
2026-11-01 05:32:28.902227+06	LOAD-W1	409.3	132.31	75.8	normal	simulator
2026-11-01 05:32:28.902227+06	LOAD-W2	431.1	131.57	82.9	normal	simulator
2026-11-01 05:32:28.902227+06	GEN-S1	1199.2	230.55	78.7	normal	simulator
2026-11-01 05:32:28.902227+06	SUB-S1	1026.2	229.38	68.9	normal	simulator
2026-11-01 05:32:28.902227+06	LOAD-S1	489.2	131.5	80.2	normal	simulator
2026-11-01 05:32:28.902227+06	LOAD-S2	336.1	131.51	71.5	normal	simulator
2026-11-01 05:32:30.837287+06	GEN-N1	990.7	229.52	80.1	normal	simulator
2026-11-01 05:32:30.837287+06	SUB-N1	827.5	230.07	62.2	normal	simulator
2026-11-01 05:32:30.837287+06	LOAD-N1	482.4	131.97	77.8	normal	simulator
2026-11-01 05:32:30.837287+06	LOAD-N2	346.6	132.2	72.2	normal	simulator
2026-11-01 05:32:30.837287+06	GEN-E1	841.6	230.17	79.6	normal	simulator
2026-11-01 05:32:30.837287+06	SUB-E1	776.6	230.62	66.2	normal	simulator
2026-11-01 05:32:30.837287+06	LOAD-E1	458.9	132.18	80.5	normal	simulator
2026-11-01 05:32:30.837287+06	LOAD-E2	309.6	131.72	68.8	normal	simulator
2026-11-01 05:32:30.837287+06	GEN-C1	1064.9	230.55	79.7	normal	simulator
2026-11-01 05:32:30.837287+06	SUB-C1	0	229.6	72.5	critical	simulator
2026-11-01 05:32:30.837287+06	LOAD-C1	674.9	130.9	88.8	warning	simulator
2026-11-01 05:32:30.837287+06	LOAD-C2	287.4	132.06	73.7	normal	simulator
2026-11-01 05:32:30.837287+06	GEN-W1	707.2	230.25	80.7	normal	simulator
2026-11-01 05:32:30.837287+06	SUB-W1	840.4	230.34	67.7	normal	simulator
2026-11-01 05:32:30.837287+06	LOAD-W1	414.7	131.59	76.8	normal	simulator
2026-11-01 05:32:30.837287+06	LOAD-W2	438.4	131.11	84.3	normal	simulator
2026-11-01 05:32:30.837287+06	GEN-S1	1199.9	229.33	80.2	normal	simulator
2026-11-01 05:32:30.837287+06	SUB-S1	825.3	229.37	71.6	normal	simulator
2026-11-01 05:32:30.837287+06	LOAD-S1	477.6	132.42	78.3	normal	simulator
2026-11-01 05:32:30.837287+06	LOAD-S2	329.9	132.24	70.2	normal	simulator
2026-11-01 05:32:31.849461+06	GEN-N1	948	230.69	78.7	normal	simulator
2026-11-01 05:32:31.849461+06	SUB-N1	821.7	230.2	61.1	normal	simulator
2026-11-01 05:32:31.849461+06	LOAD-N1	607.6	129.5	98	critical	simulator
2026-11-01 05:32:31.849461+06	LOAD-N2	424.3	131.12	88.4	warning	simulator
2026-11-01 05:32:31.849461+06	GEN-E1	838.4	229.92	81.1	normal	simulator
2026-11-01 05:32:31.849461+06	SUB-E1	778.6	229.66	65.9	normal	simulator
2026-11-01 05:32:31.849461+06	LOAD-E1	566.6	129.55	99.4	critical	simulator
2026-11-01 05:32:31.849461+06	LOAD-E2	390.6	130.92	86.8	warning	simulator
2026-11-01 05:32:31.849461+06	GEN-C1	1073.3	229.55	79.5	normal	simulator
2026-11-01 05:32:31.849461+06	SUB-C1	958.8	229.79	71	normal	simulator
2026-11-01 05:32:31.849461+06	LOAD-C1	760	129.4	100	critical	simulator
2026-11-01 05:32:31.849461+06	LOAD-C2	356.9	131.26	91.5	warning	simulator
2026-11-01 05:32:31.849461+06	GEN-W1	714.5	230.36	78.6	normal	simulator
2026-11-01 05:32:31.849461+06	SUB-W1	848	230.12	65.2	normal	simulator
2026-11-01 05:32:31.849461+06	LOAD-W1	498.4	130.37	92.3	warning	simulator
2026-11-01 05:32:31.849461+06	LOAD-W2	520	130.18	100	critical	simulator
2026-11-01 05:32:31.849461+06	GEN-S1	1163.5	229.35	80.5	normal	simulator
2026-11-01 05:32:31.849461+06	SUB-S1	823.1	230.53	69.1	normal	simulator
2026-11-01 05:32:31.849461+06	LOAD-S1	599	130.31	98.2	critical	simulator
2026-11-01 05:32:31.849461+06	LOAD-S2	416.9	130.57	88.7	warning	simulator
2026-11-01 05:32:46.650861+06	GEN-N1	982.6	229.68	81.2	normal	simulator
2026-11-01 05:32:46.650861+06	SUB-N1	1042	229.48	60.9	normal	simulator
2026-11-01 05:32:46.650861+06	LOAD-N1	600.2	129.58	96.8	critical	simulator
2026-11-01 05:32:46.650861+06	LOAD-N2	427.7	131.1	89.1	warning	simulator
2026-11-01 05:32:46.650861+06	GEN-E1	872.8	229.53	80.2	normal	simulator
2026-11-01 05:32:46.650861+06	SUB-E1	956.7	230.57	64	normal	simulator
2026-11-01 05:32:46.650861+06	LOAD-E1	570	129.95	100	critical	simulator
2026-11-01 05:32:46.650861+06	LOAD-E2	389.2	131.57	86.5	warning	simulator
2026-11-01 05:32:46.650861+06	GEN-C1	1077.5	230.45	78.2	normal	simulator
2026-11-01 05:32:46.650861+06	SUB-C1	1113.3	230.21	72.9	normal	simulator
2026-11-01 05:32:46.650861+06	LOAD-C1	760	129.77	100	critical	simulator
2026-11-01 05:32:46.650861+06	LOAD-C2	355.7	130.1	91.2	warning	simulator
2026-11-01 05:32:46.650861+06	GEN-W1	722.2	230.12	79	normal	simulator
2026-11-01 05:32:46.650861+06	SUB-W1	1033.5	229.75	66	normal	simulator
2026-11-01 05:32:46.650861+06	LOAD-W1	501.1	130.15	92.8	warning	simulator
2026-11-01 05:32:46.650861+06	LOAD-W2	520	129.39	100	critical	simulator
2026-11-01 05:32:46.650861+06	GEN-S1	1153.4	230.26	80.6	normal	simulator
2026-11-01 05:32:46.650861+06	SUB-S1	1017.5	230.03	70.3	normal	simulator
2026-11-01 05:32:46.650861+06	LOAD-S1	596	129.44	97.7	critical	simulator
2026-11-01 05:32:46.650861+06	LOAD-S2	418.3	131.58	89	warning	simulator
2026-11-01 05:33:46.944395+06	GEN-N1	977.7	229.65	79.9	normal	simulator
2026-11-01 05:33:46.944395+06	SUB-N1	821.7	230.34	62.3	normal	simulator
2026-11-01 05:33:46.944395+06	LOAD-N1	482.4	132.67	77.8	normal	simulator
2026-11-01 05:33:46.944395+06	LOAD-N2	341.3	131.66	71.1	normal	simulator
2026-11-01 05:33:46.944395+06	GEN-E1	841.4	230.32	80.3	normal	simulator
2026-11-01 05:33:46.944395+06	SUB-E1	763.6	229.63	66.3	normal	simulator
2026-11-01 05:33:46.944395+06	LOAD-E1	466.3	131.21	81.8	normal	simulator
2026-11-01 05:33:46.944395+06	LOAD-E2	312.3	132.46	69.4	normal	simulator
2026-11-01 05:33:46.944395+06	GEN-C1	1081.6	230.42	79.3	normal	simulator
2026-11-01 05:33:46.944395+06	SUB-C1	939	230.4	70.3	normal	simulator
2026-11-01 05:33:46.944395+06	LOAD-C1	677.2	130.67	89.1	warning	simulator
2026-11-01 05:33:46.944395+06	LOAD-C2	284.3	132.49	72.9	normal	simulator
2026-11-01 05:33:46.944395+06	GEN-W1	713.9	229.97	80.1	normal	simulator
2026-11-01 05:33:46.944395+06	SUB-W1	828.1	230.25	67.2	normal	simulator
2026-11-01 05:33:46.944395+06	LOAD-W1	404.5	132.63	74.9	normal	simulator
2026-11-01 05:33:46.944395+06	LOAD-W2	422.2	132.5	81.2	normal	simulator
2026-11-01 05:33:46.944395+06	GEN-S1	1178.4	230.61	79.3	normal	simulator
2026-11-01 05:33:46.944395+06	SUB-S1	823	229.59	71	normal	simulator
2026-11-01 05:33:46.944395+06	LOAD-S1	483.7	132	79.3	normal	simulator
2026-11-01 05:33:46.944395+06	LOAD-S2	331.8	131.81	70.6	normal	simulator
2026-11-01 05:34:47.185314+06	GEN-N1	979.6	229.44	78.7	normal	simulator
2026-11-01 05:34:47.185314+06	SUB-N1	828	230.56	61.7	normal	simulator
2026-11-01 05:34:47.185314+06	LOAD-N1	499.1	132.37	80.5	normal	simulator
2026-11-01 05:34:47.185314+06	LOAD-N2	338.9	132.36	70.6	normal	simulator
2026-11-01 05:34:47.185314+06	GEN-E1	846.4	229.32	80.3	normal	simulator
2026-11-01 05:34:47.185314+06	SUB-E1	785.5	229.52	66	normal	simulator
2026-11-01 05:34:47.185314+06	LOAD-E1	468.5	132.18	82.2	normal	simulator
2026-11-01 05:34:47.185314+06	LOAD-E2	309.1	131.81	68.7	normal	simulator
2026-11-01 05:34:47.185314+06	GEN-C1	1085.7	229.82	78.4	normal	simulator
2026-11-01 05:34:47.185314+06	SUB-C1	961.9	229.93	73.3	normal	simulator
2026-11-01 05:34:47.185314+06	LOAD-C1	670.3	131.61	88.2	warning	simulator
2026-11-01 05:34:47.185314+06	LOAD-C2	294.1	132.33	75.4	normal	simulator
2026-11-01 05:34:47.185314+06	GEN-W1	703.2	230.46	81.7	normal	simulator
2026-11-01 05:34:47.185314+06	SUB-W1	836.5	230.05	66.3	normal	simulator
2026-11-01 05:34:47.185314+06	LOAD-W1	408.8	132.47	75.7	normal	simulator
2026-11-01 05:34:47.185314+06	LOAD-W2	424.8	132.3	81.7	normal	simulator
2026-11-01 05:34:47.185314+06	GEN-S1	1200.3	229.93	80.3	normal	simulator
2026-11-01 05:34:47.185314+06	SUB-S1	829.2	229.36	70.8	normal	simulator
2026-11-01 05:34:47.185314+06	LOAD-S1	477.6	132.28	78.3	normal	simulator
2026-11-01 05:34:47.185314+06	LOAD-S2	339.3	132.42	72.2	normal	simulator
2026-11-01 05:35:47.485579+06	GEN-N1	960.5	230.35	81.7	normal	simulator
2026-11-01 05:35:47.485579+06	SUB-N1	827.2	229.75	63.4	normal	simulator
2026-11-01 05:35:47.485579+06	LOAD-N1	500.3	132.3	80.7	normal	simulator
2026-11-01 05:35:47.485579+06	LOAD-N2	336.5	131.97	70.1	normal	simulator
2026-11-01 05:35:47.485579+06	GEN-E1	842.1	230.48	78.6	normal	simulator
2026-11-01 05:35:47.485579+06	SUB-E1	773.5	230.32	66.5	normal	simulator
2026-11-01 05:35:47.485579+06	LOAD-E1	474.8	131.52	83.3	normal	simulator
2026-11-01 05:35:47.485579+06	LOAD-E2	308.2	131.75	68.5	normal	simulator
2026-11-01 05:35:47.485579+06	GEN-C1	1085.8	229.4	79.5	normal	simulator
2026-11-01 05:35:47.485579+06	SUB-C1	958.8	229.63	72	normal	simulator
2026-11-01 05:35:47.485579+06	LOAD-C1	677.2	131.6	89.1	warning	simulator
2026-11-01 05:35:47.485579+06	LOAD-C2	288.2	132.21	73.9	normal	simulator
2026-11-01 05:35:47.485579+06	GEN-W1	705.1	230.03	78.6	normal	simulator
2026-11-01 05:35:47.485579+06	SUB-W1	849.5	229.9	68.4	normal	simulator
2026-11-01 05:35:47.485579+06	LOAD-W1	413.1	132.46	76.5	normal	simulator
2026-11-01 05:35:47.485579+06	LOAD-W2	422.8	132.14	81.3	normal	simulator
2026-11-01 05:35:47.485579+06	GEN-S1	1136.7	230.26	80.1	normal	simulator
2026-11-01 05:35:47.485579+06	SUB-S1	821	230.63	69	normal	simulator
2026-11-01 05:35:47.485579+06	LOAD-S1	492.3	132.3	80.7	normal	simulator
2026-11-01 05:35:47.485579+06	LOAD-S2	346.4	132.06	73.7	normal	simulator
2026-11-01 05:36:47.810382+06	GEN-N1	947.5	230.51	80.7	normal	simulator
2026-11-01 05:36:47.810382+06	SUB-N1	839.9	230	63.3	normal	simulator
2026-11-01 05:36:47.810382+06	LOAD-N1	492.3	132.64	79.4	normal	simulator
2026-11-01 05:36:47.810382+06	LOAD-N2	342.2	132.49	71.3	normal	simulator
2026-11-01 05:36:47.810382+06	GEN-E1	830.8	229.21	81	normal	simulator
2026-11-01 05:36:47.810382+06	SUB-E1	765.1	230.17	64.9	normal	simulator
2026-11-01 05:36:47.810382+06	LOAD-E1	458.9	131.47	80.5	normal	simulator
2026-11-01 05:36:47.810382+06	LOAD-E2	312.8	131.96	69.5	normal	simulator
2026-11-01 05:36:47.810382+06	GEN-C1	1042.6	230.16	79.2	normal	simulator
2026-11-01 05:36:47.810382+06	SUB-C1	961.4	230.32	71.3	normal	simulator
2026-11-01 05:36:47.810382+06	LOAD-C1	671.1	131.2	88.3	warning	simulator
2026-11-01 05:36:47.810382+06	LOAD-C2	291.7	132.51	74.8	normal	simulator
2026-11-01 05:36:47.810382+06	GEN-W1	685.4	229.51	81.6	normal	simulator
2026-11-01 05:36:47.810382+06	SUB-W1	849.9	230.45	65.3	normal	simulator
2026-11-01 05:36:47.810382+06	LOAD-W1	408.8	131.89	75.7	normal	simulator
2026-11-01 05:36:47.810382+06	LOAD-W2	426.9	131.4	82.1	normal	simulator
2026-11-01 05:36:47.810382+06	GEN-S1	1180.8	229.31	80.8	normal	simulator
2026-11-01 05:36:47.810382+06	SUB-S1	828.4	230.45	68.8	normal	simulator
2026-11-01 05:36:47.810382+06	LOAD-S1	496.5	131.35	81.4	normal	simulator
2026-11-01 05:36:47.810382+06	LOAD-S2	340.3	132.52	72.4	normal	simulator
2026-11-01 05:37:48.125153+06	GEN-N1	958.5	230.04	81.7	normal	simulator
2026-11-01 05:37:48.125153+06	SUB-N1	827.1	229.66	60.9	normal	simulator
2026-11-01 05:37:48.125153+06	LOAD-N1	497.2	132.05	80.2	normal	simulator
2026-11-01 05:37:48.125153+06	LOAD-N2	342.2	131.98	71.3	normal	simulator
2026-11-01 05:37:48.125153+06	GEN-E1	880.9	229.58	80.5	normal	simulator
2026-11-01 05:37:48.125153+06	SUB-E1	758.5	230.58	63.6	normal	simulator
2026-11-01 05:37:48.125153+06	LOAD-E1	458.9	131.65	80.5	normal	simulator
2026-11-01 05:37:48.125153+06	LOAD-E2	301.5	131.47	67	normal	simulator
2026-11-01 05:37:48.125153+06	GEN-C1	1021.1	229.48	81.3	normal	simulator
2026-11-01 05:37:48.125153+06	SUB-C1	956.5	230.4	72.4	normal	simulator
2026-11-01 05:37:48.125153+06	LOAD-C1	664.2	131.55	87.4	warning	simulator
2026-11-01 05:37:48.125153+06	LOAD-C2	291.3	132.02	74.7	normal	simulator
2026-11-01 05:37:48.125153+06	GEN-W1	710.2	229.89	79.3	normal	simulator
2026-11-01 05:37:48.125153+06	SUB-W1	839.9	230.18	68.7	normal	simulator
2026-11-01 05:37:48.125153+06	LOAD-W1	402.3	132.27	74.5	normal	simulator
2026-11-01 05:37:48.125153+06	LOAD-W2	426.9	131.85	82.1	normal	simulator
2026-11-01 05:37:48.125153+06	GEN-S1	1203	230.57	80.1	normal	simulator
2026-11-01 05:37:48.125153+06	SUB-S1	838.5	229.94	70.1	normal	simulator
2026-11-01 05:37:48.125153+06	LOAD-S1	481.3	131.88	78.9	normal	simulator
2026-11-01 05:37:48.125153+06	LOAD-S2	344	132.44	73.2	normal	simulator
2026-11-01 05:38:48.439753+06	GEN-N1	997.2	229.79	78.8	normal	simulator
2026-11-01 05:38:48.439753+06	SUB-N1	828.1	229.44	62	normal	simulator
2026-11-01 05:38:48.439753+06	LOAD-N1	479.3	132.67	77.3	normal	simulator
2026-11-01 05:38:48.439753+06	LOAD-N2	340.3	131.44	70.9	normal	simulator
2026-11-01 05:38:48.439753+06	GEN-E1	843.7	229.34	79.6	normal	simulator
2026-11-01 05:38:48.439753+06	SUB-E1	782.9	230.11	66.1	normal	simulator
2026-11-01 05:38:48.439753+06	LOAD-E1	464	132.19	81.4	normal	simulator
2026-11-01 05:38:48.439753+06	LOAD-E2	313.6	131.89	69.7	normal	simulator
2026-11-01 05:38:48.439753+06	GEN-C1	1019.8	230.39	81.2	normal	simulator
2026-11-01 05:38:48.439753+06	SUB-C1	941.3	230.23	72.3	normal	simulator
2026-11-01 05:38:48.439753+06	LOAD-C1	658.2	130.82	86.6	warning	simulator
2026-11-01 05:38:48.439753+06	LOAD-C2	290.9	131.94	74.6	normal	simulator
2026-11-01 05:38:48.439753+06	GEN-W1	694.7	229.52	78.7	normal	simulator
2026-11-01 05:38:48.439753+06	SUB-W1	832.6	230.65	67.9	normal	simulator
2026-11-01 05:38:48.439753+06	LOAD-W1	417.4	132.4	77.3	normal	simulator
2026-11-01 05:38:48.439753+06	LOAD-W2	424.8	131.97	81.7	normal	simulator
2026-11-01 05:38:48.439753+06	GEN-S1	1180.5	229.58	80.2	normal	simulator
2026-11-01 05:38:48.439753+06	SUB-S1	829.6	229.74	70.8	normal	simulator
2026-11-01 05:38:48.439753+06	LOAD-S1	492.9	131.77	80.8	normal	simulator
2026-11-01 05:38:48.439753+06	LOAD-S2	346.4	131.34	73.7	normal	simulator
2026-11-01 05:39:48.788414+06	GEN-N1	967.7	230.44	80.8	normal	simulator
2026-11-01 05:39:48.788414+06	SUB-N1	830.3	230.56	60.6	normal	simulator
2026-11-01 05:39:48.788414+06	LOAD-N1	492.3	132.42	79.4	normal	simulator
2026-11-01 05:39:48.788414+06	LOAD-N2	339.4	131.81	70.7	normal	simulator
2026-11-01 05:39:48.788414+06	GEN-E1	831.5	229.51	79	normal	simulator
2026-11-01 05:39:48.788414+06	SUB-E1	759.2	229.34	63.9	normal	simulator
2026-11-01 05:39:48.788414+06	LOAD-E1	470.2	132.22	82.5	normal	simulator
2026-11-01 05:39:48.788414+06	LOAD-E2	307.4	132.17	68.3	normal	simulator
2026-11-01 05:39:48.788414+06	GEN-C1	1032	229.53	78.6	normal	simulator
2026-11-01 05:39:48.788414+06	SUB-C1	959.1	229.71	72.9	normal	simulator
2026-11-01 05:39:48.788414+06	LOAD-C1	678.7	131.4	89.3	warning	simulator
2026-11-01 05:39:48.788414+06	LOAD-C2	292.9	131.52	75.1	normal	simulator
2026-11-01 05:39:48.788414+06	GEN-W1	712.4	229.7	81.5	normal	simulator
2026-11-01 05:39:48.788414+06	SUB-W1	842.3	230.54	67.9	normal	simulator
2026-11-01 05:39:48.788414+06	LOAD-W1	410.9	131.32	76.1	normal	simulator
2026-11-01 05:39:48.788414+06	LOAD-W2	436.8	131.52	84	normal	simulator
2026-11-01 05:39:48.788414+06	GEN-S1	1162.3	230.48	80.2	normal	simulator
2026-11-01 05:39:48.788414+06	SUB-S1	830.8	230.61	71	normal	simulator
2026-11-01 05:39:48.788414+06	LOAD-S1	494.1	131.97	81	normal	simulator
2026-11-01 05:39:48.788414+06	LOAD-S2	341.2	132.42	72.6	normal	simulator
2026-11-01 05:40:49.117376+06	GEN-N1	957.1	230.15	79	normal	simulator
2026-11-01 05:40:49.117376+06	SUB-N1	845.9	230.58	60.7	normal	simulator
2026-11-01 05:40:49.117376+06	LOAD-N1	481.7	131.83	77.7	normal	simulator
2026-11-01 05:40:49.117376+06	LOAD-N2	343.7	132.48	71.6	normal	simulator
2026-11-01 05:40:49.117376+06	GEN-E1	854.7	230.21	78.3	normal	simulator
2026-11-01 05:40:49.117376+06	SUB-E1	779.1	230.22	64.4	normal	simulator
2026-11-01 05:40:49.117376+06	LOAD-E1	470.2	131.69	82.5	normal	simulator
2026-11-01 05:40:49.117376+06	LOAD-E2	301.1	131.68	66.9	normal	simulator
2026-11-01 05:40:49.117376+06	GEN-C1	1047.2	230.32	81	normal	simulator
2026-11-01 05:40:49.117376+06	SUB-C1	958	229.9	71.1	normal	simulator
2026-11-01 05:40:49.117376+06	LOAD-C1	668	130.44	87.9	warning	simulator
2026-11-01 05:40:49.117376+06	LOAD-C2	284.7	132.56	73	normal	simulator
2026-11-01 05:40:49.117376+06	GEN-W1	723.7	229.73	81.1	normal	simulator
2026-11-01 05:40:49.117376+06	SUB-W1	833.2	229.93	66.4	normal	simulator
2026-11-01 05:40:49.117376+06	LOAD-W1	402.8	132.55	74.6	normal	simulator
2026-11-01 05:40:49.117376+06	LOAD-W2	432.1	131.78	83.1	normal	simulator
2026-11-01 05:40:49.117376+06	GEN-S1	1171.7	230.18	78.4	normal	simulator
2026-11-01 05:40:49.117376+06	SUB-S1	826.2	229.36	70.7	normal	simulator
2026-11-01 05:40:49.117376+06	LOAD-S1	497.1	131.52	81.5	normal	simulator
2026-11-01 05:40:49.117376+06	LOAD-S2	337	132.3	71.7	normal	simulator
2026-11-01 05:41:49.491229+06	GEN-N1	986.4	229.81	81.8	normal	simulator
2026-11-01 05:41:49.491229+06	SUB-N1	818.9	229.6	61.3	normal	simulator
2026-11-01 05:41:49.491229+06	LOAD-N1	496	131.74	80	normal	simulator
2026-11-01 05:41:49.491229+06	LOAD-N2	343.7	132.07	71.6	normal	simulator
2026-11-01 05:41:49.491229+06	GEN-E1	846.8	230.17	79.7	normal	simulator
2026-11-01 05:41:49.491229+06	SUB-E1	770.1	229.44	63.9	normal	simulator
2026-11-01 05:41:49.491229+06	LOAD-E1	461.1	131.38	80.9	normal	simulator
2026-11-01 05:41:49.491229+06	LOAD-E2	309.1	131.38	68.7	normal	simulator
2026-11-01 05:41:49.491229+06	GEN-C1	1051.4	229.97	78.6	normal	simulator
2026-11-01 05:41:49.491229+06	SUB-C1	962.8	229.51	73.5	normal	simulator
2026-11-01 05:41:49.491229+06	LOAD-C1	671.1	131.6	88.3	warning	simulator
2026-11-01 05:41:49.491229+06	LOAD-C2	281.6	131.63	72.2	normal	simulator
2026-11-01 05:41:49.491229+06	GEN-W1	682.6	229.99	80.5	normal	simulator
2026-11-01 05:41:49.491229+06	SUB-W1	855.8	229.31	67.5	normal	simulator
2026-11-01 05:41:49.491229+06	LOAD-W1	409.9	132.16	75.9	normal	simulator
2026-11-01 05:41:49.491229+06	LOAD-W2	426.9	132.05	82.1	normal	simulator
2026-11-01 05:41:49.491229+06	GEN-S1	1150.4	229.54	81.1	normal	simulator
2026-11-01 05:41:49.491229+06	SUB-S1	817.3	230.44	69.5	normal	simulator
2026-11-01 05:41:49.491229+06	LOAD-S1	492.9	132.05	80.8	normal	simulator
2026-11-01 05:41:49.491229+06	LOAD-S2	338.4	132.05	72	normal	simulator
2026-11-01 05:42:49.860044+06	GEN-N1	956.3	230.01	78.4	normal	simulator
2026-11-01 05:42:49.860044+06	SUB-N1	837.2	229.82	63.2	normal	simulator
2026-11-01 05:42:49.860044+06	LOAD-N1	482.4	131.41	77.8	normal	simulator
2026-11-01 05:42:49.860044+06	LOAD-N2	345.6	131.76	72	normal	simulator
2026-11-01 05:42:49.860044+06	GEN-E1	853.2	230.36	79.2	normal	simulator
2026-11-01 05:42:49.860044+06	SUB-E1	780.6	229.62	65.2	normal	simulator
2026-11-01 05:42:49.860044+06	LOAD-E1	474.2	131.96	83.2	normal	simulator
2026-11-01 05:42:49.860044+06	LOAD-E2	305.6	132.57	67.9	normal	simulator
2026-11-01 05:42:49.860044+06	GEN-C1	1046.9	229.36	80.3	normal	simulator
2026-11-01 05:42:49.860044+06	SUB-C1	963.7	230.31	72.6	normal	simulator
2026-11-01 05:42:49.860044+06	LOAD-C1	663.5	130.75	87.3	warning	simulator
2026-11-01 05:42:49.860044+06	LOAD-C2	295.2	132.66	75.7	normal	simulator
2026-11-01 05:42:49.860044+06	GEN-W1	701.6	230.41	79.1	normal	simulator
2026-11-01 05:42:49.860044+06	SUB-W1	838.3	230.64	67.4	normal	simulator
2026-11-01 05:42:49.860044+06	LOAD-W1	413.6	132.09	76.6	normal	simulator
2026-11-01 05:42:49.860044+06	LOAD-W2	423.8	132.19	81.5	normal	simulator
2026-11-01 05:42:49.860044+06	GEN-S1	1154.4	230.63	80.5	normal	simulator
2026-11-01 05:42:49.860044+06	SUB-S1	822	229.44	70.5	normal	simulator
2026-11-01 05:42:49.860044+06	LOAD-S1	486.2	132.02	79.7	normal	simulator
2026-11-01 05:42:49.860044+06	LOAD-S2	332.3	132.19	70.7	normal	simulator
2026-11-01 05:43:50.224719+06	GEN-N1	954.7	230.46	80.7	normal	simulator
2026-11-01 05:43:50.224719+06	SUB-N1	831.7	230.13	62.7	normal	simulator
2026-11-01 05:43:50.224719+06	LOAD-N1	483	132.11	77.9	normal	simulator
2026-11-01 05:43:50.224719+06	LOAD-N2	333.6	132.09	69.5	normal	simulator
2026-11-01 05:43:50.224719+06	GEN-E1	882	229.67	81.7	normal	simulator
2026-11-01 05:43:50.224719+06	SUB-E1	770.5	230.06	66.5	normal	simulator
2026-11-01 05:43:50.224719+06	LOAD-E1	459.4	132.01	80.6	normal	simulator
2026-11-01 05:43:50.224719+06	LOAD-E2	311.4	131.48	69.2	normal	simulator
2026-11-01 05:43:50.224719+06	GEN-C1	1071.3	230.37	79.4	normal	simulator
2026-11-01 05:43:50.224719+06	SUB-C1	951.3	230.11	73.4	normal	simulator
2026-11-01 05:43:50.224719+06	LOAD-C1	664.2	131.78	87.4	warning	simulator
2026-11-01 05:43:50.224719+06	LOAD-C2	282.4	131.6	72.4	normal	simulator
2026-11-01 05:43:50.224719+06	GEN-W1	693.5	230.36	79.3	normal	simulator
2026-11-01 05:43:50.224719+06	SUB-W1	857.9	229.85	66.9	normal	simulator
2026-11-01 05:43:50.224719+06	LOAD-W1	406.1	132.17	75.2	normal	simulator
2026-11-01 05:43:50.224719+06	LOAD-W2	424.8	131.66	81.7	normal	simulator
2026-11-01 05:43:50.224719+06	GEN-S1	1162.7	229.32	79.8	normal	simulator
2026-11-01 05:43:50.224719+06	SUB-S1	837.9	230.41	69.9	normal	simulator
2026-11-01 05:43:50.224719+06	LOAD-S1	497.8	132.5	81.6	normal	simulator
2026-11-01 05:43:50.224719+06	LOAD-S2	331.4	132.28	70.5	normal	simulator
2026-11-01 05:44:50.587358+06	GEN-N1	984.6	230.53	81.3	normal	simulator
2026-11-01 05:44:50.587358+06	SUB-N1	827.4	229.55	62.2	normal	simulator
2026-11-01 05:44:50.587358+06	LOAD-N1	479.3	132.6	77.3	normal	simulator
2026-11-01 05:44:50.587358+06	LOAD-N2	342.7	132.55	71.4	normal	simulator
2026-11-01 05:44:50.587358+06	GEN-E1	868.3	229.3	81.1	normal	simulator
2026-11-01 05:44:50.587358+06	SUB-E1	780	230.08	64.9	normal	simulator
2026-11-01 05:44:50.587358+06	LOAD-E1	457.7	131.97	80.3	normal	simulator
2026-11-01 05:44:50.587358+06	LOAD-E2	304.6	132.28	67.7	normal	simulator
2026-11-01 05:44:50.587358+06	GEN-C1	1029.6	229.7	79.1	normal	simulator
2026-11-01 05:44:50.587358+06	SUB-C1	945.9	230.25	73	normal	simulator
2026-11-01 05:44:50.587358+06	LOAD-C1	668	131.61	87.9	warning	simulator
2026-11-01 05:44:50.587358+06	LOAD-C2	294.8	131.71	75.6	normal	simulator
2026-11-01 05:44:50.587358+06	GEN-W1	715.8	229.4	79.1	normal	simulator
2026-11-01 05:44:50.587358+06	SUB-W1	837.6	230.53	65.8	normal	simulator
2026-11-01 05:44:50.587358+06	LOAD-W1	409.3	132.1	75.8	normal	simulator
2026-11-01 05:44:50.587358+06	LOAD-W2	435.8	131.12	83.8	normal	simulator
2026-11-01 05:44:50.587358+06	GEN-S1	1142.2	230.19	80.5	normal	simulator
2026-11-01 05:44:50.587358+06	SUB-S1	829.3	229.85	68.7	normal	simulator
2026-11-01 05:44:50.587358+06	LOAD-S1	478.9	131.68	78.5	normal	simulator
2026-11-01 05:44:50.587358+06	LOAD-S2	330.9	131.42	70.4	normal	simulator
2026-11-01 05:45:50.936505+06	GEN-N1	964.7	229.74	81.7	normal	simulator
2026-11-01 05:45:50.936505+06	SUB-N1	837.2	229.61	61.4	normal	simulator
2026-11-01 05:45:50.936505+06	LOAD-N1	492.9	131.93	79.5	normal	simulator
2026-11-01 05:45:50.936505+06	LOAD-N2	349.4	132.57	72.8	normal	simulator
2026-11-01 05:45:50.936505+06	GEN-E1	840.8	229.48	78.4	normal	simulator
2026-11-01 05:45:50.936505+06	SUB-E1	774.9	230.03	63.8	normal	simulator
2026-11-01 05:45:50.936505+06	LOAD-E1	474.2	131.53	83.2	normal	simulator
2026-11-01 05:45:50.936505+06	LOAD-E2	298.8	132.7	66.4	normal	simulator
2026-11-01 05:45:50.936505+06	GEN-C1	1068.1	230	78.5	normal	simulator
2026-11-01 05:45:50.936505+06	SUB-C1	957.7	230.3	71.1	normal	simulator
2026-11-01 05:45:50.936505+06	LOAD-C1	660.4	131.75	86.9	warning	simulator
2026-11-01 05:45:50.936505+06	LOAD-C2	285.5	132.07	73.2	normal	simulator
2026-11-01 05:45:50.936505+06	GEN-W1	693.5	229.77	81	normal	simulator
2026-11-01 05:45:50.936505+06	SUB-W1	845.1	229.81	67.8	normal	simulator
2026-11-01 05:45:50.936505+06	LOAD-W1	418	132.27	77.4	normal	simulator
2026-11-01 05:45:50.936505+06	LOAD-W2	426.4	131.43	82	normal	simulator
2026-11-01 05:45:50.936505+06	GEN-S1	1163.4	230.04	80.9	normal	simulator
2026-11-01 05:45:50.936505+06	SUB-S1	840.5	229.53	71.7	normal	simulator
2026-11-01 05:45:50.936505+06	LOAD-S1	481.3	132.04	78.9	normal	simulator
2026-11-01 05:45:50.936505+06	LOAD-S2	337	131.43	71.7	normal	simulator
2026-11-01 05:46:51.285941+06	GEN-N1	988.1	229.76	79.4	normal	simulator
2026-11-01 05:46:51.285941+06	SUB-N1	830.7	230.4	63	normal	simulator
2026-11-01 05:46:51.285941+06	LOAD-N1	491.7	131.62	79.3	normal	simulator
2026-11-01 05:46:51.285941+06	LOAD-N2	348	131.98	72.5	normal	simulator
2026-11-01 05:46:51.285941+06	GEN-E1	834	229.68	78.7	normal	simulator
2026-11-01 05:46:51.285941+06	SUB-E1	787.6	230.4	65.2	normal	simulator
2026-11-01 05:46:51.285941+06	LOAD-E1	461.1	131.65	80.9	normal	simulator
2026-11-01 05:46:51.285941+06	LOAD-E2	311.4	132.02	69.2	normal	simulator
2026-11-01 05:46:51.285941+06	GEN-C1	1027.6	230.38	80.2	normal	simulator
2026-11-01 05:46:51.285941+06	SUB-C1	963.9	230.04	72.5	normal	simulator
2026-11-01 05:46:51.285941+06	LOAD-C1	662	131.27	87.1	warning	simulator
2026-11-01 05:46:51.285941+06	LOAD-C2	285.5	132.61	73.2	normal	simulator
2026-11-01 05:46:51.285941+06	GEN-W1	705.9	229.28	80.6	normal	simulator
2026-11-01 05:46:51.285941+06	SUB-W1	842.8	229.44	65.3	normal	simulator
2026-11-01 05:46:51.285941+06	LOAD-W1	401.2	132.4	74.3	normal	simulator
2026-11-01 05:46:51.285941+06	LOAD-W2	430	131.26	82.7	normal	simulator
2026-11-01 05:46:51.285941+06	GEN-S1	1180.7	229.83	81.3	normal	simulator
2026-11-01 05:46:51.285941+06	SUB-S1	811	230.03	68.2	normal	simulator
2026-11-01 05:46:51.285941+06	LOAD-S1	483.1	131.75	79.2	normal	simulator
2026-11-01 05:46:51.285941+06	LOAD-S2	337.9	132.42	71.9	normal	simulator
2026-11-01 13:16:07.497293+06	GEN-N1	988	230.41	80.8	normal	simulator
2026-11-01 13:16:07.497293+06	SUB-N1	827.5	230.4	62.3	normal	simulator
2026-11-01 13:16:07.497293+06	LOAD-N1	481.7	131.99	77.7	normal	simulator
2026-11-01 13:16:07.497293+06	LOAD-N2	340.3	132.7	70.9	normal	simulator
2026-11-01 13:16:07.497293+06	GEN-E1	846.3	230.37	79.3	normal	simulator
2026-11-01 13:16:07.497293+06	SUB-E1	778.8	230.58	63.8	normal	simulator
2026-11-01 13:16:07.497293+06	LOAD-E1	475.4	132.09	83.4	normal	simulator
2026-11-01 13:16:07.497293+06	LOAD-E2	302.4	132.14	67.2	normal	simulator
2026-11-01 13:16:07.497293+06	GEN-C1	1058.1	229.63	81.2	normal	simulator
2026-11-01 13:16:07.497293+06	SUB-C1	959.4	229.76	71.7	normal	simulator
2026-11-01 13:16:07.497293+06	LOAD-C1	661.2	130.73	87	warning	simulator
2026-11-01 13:16:07.497293+06	LOAD-C2	295.6	132.67	75.8	normal	simulator
2026-11-01 13:16:07.497293+06	GEN-W1	686.9	229.31	81.8	normal	simulator
2026-11-01 13:16:07.497293+06	SUB-W1	836.8	229.96	67.6	normal	simulator
2026-11-01 13:16:07.497293+06	LOAD-W1	419.6	131.88	77.7	normal	simulator
2026-11-01 13:16:07.497293+06	LOAD-W2	435.8	131.92	83.8	normal	simulator
2026-11-01 13:16:07.497293+06	GEN-S1	1200.9	229.81	79.9	normal	simulator
2026-11-01 13:16:07.497293+06	SUB-S1	826.7	229.52	70	normal	simulator
2026-11-01 13:16:07.497293+06	LOAD-S1	492.9	132.26	80.8	normal	simulator
2026-11-01 13:16:07.497293+06	LOAD-S2	345	132.33	73.4	normal	simulator
2026-11-01 13:27:45.808719+06	GEN-N1	959.2	230.33	80.6	normal	simulator
2026-11-01 13:27:45.808719+06	SUB-N1	843.7	229.99	60.5	normal	simulator
2026-11-01 13:27:45.808719+06	LOAD-N1	495.4	131.71	79.9	normal	simulator
2026-11-01 13:27:45.808719+06	LOAD-N2	337.9	131.78	70.4	normal	simulator
2026-11-01 13:27:45.808719+06	GEN-E1	852.4	229.87	80.4	normal	simulator
2026-11-01 13:27:45.808719+06	SUB-E1	764.3	230.48	66.7	normal	simulator
2026-11-01 13:27:45.808719+06	LOAD-E1	457.7	132.64	80.3	normal	simulator
2026-11-01 13:27:45.808719+06	LOAD-E2	313.6	132.01	69.7	normal	simulator
2026-11-01 12:33:52.861267+06	GEN-N1	947.2	230.14	78.7	normal	simulator
2026-11-01 12:33:52.861267+06	SUB-N1	832.1	229.33	63.6	normal	simulator
2026-11-01 12:33:52.861267+06	LOAD-N1	492.9	131.9	79.5	normal	simulator
2026-11-01 12:33:52.861267+06	LOAD-N2	346.6	132.68	72.2	normal	simulator
2026-11-01 12:33:52.861267+06	GEN-E1	833.2	230.06	79.3	normal	simulator
2026-11-01 12:33:52.861267+06	SUB-E1	773.5	229.82	66.4	normal	simulator
2026-11-01 12:33:52.861267+06	LOAD-E1	472	131.15	82.8	normal	simulator
2026-11-01 12:33:52.861267+06	LOAD-E2	307.4	132	68.3	normal	simulator
2026-11-01 12:33:52.861267+06	GEN-C1	1082.2	229.39	81.2	normal	simulator
2026-11-01 12:33:52.861267+06	SUB-C1	957.9	230.28	72.7	normal	simulator
2026-11-01 12:33:52.861267+06	LOAD-C1	667.3	130.94	87.8	warning	simulator
2026-11-01 12:33:52.861267+06	LOAD-C2	283.5	132.23	72.7	normal	simulator
2026-11-01 12:33:52.861267+06	GEN-W1	682.8	229.34	80.2	normal	simulator
2026-11-01 12:33:52.861267+06	SUB-W1	848.5	229.32	67.9	normal	simulator
2026-11-01 12:33:52.861267+06	LOAD-W1	416.9	132.12	77.2	normal	simulator
2026-11-01 12:33:52.861267+06	LOAD-W2	428.5	131.58	82.4	normal	simulator
2026-11-01 12:33:52.861267+06	GEN-S1	1153.8	230.27	78.6	normal	simulator
2026-11-01 12:33:52.861267+06	SUB-S1	838.7	230.43	70.5	normal	simulator
2026-11-01 12:33:52.861267+06	LOAD-S1	483.1	131.46	79.2	normal	simulator
2026-11-01 12:33:52.861267+06	LOAD-S2	338.9	131.77	72.1	normal	simulator
2026-11-01 12:34:53.226386+06	GEN-N1	975.3	229.66	80.5	normal	simulator
2026-11-01 12:34:53.226386+06	SUB-N1	830.6	229.96	60.8	normal	simulator
2026-11-01 12:34:53.226386+06	LOAD-N1	490.4	132.65	79.1	normal	simulator
2026-11-01 12:34:53.226386+06	LOAD-N2	341.3	132.66	71.1	normal	simulator
2026-11-01 12:34:53.226386+06	GEN-E1	869.1	230.2	79	normal	simulator
2026-11-01 12:34:53.226386+06	SUB-E1	759.8	230.24	66.7	normal	simulator
2026-11-01 12:34:53.226386+06	LOAD-E1	473.1	132.13	83	normal	simulator
2026-11-01 12:34:53.226386+06	LOAD-E2	305.6	131.62	67.9	normal	simulator
2026-11-01 12:34:53.226386+06	GEN-C1	1071	230.51	80.3	normal	simulator
2026-11-01 12:34:53.226386+06	SUB-C1	962.6	229.45	71.5	normal	simulator
2026-11-01 12:34:53.226386+06	LOAD-C1	662.7	130.85	87.2	warning	simulator
2026-11-01 12:34:53.226386+06	LOAD-C2	283.9	132.47	72.8	normal	simulator
2026-11-01 12:34:53.226386+06	GEN-W1	683.5	229.3	78.6	normal	simulator
2026-11-01 12:34:53.226386+06	SUB-W1	828.2	229.99	68.6	normal	simulator
2026-11-01 12:34:53.226386+06	LOAD-W1	411.5	131.96	76.2	normal	simulator
2026-11-01 12:34:53.226386+06	LOAD-W2	434.7	131.01	83.6	normal	simulator
2026-11-01 12:34:53.226386+06	GEN-S1	1166.7	229.67	79.8	normal	simulator
2026-11-01 12:34:53.226386+06	SUB-S1	819.8	229.51	70.6	normal	simulator
2026-11-01 12:34:53.226386+06	LOAD-S1	494.7	131.24	81.1	normal	simulator
2026-11-01 12:34:53.226386+06	LOAD-S2	344	132.09	73.2	normal	simulator
2026-11-01 12:35:53.600468+06	GEN-N1	983.6	229.91	80.2	normal	simulator
2026-11-01 12:35:53.600468+06	SUB-N1	844	230.04	60.6	normal	simulator
2026-11-01 12:35:53.600468+06	LOAD-N1	491	131.35	79.2	normal	simulator
2026-11-01 12:35:53.600468+06	LOAD-N2	341.8	131.63	71.2	normal	simulator
2026-11-01 12:35:53.600468+06	GEN-E1	839	230.26	81.4	normal	simulator
2026-11-01 12:35:53.600468+06	SUB-E1	782.1	229.6	64.2	normal	simulator
2026-11-01 12:35:53.600468+06	LOAD-E1	472	132.14	82.8	normal	simulator
2026-11-01 12:35:53.600468+06	LOAD-E2	308.7	132.16	68.6	normal	simulator
2026-11-01 12:35:53.600468+06	GEN-C1	1054.8	229.4	80	normal	simulator
2026-11-01 12:35:53.600468+06	SUB-C1	949	230.32	73.4	normal	simulator
2026-11-01 12:35:53.600468+06	LOAD-C1	669.6	131.64	88.1	warning	simulator
2026-11-01 12:35:53.600468+06	LOAD-C2	283.1	131.41	72.6	normal	simulator
2026-11-01 12:35:53.600468+06	GEN-W1	704.9	229.53	79.4	normal	simulator
2026-11-01 12:35:53.600468+06	SUB-W1	843.7	230.09	65.7	normal	simulator
2026-11-01 12:35:53.600468+06	LOAD-W1	413.6	131.77	76.6	normal	simulator
2026-11-01 12:35:53.600468+06	LOAD-W2	437.8	131.57	84.2	normal	simulator
2026-11-01 12:35:53.600468+06	GEN-S1	1206.2	229.93	80.8	normal	simulator
2026-11-01 12:35:53.600468+06	SUB-S1	835.2	229.57	68.9	normal	simulator
2026-11-01 12:35:53.600468+06	LOAD-S1	489.8	131.77	80.3	normal	simulator
2026-11-01 12:35:53.600468+06	LOAD-S2	342.6	131.34	72.9	normal	simulator
2026-11-01 12:36:53.950937+06	GEN-N1	986	229.99	79.8	normal	simulator
2026-11-01 12:36:53.950937+06	SUB-N1	831	230.13	63.3	normal	simulator
2026-11-01 12:36:53.950937+06	LOAD-N1	492.9	132.64	79.5	normal	simulator
2026-11-01 12:36:53.950937+06	LOAD-N2	334.6	131.96	69.7	normal	simulator
2026-11-01 12:36:53.950937+06	GEN-E1	837.8	229.93	79.1	normal	simulator
2026-11-01 12:36:53.950937+06	SUB-E1	771.4	230.69	66.5	normal	simulator
2026-11-01 12:36:53.950937+06	LOAD-E1	469.7	131.55	82.4	normal	simulator
2026-11-01 12:36:53.950937+06	LOAD-E2	309.1	131.98	68.7	normal	simulator
2026-11-01 12:36:53.950937+06	GEN-C1	1035.2	229.78	81.4	normal	simulator
2026-11-01 12:36:53.950937+06	SUB-C1	974.6	230.44	70.2	normal	simulator
2026-11-01 12:36:53.950937+06	LOAD-C1	674.9	131.57	88.8	warning	simulator
2026-11-01 12:36:53.950937+06	LOAD-C2	287.8	132.64	73.8	normal	simulator
2026-11-01 12:36:53.950937+06	GEN-W1	708	230.26	80.8	normal	simulator
2026-11-01 12:36:53.950937+06	SUB-W1	831.3	229.74	67.8	normal	simulator
2026-11-01 12:36:53.950937+06	LOAD-W1	415.3	131.63	76.9	normal	simulator
2026-11-01 12:36:53.950937+06	LOAD-W2	437.3	131.43	84.1	normal	simulator
2026-11-01 12:36:53.950937+06	GEN-S1	1132.9	230.28	81	normal	simulator
2026-11-01 12:36:53.950937+06	SUB-S1	817.8	229.71	70.9	normal	simulator
2026-11-01 12:36:53.950937+06	LOAD-S1	488.6	132.09	80.1	normal	simulator
2026-11-01 12:36:53.950937+06	LOAD-S2	345	132.45	73.4	normal	simulator
2026-11-01 12:37:54.31842+06	GEN-N1	1005.1	229.44	81	normal	simulator
2026-11-01 12:37:54.31842+06	SUB-N1	836.3	230.66	60.2	normal	simulator
2026-11-01 12:37:54.31842+06	LOAD-N1	496	132.56	80	normal	simulator
2026-11-01 12:37:54.31842+06	LOAD-N2	348.5	132.62	72.6	normal	simulator
2026-11-01 12:37:54.31842+06	GEN-E1	838.2	230.11	78.3	normal	simulator
2026-11-01 12:37:54.31842+06	SUB-E1	782.8	230.62	65.7	normal	simulator
2026-11-01 12:37:54.31842+06	LOAD-E1	464	131.15	81.4	normal	simulator
2026-11-01 12:37:54.31842+06	LOAD-E2	302.4	131.55	67.2	normal	simulator
2026-11-01 12:37:54.31842+06	GEN-C1	1028.2	230.36	79	normal	simulator
2026-11-01 12:37:54.31842+06	SUB-C1	958.5	229.98	73.5	normal	simulator
2026-11-01 12:37:54.31842+06	LOAD-C1	670.3	131.45	88.2	warning	simulator
2026-11-01 12:37:54.31842+06	LOAD-C2	285.5	131.34	73.2	normal	simulator
2026-11-01 12:37:54.31842+06	GEN-W1	686.5	230.27	79.2	normal	simulator
2026-11-01 12:37:54.31842+06	SUB-W1	831.4	229.77	68.7	normal	simulator
2026-11-01 12:37:54.31842+06	LOAD-W1	412.6	132.19	76.4	normal	simulator
2026-11-01 12:37:54.31842+06	LOAD-W2	437.3	131.37	84.1	normal	simulator
2026-11-01 12:37:54.31842+06	GEN-S1	1197.7	230.13	78.5	normal	simulator
2026-11-01 12:37:54.31842+06	SUB-S1	838.4	230.29	70.6	normal	simulator
2026-11-01 12:37:54.31842+06	LOAD-S1	484.9	132.47	79.5	normal	simulator
2026-11-01 12:37:54.31842+06	LOAD-S2	330.4	132.59	70.3	normal	simulator
2026-11-01 12:38:54.688197+06	GEN-N1	965.9	229.99	78.6	normal	simulator
2026-11-01 12:38:54.688197+06	SUB-N1	830.9	230.45	62.3	normal	simulator
2026-11-01 12:38:54.688197+06	LOAD-N1	489.8	132.36	79	normal	simulator
2026-11-01 12:38:54.688197+06	LOAD-N2	347	132.67	72.3	normal	simulator
2026-11-01 12:38:54.688197+06	GEN-E1	833	230.27	80	normal	simulator
2026-11-01 12:38:54.688197+06	SUB-E1	765.9	230.07	66.6	normal	simulator
2026-11-01 12:38:54.688197+06	LOAD-E1	468	131.69	82.1	normal	simulator
2026-11-01 12:38:54.688197+06	LOAD-E2	313.2	131.83	69.6	normal	simulator
2026-11-01 12:38:54.688197+06	GEN-C1	1056.9	229.84	80	normal	simulator
2026-11-01 12:38:54.688197+06	SUB-C1	949.8	230	72.3	normal	simulator
2026-11-01 12:38:54.688197+06	LOAD-C1	665.8	130.49	87.6	warning	simulator
2026-11-01 12:38:54.688197+06	LOAD-C2	293.3	131.42	75.2	normal	simulator
2026-11-01 12:38:54.688197+06	GEN-W1	720.1	229.86	80.7	normal	simulator
2026-11-01 12:38:54.688197+06	SUB-W1	854.2	229.94	68	normal	simulator
2026-11-01 12:38:54.688197+06	LOAD-W1	406.1	132.64	75.2	normal	simulator
2026-11-01 12:38:54.688197+06	LOAD-W2	440.4	131.6	84.7	normal	simulator
2026-11-01 12:38:54.688197+06	GEN-S1	1144.8	229.54	79.3	normal	simulator
2026-11-01 12:38:54.688197+06	SUB-S1	826.7	229.31	70.6	normal	simulator
2026-11-01 12:38:54.688197+06	LOAD-S1	478.9	131.45	78.5	normal	simulator
2026-11-01 12:38:54.688197+06	LOAD-S2	345.4	132.16	73.5	normal	simulator
2026-11-01 12:39:55.077937+06	GEN-N1	975.4	229.88	79.5	normal	simulator
2026-11-01 12:39:55.077937+06	SUB-N1	837.2	229.75	60.7	normal	simulator
2026-11-01 12:39:55.077937+06	LOAD-N1	484.8	132.6	78.2	normal	simulator
2026-11-01 12:39:55.077937+06	LOAD-N2	334.1	132.6	69.6	normal	simulator
2026-11-01 12:39:55.077937+06	GEN-E1	884.9	229.54	80.4	normal	simulator
2026-11-01 12:39:55.077937+06	SUB-E1	776.9	230.5	63.8	normal	simulator
2026-11-01 12:39:55.077937+06	LOAD-E1	472.5	131.83	82.9	normal	simulator
2026-11-01 12:39:55.077937+06	LOAD-E2	302.4	132.58	67.2	normal	simulator
2026-11-01 12:39:55.077937+06	GEN-C1	1068.2	229.66	78.8	normal	simulator
2026-11-01 12:39:55.077937+06	SUB-C1	945.1	230.2	73.5	normal	simulator
2026-11-01 12:39:55.077937+06	LOAD-C1	676.4	131.26	89	warning	simulator
2026-11-01 12:39:55.077937+06	LOAD-C2	290.9	132.09	74.6	normal	simulator
2026-11-01 12:39:55.077937+06	GEN-W1	686.9	229.61	78.5	normal	simulator
2026-11-01 12:39:55.077937+06	SUB-W1	830.3	230.67	68.1	normal	simulator
2026-11-01 12:39:55.077937+06	LOAD-W1	419	131.96	77.6	normal	simulator
2026-11-01 12:39:55.077937+06	LOAD-W2	429.5	131.79	82.6	normal	simulator
2026-11-01 12:39:55.077937+06	GEN-S1	1168.8	230.19	80.7	normal	simulator
2026-11-01 12:39:55.077937+06	SUB-S1	835.2	229.48	68.9	normal	simulator
2026-11-01 12:39:55.077937+06	LOAD-S1	484.9	132.35	79.5	normal	simulator
2026-11-01 12:39:55.077937+06	LOAD-S2	337	131.36	71.7	normal	simulator
2026-11-01 12:45:57.385539+06	GEN-N1	965	230.06	80.9	normal	simulator
2026-11-01 12:45:57.385539+06	SUB-N1	834.7	229.88	63.6	normal	simulator
2026-11-01 12:45:57.385539+06	LOAD-N1	493.5	131.46	79.6	normal	simulator
2026-11-01 12:45:57.385539+06	LOAD-N2	337.9	132.21	70.4	normal	simulator
2026-11-01 12:45:57.385539+06	GEN-E1	857.8	229.62	81.2	normal	simulator
2026-11-01 12:45:57.385539+06	SUB-E1	780	229.5	65.9	normal	simulator
2026-11-01 12:45:57.385539+06	LOAD-E1	458.3	131.95	80.4	normal	simulator
2026-11-01 12:45:57.385539+06	LOAD-E2	309.1	131.75	68.7	normal	simulator
2026-11-01 12:45:57.385539+06	GEN-C1	1069.8	229.28	80.5	normal	simulator
2026-11-01 12:45:57.385539+06	SUB-C1	945.6	229.53	72.5	normal	simulator
2026-11-01 12:45:57.385539+06	LOAD-C1	669.6	130.52	88.1	warning	simulator
2026-11-01 12:45:57.385539+06	LOAD-C2	282	132.5	72.3	normal	simulator
2026-11-01 12:45:57.385539+06	GEN-W1	713.6	229.3	80.8	normal	simulator
2026-11-01 12:45:57.385539+06	SUB-W1	846.5	230.23	67.5	normal	simulator
2026-11-01 12:45:57.385539+06	LOAD-W1	403.9	132.36	74.8	normal	simulator
2026-11-01 12:45:57.385539+06	LOAD-W2	436.3	131.65	83.9	normal	simulator
2026-11-01 12:45:57.385539+06	GEN-S1	1162.5	229.91	80	normal	simulator
2026-11-01 12:45:57.385539+06	SUB-S1	832.1	229.42	70.5	normal	simulator
2026-11-01 12:45:57.385539+06	LOAD-S1	488.6	131.64	80.1	normal	simulator
2026-11-01 12:45:57.385539+06	LOAD-S2	332.8	132.15	70.8	normal	simulator
2026-11-01 12:46:57.704511+06	GEN-N1	983.4	229.32	79.4	normal	simulator
2026-11-01 12:46:57.704511+06	SUB-N1	830.4	230.12	61.7	normal	simulator
2026-11-01 12:46:57.704511+06	LOAD-N1	479.9	131.57	77.4	normal	simulator
2026-11-01 12:46:57.704511+06	LOAD-N2	337.9	131.8	70.4	normal	simulator
2026-11-01 12:46:57.704511+06	GEN-E1	853.1	230.11	81.6	normal	simulator
2026-11-01 12:46:57.704511+06	SUB-E1	778.7	229.52	64.8	normal	simulator
2026-11-01 12:46:57.704511+06	LOAD-E1	470.8	131.82	82.6	normal	simulator
2026-11-01 12:46:57.704511+06	LOAD-E2	306.4	132.34	68.1	normal	simulator
2026-11-01 12:46:57.704511+06	GEN-C1	1080.1	229.86	80.2	normal	simulator
2026-11-01 12:46:57.704511+06	SUB-C1	966.9	230.2	71.9	normal	simulator
2026-11-01 12:46:57.704511+06	LOAD-C1	674.1	131.51	88.7	warning	simulator
2026-11-01 12:46:57.704511+06	LOAD-C2	291.3	131.96	74.7	normal	simulator
2026-11-01 12:46:57.704511+06	GEN-W1	708.6	229.8	79.4	normal	simulator
2026-11-01 12:46:57.704511+06	SUB-W1	828.7	230.65	68.5	normal	simulator
2026-11-01 12:46:57.704511+06	LOAD-W1	413.1	131.31	76.5	normal	simulator
2026-11-01 12:46:57.704511+06	LOAD-W2	429.5	131.82	82.6	normal	simulator
2026-11-01 12:40:55.455022+06	GEN-N1	985.3	230.3	79.9	normal	simulator
2026-11-01 12:40:55.455022+06	SUB-N1	827.4	229.91	60.6	normal	simulator
2026-11-01 12:40:55.455022+06	LOAD-N1	480.5	131.55	77.5	normal	simulator
2026-11-01 12:40:55.455022+06	LOAD-N2	347.5	131.31	72.4	normal	simulator
2026-11-01 12:40:55.455022+06	GEN-E1	837.9	229.41	80.2	normal	simulator
2026-11-01 12:40:55.455022+06	SUB-E1	783.9	229.41	64.4	normal	simulator
2026-11-01 12:40:55.455022+06	LOAD-E1	460	132.5	80.7	normal	simulator
2026-11-01 12:40:55.455022+06	LOAD-E2	312.3	131.93	69.4	normal	simulator
2026-11-01 12:40:55.455022+06	GEN-C1	1050.5	229.52	79.1	normal	simulator
2026-11-01 12:40:55.455022+06	SUB-C1	952.4	229.67	73.2	normal	simulator
2026-11-01 12:40:55.455022+06	LOAD-C1	668.8	131.71	88	warning	simulator
2026-11-01 12:40:55.455022+06	LOAD-C2	288.6	132.27	74	normal	simulator
2026-11-01 12:40:55.455022+06	GEN-W1	690.6	229.93	79.5	normal	simulator
2026-11-01 12:40:55.455022+06	SUB-W1	838.5	230.37	68.6	normal	simulator
2026-11-01 12:40:55.455022+06	LOAD-W1	415.3	131.77	76.9	normal	simulator
2026-11-01 12:40:55.455022+06	LOAD-W2	432.1	132.16	83.1	normal	simulator
2026-11-01 12:40:55.455022+06	GEN-S1	1152	229.52	78.8	normal	simulator
2026-11-01 12:40:55.455022+06	SUB-S1	829.1	229.69	70.2	normal	simulator
2026-11-01 12:40:55.455022+06	LOAD-S1	484.3	131.48	79.4	normal	simulator
2026-11-01 12:40:55.455022+06	LOAD-S2	342.2	132.32	72.8	normal	simulator
2026-11-01 12:41:55.831346+06	GEN-N1	948.3	229.31	78.7	normal	simulator
2026-11-01 12:41:55.831346+06	SUB-N1	839.1	230.67	60.6	normal	simulator
2026-11-01 12:41:55.831346+06	LOAD-N1	494.8	131.62	79.8	normal	simulator
2026-11-01 12:41:55.831346+06	LOAD-N2	342.2	132.37	71.3	normal	simulator
2026-11-01 12:41:55.831346+06	GEN-E1	853.1	230.49	79.9	normal	simulator
2026-11-01 12:41:55.831346+06	SUB-E1	758.9	230.24	64.6	normal	simulator
2026-11-01 12:41:55.831346+06	LOAD-E1	468.5	131.17	82.2	normal	simulator
2026-11-01 12:41:55.831346+06	LOAD-E2	297.9	131.99	66.2	normal	simulator
2026-11-01 12:41:55.831346+06	GEN-C1	1036.6	229.73	79.7	normal	simulator
2026-11-01 12:41:55.831346+06	SUB-C1	954.8	229.49	71.8	normal	simulator
2026-11-01 12:41:55.831346+06	LOAD-C1	671.8	130.64	88.4	warning	simulator
2026-11-01 12:41:55.831346+06	LOAD-C2	282	132.42	72.3	normal	simulator
2026-11-01 12:41:55.831346+06	GEN-W1	712.8	229.92	80.2	normal	simulator
2026-11-01 12:41:55.831346+06	SUB-W1	832	229.73	68.3	normal	simulator
2026-11-01 12:41:55.831346+06	LOAD-W1	415.3	132.06	76.9	normal	simulator
2026-11-01 12:41:55.831346+06	LOAD-W2	430.6	131.38	82.8	normal	simulator
2026-11-01 12:41:55.831346+06	GEN-S1	1134.8	229.96	81.7	normal	simulator
2026-11-01 12:41:55.831346+06	SUB-S1	836.9	229.33	71.7	normal	simulator
2026-11-01 12:41:55.831346+06	LOAD-S1	477.6	131.45	78.3	normal	simulator
2026-11-01 12:41:55.831346+06	LOAD-S2	341.7	132.7	72.7	normal	simulator
2026-11-01 12:42:56.21559+06	GEN-N1	988.8	229.29	80.4	normal	simulator
2026-11-01 12:42:56.21559+06	SUB-N1	828	229.98	62.9	normal	simulator
2026-11-01 12:42:56.21559+06	LOAD-N1	498.5	132.47	80.4	normal	simulator
2026-11-01 12:42:56.21559+06	LOAD-N2	337	132	70.2	normal	simulator
2026-11-01 12:42:56.21559+06	GEN-E1	877.3	230.23	79.7	normal	simulator
2026-11-01 12:42:56.21559+06	SUB-E1	768.4	230.62	63.5	normal	simulator
2026-11-01 12:42:56.21559+06	LOAD-E1	460.6	132.14	80.8	normal	simulator
2026-11-01 12:42:56.21559+06	LOAD-E2	302.4	131.99	67.2	normal	simulator
2026-11-01 12:42:56.21559+06	GEN-C1	1049.1	230.23	79.2	normal	simulator
2026-11-01 12:42:56.21559+06	SUB-C1	956.5	229.63	70.5	normal	simulator
2026-11-01 12:42:56.21559+06	LOAD-C1	657.4	130.92	86.5	warning	simulator
2026-11-01 12:42:56.21559+06	LOAD-C2	289.8	132.23	74.3	normal	simulator
2026-11-01 12:42:56.21559+06	GEN-W1	687.4	229.73	79.9	normal	simulator
2026-11-01 12:42:56.21559+06	SUB-W1	844.8	229.82	66.5	normal	simulator
2026-11-01 12:42:56.21559+06	LOAD-W1	410.9	131.32	76.1	normal	simulator
2026-11-01 12:42:56.21559+06	LOAD-W2	430	131.54	82.7	normal	simulator
2026-11-01 12:42:56.21559+06	GEN-S1	1177.9	229.79	78.3	normal	simulator
2026-11-01 12:42:56.21559+06	SUB-S1	839.3	230.44	69.4	normal	simulator
2026-11-01 12:42:56.21559+06	LOAD-S1	480.1	132.52	78.7	normal	simulator
2026-11-01 12:42:56.21559+06	LOAD-S2	335.6	132.51	71.4	normal	simulator
2026-11-01 13:18:08.094853+06	GEN-N1	970.8	229.78	80.9	normal	simulator
2026-11-01 13:18:08.094853+06	SUB-N1	818.1	230.68	60.3	normal	simulator
2026-11-01 13:18:08.094853+06	LOAD-N1	488.6	131.61	78.8	normal	simulator
2026-11-01 13:18:08.094853+06	LOAD-N2	349	131.63	72.7	normal	simulator
2026-11-01 13:18:08.094853+06	GEN-E1	834.1	229.79	79.8	normal	simulator
2026-11-01 13:18:08.094853+06	SUB-E1	783.4	229.53	66	normal	simulator
2026-11-01 13:18:08.094853+06	LOAD-E1	461.1	132.14	80.9	normal	simulator
2026-11-01 13:18:08.094853+06	LOAD-E2	309.6	132.05	68.8	normal	simulator
2026-11-01 13:18:08.094853+06	GEN-C1	1034.8	229.5	80.6	normal	simulator
2026-11-01 13:18:08.094853+06	SUB-C1	950.8	229.5	72.3	normal	simulator
2026-11-01 13:18:08.094853+06	LOAD-C1	662.7	130.6	87.2	warning	simulator
2026-11-01 13:18:08.094853+06	LOAD-C2	294.4	131.37	75.5	normal	simulator
2026-11-01 13:18:08.094853+06	GEN-W1	679.6	230.59	79.9	normal	simulator
2026-11-01 13:18:08.094853+06	SUB-W1	845.8	229.68	67.4	normal	simulator
2026-11-01 13:18:08.094853+06	LOAD-W1	416.9	131.6	77.2	normal	simulator
2026-11-01 13:18:08.094853+06	LOAD-W2	437.8	131.92	84.2	normal	simulator
2026-11-01 13:18:08.094853+06	GEN-S1	1144.7	230.43	80.1	normal	simulator
2026-11-01 13:18:08.094853+06	SUB-S1	808	229.75	68.4	normal	simulator
2026-11-01 13:18:08.094853+06	LOAD-S1	486.8	131.7	79.8	normal	simulator
2026-11-01 13:18:08.094853+06	LOAD-S2	346.4	132.09	73.7	normal	simulator
2026-11-01 13:27:45.808719+06	GEN-C1	1076.7	229.67	79.4	normal	simulator
2026-11-01 13:27:45.808719+06	SUB-C1	948	229.55	70.7	normal	simulator
2026-11-01 13:27:45.808719+06	LOAD-C1	655.9	131.59	86.3	warning	simulator
2026-11-01 13:27:45.808719+06	LOAD-C2	293.7	132.67	75.3	normal	simulator
2026-11-01 13:27:45.808719+06	GEN-W1	680.2	229.95	80.1	normal	simulator
2026-11-01 13:27:45.808719+06	SUB-W1	842.4	230.11	67.4	normal	simulator
2026-11-01 13:27:45.808719+06	LOAD-W1	418.5	132.15	77.5	normal	simulator
2026-11-01 13:27:45.808719+06	LOAD-W2	424.3	132.34	81.6	normal	simulator
2026-11-01 12:43:56.619417+06	GEN-N1	960.9	230.44	78.6	normal	simulator
2026-11-01 12:43:56.619417+06	SUB-N1	821.8	229.68	63.5	normal	simulator
2026-11-01 12:43:56.619417+06	LOAD-N1	483.6	132.38	78	normal	simulator
2026-11-01 12:43:56.619417+06	LOAD-N2	335	132.5	69.8	normal	simulator
2026-11-01 12:43:56.619417+06	GEN-E1	883.2	230.3	80.5	normal	simulator
2026-11-01 12:43:56.619417+06	SUB-E1	790.7	229.95	66.1	normal	simulator
2026-11-01 12:43:56.619417+06	LOAD-E1	475.4	132.15	83.4	normal	simulator
2026-11-01 12:43:56.619417+06	LOAD-E2	302.4	131.41	67.2	normal	simulator
2026-11-01 12:43:56.619417+06	GEN-C1	1067.5	230.04	79.8	normal	simulator
2026-11-01 12:43:56.619417+06	SUB-C1	947.1	229.55	71.1	normal	simulator
2026-11-01 12:43:56.619417+06	LOAD-C1	674.9	130.79	88.8	warning	simulator
2026-11-01 12:43:56.619417+06	LOAD-C2	290.9	131.97	74.6	normal	simulator
2026-11-01 12:43:56.619417+06	GEN-W1	711.6	229.27	80.3	normal	simulator
2026-11-01 12:43:56.619417+06	SUB-W1	839.4	230.69	68.4	normal	simulator
2026-11-01 12:43:56.619417+06	LOAD-W1	414.2	132.22	76.7	normal	simulator
2026-11-01 12:43:56.619417+06	LOAD-W2	428	131.41	82.3	normal	simulator
2026-11-01 12:43:56.619417+06	GEN-S1	1158.4	230.07	78.5	normal	simulator
2026-11-01 12:43:56.619417+06	SUB-S1	818	230.3	70.9	normal	simulator
2026-11-01 12:43:56.619417+06	LOAD-S1	485.6	131.93	79.6	normal	simulator
2026-11-01 12:43:56.619417+06	LOAD-S2	337.9	132.57	71.9	normal	simulator
2026-11-01 12:44:57.009152+06	GEN-N1	986.1	229.38	80.3	normal	simulator
2026-11-01 12:44:57.009152+06	SUB-N1	835.3	230.22	62.3	normal	simulator
2026-11-01 12:44:57.009152+06	LOAD-N1	488.6	131.77	78.8	normal	simulator
2026-11-01 12:44:57.009152+06	LOAD-N2	335.5	131.84	69.9	normal	simulator
2026-11-01 12:44:57.009152+06	GEN-E1	837.7	230.3	79.6	normal	simulator
2026-11-01 12:44:57.009152+06	SUB-E1	774.6	229.7	66.1	normal	simulator
2026-11-01 12:44:57.009152+06	LOAD-E1	473.1	131.4	83	normal	simulator
2026-11-01 12:44:57.009152+06	LOAD-E2	299.7	131.33	66.6	normal	simulator
2026-11-01 12:44:57.009152+06	GEN-C1	1042.8	229.34	81.4	normal	simulator
2026-11-01 12:44:57.009152+06	SUB-C1	948.6	230.19	72.5	normal	simulator
2026-11-01 12:44:57.009152+06	LOAD-C1	677.9	130.48	89.2	warning	simulator
2026-11-01 12:44:57.009152+06	LOAD-C2	285.9	132.36	73.3	normal	simulator
2026-11-01 12:44:57.009152+06	GEN-W1	706.9	230.29	81.7	normal	simulator
2026-11-01 12:44:57.009152+06	SUB-W1	833.4	229.79	68.4	normal	simulator
2026-11-01 12:44:57.009152+06	LOAD-W1	408.8	131.46	75.7	normal	simulator
2026-11-01 12:44:57.009152+06	LOAD-W2	426.4	131.19	82	normal	simulator
2026-11-01 12:44:57.009152+06	GEN-S1	1199.1	229.61	80.6	normal	simulator
2026-11-01 12:44:57.009152+06	SUB-S1	825.9	229.44	71.3	normal	simulator
2026-11-01 12:44:57.009152+06	LOAD-S1	486.2	132.53	79.7	normal	simulator
2026-11-01 12:44:57.009152+06	LOAD-S2	333.7	131.38	71	normal	simulator
2026-11-01 13:19:08.368079+06	GEN-N1	980.3	230.51	81	normal	simulator
2026-11-01 13:19:08.368079+06	SUB-N1	819.8	229.85	63	normal	simulator
2026-11-01 13:19:08.368079+06	LOAD-N1	499.7	131.28	80.6	normal	simulator
2026-11-01 13:19:08.368079+06	LOAD-N2	337	132.43	70.2	normal	simulator
2026-11-01 13:19:08.368079+06	GEN-E1	845.2	229.54	78.6	normal	simulator
2026-11-01 13:19:08.368079+06	SUB-E1	781.4	230.67	66.4	normal	simulator
2026-11-01 13:19:08.368079+06	LOAD-E1	472.5	131.79	82.9	normal	simulator
2026-11-01 13:19:08.368079+06	LOAD-E2	310.9	132.37	69.1	normal	simulator
2026-11-01 13:19:08.368079+06	GEN-C1	1021.8	230.18	81	normal	simulator
2026-11-01 13:19:08.368079+06	SUB-C1	965.9	229.44	73.1	normal	simulator
2026-11-01 13:19:08.368079+06	LOAD-C1	674.9	130.58	88.8	warning	simulator
2026-11-01 13:19:08.368079+06	LOAD-C2	288.2	132.6	73.9	normal	simulator
2026-11-01 13:19:08.368079+06	GEN-W1	687.3	230.14	81.2	normal	simulator
2026-11-01 13:19:08.368079+06	SUB-W1	857.4	230.33	66	normal	simulator
2026-11-01 13:19:08.368079+06	LOAD-W1	401.2	131.46	74.3	normal	simulator
2026-11-01 13:19:08.368079+06	LOAD-W2	434.2	131.96	83.5	normal	simulator
2026-11-01 13:19:08.368079+06	GEN-S1	1148.7	229.64	79.1	normal	simulator
2026-11-01 13:19:08.368079+06	SUB-S1	828.4	230.14	71.6	normal	simulator
2026-11-01 13:19:08.368079+06	LOAD-S1	481.3	131.97	78.9	normal	simulator
2026-11-01 13:19:08.368079+06	LOAD-S2	336.1	132.61	71.5	normal	simulator
2026-11-01 13:27:45.808719+06	GEN-S1	1198.3	230.11	79.1	normal	simulator
2026-11-01 13:27:45.808719+06	SUB-S1	819	230.69	69.8	normal	simulator
2026-11-01 13:27:45.808719+06	LOAD-S1	477	131.57	78.2	normal	simulator
2026-11-01 13:27:45.808719+06	LOAD-S2	332.8	132.64	70.8	normal	simulator
2026-11-01 13:32:12.910454+06	GEN-E1	872.5	229.59	79.9	normal	simulator
2026-11-01 13:32:12.910454+06	SUB-E1	770.2	229.31	65	normal	simulator
2026-11-01 13:32:12.910454+06	LOAD-E1	469.7	131.99	82.4	normal	simulator
2026-11-01 13:32:12.910454+06	LOAD-E2	313.2	131.95	69.6	normal	simulator
2026-11-01 13:32:12.910454+06	GEN-C1	1055.3	230.05	80.1	normal	simulator
2026-11-01 13:32:12.910454+06	SUB-C1	960.7	230.39	71.7	normal	simulator
2026-11-01 13:32:12.910454+06	LOAD-C1	658.9	131.38	86.7	warning	simulator
2026-11-01 13:32:12.910454+06	LOAD-C2	291.7	131.88	74.8	normal	simulator
2026-11-01 13:32:12.910454+06	GEN-W1	685.5	229.85	78.9	normal	simulator
2026-11-01 13:32:12.910454+06	SUB-W1	841	229.38	66.6	normal	simulator
2026-11-01 13:32:12.910454+06	LOAD-W1	419.6	131.72	77.7	normal	simulator
2026-11-01 13:32:12.910454+06	LOAD-W2	437.3	132.05	84.1	normal	simulator
2026-11-01 13:32:12.910454+06	GEN-S1	1141.9	229.96	79.9	normal	simulator
2026-11-01 13:32:12.910454+06	SUB-S1	809.6	230.41	68.6	normal	simulator
2026-11-01 13:32:12.910454+06	LOAD-S1	479.5	132.47	78.6	normal	simulator
2026-11-01 13:32:12.910454+06	LOAD-S2	334.6	131.49	71.2	normal	simulator
2026-11-01 13:33:57.765748+06	GEN-N1	271.5	230.26	79.9	normal	simulator
2026-11-01 13:33:57.765748+06	SUB-N1	833.3	229.67	62.3	normal	simulator
2026-11-01 13:33:57.765748+06	LOAD-N1	498.5	131.92	80.4	normal	simulator
2026-11-01 13:33:57.765748+06	LOAD-N2	339.4	132.08	70.7	normal	simulator
2026-11-01 13:33:57.765748+06	GEN-E1	855.7	230.63	79.1	normal	simulator
2026-11-01 13:33:57.765748+06	SUB-E1	771.3	230.5	64.4	normal	simulator
2026-11-01 13:33:57.765748+06	LOAD-E1	475.9	132.12	83.5	normal	simulator
2026-11-01 13:33:57.765748+06	LOAD-E2	300.1	131.43	66.7	normal	simulator
2026-11-01 12:46:57.704511+06	GEN-S1	1143.2	229.97	80.5	normal	simulator
2026-11-01 12:46:57.704511+06	SUB-S1	827.3	229.82	68.5	normal	simulator
2026-11-01 12:46:57.704511+06	LOAD-S1	491.7	132.05	80.6	normal	simulator
2026-11-01 12:46:57.704511+06	LOAD-S2	330.9	132.21	70.4	normal	simulator
2026-11-01 12:47:58.039614+06	GEN-N1	958.6	229.53	78.2	normal	simulator
2026-11-01 12:47:58.039614+06	SUB-N1	839.6	230.52	60.9	normal	simulator
2026-11-01 12:47:58.039614+06	LOAD-N1	489.2	132.09	78.9	normal	simulator
2026-11-01 12:47:58.039614+06	LOAD-N2	334.6	132.49	69.7	normal	simulator
2026-11-01 12:47:58.039614+06	GEN-E1	860	230.67	78.7	normal	simulator
2026-11-01 12:47:58.039614+06	SUB-E1	774.2	229.38	64.9	normal	simulator
2026-11-01 12:47:58.039614+06	LOAD-E1	458.3	131.46	80.4	normal	simulator
2026-11-01 12:47:58.039614+06	LOAD-E2	311.4	132.07	69.2	normal	simulator
2026-11-01 12:47:58.039614+06	GEN-C1	1046.1	229.79	81.5	normal	simulator
2026-11-01 12:47:58.039614+06	SUB-C1	953.7	229.52	70.6	normal	simulator
2026-11-01 12:47:58.039614+06	LOAD-C1	672.6	130.73	88.5	warning	simulator
2026-11-01 12:47:58.039614+06	LOAD-C2	287.8	131.75	73.8	normal	simulator
2026-11-01 12:47:58.039614+06	GEN-W1	700.3	230.61	78.9	normal	simulator
2026-11-01 12:47:58.039614+06	SUB-W1	848.5	230.03	65.7	normal	simulator
2026-11-01 12:47:58.039614+06	LOAD-W1	405	131.56	75	normal	simulator
2026-11-01 12:47:58.039614+06	LOAD-W2	423.8	131.18	81.5	normal	simulator
2026-11-01 12:47:58.039614+06	GEN-S1	1165.9	229.53	81.2	normal	simulator
2026-11-01 12:47:58.039614+06	SUB-S1	830	230.55	71.1	normal	simulator
2026-11-01 12:47:58.039614+06	LOAD-S1	497.8	131.8	81.6	normal	simulator
2026-11-01 12:47:58.039614+06	LOAD-S2	335.1	131.88	71.3	normal	simulator
2026-11-01 12:48:58.333971+06	GEN-N1	963	229.34	79.2	normal	simulator
2026-11-01 12:48:58.333971+06	SUB-N1	842.4	230.67	63.6	normal	simulator
2026-11-01 12:48:58.333971+06	LOAD-N1	481.7	132.01	77.7	normal	simulator
2026-11-01 12:48:58.333971+06	LOAD-N2	340.3	132.56	70.9	normal	simulator
2026-11-01 12:48:58.333971+06	GEN-E1	880.5	230.36	79.3	normal	simulator
2026-11-01 12:48:58.333971+06	SUB-E1	786.7	230.03	64.3	normal	simulator
2026-11-01 12:48:58.333971+06	LOAD-E1	475.4	131.92	83.4	normal	simulator
2026-11-01 12:48:58.333971+06	LOAD-E2	311.4	132.18	69.2	normal	simulator
2026-11-01 12:48:58.333971+06	GEN-C1	1078.2	229.37	81.2	normal	simulator
2026-11-01 12:48:58.333971+06	SUB-C1	944.4	230.52	72.8	normal	simulator
2026-11-01 12:48:58.333971+06	LOAD-C1	671.1	130.61	88.3	warning	simulator
2026-11-01 12:48:58.333971+06	LOAD-C2	295.2	131.7	75.7	normal	simulator
2026-11-01 12:48:58.333971+06	GEN-W1	689.7	230.1	80.7	normal	simulator
2026-11-01 12:48:58.333971+06	SUB-W1	839.9	229.71	66.9	normal	simulator
2026-11-01 12:48:58.333971+06	LOAD-W1	412.6	131.93	76.4	normal	simulator
2026-11-01 12:48:58.333971+06	LOAD-W2	422.2	132.16	81.2	normal	simulator
2026-11-01 12:48:58.333971+06	GEN-S1	1179.8	229.56	81.6	normal	simulator
2026-11-01 12:48:58.333971+06	SUB-S1	822.2	230.43	68.5	normal	simulator
2026-11-01 12:48:58.333971+06	LOAD-S1	493.5	132.06	80.9	normal	simulator
2026-11-01 12:48:58.333971+06	LOAD-S2	337.5	131.59	71.8	normal	simulator
2026-11-01 12:49:58.685849+06	GEN-N1	982	230	81	normal	simulator
2026-11-01 12:49:58.685849+06	SUB-N1	831.8	230.34	62.7	normal	simulator
2026-11-01 12:49:58.685849+06	LOAD-N1	495.4	132.1	79.9	normal	simulator
2026-11-01 12:49:58.685849+06	LOAD-N2	348.5	132.25	72.6	normal	simulator
2026-11-01 12:49:58.685849+06	GEN-E1	882.8	229.21	81.6	normal	simulator
2026-11-01 12:49:58.685849+06	SUB-E1	766.7	230.56	63.7	normal	simulator
2026-11-01 12:49:58.685849+06	LOAD-E1	471.4	131.29	82.7	normal	simulator
2026-11-01 12:49:58.685849+06	LOAD-E2	304.6	131.92	67.7	normal	simulator
2026-11-01 12:49:58.685849+06	GEN-C1	1077.9	230.07	79.8	normal	simulator
2026-11-01 12:49:58.685849+06	SUB-C1	956	229.5	73.7	normal	simulator
2026-11-01 12:49:58.685849+06	LOAD-C1	671.1	131.47	88.3	warning	simulator
2026-11-01 12:49:58.685849+06	LOAD-C2	284.7	132.66	73	normal	simulator
2026-11-01 12:49:58.685849+06	GEN-W1	708	230.13	80	normal	simulator
2026-11-01 12:49:58.685849+06	SUB-W1	842.2	229.55	66.9	normal	simulator
2026-11-01 12:49:58.685849+06	LOAD-W1	402.3	131.81	74.5	normal	simulator
2026-11-01 12:49:58.685849+06	LOAD-W2	429	131.92	82.5	normal	simulator
2026-11-01 12:49:58.685849+06	GEN-S1	1162.1	230.28	78.5	normal	simulator
2026-11-01 12:49:58.685849+06	SUB-S1	832	229.43	70.1	normal	simulator
2026-11-01 12:49:58.685849+06	LOAD-S1	495.3	132.25	81.2	normal	simulator
2026-11-01 12:49:58.685849+06	LOAD-S2	330.4	131.9	70.3	normal	simulator
2026-11-01 12:50:59.032616+06	GEN-N1	996	229.92	80.9	normal	simulator
2026-11-01 12:50:59.032616+06	SUB-N1	820.7	230.49	60.5	normal	simulator
2026-11-01 12:50:59.032616+06	LOAD-N1	479.9	132.58	77.4	normal	simulator
2026-11-01 12:50:59.032616+06	LOAD-N2	348.5	131.42	72.6	normal	simulator
2026-11-01 12:50:59.032616+06	GEN-E1	858.9	229.35	79.5	normal	simulator
2026-11-01 12:50:59.032616+06	SUB-E1	786.7	230.32	65.1	normal	simulator
2026-11-01 12:50:59.032616+06	LOAD-E1	466.8	131.55	81.9	normal	simulator
2026-11-01 12:50:59.032616+06	LOAD-E2	304.2	132.5	67.6	normal	simulator
2026-11-01 12:50:59.032616+06	GEN-C1	1053.7	229.53	78.6	normal	simulator
2026-11-01 12:50:59.032616+06	SUB-C1	965.3	229.36	72.8	normal	simulator
2026-11-01 12:50:59.032616+06	LOAD-C1	660.4	130.76	86.9	warning	simulator
2026-11-01 12:50:59.032616+06	LOAD-C2	290.6	131.88	74.5	normal	simulator
2026-11-01 12:50:59.032616+06	GEN-W1	691.5	229.8	80	normal	simulator
2026-11-01 12:50:59.032616+06	SUB-W1	841.7	229.98	65.6	normal	simulator
2026-11-01 12:50:59.032616+06	LOAD-W1	402.3	131.52	74.5	normal	simulator
2026-11-01 12:50:59.032616+06	LOAD-W2	432.6	131.97	83.2	normal	simulator
2026-11-01 12:50:59.032616+06	GEN-S1	1204.2	230.17	80.4	normal	simulator
2026-11-01 12:50:59.032616+06	SUB-S1	825.1	230.05	69	normal	simulator
2026-11-01 12:50:59.032616+06	LOAD-S1	497.8	132.39	81.6	normal	simulator
2026-11-01 12:50:59.032616+06	LOAD-S2	332.8	132.57	70.8	normal	simulator
2026-11-01 12:51:59.359039+06	GEN-N1	953.8	229.46	79.4	normal	simulator
2026-11-01 12:51:59.359039+06	SUB-N1	825.8	229.64	62.5	normal	simulator
2026-11-01 12:51:59.359039+06	LOAD-N1	489.8	132.16	79	normal	simulator
2026-11-01 12:51:59.359039+06	LOAD-N2	332.6	131.41	69.3	normal	simulator
2026-11-01 12:51:59.359039+06	GEN-E1	848.5	229.98	81.7	normal	simulator
2026-11-01 12:51:59.359039+06	SUB-E1	760.9	230.21	64.8	normal	simulator
2026-11-01 12:51:59.359039+06	LOAD-E1	476.5	132.08	83.6	normal	simulator
2026-11-01 12:51:59.359039+06	LOAD-E2	308.7	132.04	68.6	normal	simulator
2026-11-01 12:51:59.359039+06	GEN-C1	1029.4	230.15	81.3	normal	simulator
2026-11-01 12:51:59.359039+06	SUB-C1	972.8	230.39	73.5	normal	simulator
2026-11-01 12:51:59.359039+06	LOAD-C1	664.2	131.02	87.4	warning	simulator
2026-11-01 12:51:59.359039+06	LOAD-C2	284.3	132.06	72.9	normal	simulator
2026-11-01 12:51:59.359039+06	GEN-W1	706.7	230.49	80.2	normal	simulator
2026-11-01 12:51:59.359039+06	SUB-W1	840.2	230.19	67.8	normal	simulator
2026-11-01 12:51:59.359039+06	LOAD-W1	414.7	132.24	76.8	normal	simulator
2026-11-01 12:51:59.359039+06	LOAD-W2	426.9	132.38	82.1	normal	simulator
2026-11-01 12:51:59.359039+06	GEN-S1	1195.9	230.15	81.6	normal	simulator
2026-11-01 12:51:59.359039+06	SUB-S1	813.6	229.75	70.5	normal	simulator
2026-11-01 12:51:59.359039+06	LOAD-S1	499	132.08	81.8	normal	simulator
2026-11-01 12:51:59.359039+06	LOAD-S2	338.4	132.18	72	normal	simulator
2026-11-01 12:57:52.059493+06	GEN-N1	983.7	229.85	80.2	normal	simulator
2026-11-01 12:57:52.059493+06	SUB-N1	844.1	230.09	62.2	normal	simulator
2026-11-01 12:57:52.059493+06	LOAD-N1	493.5	132.47	79.6	normal	simulator
2026-11-01 12:57:52.059493+06	LOAD-N2	340.3	132.15	70.9	normal	simulator
2026-11-01 12:57:52.059493+06	GEN-E1	873.4	229.45	80.1	normal	simulator
2026-11-01 12:57:52.059493+06	SUB-E1	767.7	230.56	65.6	normal	simulator
2026-11-01 12:57:52.059493+06	LOAD-E1	474.2	131.52	83.2	normal	simulator
2026-11-01 12:57:52.059493+06	LOAD-E2	305.6	131.4	67.9	normal	simulator
2026-11-01 12:57:52.059493+06	GEN-C1	1049.1	229.64	81	normal	simulator
2026-11-01 12:57:52.059493+06	SUB-C1	957.3	230.03	72.9	normal	simulator
2026-11-01 12:57:52.059493+06	LOAD-C1	679.4	130.77	89.4	warning	simulator
2026-11-01 12:57:52.059493+06	LOAD-C2	294.8	132.26	75.6	normal	simulator
2026-11-01 12:57:52.059493+06	GEN-W1	700.3	230.26	81.4	normal	simulator
2026-11-01 12:57:52.059493+06	SUB-W1	841.3	229.82	66.6	normal	simulator
2026-11-01 12:57:52.059493+06	LOAD-W1	407.2	131.5	75.4	normal	simulator
2026-11-01 12:57:52.059493+06	LOAD-W2	431.6	131.82	83	normal	simulator
2026-11-01 12:57:52.059493+06	GEN-S1	1143.4	230.25	80.2	normal	simulator
2026-11-01 12:57:52.059493+06	SUB-S1	831.6	229.38	69.1	normal	simulator
2026-11-01 12:57:52.059493+06	LOAD-S1	482.5	131.62	79.1	normal	simulator
2026-11-01 12:57:52.059493+06	LOAD-S2	345	132.21	73.4	normal	simulator
2026-11-01 12:58:11.537069+06	GEN-N1	274.2	229.98	78.4	normal	simulator
2026-11-01 12:58:11.537069+06	SUB-N1	1033.9	229.38	62	normal	simulator
2026-11-01 12:58:11.537069+06	LOAD-N1	482.4	132.3	77.8	normal	simulator
2026-11-01 12:58:11.537069+06	LOAD-N2	333.1	131.51	69.4	normal	simulator
2026-11-01 12:58:11.537069+06	GEN-E1	839	230.3	79.8	normal	simulator
2026-11-01 12:58:11.537069+06	SUB-E1	951.1	230.01	66.1	normal	simulator
2026-11-01 12:58:11.537069+06	LOAD-E1	470.2	131.75	82.5	normal	simulator
2026-11-01 12:58:11.537069+06	LOAD-E2	305.1	132.53	67.8	normal	simulator
2026-11-01 12:58:11.537069+06	GEN-C1	1019.5	229.9	79.1	normal	simulator
2026-11-01 12:58:11.537069+06	SUB-C1	1115.7	229.82	73.6	normal	simulator
2026-11-01 12:58:11.537069+06	LOAD-C1	660.4	131.62	86.9	warning	simulator
2026-11-01 12:58:11.537069+06	LOAD-C2	291.3	132.03	74.7	normal	simulator
2026-11-01 12:58:11.537069+06	GEN-W1	202.2	229.6	81.3	normal	simulator
2026-11-01 12:58:11.537069+06	SUB-W1	1018.4	230.22	65.3	normal	simulator
2026-11-01 12:58:11.537069+06	LOAD-W1	401.8	132.53	74.4	normal	simulator
2026-11-01 12:58:11.537069+06	LOAD-W2	436.3	130.93	83.9	normal	simulator
2026-11-01 12:58:11.537069+06	GEN-S1	1145.4	229.73	79.3	normal	simulator
2026-11-01 12:58:11.537069+06	SUB-S1	1006	229.42	68.4	normal	simulator
2026-11-01 12:58:11.537069+06	LOAD-S1	497.1	132.42	81.5	normal	simulator
2026-11-01 12:58:11.537069+06	LOAD-S2	338.4	131.63	72	normal	simulator
2026-11-01 13:20:08.617741+06	GEN-N1	953.2	229.4	78.4	normal	simulator
2026-11-01 13:20:08.617741+06	SUB-N1	826.3	229.98	63	normal	simulator
2026-11-01 13:20:08.617741+06	LOAD-N1	487.3	131.33	78.6	normal	simulator
2026-11-01 13:20:08.617741+06	LOAD-N2	347.5	131.55	72.4	normal	simulator
2026-11-01 13:20:08.617741+06	GEN-E1	835.6	230.02	81.3	normal	simulator
2026-11-01 13:20:08.617741+06	SUB-E1	771.4	229.98	65.5	normal	simulator
2026-11-01 13:20:08.617741+06	LOAD-E1	474.2	131.6	83.2	normal	simulator
2026-11-01 13:20:08.617741+06	LOAD-E2	302.4	132.62	67.2	normal	simulator
2026-11-01 13:20:08.617741+06	GEN-C1	1034.2	230.39	80.1	normal	simulator
2026-11-01 13:20:08.617741+06	SUB-C1	969.6	230.36	71.8	normal	simulator
2026-11-01 13:20:08.617741+06	LOAD-C1	655.1	131.19	86.2	warning	simulator
2026-11-01 13:20:08.617741+06	LOAD-C2	292.5	131.65	75	normal	simulator
2026-11-01 13:20:08.617741+06	GEN-W1	708.7	229.82	79.7	normal	simulator
2026-11-01 13:20:08.617741+06	SUB-W1	839.9	230.16	66.9	normal	simulator
2026-11-01 13:20:08.617741+06	LOAD-W1	407.7	131.8	75.5	normal	simulator
2026-11-01 13:20:08.617741+06	LOAD-W2	426.9	131.59	82.1	normal	simulator
2026-11-01 13:20:08.617741+06	GEN-S1	1198.7	229.96	81.4	normal	simulator
2026-11-01 13:20:08.617741+06	SUB-S1	834.5	230.67	70.2	normal	simulator
2026-11-01 13:20:08.617741+06	LOAD-S1	481.3	131.94	78.9	normal	simulator
2026-11-01 13:20:08.617741+06	LOAD-S2	341.2	131.78	72.6	normal	simulator
2026-11-01 13:21:08.882504+06	GEN-N1	966.4	229.45	81	normal	simulator
2026-11-01 13:21:08.882504+06	SUB-N1	831.9	230.46	63	normal	simulator
2026-11-01 13:21:08.882504+06	LOAD-N1	486.7	131.81	78.5	normal	simulator
2026-11-01 13:21:08.882504+06	LOAD-N2	342.7	132.52	71.4	normal	simulator
2026-11-01 13:21:08.882504+06	GEN-E1	869.7	229.7	79.2	normal	simulator
2026-11-01 13:21:08.882504+06	SUB-E1	782.1	229.59	66	normal	simulator
2026-11-01 13:21:08.882504+06	LOAD-E1	469.1	132.31	82.3	normal	simulator
2026-11-01 13:21:08.882504+06	LOAD-E2	308.7	132.22	68.6	normal	simulator
2026-11-01 13:21:08.882504+06	GEN-C1	1060.8	229.65	80.7	normal	simulator
2026-11-01 13:21:08.882504+06	SUB-C1	956.6	229.63	71.8	normal	simulator
2026-11-01 13:21:08.882504+06	LOAD-C1	676.4	131.37	89	warning	simulator
2026-11-01 13:21:08.882504+06	LOAD-C2	286.3	131.52	73.4	normal	simulator
2026-11-01 12:52:59.644751+06	GEN-N1	985.5	229.29	81.7	normal	simulator
2026-11-01 12:52:59.644751+06	SUB-N1	824.3	230.09	61.9	normal	simulator
2026-11-01 12:52:59.644751+06	LOAD-N1	501	132.11	80.8	normal	simulator
2026-11-01 12:52:59.644751+06	LOAD-N2	337	131.42	70.2	normal	simulator
2026-11-01 12:52:59.644751+06	GEN-E1	851.1	229.88	78.6	normal	simulator
2026-11-01 12:52:59.644751+06	SUB-E1	766.2	229.39	63.4	normal	simulator
2026-11-01 12:52:59.644751+06	LOAD-E1	461.7	131.85	81	normal	simulator
2026-11-01 12:52:59.644751+06	LOAD-E2	312.3	132.43	69.4	normal	simulator
2026-11-01 12:52:59.644751+06	GEN-C1	1034.2	229.56	81	normal	simulator
2026-11-01 12:52:59.644751+06	SUB-C1	944.1	229.57	73.1	normal	simulator
2026-11-01 12:52:59.644751+06	LOAD-C1	677.2	130.44	89.1	warning	simulator
2026-11-01 12:52:59.644751+06	LOAD-C2	293.7	132.55	75.3	normal	simulator
2026-11-01 12:52:59.644751+06	GEN-W1	685.9	230.17	79.1	normal	simulator
2026-11-01 12:52:59.644751+06	SUB-W1	841.6	230.62	67.9	normal	simulator
2026-11-01 12:52:59.644751+06	LOAD-W1	412.6	131.63	76.4	normal	simulator
2026-11-01 12:52:59.644751+06	LOAD-W2	433.2	131.83	83.3	normal	simulator
2026-11-01 12:52:59.644751+06	GEN-S1	1192	230.48	80.7	normal	simulator
2026-11-01 12:52:59.644751+06	SUB-S1	833	230.02	70.9	normal	simulator
2026-11-01 12:52:59.644751+06	LOAD-S1	480.1	132.25	78.7	normal	simulator
2026-11-01 12:52:59.644751+06	LOAD-S2	345.4	132.3	73.5	normal	simulator
2026-11-01 12:53:59.977085+06	GEN-N1	973.6	229.8	80.8	normal	simulator
2026-11-01 12:53:59.977085+06	SUB-N1	835.4	230.36	61.1	normal	simulator
2026-11-01 12:53:59.977085+06	LOAD-N1	499.7	131.59	80.6	normal	simulator
2026-11-01 12:53:59.977085+06	LOAD-N2	339.4	131.31	70.7	normal	simulator
2026-11-01 12:53:59.977085+06	GEN-E1	869.8	230.36	79.2	normal	simulator
2026-11-01 12:53:59.977085+06	SUB-E1	763.7	230.09	65.3	normal	simulator
2026-11-01 12:53:59.977085+06	LOAD-E1	472	131.79	82.8	normal	simulator
2026-11-01 12:53:59.977085+06	LOAD-E2	309.1	132.59	68.7	normal	simulator
2026-11-01 12:53:59.977085+06	GEN-C1	1049.3	230.07	78.4	normal	simulator
2026-11-01 12:53:59.977085+06	SUB-C1	955.2	230.55	72.4	normal	simulator
2026-11-01 12:53:59.977085+06	LOAD-C1	669.6	131.45	88.1	warning	simulator
2026-11-01 12:53:59.977085+06	LOAD-C2	290.9	131.89	74.6	normal	simulator
2026-11-01 12:53:59.977085+06	GEN-W1	709.1	229.25	81.3	normal	simulator
2026-11-01 12:53:59.977085+06	SUB-W1	845.5	230.04	67.3	normal	simulator
2026-11-01 12:53:59.977085+06	LOAD-W1	407.7	132.37	75.5	normal	simulator
2026-11-01 12:53:59.977085+06	LOAD-W2	429.5	132.25	82.6	normal	simulator
2026-11-01 12:53:59.977085+06	GEN-S1	1204.7	230.03	79.6	normal	simulator
2026-11-01 12:53:59.977085+06	SUB-S1	811.1	230.06	71	normal	simulator
2026-11-01 12:53:59.977085+06	LOAD-S1	488.6	132.16	80.1	normal	simulator
2026-11-01 12:53:59.977085+06	LOAD-S2	340.8	132.38	72.5	normal	simulator
2026-11-01 12:55:00.341597+06	GEN-N1	988.2	230.33	79.7	normal	simulator
2026-11-01 12:55:00.341597+06	SUB-N1	842.9	230.31	63.6	normal	simulator
2026-11-01 12:55:00.341597+06	LOAD-N1	484.8	131.49	78.2	normal	simulator
2026-11-01 12:55:00.341597+06	LOAD-N2	344.6	132.33	71.8	normal	simulator
2026-11-01 12:55:00.341597+06	GEN-E1	883.8	230.07	80.4	normal	simulator
2026-11-01 12:55:00.341597+06	SUB-E1	763.1	229.39	66.2	normal	simulator
2026-11-01 12:55:00.341597+06	LOAD-E1	457.1	132.04	80.2	normal	simulator
2026-11-01 12:55:00.341597+06	LOAD-E2	314.1	131.59	69.8	normal	simulator
2026-11-01 12:55:00.341597+06	GEN-C1	1059.8	229.61	79	normal	simulator
2026-11-01 12:55:00.341597+06	SUB-C1	939.7	229.62	72	normal	simulator
2026-11-01 12:55:00.341597+06	LOAD-C1	680.2	130.73	89.5	warning	simulator
2026-11-01 12:55:00.341597+06	LOAD-C2	282.4	132.1	72.4	normal	simulator
2026-11-01 12:55:00.341597+06	GEN-W1	691.5	230.04	80.7	normal	simulator
2026-11-01 12:55:00.341597+06	SUB-W1	834.4	229.47	65.7	normal	simulator
2026-11-01 12:55:00.341597+06	LOAD-W1	405.5	132.56	75.1	normal	simulator
2026-11-01 12:55:00.341597+06	LOAD-W2	435.2	131.67	83.7	normal	simulator
2026-11-01 12:55:00.341597+06	GEN-S1	1161.1	230.23	78.7	normal	simulator
2026-11-01 12:55:00.341597+06	SUB-S1	817.5	229.84	70	normal	simulator
2026-11-01 12:55:00.341597+06	LOAD-S1	484.3	132.14	79.4	normal	simulator
2026-11-01 12:55:00.341597+06	LOAD-S2	335.1	132.49	71.3	normal	simulator
2026-11-01 12:56:00.691879+06	GEN-N1	947.8	229.9	79.3	normal	simulator
2026-11-01 12:56:00.691879+06	SUB-N1	832.1	229.65	61.6	normal	simulator
2026-11-01 12:56:00.691879+06	LOAD-N1	488.6	131.86	78.8	normal	simulator
2026-11-01 12:56:00.691879+06	LOAD-N2	339.4	131.64	70.7	normal	simulator
2026-11-01 12:56:00.691879+06	GEN-E1	832.1	229.51	79	normal	simulator
2026-11-01 12:56:00.691879+06	SUB-E1	788.4	230.65	63.4	normal	simulator
2026-11-01 12:56:00.691879+06	LOAD-E1	472	131.78	82.8	normal	simulator
2026-11-01 12:56:00.691879+06	LOAD-E2	306	131.49	68	normal	simulator
2026-11-01 12:56:00.691879+06	GEN-C1	1085.9	229.48	80.4	normal	simulator
2026-11-01 12:56:00.691879+06	SUB-C1	971.6	229.95	71.6	normal	simulator
2026-11-01 12:56:00.691879+06	LOAD-C1	659.7	131.6	86.8	warning	simulator
2026-11-01 12:56:00.691879+06	LOAD-C2	287.8	132.49	73.8	normal	simulator
2026-11-01 12:56:00.691879+06	GEN-W1	690.4	230.15	78.8	normal	simulator
2026-11-01 12:56:00.691879+06	SUB-W1	838.8	230.66	67.2	normal	simulator
2026-11-01 12:56:00.691879+06	LOAD-W1	418	132.56	77.4	normal	simulator
2026-11-01 12:56:00.691879+06	LOAD-W2	428	131.78	82.3	normal	simulator
2026-11-01 12:56:00.691879+06	GEN-S1	1132.5	229.63	78.2	normal	simulator
2026-11-01 12:56:00.691879+06	SUB-S1	826.6	229.82	70.9	normal	simulator
2026-11-01 12:56:00.691879+06	LOAD-S1	494.1	131.43	81	normal	simulator
2026-11-01 12:56:00.691879+06	LOAD-S2	339.8	131.46	72.3	normal	simulator
2026-11-01 12:57:00.988286+06	GEN-N1	985.5	230.41	81.1	normal	simulator
2026-11-01 12:57:00.988286+06	SUB-N1	829.7	230.07	61.4	normal	simulator
2026-11-01 12:57:00.988286+06	LOAD-N1	487.9	131.5	78.7	normal	simulator
2026-11-01 12:57:00.988286+06	LOAD-N2	343.2	132.55	71.5	normal	simulator
2026-11-01 12:57:00.988286+06	GEN-E1	850.7	230.54	79.9	normal	simulator
2026-11-01 12:57:00.988286+06	SUB-E1	771.5	230.09	65.5	normal	simulator
2026-11-01 12:57:00.988286+06	LOAD-E1	473.1	131.64	83	normal	simulator
2026-11-01 12:57:00.988286+06	LOAD-E2	305.1	132.62	67.8	normal	simulator
2026-11-01 12:57:00.988286+06	GEN-C1	1022.9	230.63	80.6	normal	simulator
2026-11-01 12:57:00.988286+06	SUB-C1	960.5	229.59	73.7	normal	simulator
2026-11-01 12:57:00.988286+06	LOAD-C1	661.2	130.67	87	warning	simulator
2026-11-01 12:57:00.988286+06	LOAD-C2	293.3	131.37	75.2	normal	simulator
2026-11-01 12:57:00.988286+06	GEN-W1	686.2	229.65	80.4	normal	simulator
2026-11-01 12:57:00.988286+06	SUB-W1	829.2	229.69	66	normal	simulator
2026-11-01 12:57:00.988286+06	LOAD-W1	413.1	132.52	76.5	normal	simulator
2026-11-01 12:57:00.988286+06	LOAD-W2	435.2	131.72	83.7	normal	simulator
2026-11-01 12:57:00.988286+06	GEN-S1	1206.5	229.39	81.1	normal	simulator
2026-11-01 12:57:00.988286+06	SUB-S1	831	229.6	69.6	normal	simulator
2026-11-01 12:57:00.988286+06	LOAD-S1	493.5	131.28	80.9	normal	simulator
2026-11-01 12:57:00.988286+06	LOAD-S2	337	131.66	71.7	normal	simulator
2026-11-01 12:58:01.342176+06	GEN-N1	1000.3	229.72	79.1	normal	simulator
2026-11-01 12:58:01.342176+06	SUB-N1	823.8	230.49	60.7	normal	simulator
2026-11-01 12:58:01.342176+06	LOAD-N1	479.9	132.36	77.4	normal	simulator
2026-11-01 12:58:01.342176+06	LOAD-N2	337.4	131.65	70.3	normal	simulator
2026-11-01 12:58:01.342176+06	GEN-E1	847	229.38	81.1	normal	simulator
2026-11-01 12:58:01.342176+06	SUB-E1	767.7	230.17	65.9	normal	simulator
2026-11-01 12:58:01.342176+06	LOAD-E1	472	131.53	82.8	normal	simulator
2026-11-01 12:58:01.342176+06	LOAD-E2	313.6	131.45	69.7	normal	simulator
2026-11-01 12:58:01.342176+06	GEN-C1	1042.3	230.05	79.7	normal	simulator
2026-11-01 12:58:01.342176+06	SUB-C1	955.8	229.56	72.5	normal	simulator
2026-11-01 12:58:01.342176+06	LOAD-C1	666.5	130.5	87.7	warning	simulator
2026-11-01 12:58:01.342176+06	LOAD-C2	294.1	131.46	75.4	normal	simulator
2026-11-01 12:58:01.342176+06	GEN-W1	679.7	229.66	80.1	normal	simulator
2026-11-01 12:58:01.342176+06	SUB-W1	849.5	229.75	67.8	normal	simulator
2026-11-01 12:58:01.342176+06	LOAD-W1	409.3	132.32	75.8	normal	simulator
2026-11-01 12:58:01.342176+06	LOAD-W2	436.3	131.98	83.9	normal	simulator
2026-11-01 12:58:01.342176+06	GEN-S1	1167.6	229.46	80.2	normal	simulator
2026-11-01 12:58:01.342176+06	SUB-S1	820.8	230.47	68.5	normal	simulator
2026-11-01 12:58:01.342176+06	LOAD-S1	488	131.64	80	normal	simulator
2026-11-01 12:58:01.342176+06	LOAD-S2	343.6	131.48	73.1	normal	simulator
2026-11-01 12:58:06.001849+06	GEN-N1	1000.6	229.64	81.7	normal	simulator
2026-11-01 12:58:06.001849+06	SUB-N1	950.1	230.48	62.2	normal	simulator
2026-11-01 12:58:06.001849+06	LOAD-N1	590.9	130.9	95.3	critical	simulator
2026-11-01 12:58:06.001849+06	LOAD-N2	426.7	131.26	88.9	warning	simulator
2026-11-01 12:58:06.001849+06	GEN-E1	838.5	229.32	79.1	normal	simulator
2026-11-01 12:58:06.001849+06	SUB-E1	897.2	229.98	63.6	normal	simulator
2026-11-01 12:58:06.001849+06	LOAD-E1	570	129.36	100	critical	simulator
2026-11-01 12:58:06.001849+06	LOAD-E2	387.9	131.91	86.2	warning	simulator
2026-11-01 12:58:06.001849+06	GEN-C1	1023.1	229.84	78.4	normal	simulator
2026-11-01 12:58:06.001849+06	SUB-C1	1067.8	230.59	71.7	normal	simulator
2026-11-01 12:58:06.001849+06	LOAD-C1	760	129.24	100	critical	simulator
2026-11-01 12:58:06.001849+06	LOAD-C2	352.2	130.9	90.3	warning	simulator
2026-11-01 12:58:06.001849+06	GEN-W1	714.9	230.41	81.7	normal	simulator
2026-11-01 12:58:06.001849+06	SUB-W1	958.7	229.66	65.6	normal	simulator
2026-11-01 12:58:06.001849+06	LOAD-W1	506.5	130.97	93.8	warning	simulator
2026-11-01 12:58:06.001849+06	LOAD-W2	520	129.42	100	critical	simulator
2026-11-01 12:58:06.001849+06	GEN-S1	1179.7	229.86	81	normal	simulator
2026-11-01 12:58:06.001849+06	SUB-S1	933.7	230.06	69.6	normal	simulator
2026-11-01 12:58:06.001849+06	LOAD-S1	605.7	129.61	99.3	critical	simulator
2026-11-01 12:58:06.001849+06	LOAD-S2	429.1	130.6	91.3	warning	simulator
2026-11-01 13:21:08.882504+06	GEN-W1	707	229.95	81	normal	simulator
2026-11-01 13:21:08.882504+06	SUB-W1	840.2	229.98	68.5	normal	simulator
2026-11-01 13:21:08.882504+06	LOAD-W1	412.6	131.6	76.4	normal	simulator
2026-11-01 13:21:08.882504+06	LOAD-W2	439.9	130.82	84.6	normal	simulator
2026-11-01 13:21:08.882504+06	GEN-S1	1137	229.57	79.5	normal	simulator
2026-11-01 13:21:08.882504+06	SUB-S1	833.7	230.28	71.6	normal	simulator
2026-11-01 13:21:08.882504+06	LOAD-S1	480.1	132.42	78.7	normal	simulator
2026-11-01 13:21:08.882504+06	LOAD-S2	342.6	132.64	72.9	normal	simulator
2026-11-01 13:27:45.816883+06	GEN-N1	271.5	230.26	79.9	normal	simulator
2026-11-01 13:27:45.816883+06	SUB-N1	833.3	229.67	62.3	normal	simulator
2026-11-01 13:27:45.816883+06	LOAD-N1	498.5	131.92	80.4	normal	simulator
2026-11-01 13:27:45.816883+06	LOAD-N2	339.4	132.08	70.7	normal	simulator
2026-11-01 13:27:45.816883+06	GEN-E1	855.7	230.63	79.1	normal	simulator
2026-11-01 13:27:45.816883+06	SUB-E1	771.3	230.5	64.4	normal	simulator
2026-11-01 13:27:45.816883+06	LOAD-E1	475.9	132.12	83.5	normal	simulator
2026-11-01 13:27:45.816883+06	LOAD-E2	300.1	131.43	66.7	normal	simulator
2026-11-01 13:27:45.816883+06	GEN-C1	1067.5	229.57	80.6	normal	simulator
2026-11-01 13:27:45.816883+06	SUB-C1	949.6	229.57	70.7	normal	simulator
2026-11-01 13:27:45.816883+06	LOAD-C1	658.9	130.68	86.7	warning	simulator
2026-11-01 13:27:45.816883+06	LOAD-C2	290.9	132.18	74.6	normal	simulator
2026-11-01 13:27:45.816883+06	GEN-W1	202.5	229.83	80.8	normal	simulator
2026-11-01 13:27:45.816883+06	SUB-W1	842.8	229.45	66.9	normal	simulator
2026-11-01 13:27:45.816883+06	LOAD-W1	411.5	131.65	76.2	normal	simulator
2026-11-01 13:27:45.816883+06	LOAD-W2	436.3	131.97	83.9	normal	simulator
2026-11-01 13:27:45.816883+06	GEN-S1	1179.2	229.56	80.7	normal	simulator
2026-11-01 13:27:45.816883+06	SUB-S1	809.8	230.52	69.9	normal	simulator
2026-11-01 13:27:45.816883+06	LOAD-S1	486.2	131.36	79.7	normal	simulator
2026-11-01 13:27:45.816883+06	LOAD-S2	344.5	131.84	73.3	normal	simulator
2026-11-01 13:32:43.553263+06	GEN-N1	1002	230.27	79	normal	simulator
2026-11-01 13:32:43.553263+06	SUB-N1	839.1	230.63	62.8	normal	simulator
2026-11-01 13:32:43.553263+06	LOAD-N1	499.1	131.3	80.5	normal	simulator
2026-11-01 13:32:43.553263+06	LOAD-N2	344.6	132.43	71.8	normal	simulator
2026-11-01 13:32:43.553263+06	GEN-E1	843.3	229.55	79.7	normal	simulator
2026-11-01 13:32:43.553263+06	SUB-E1	782.4	229.56	65.5	normal	simulator
2026-11-01 13:32:43.553263+06	LOAD-E1	462.8	131.9	81.2	normal	simulator
2026-11-01 13:32:43.553263+06	LOAD-E2	301.5	131.46	67	normal	simulator
2026-11-01 12:58:01.979125+06	GEN-N1	972	229.68	78.8	normal	simulator
2026-11-01 12:58:01.979125+06	SUB-N1	817.3	230.4	62.4	normal	simulator
2026-11-01 12:58:01.979125+06	LOAD-N1	568.5	130.44	91.7	warning	simulator
2026-11-01 12:58:01.979125+06	LOAD-N2	385	132.52	80.2	normal	simulator
2026-11-01 12:58:01.979125+06	GEN-E1	856.7	229.55	78.4	normal	simulator
2026-11-01 12:58:01.979125+06	SUB-E1	785.6	230.54	66	normal	simulator
2026-11-01 12:58:01.979125+06	LOAD-E1	530.1	131.25	93	warning	simulator
2026-11-01 12:58:01.979125+06	LOAD-E2	347.9	132.64	77.3	normal	simulator
2026-11-01 12:58:01.979125+06	GEN-C1	1070.7	230.05	79.3	normal	simulator
2026-11-01 12:58:01.979125+06	SUB-C1	960.6	230.63	70.7	normal	simulator
2026-11-01 12:58:01.979125+06	LOAD-C1	760	129.41	100	critical	simulator
2026-11-01 12:58:01.979125+06	LOAD-C2	336.2	130.84	86.2	warning	simulator
2026-11-01 12:58:01.979125+06	GEN-W1	683.2	230.2	81.3	normal	simulator
2026-11-01 12:58:01.979125+06	SUB-W1	845.6	230.63	67	normal	simulator
2026-11-01 12:58:01.979125+06	LOAD-W1	468.2	130.65	86.7	warning	simulator
2026-11-01 12:58:01.979125+06	LOAD-W2	484.6	129.96	93.2	warning	simulator
2026-11-01 12:58:01.979125+06	GEN-S1	1142.1	229.76	78.5	normal	simulator
2026-11-01 12:58:01.979125+06	SUB-S1	831.6	229.98	69	normal	simulator
2026-11-01 12:58:01.979125+06	LOAD-S1	560	130.75	91.8	warning	simulator
2026-11-01 12:58:01.979125+06	LOAD-S2	396.2	131.44	84.3	normal	simulator
2026-11-01 12:59:01.703461+06	GEN-N1	997.2	230.43	78.6	normal	simulator
2026-11-01 12:59:01.703461+06	SUB-N1	819.1	230.67	63	normal	simulator
2026-11-01 12:59:01.703461+06	LOAD-N1	486.7	131.66	78.5	normal	simulator
2026-11-01 12:59:01.703461+06	LOAD-N2	345.1	131.63	71.9	normal	simulator
2026-11-01 12:59:01.703461+06	GEN-E1	872.4	229.97	79.9	normal	simulator
2026-11-01 12:59:01.703461+06	SUB-E1	777.5	229.49	65.7	normal	simulator
2026-11-01 12:59:01.703461+06	LOAD-E1	458.9	132.13	80.5	normal	simulator
2026-11-01 12:59:01.703461+06	LOAD-E2	303.3	132.34	67.4	normal	simulator
2026-11-01 12:59:01.703461+06	GEN-C1	1035.9	229.34	79.3	normal	simulator
2026-11-01 12:59:01.703461+06	SUB-C1	973	230.27	73.4	normal	simulator
2026-11-01 12:59:01.703461+06	LOAD-C1	675.6	130.62	88.9	warning	simulator
2026-11-01 12:59:01.703461+06	LOAD-C2	291.3	132.07	74.7	normal	simulator
2026-11-01 12:59:01.703461+06	GEN-W1	693.5	230.22	79.1	normal	simulator
2026-11-01 12:59:01.703461+06	SUB-W1	842.9	229.98	65.7	normal	simulator
2026-11-01 12:59:01.703461+06	LOAD-W1	407.2	132.64	75.4	normal	simulator
2026-11-01 12:59:01.703461+06	LOAD-W2	436.3	131.62	83.9	normal	simulator
2026-11-01 12:59:01.703461+06	GEN-S1	1202.5	229.62	80.7	normal	simulator
2026-11-01 12:59:01.703461+06	SUB-S1	826.7	229.82	69.5	normal	simulator
2026-11-01 12:59:01.703461+06	LOAD-S1	486.8	131.48	79.8	normal	simulator
2026-11-01 12:59:01.703461+06	LOAD-S2	339.3	131.84	72.2	normal	simulator
2026-11-01 13:00:02.010344+06	GEN-N1	978.4	230.65	80	normal	simulator
2026-11-01 13:00:02.010344+06	SUB-N1	824.8	230.11	63.8	normal	simulator
2026-11-01 13:00:02.010344+06	LOAD-N1	491.7	132.47	79.3	normal	simulator
2026-11-01 13:00:02.010344+06	LOAD-N2	338.4	131.59	70.5	normal	simulator
2026-11-01 13:00:02.010344+06	GEN-E1	849.6	230.7	79.8	normal	simulator
2026-11-01 13:00:02.010344+06	SUB-E1	775.2	230.46	65.2	normal	simulator
2026-11-01 13:00:02.010344+06	LOAD-E1	471.4	132.1	82.7	normal	simulator
2026-11-01 13:00:02.010344+06	LOAD-E2	304.2	132.6	67.6	normal	simulator
2026-11-01 13:00:02.010344+06	GEN-C1	1064.2	230.35	80.7	normal	simulator
2026-11-01 13:00:02.010344+06	SUB-C1	974.2	229.99	71.8	normal	simulator
2026-11-01 13:00:02.010344+06	LOAD-C1	671.1	130.78	88.3	warning	simulator
2026-11-01 13:00:02.010344+06	LOAD-C2	289.8	131.73	74.3	normal	simulator
2026-11-01 13:00:02.010344+06	GEN-W1	695.6	229.76	81	normal	simulator
2026-11-01 13:00:02.010344+06	SUB-W1	834.2	230.37	67.4	normal	simulator
2026-11-01 13:00:02.010344+06	LOAD-W1	417.4	131.78	77.3	normal	simulator
2026-11-01 13:00:02.010344+06	LOAD-W2	435.8	131	83.8	normal	simulator
2026-11-01 13:00:02.010344+06	GEN-S1	1180.9	230.18	81.2	normal	simulator
2026-11-01 13:00:02.010344+06	SUB-S1	835	230.15	69.1	normal	simulator
2026-11-01 13:00:02.010344+06	LOAD-S1	481.3	132.35	78.9	normal	simulator
2026-11-01 13:00:02.010344+06	LOAD-S2	346.4	131.31	73.7	normal	simulator
2026-11-01 13:01:02.311929+06	GEN-N1	950.6	230.6	79.9	normal	simulator
2026-11-01 13:01:02.311929+06	SUB-N1	845.4	230.35	63	normal	simulator
2026-11-01 13:01:02.311929+06	LOAD-N1	481.1	131.74	77.6	normal	simulator
2026-11-01 13:01:02.311929+06	LOAD-N2	347	131.35	72.3	normal	simulator
2026-11-01 13:01:02.311929+06	GEN-E1	840.8	230	80.5	normal	simulator
2026-11-01 13:01:02.311929+06	SUB-E1	758.4	229.92	65	normal	simulator
2026-11-01 13:01:02.311929+06	LOAD-E1	461.7	131.57	81	normal	simulator
2026-11-01 13:01:02.311929+06	LOAD-E2	299.2	131.44	66.5	normal	simulator
2026-11-01 13:01:02.311929+06	GEN-C1	1039.2	229.82	79.2	normal	simulator
2026-11-01 13:01:02.311929+06	SUB-C1	954.3	230.7	71.6	normal	simulator
2026-11-01 13:01:02.311929+06	LOAD-C1	658.2	130.79	86.6	warning	simulator
2026-11-01 13:01:02.311929+06	LOAD-C2	290.9	132.52	74.6	normal	simulator
2026-11-01 13:01:02.311929+06	GEN-W1	717.6	229.85	80.6	normal	simulator
2026-11-01 13:01:02.311929+06	SUB-W1	832	229.7	67.4	normal	simulator
2026-11-01 13:01:02.311929+06	LOAD-W1	402.3	132.39	74.5	normal	simulator
2026-11-01 13:01:02.311929+06	LOAD-W2	424.8	131.25	81.7	normal	simulator
2026-11-01 13:01:02.311929+06	GEN-S1	1189.4	229.75	81.2	normal	simulator
2026-11-01 13:01:02.311929+06	SUB-S1	824.5	230.63	70.2	normal	simulator
2026-11-01 13:01:02.311929+06	LOAD-S1	484.3	131.56	79.4	normal	simulator
2026-11-01 13:01:02.311929+06	LOAD-S2	340.3	131.73	72.4	normal	simulator
2026-11-01 13:02:02.650356+06	GEN-N1	1004.4	229.37	81.1	normal	simulator
2026-11-01 13:02:02.650356+06	SUB-N1	820.8	229.53	63.1	normal	simulator
2026-11-01 13:02:02.650356+06	LOAD-N1	481.7	131.72	77.7	normal	simulator
2026-11-01 13:02:02.650356+06	LOAD-N2	338.4	132.2	70.5	normal	simulator
2026-11-01 13:02:02.650356+06	GEN-E1	873.8	230.04	81.6	normal	simulator
2026-11-01 13:02:02.650356+06	SUB-E1	773.2	230.31	66.8	normal	simulator
2026-11-01 13:02:02.650356+06	LOAD-E1	458.9	131.29	80.5	normal	simulator
2026-11-01 13:02:02.650356+06	LOAD-E2	297.9	131.62	66.2	normal	simulator
2026-11-01 13:02:02.650356+06	GEN-C1	1020.7	229.96	79.2	normal	simulator
2026-11-01 13:02:02.650356+06	SUB-C1	948.2	230.67	71.8	normal	simulator
2026-11-01 13:02:02.650356+06	LOAD-C1	665	130.82	87.5	warning	simulator
2026-11-01 13:02:02.650356+06	LOAD-C2	286.3	132.3	73.4	normal	simulator
2026-11-01 13:02:02.650356+06	GEN-W1	699.2	230.44	80.5	normal	simulator
2026-11-01 13:02:02.650356+06	SUB-W1	826.1	229.73	68.6	normal	simulator
2026-11-01 13:02:02.650356+06	LOAD-W1	415.3	131.59	76.9	normal	simulator
2026-11-01 13:02:02.650356+06	LOAD-W2	428.5	131.15	82.4	normal	simulator
2026-11-01 13:02:02.650356+06	GEN-S1	1140.8	230.11	78.4	normal	simulator
2026-11-01 13:02:02.650356+06	SUB-S1	821.6	230.13	69	normal	simulator
2026-11-01 13:02:02.650356+06	LOAD-S1	489.2	131.64	80.2	normal	simulator
2026-11-01 13:02:02.650356+06	LOAD-S2	345.9	131.87	73.6	normal	simulator
2026-11-01 13:06:04.021986+06	GEN-N1	963.8	229.76	81.5	normal	simulator
2026-11-01 13:06:04.021986+06	SUB-N1	829.6	229.33	63.5	normal	simulator
2026-11-01 13:06:04.021986+06	LOAD-N1	497.2	131.53	80.2	normal	simulator
2026-11-01 13:06:04.021986+06	LOAD-N2	346.6	131.78	72.2	normal	simulator
2026-11-01 13:06:04.021986+06	GEN-E1	857.8	229.24	81.4	normal	simulator
2026-11-01 13:06:04.021986+06	SUB-E1	762.2	230.53	65	normal	simulator
2026-11-01 13:06:04.021986+06	LOAD-E1	468	131.84	82.1	normal	simulator
2026-11-01 13:06:04.021986+06	LOAD-E2	309.1	131.94	68.7	normal	simulator
2026-11-01 13:06:04.021986+06	GEN-C1	1084.1	229.51	79.2	normal	simulator
2026-11-01 13:06:04.021986+06	SUB-C1	956.2	230.37	71.5	normal	simulator
2026-11-01 13:06:04.021986+06	LOAD-C1	670.3	130.73	88.2	warning	simulator
2026-11-01 13:06:04.021986+06	LOAD-C2	290.9	132.38	74.6	normal	simulator
2026-11-01 13:06:04.021986+06	GEN-W1	688.6	230.3	81.2	normal	simulator
2026-11-01 13:06:04.021986+06	SUB-W1	841	230.68	66.3	normal	simulator
2026-11-01 13:06:04.021986+06	LOAD-W1	409.3	131.66	75.8	normal	simulator
2026-11-01 13:06:04.021986+06	LOAD-W2	430.6	131.28	82.8	normal	simulator
2026-11-01 13:06:04.021986+06	GEN-S1	1160.9	230.4	80.1	normal	simulator
2026-11-01 13:06:04.021986+06	SUB-S1	832.2	229.31	70.5	normal	simulator
2026-11-01 13:06:04.021986+06	LOAD-S1	486.2	132.48	79.7	normal	simulator
2026-11-01 13:06:04.021986+06	LOAD-S2	334.6	132.29	71.2	normal	simulator
2026-11-01 13:09:05.518956+06	GEN-N1	982.9	230.02	80.7	normal	simulator
2026-11-01 13:09:05.518956+06	SUB-N1	828.4	229.97	62.3	normal	simulator
2026-11-01 13:09:05.518956+06	LOAD-N1	499.1	131.67	80.5	normal	simulator
2026-11-01 13:09:05.518956+06	LOAD-N2	340.8	131.49	71	normal	simulator
2026-11-01 13:09:05.518956+06	GEN-E1	860	229.5	80	normal	simulator
2026-11-01 13:09:05.518956+06	SUB-E1	767.9	230.19	66.2	normal	simulator
2026-11-01 13:09:05.518956+06	LOAD-E1	460.6	131.46	80.8	normal	simulator
2026-11-01 13:09:05.518956+06	LOAD-E2	308.7	132.03	68.6	normal	simulator
2026-11-01 13:09:05.518956+06	GEN-C1	1039.5	230.62	79.7	normal	simulator
2026-11-01 13:09:05.518956+06	SUB-C1	956.4	230.57	71.6	normal	simulator
2026-11-01 13:09:05.518956+06	LOAD-C1	662	131.91	87.1	warning	simulator
2026-11-01 13:09:05.518956+06	LOAD-C2	287.4	132.08	73.7	normal	simulator
2026-11-01 13:09:05.518956+06	GEN-W1	685.6	230.51	81.4	normal	simulator
2026-11-01 13:09:05.518956+06	SUB-W1	827.7	229.45	65.4	normal	simulator
2026-11-01 13:09:05.518956+06	LOAD-W1	402.8	132.69	74.6	normal	simulator
2026-11-01 13:09:05.518956+06	LOAD-W2	424.8	131.27	81.7	normal	simulator
2026-11-01 13:09:05.518956+06	GEN-S1	1174.5	229.8	78.7	normal	simulator
2026-11-01 13:09:05.518956+06	SUB-S1	817.5	229.7	68.7	normal	simulator
2026-11-01 13:09:05.518956+06	LOAD-S1	481.9	132.26	79	normal	simulator
2026-11-01 13:09:05.518956+06	LOAD-S2	332.3	131.49	70.7	normal	simulator
2026-11-01 13:11:06.082312+06	GEN-N1	952.5	229.36	79.8	normal	simulator
2026-11-01 13:11:06.082312+06	SUB-N1	833.7	230.28	61.2	normal	simulator
2026-11-01 13:11:06.082312+06	LOAD-N1	496	131.89	80	normal	simulator
2026-11-01 13:11:06.082312+06	LOAD-N2	340.8	131.91	71	normal	simulator
2026-11-01 13:11:06.082312+06	GEN-E1	878.5	229.99	78.5	normal	simulator
2026-11-01 13:11:06.082312+06	SUB-E1	786	230.16	65.7	normal	simulator
2026-11-01 13:11:06.082312+06	LOAD-E1	475.4	132.13	83.4	normal	simulator
2026-11-01 13:11:06.082312+06	LOAD-E2	312.8	131.77	69.5	normal	simulator
2026-11-01 13:11:06.082312+06	GEN-C1	1086.1	230.38	79.4	normal	simulator
2026-11-01 13:11:06.082312+06	SUB-C1	969.7	229.71	70.2	normal	simulator
2026-11-01 13:11:06.082312+06	LOAD-C1	671.1	130.92	88.3	warning	simulator
2026-11-01 13:11:06.082312+06	LOAD-C2	294.4	131.99	75.5	normal	simulator
2026-11-01 13:11:06.082312+06	GEN-W1	701.4	230.67	79.9	normal	simulator
2026-11-01 13:11:06.082312+06	SUB-W1	844.2	230.7	65.3	normal	simulator
2026-11-01 13:11:06.082312+06	LOAD-W1	412	131.32	76.3	normal	simulator
2026-11-01 13:11:06.082312+06	LOAD-W2	425.9	131.81	81.9	normal	simulator
2026-11-01 13:11:06.082312+06	GEN-S1	1182.8	230.46	80	normal	simulator
2026-11-01 13:11:06.082312+06	SUB-S1	830.2	229.41	71.3	normal	simulator
2026-11-01 13:11:06.082312+06	LOAD-S1	487.4	131.33	79.9	normal	simulator
2026-11-01 13:11:06.082312+06	LOAD-S2	339.8	131.97	72.3	normal	simulator
2026-11-01 13:14:06.951343+06	GEN-N1	979.1	230.12	79.8	normal	simulator
2026-11-01 13:14:06.951343+06	SUB-N1	839.8	229.59	62.7	normal	simulator
2026-11-01 13:14:06.951343+06	LOAD-N1	497.2	132.19	80.2	normal	simulator
2026-11-01 13:14:06.951343+06	LOAD-N2	344.2	131.59	71.7	normal	simulator
2026-11-01 13:14:06.951343+06	GEN-E1	848.1	229.71	80.9	normal	simulator
2026-11-01 13:14:06.951343+06	SUB-E1	766.7	229.47	64.7	normal	simulator
2026-11-01 13:14:06.951343+06	LOAD-E1	472	131.07	82.8	normal	simulator
2026-11-01 13:14:06.951343+06	LOAD-E2	310.1	131.51	68.9	normal	simulator
2026-11-01 13:14:06.951343+06	GEN-C1	1078.7	229.61	81	normal	simulator
2026-11-01 13:14:06.951343+06	SUB-C1	965	229.62	70.7	normal	simulator
2026-11-01 13:14:06.951343+06	LOAD-C1	662	131.91	87.1	warning	simulator
2026-11-01 13:14:06.951343+06	LOAD-C2	294.4	132.25	75.5	normal	simulator
2026-11-01 13:14:06.951343+06	GEN-W1	687.1	230.42	78.3	normal	simulator
2026-11-01 13:14:06.951343+06	SUB-W1	852.5	230.56	65.5	normal	simulator
2026-11-01 13:14:06.951343+06	LOAD-W1	418	131.47	77.4	normal	simulator
2026-11-01 13:14:06.951343+06	LOAD-W2	432.6	131.45	83.2	normal	simulator
2026-11-01 13:03:02.985471+06	GEN-N1	985.1	230.39	78.7	normal	simulator
2026-11-01 13:03:02.985471+06	SUB-N1	813.9	230.3	61	normal	simulator
2026-11-01 13:03:02.985471+06	LOAD-N1	484.8	131.45	78.2	normal	simulator
2026-11-01 13:03:02.985471+06	LOAD-N2	334.1	132.21	69.6	normal	simulator
2026-11-01 13:03:02.985471+06	GEN-E1	872.7	230.18	80.2	normal	simulator
2026-11-01 13:03:02.985471+06	SUB-E1	771.1	229.58	66.1	normal	simulator
2026-11-01 13:03:02.985471+06	LOAD-E1	460.6	132.59	80.8	normal	simulator
2026-11-01 13:03:02.985471+06	LOAD-E2	308.7	131.8	68.6	normal	simulator
2026-11-01 13:03:02.985471+06	GEN-C1	1079.3	229.98	79.7	normal	simulator
2026-11-01 13:03:02.985471+06	SUB-C1	949.6	229.45	70.4	normal	simulator
2026-11-01 13:03:02.985471+06	LOAD-C1	670.3	131.57	88.2	warning	simulator
2026-11-01 13:03:02.985471+06	LOAD-C2	291.7	132.59	74.8	normal	simulator
2026-11-01 13:03:02.985471+06	GEN-W1	694.9	229.67	78.5	normal	simulator
2026-11-01 13:03:02.985471+06	SUB-W1	834.7	230.27	67.3	normal	simulator
2026-11-01 13:03:02.985471+06	LOAD-W1	418	132.11	77.4	normal	simulator
2026-11-01 13:03:02.985471+06	LOAD-W2	439.4	131.6	84.5	normal	simulator
2026-11-01 13:03:02.985471+06	GEN-S1	1142.1	230.27	80.8	normal	simulator
2026-11-01 13:03:02.985471+06	SUB-S1	839.3	230.11	68.6	normal	simulator
2026-11-01 13:03:02.985471+06	LOAD-S1	485.6	132.03	79.6	normal	simulator
2026-11-01 13:03:02.985471+06	LOAD-S2	340.3	132.33	72.4	normal	simulator
2026-11-01 13:04:03.326936+06	GEN-N1	965.6	230.36	78.5	normal	simulator
2026-11-01 13:04:03.326936+06	SUB-N1	819.7	229.44	63.2	normal	simulator
2026-11-01 13:04:03.326936+06	LOAD-N1	490.4	132.08	79.1	normal	simulator
2026-11-01 13:04:03.326936+06	LOAD-N2	349.4	132.02	72.8	normal	simulator
2026-11-01 13:04:03.326936+06	GEN-E1	838.5	229.46	81	normal	simulator
2026-11-01 13:04:03.326936+06	SUB-E1	779.2	230.02	64	normal	simulator
2026-11-01 13:04:03.326936+06	LOAD-E1	469.7	131.86	82.4	normal	simulator
2026-11-01 13:04:03.326936+06	LOAD-E2	306.4	131.98	68.1	normal	simulator
2026-11-01 13:04:03.326936+06	GEN-C1	1057.1	229.7	80.4	normal	simulator
2026-11-01 13:04:03.326936+06	SUB-C1	949.5	230.34	71.8	normal	simulator
2026-11-01 13:04:03.326936+06	LOAD-C1	665	131.27	87.5	warning	simulator
2026-11-01 13:04:03.326936+06	LOAD-C2	284.3	132.22	72.9	normal	simulator
2026-11-01 13:04:03.326936+06	GEN-W1	714.7	229.97	80.9	normal	simulator
2026-11-01 13:04:03.326936+06	SUB-W1	847.2	229.38	65.2	normal	simulator
2026-11-01 13:04:03.326936+06	LOAD-W1	413.6	131.67	76.6	normal	simulator
2026-11-01 13:04:03.326936+06	LOAD-W2	433.2	131.1	83.3	normal	simulator
2026-11-01 13:04:03.326936+06	GEN-S1	1166	230.51	80.3	normal	simulator
2026-11-01 13:04:03.326936+06	SUB-S1	833.4	230.04	70.5	normal	simulator
2026-11-01 13:04:03.326936+06	LOAD-S1	480.7	132.1	78.8	normal	simulator
2026-11-01 13:04:03.326936+06	LOAD-S2	343.6	132.53	73.1	normal	simulator
2026-11-01 13:08:05.267859+06	GEN-N1	959.3	230.04	80.2	normal	simulator
2026-11-01 13:08:05.267859+06	SUB-N1	828.2	230.41	63.5	normal	simulator
2026-11-01 13:08:05.267859+06	LOAD-N1	479.9	131.9	77.4	normal	simulator
2026-11-01 13:08:05.267859+06	LOAD-N2	342.7	132.01	71.4	normal	simulator
2026-11-01 13:08:05.267859+06	GEN-E1	884	230.33	81.7	normal	simulator
2026-11-01 13:08:05.267859+06	SUB-E1	786.2	230.22	65.6	normal	simulator
2026-11-01 13:08:05.267859+06	LOAD-E1	473.7	131.48	83.1	normal	simulator
2026-11-01 13:08:05.267859+06	LOAD-E2	300.6	132.16	66.8	normal	simulator
2026-11-01 13:08:05.267859+06	GEN-C1	1065.4	230.32	79.2	normal	simulator
2026-11-01 13:08:05.267859+06	SUB-C1	955.5	229.84	72.2	normal	simulator
2026-11-01 13:08:05.267859+06	LOAD-C1	656.6	131.69	86.4	warning	simulator
2026-11-01 13:08:05.267859+06	LOAD-C2	289	131.41	74.1	normal	simulator
2026-11-01 13:08:05.267859+06	GEN-W1	680.3	229.56	80.8	normal	simulator
2026-11-01 13:08:05.267859+06	SUB-W1	845	229.85	67.1	normal	simulator
2026-11-01 13:08:05.267859+06	LOAD-W1	416.3	132.41	77.1	normal	simulator
2026-11-01 13:08:05.267859+06	LOAD-W2	429	132.28	82.5	normal	simulator
2026-11-01 13:08:05.267859+06	GEN-S1	1162.7	230	81.3	normal	simulator
2026-11-01 13:08:05.267859+06	SUB-S1	833.4	230.54	71.4	normal	simulator
2026-11-01 13:08:05.267859+06	LOAD-S1	477.6	132.23	78.3	normal	simulator
2026-11-01 13:08:05.267859+06	LOAD-S2	341.2	131.67	72.6	normal	simulator
2026-11-01 13:22:07.263533+06	GEN-N1	1002	230.27	79	normal	simulator
2026-11-01 13:22:07.263533+06	SUB-N1	839.1	230.63	62.8	normal	simulator
2026-11-01 13:22:07.263533+06	LOAD-N1	499.1	131.3	80.5	normal	simulator
2026-11-01 13:22:07.263533+06	LOAD-N2	344.6	132.43	71.8	normal	simulator
2026-11-01 13:22:07.263533+06	GEN-E1	843.3	229.55	79.7	normal	simulator
2026-11-01 13:22:07.263533+06	SUB-E1	782.4	229.56	65.5	normal	simulator
2026-11-01 13:22:07.263533+06	LOAD-E1	462.8	131.9	81.2	normal	simulator
2026-11-01 13:22:07.263533+06	LOAD-E2	301.5	131.46	67	normal	simulator
2026-11-01 13:22:07.263533+06	GEN-C1	1046.3	229.36	80.9	normal	simulator
2026-11-01 13:22:07.263533+06	SUB-C1	956.2	230.62	70.3	normal	simulator
2026-11-01 13:22:07.263533+06	LOAD-C1	655.1	130.8	86.2	warning	simulator
2026-11-01 13:22:07.263533+06	LOAD-C2	292.9	131.76	75.1	normal	simulator
2026-11-01 13:22:07.263533+06	GEN-W1	697	230.12	79	normal	simulator
2026-11-01 13:22:07.263533+06	SUB-W1	828.7	229.89	68.1	normal	simulator
2026-11-01 13:22:07.263533+06	LOAD-W1	407.7	132.17	75.5	normal	simulator
2026-11-01 13:22:07.263533+06	LOAD-W2	434.7	131.97	83.6	normal	simulator
2026-11-01 13:22:07.263533+06	GEN-S1	1135.4	230.1	79.3	normal	simulator
2026-11-01 13:22:07.263533+06	SUB-S1	830.9	230.44	69.9	normal	simulator
2026-11-01 13:22:07.263533+06	LOAD-S1	482.5	132.55	79.1	normal	simulator
2026-11-01 13:22:07.263533+06	LOAD-S2	336.5	131.53	71.6	normal	simulator
2026-11-01 13:31:23.034105+06	GEN-N1	959.2	230.33	80.6	normal	simulator
2026-11-01 13:31:23.034105+06	SUB-N1	843.7	229.99	60.5	normal	simulator
2026-11-01 13:31:23.034105+06	LOAD-N1	495.4	131.71	79.9	normal	simulator
2026-11-01 13:31:23.034105+06	LOAD-N2	337.9	131.78	70.4	normal	simulator
2026-11-01 13:31:23.034105+06	GEN-E1	852.4	229.87	80.4	normal	simulator
2026-11-01 13:31:23.034105+06	SUB-E1	764.3	230.48	66.7	normal	simulator
2026-11-01 13:31:23.034105+06	LOAD-E1	457.7	132.64	80.3	normal	simulator
2026-11-01 13:31:23.034105+06	LOAD-E2	313.6	132.01	69.7	normal	simulator
2026-11-01 13:05:03.673261+06	GEN-N1	949.8	230.25	78.2	normal	simulator
2026-11-01 13:05:03.673261+06	SUB-N1	829.6	229.38	60.3	normal	simulator
2026-11-01 13:05:03.673261+06	LOAD-N1	492.3	131.93	79.4	normal	simulator
2026-11-01 13:05:03.673261+06	LOAD-N2	349	132.59	72.7	normal	simulator
2026-11-01 13:05:03.673261+06	GEN-E1	874.4	230.2	79.7	normal	simulator
2026-11-01 13:05:03.673261+06	SUB-E1	766.4	229.74	64.7	normal	simulator
2026-11-01 13:05:03.673261+06	LOAD-E1	476.5	131.65	83.6	normal	simulator
2026-11-01 13:05:03.673261+06	LOAD-E2	301.9	131.59	67.1	normal	simulator
2026-11-01 13:05:03.673261+06	GEN-C1	1044.6	230.61	78.9	normal	simulator
2026-11-01 13:05:03.673261+06	SUB-C1	956.2	230.02	72.1	normal	simulator
2026-11-01 13:05:03.673261+06	LOAD-C1	672.6	130.4	88.5	warning	simulator
2026-11-01 13:05:03.673261+06	LOAD-C2	288.6	132.29	74	normal	simulator
2026-11-01 13:05:03.673261+06	GEN-W1	693.4	230.13	79.5	normal	simulator
2026-11-01 13:05:03.673261+06	SUB-W1	831	229.94	68.1	normal	simulator
2026-11-01 13:05:03.673261+06	LOAD-W1	416.9	131.69	77.2	normal	simulator
2026-11-01 13:05:03.673261+06	LOAD-W2	431.1	131	82.9	normal	simulator
2026-11-01 13:05:03.673261+06	GEN-S1	1200.9	230.52	80.9	normal	simulator
2026-11-01 13:05:03.673261+06	SUB-S1	812.4	229.79	69	normal	simulator
2026-11-01 13:05:03.673261+06	LOAD-S1	483.1	131.7	79.2	normal	simulator
2026-11-01 13:05:03.673261+06	LOAD-S2	337.5	132.67	71.8	normal	simulator
2026-11-01 13:07:04.338795+06	GEN-N1	992.6	230.05	78.9	normal	simulator
2026-11-01 13:07:04.338795+06	SUB-N1	828.1	229.3	62.8	normal	simulator
2026-11-01 13:07:04.338795+06	LOAD-N1	488.6	132.44	78.8	normal	simulator
2026-11-01 13:07:04.338795+06	LOAD-N2	334.1	132.16	69.6	normal	simulator
2026-11-01 13:07:04.338795+06	GEN-E1	841.7	230.06	79.5	normal	simulator
2026-11-01 13:07:04.338795+06	SUB-E1	774.9	230.55	64.3	normal	simulator
2026-11-01 13:07:04.338795+06	LOAD-E1	475.9	132.28	83.5	normal	simulator
2026-11-01 13:07:04.338795+06	LOAD-E2	300.1	131.53	66.7	normal	simulator
2026-11-01 13:07:04.338795+06	GEN-C1	1020	230.41	79	normal	simulator
2026-11-01 13:07:04.338795+06	SUB-C1	955.9	230.09	72.1	normal	simulator
2026-11-01 13:07:04.338795+06	LOAD-C1	674.1	130.79	88.7	warning	simulator
2026-11-01 13:07:04.338795+06	LOAD-C2	293.7	132.19	75.3	normal	simulator
2026-11-01 13:07:04.338795+06	GEN-W1	690.7	229.73	80.7	normal	simulator
2026-11-01 13:07:04.338795+06	SUB-W1	845.5	229.67	68.7	normal	simulator
2026-11-01 13:07:04.338795+06	LOAD-W1	406.1	132.21	75.2	normal	simulator
2026-11-01 13:07:04.338795+06	LOAD-W2	439.9	131.55	84.6	normal	simulator
2026-11-01 13:07:04.338795+06	GEN-S1	1150.3	230.19	78.8	normal	simulator
2026-11-01 13:07:04.338795+06	SUB-S1	831.5	230.59	70.4	normal	simulator
2026-11-01 13:07:04.338795+06	LOAD-S1	495.9	131.71	81.3	normal	simulator
2026-11-01 13:07:04.338795+06	LOAD-S2	340.3	132.44	72.4	normal	simulator
2026-11-01 13:10:05.816118+06	GEN-N1	958.9	229.97	81.2	normal	simulator
2026-11-01 13:10:05.816118+06	SUB-N1	835.6	230.1	61.1	normal	simulator
2026-11-01 13:10:05.816118+06	LOAD-N1	492.3	131.82	79.4	normal	simulator
2026-11-01 13:10:05.816118+06	LOAD-N2	336.5	131.96	70.1	normal	simulator
2026-11-01 13:10:05.816118+06	GEN-E1	850	229.38	80.6	normal	simulator
2026-11-01 13:10:05.816118+06	SUB-E1	781.6	229.59	66.5	normal	simulator
2026-11-01 13:10:05.816118+06	LOAD-E1	464	131.55	81.4	normal	simulator
2026-11-01 13:10:05.816118+06	LOAD-E2	312.3	131.77	69.4	normal	simulator
2026-11-01 13:10:05.816118+06	GEN-C1	1059.2	230.31	81.1	normal	simulator
2026-11-01 13:10:05.816118+06	SUB-C1	954.1	229.72	71.6	normal	simulator
2026-11-01 13:10:05.816118+06	LOAD-C1	677.9	131.53	89.2	warning	simulator
2026-11-01 13:10:05.816118+06	LOAD-C2	285.1	131.82	73.1	normal	simulator
2026-11-01 13:10:05.816118+06	GEN-W1	679.7	229.31	81.5	normal	simulator
2026-11-01 13:10:05.816118+06	SUB-W1	835.5	229.4	66.7	normal	simulator
2026-11-01 13:10:05.816118+06	LOAD-W1	402.8	132.32	74.6	normal	simulator
2026-11-01 13:10:05.816118+06	LOAD-W2	425.9	132.14	81.9	normal	simulator
2026-11-01 13:10:05.816118+06	GEN-S1	1166	230.01	79.2	normal	simulator
2026-11-01 13:10:05.816118+06	SUB-S1	817.4	230	71.3	normal	simulator
2026-11-01 13:10:05.816118+06	LOAD-S1	484.3	132.45	79.4	normal	simulator
2026-11-01 13:10:05.816118+06	LOAD-S2	339.3	132.7	72.2	normal	simulator
2026-11-01 13:12:06.372072+06	GEN-N1	982.5	230.34	79.9	normal	simulator
2026-11-01 13:12:06.372072+06	SUB-N1	827.3	229.97	63.4	normal	simulator
2026-11-01 13:12:06.372072+06	LOAD-N1	497.2	131.31	80.2	normal	simulator
2026-11-01 13:12:06.372072+06	LOAD-N2	337.9	131.68	70.4	normal	simulator
2026-11-01 13:12:06.372072+06	GEN-E1	847.3	230.4	80	normal	simulator
2026-11-01 13:12:06.372072+06	SUB-E1	780.3	230.54	66.3	normal	simulator
2026-11-01 13:12:06.372072+06	LOAD-E1	461.7	132.05	81	normal	simulator
2026-11-01 13:12:06.372072+06	LOAD-E2	301.5	131.63	67	normal	simulator
2026-11-01 13:12:06.372072+06	GEN-C1	1028.8	230.53	79.4	normal	simulator
2026-11-01 13:12:06.372072+06	SUB-C1	954.2	230.55	70.3	normal	simulator
2026-11-01 13:12:06.372072+06	LOAD-C1	680.2	131.29	89.5	warning	simulator
2026-11-01 13:12:06.372072+06	LOAD-C2	293.3	131.34	75.2	normal	simulator
2026-11-01 13:12:06.372072+06	GEN-W1	697.5	230.2	79.9	normal	simulator
2026-11-01 13:12:06.372072+06	SUB-W1	831.3	229.53	67.7	normal	simulator
2026-11-01 13:12:06.372072+06	LOAD-W1	403.4	131.95	74.7	normal	simulator
2026-11-01 13:12:06.372072+06	LOAD-W2	435.8	131.7	83.8	normal	simulator
2026-11-01 13:12:06.372072+06	GEN-S1	1170.3	230.11	79.1	normal	simulator
2026-11-01 13:12:06.372072+06	SUB-S1	815.5	230.14	71.4	normal	simulator
2026-11-01 13:12:06.372072+06	LOAD-S1	489.2	132.17	80.2	normal	simulator
2026-11-01 13:12:06.372072+06	LOAD-S2	330.9	132.43	70.4	normal	simulator
2026-11-01 13:13:06.663784+06	GEN-N1	960.4	230.44	79.2	normal	simulator
2026-11-01 13:13:06.663784+06	SUB-N1	837.1	230.14	61.4	normal	simulator
2026-11-01 13:13:06.663784+06	LOAD-N1	492.9	131.56	79.5	normal	simulator
2026-11-01 13:13:06.663784+06	LOAD-N2	341.8	131.41	71.2	normal	simulator
2026-11-01 13:13:06.663784+06	GEN-E1	878.2	230.49	78.6	normal	simulator
2026-11-01 13:13:06.663784+06	SUB-E1	774.9	229.59	66.5	normal	simulator
2026-11-01 13:13:06.663784+06	LOAD-E1	475.9	131.1	83.5	normal	simulator
2026-11-01 13:13:06.663784+06	LOAD-E2	308.7	132.17	68.6	normal	simulator
2026-11-01 13:13:06.663784+06	GEN-C1	1024.4	230.09	80.5	normal	simulator
2026-11-01 13:13:06.663784+06	SUB-C1	962	229.75	70.3	normal	simulator
2026-11-01 13:13:06.663784+06	LOAD-C1	672.6	131.66	88.5	warning	simulator
2026-11-01 13:13:06.663784+06	LOAD-C2	290.6	132.63	74.5	normal	simulator
2026-11-01 13:13:06.663784+06	GEN-W1	718	229.43	79.3	normal	simulator
2026-11-01 13:13:06.663784+06	SUB-W1	839.6	229.89	66.1	normal	simulator
2026-11-01 13:13:06.663784+06	LOAD-W1	415.3	131.77	76.9	normal	simulator
2026-11-01 13:13:06.663784+06	LOAD-W2	424.8	131.62	81.7	normal	simulator
2026-11-01 13:13:06.663784+06	GEN-S1	1193.8	230.43	79.7	normal	simulator
2026-11-01 13:13:06.663784+06	SUB-S1	821.2	230.5	69.2	normal	simulator
2026-11-01 13:13:06.663784+06	LOAD-S1	495.9	131.55	81.3	normal	simulator
2026-11-01 13:13:06.663784+06	LOAD-S2	345.9	132.03	73.6	normal	simulator
2026-11-01 13:26:34.12734+06	GEN-N1	959.2	230.33	80.6	normal	simulator
2026-11-01 13:26:34.12734+06	SUB-N1	843.7	229.99	60.5	normal	simulator
2026-11-01 13:26:34.12734+06	LOAD-N1	495.4	131.71	79.9	normal	simulator
2026-11-01 13:26:34.12734+06	LOAD-N2	337.9	131.78	70.4	normal	simulator
2026-11-01 13:26:34.12734+06	GEN-E1	852.4	229.87	80.4	normal	simulator
2026-11-01 13:26:34.12734+06	SUB-E1	764.3	230.48	66.7	normal	simulator
2026-11-01 13:26:34.12734+06	LOAD-E1	457.7	132.64	80.3	normal	simulator
2026-11-01 13:26:34.12734+06	LOAD-E2	313.6	132.01	69.7	normal	simulator
2026-11-01 13:26:34.12734+06	GEN-C1	1076.7	229.67	79.4	normal	simulator
2026-11-01 13:26:34.12734+06	SUB-C1	948	229.55	70.7	normal	simulator
2026-11-01 13:26:34.12734+06	LOAD-C1	655.9	131.59	86.3	warning	simulator
2026-11-01 13:26:34.12734+06	LOAD-C2	293.7	132.67	75.3	normal	simulator
2026-11-01 13:26:34.12734+06	GEN-W1	680.2	229.95	80.1	normal	simulator
2026-11-01 13:26:34.12734+06	SUB-W1	842.4	230.11	67.4	normal	simulator
2026-11-01 13:26:34.12734+06	LOAD-W1	418.5	132.15	77.5	normal	simulator
2026-11-01 13:26:34.12734+06	LOAD-W2	424.3	132.34	81.6	normal	simulator
2026-11-01 13:26:34.12734+06	GEN-S1	1198.3	230.11	79.1	normal	simulator
2026-11-01 13:26:34.12734+06	SUB-S1	819	230.69	69.8	normal	simulator
2026-11-01 13:26:34.12734+06	LOAD-S1	477	131.57	78.2	normal	simulator
2026-11-01 13:26:34.12734+06	LOAD-S2	332.8	132.64	70.8	normal	simulator
2026-11-01 13:31:23.034105+06	GEN-C1	1076.7	229.67	79.4	normal	simulator
2026-11-01 13:31:23.034105+06	SUB-C1	948	229.55	70.7	normal	simulator
2026-11-01 13:31:23.034105+06	LOAD-C1	655.9	131.59	86.3	warning	simulator
2026-11-01 13:31:23.034105+06	LOAD-C2	293.7	132.67	75.3	normal	simulator
2026-11-01 13:31:23.034105+06	GEN-W1	680.2	229.95	80.1	normal	simulator
2026-11-01 13:31:23.034105+06	SUB-W1	842.4	230.11	67.4	normal	simulator
2026-11-01 13:31:23.034105+06	LOAD-W1	418.5	132.15	77.5	normal	simulator
2026-11-01 13:31:23.034105+06	LOAD-W2	424.3	132.34	81.6	normal	simulator
2026-11-01 13:31:23.034105+06	GEN-S1	1198.3	230.11	79.1	normal	simulator
2026-11-01 13:31:23.034105+06	SUB-S1	819	230.69	69.8	normal	simulator
2026-11-01 13:31:23.034105+06	LOAD-S1	477	131.57	78.2	normal	simulator
2026-11-01 13:31:23.034105+06	LOAD-S2	332.8	132.64	70.8	normal	simulator
2026-11-01 13:32:43.553263+06	GEN-C1	1046.3	229.36	80.9	normal	simulator
2026-11-01 13:32:43.553263+06	SUB-C1	956.2	230.62	70.3	normal	simulator
2026-11-01 13:32:43.553263+06	LOAD-C1	655.1	130.8	86.2	warning	simulator
2026-11-01 13:32:43.553263+06	LOAD-C2	292.9	131.76	75.1	normal	simulator
2026-11-01 13:32:43.553263+06	GEN-W1	697	230.12	79	normal	simulator
2026-11-01 13:32:43.553263+06	SUB-W1	828.7	229.89	68.1	normal	simulator
2026-11-01 13:32:43.553263+06	LOAD-W1	407.7	132.17	75.5	normal	simulator
2026-11-01 13:32:43.553263+06	LOAD-W2	434.7	131.97	83.6	normal	simulator
2026-11-01 13:32:43.553263+06	GEN-S1	1135.4	230.1	79.3	normal	simulator
2026-11-01 13:32:43.553263+06	SUB-S1	830.9	230.44	69.9	normal	simulator
2026-11-01 13:32:43.553263+06	LOAD-S1	482.5	132.55	79.1	normal	simulator
2026-11-01 13:32:43.553263+06	LOAD-S2	336.5	131.53	71.6	normal	simulator
2026-11-01 13:33:57.765748+06	GEN-C1	1067.5	229.57	80.6	normal	simulator
2026-11-01 13:33:57.765748+06	SUB-C1	949.6	229.57	70.7	normal	simulator
2026-11-01 13:33:57.765748+06	LOAD-C1	658.9	130.68	86.7	warning	simulator
2026-11-01 13:33:57.765748+06	LOAD-C2	290.9	132.18	74.6	normal	simulator
2026-11-01 13:33:57.765748+06	GEN-W1	202.5	229.83	80.8	normal	simulator
2026-11-01 13:33:57.765748+06	SUB-W1	842.8	229.45	66.9	normal	simulator
2026-11-01 13:33:57.765748+06	LOAD-W1	411.5	131.65	76.2	normal	simulator
2026-11-01 13:33:57.765748+06	LOAD-W2	436.3	131.97	83.9	normal	simulator
2026-11-01 13:33:57.765748+06	GEN-S1	1179.2	229.56	80.7	normal	simulator
2026-11-01 13:33:57.765748+06	SUB-S1	809.8	230.52	69.9	normal	simulator
2026-11-01 13:33:57.765748+06	LOAD-S1	486.2	131.36	79.7	normal	simulator
2026-11-01 13:33:57.765748+06	LOAD-S2	344.5	131.84	73.3	normal	simulator
2026-11-01 13:35:48.252378+06	GEN-N1	992.3	229.61	81.8	normal	simulator
2026-11-01 13:35:48.252378+06	SUB-N1	950.9	230.23	62.1	normal	simulator
2026-11-01 13:35:48.252378+06	LOAD-N1	609.5	129.43	98.3	critical	simulator
2026-11-01 13:35:48.252378+06	LOAD-N2	419.5	131.51	87.4	warning	simulator
2026-11-01 13:35:48.252378+06	GEN-E1	846.1	229.84	79.6	normal	simulator
2026-11-01 13:35:48.252378+06	SUB-E1	876.5	230.37	64.9	normal	simulator
2026-11-01 13:35:48.252378+06	LOAD-E1	564.3	130.37	99	critical	simulator
2026-11-01 13:35:48.252378+06	LOAD-E2	390.6	131.76	86.8	warning	simulator
2026-11-01 13:35:48.252378+06	GEN-C1	1057.4	230.47	78.5	normal	simulator
2026-11-01 13:35:48.252378+06	SUB-C1	1081.3	229.49	71.8	normal	simulator
2026-11-01 13:35:48.252378+06	LOAD-C1	760	129.37	100	critical	simulator
2026-11-01 13:35:48.252378+06	LOAD-C2	352.6	130.22	90.4	warning	simulator
2026-11-01 13:35:48.252378+06	GEN-W1	719.9	230.36	80.1	normal	simulator
2026-11-01 13:35:48.252378+06	SUB-W1	956.7	230.37	65.7	normal	simulator
2026-11-01 13:35:48.252378+06	LOAD-W1	515.2	130.91	95.4	critical	simulator
2026-11-01 13:35:48.252378+06	LOAD-W2	520	129.25	100	critical	simulator
2026-11-01 13:35:48.252378+06	GEN-S1	1189.6	229.59	80.2	normal	simulator
2026-11-01 13:35:48.252378+06	SUB-S1	927.9	230.19	70.6	normal	simulator
2026-11-01 13:35:48.252378+06	LOAD-S1	597.8	129.75	98	critical	simulator
2026-11-01 13:35:48.252378+06	LOAD-S2	423	130.69	90	warning	simulator
2026-11-01 13:14:06.951343+06	GEN-S1	1175.6	229.45	81.7	normal	simulator
2026-11-01 13:14:06.951343+06	SUB-S1	817.5	230.37	69.8	normal	simulator
2026-11-01 13:14:06.951343+06	LOAD-S1	484.9	132.32	79.5	normal	simulator
2026-11-01 13:14:06.951343+06	LOAD-S2	345.4	132.45	73.5	normal	simulator
2026-11-01 13:26:34.136256+06	GEN-N1	271.5	230.26	79.9	normal	simulator
2026-11-01 13:26:34.136256+06	SUB-N1	833.3	229.67	62.3	normal	simulator
2026-11-01 13:26:34.136256+06	LOAD-N1	498.5	131.92	80.4	normal	simulator
2026-11-01 13:26:34.136256+06	LOAD-N2	339.4	132.08	70.7	normal	simulator
2026-11-01 13:26:34.136256+06	GEN-E1	855.7	230.63	79.1	normal	simulator
2026-11-01 13:26:34.136256+06	SUB-E1	771.3	230.5	64.4	normal	simulator
2026-11-01 13:26:34.136256+06	LOAD-E1	475.9	132.12	83.5	normal	simulator
2026-11-01 13:26:34.136256+06	LOAD-E2	300.1	131.43	66.7	normal	simulator
2026-11-01 13:26:34.136256+06	GEN-C1	1067.5	229.57	80.6	normal	simulator
2026-11-01 13:26:34.136256+06	SUB-C1	949.6	229.57	70.7	normal	simulator
2026-11-01 13:26:34.136256+06	LOAD-C1	658.9	130.68	86.7	warning	simulator
2026-11-01 13:26:34.136256+06	LOAD-C2	290.9	132.18	74.6	normal	simulator
2026-11-01 13:26:34.136256+06	GEN-W1	202.5	229.83	80.8	normal	simulator
2026-11-01 13:26:34.136256+06	SUB-W1	842.8	229.45	66.9	normal	simulator
2026-11-01 13:26:34.136256+06	LOAD-W1	411.5	131.65	76.2	normal	simulator
2026-11-01 13:26:34.136256+06	LOAD-W2	436.3	131.97	83.9	normal	simulator
2026-11-01 13:26:34.136256+06	GEN-S1	1179.2	229.56	80.7	normal	simulator
2026-11-01 13:26:34.136256+06	SUB-S1	809.8	230.52	69.9	normal	simulator
2026-11-01 13:26:34.136256+06	LOAD-S1	486.2	131.36	79.7	normal	simulator
2026-11-01 13:26:34.136256+06	LOAD-S2	344.5	131.84	73.3	normal	simulator
2026-11-01 13:31:23.04459+06	GEN-N1	271.5	230.26	79.9	normal	simulator
2026-11-01 13:31:23.04459+06	SUB-N1	833.3	229.67	62.3	normal	simulator
2026-11-01 13:31:23.04459+06	LOAD-N1	498.5	131.92	80.4	normal	simulator
2026-11-01 13:31:23.04459+06	LOAD-N2	339.4	132.08	70.7	normal	simulator
2026-11-01 13:31:23.04459+06	GEN-E1	855.7	230.63	79.1	normal	simulator
2026-11-01 13:31:23.04459+06	SUB-E1	771.3	230.5	64.4	normal	simulator
2026-11-01 13:31:23.04459+06	LOAD-E1	475.9	132.12	83.5	normal	simulator
2026-11-01 13:31:23.04459+06	LOAD-E2	300.1	131.43	66.7	normal	simulator
2026-11-01 13:31:23.04459+06	GEN-C1	1067.5	229.57	80.6	normal	simulator
2026-11-01 13:31:23.04459+06	SUB-C1	949.6	229.57	70.7	normal	simulator
2026-11-01 13:31:23.04459+06	LOAD-C1	658.9	130.68	86.7	warning	simulator
2026-11-01 13:31:23.04459+06	LOAD-C2	290.9	132.18	74.6	normal	simulator
2026-11-01 13:31:23.04459+06	GEN-W1	202.5	229.83	80.8	normal	simulator
2026-11-01 13:31:23.04459+06	SUB-W1	842.8	229.45	66.9	normal	simulator
2026-11-01 13:31:23.04459+06	LOAD-W1	411.5	131.65	76.2	normal	simulator
2026-11-01 13:31:23.04459+06	LOAD-W2	436.3	131.97	83.9	normal	simulator
2026-11-01 13:31:23.04459+06	GEN-S1	1179.2	229.56	80.7	normal	simulator
2026-11-01 13:31:23.04459+06	SUB-S1	809.8	230.52	69.9	normal	simulator
2026-11-01 13:31:23.04459+06	LOAD-S1	486.2	131.36	79.7	normal	simulator
2026-11-01 13:31:23.04459+06	LOAD-S2	344.5	131.84	73.3	normal	simulator
2026-11-01 13:33:57.75608+06	GEN-N1	959.2	230.33	80.6	normal	simulator
2026-11-01 13:33:57.75608+06	SUB-N1	843.7	229.99	60.5	normal	simulator
2026-11-01 13:33:57.75608+06	LOAD-N1	495.4	131.71	79.9	normal	simulator
2026-11-01 13:33:57.75608+06	LOAD-N2	337.9	131.78	70.4	normal	simulator
2026-11-01 13:33:57.75608+06	GEN-E1	852.4	229.87	80.4	normal	simulator
2026-11-01 13:33:57.75608+06	SUB-E1	764.3	230.48	66.7	normal	simulator
2026-11-01 13:33:57.75608+06	LOAD-E1	457.7	132.64	80.3	normal	simulator
2026-11-01 13:33:57.75608+06	LOAD-E2	313.6	132.01	69.7	normal	simulator
2026-11-01 13:33:57.75608+06	GEN-C1	1076.7	229.67	79.4	normal	simulator
2026-11-01 13:33:57.75608+06	SUB-C1	948	229.55	70.7	normal	simulator
2026-11-01 13:33:57.75608+06	LOAD-C1	655.9	131.59	86.3	warning	simulator
2026-11-01 13:33:57.75608+06	LOAD-C2	293.7	132.67	75.3	normal	simulator
2026-11-01 13:33:57.75608+06	GEN-W1	680.2	229.95	80.1	normal	simulator
2026-11-01 13:33:57.75608+06	SUB-W1	842.4	230.11	67.4	normal	simulator
2026-11-01 13:33:57.75608+06	LOAD-W1	418.5	132.15	77.5	normal	simulator
2026-11-01 13:33:57.75608+06	LOAD-W2	424.3	132.34	81.6	normal	simulator
2026-11-01 13:33:57.75608+06	GEN-S1	1198.3	230.11	79.1	normal	simulator
2026-11-01 13:33:57.75608+06	SUB-S1	819	230.69	69.8	normal	simulator
2026-11-01 13:33:57.75608+06	LOAD-S1	477	131.57	78.2	normal	simulator
2026-11-01 13:33:57.75608+06	LOAD-S2	332.8	132.64	70.8	normal	simulator
2026-11-01 13:35:48.220792+06	GEN-N1	952.4	230.55	79.9	normal	simulator
2026-11-01 13:35:48.220792+06	SUB-N1	834.9	230.69	62.5	normal	simulator
2026-11-01 13:35:48.220792+06	LOAD-N1	556.8	130.28	89.8	warning	simulator
2026-11-01 13:35:48.220792+06	LOAD-N2	394.1	132	82.1	normal	simulator
2026-11-01 13:35:48.220792+06	GEN-E1	883.5	230.48	79.6	normal	simulator
2026-11-01 13:35:48.220792+06	SUB-E1	775.5	230.35	66.2	normal	simulator
2026-11-01 13:35:48.220792+06	LOAD-E1	521	131.44	91.4	warning	simulator
2026-11-01 13:35:48.220792+06	LOAD-E2	355.5	131.46	79	normal	simulator
2026-11-01 13:35:48.220792+06	GEN-C1	1036	230.18	78.9	normal	simulator
2026-11-01 13:35:48.220792+06	SUB-C1	939.4	229.35	73.5	normal	simulator
2026-11-01 13:35:48.220792+06	LOAD-C1	746.3	129.81	98.2	critical	simulator
2026-11-01 13:35:48.220792+06	LOAD-C2	335	130.81	85.9	warning	simulator
2026-11-01 13:35:48.220792+06	GEN-W1	693.1	229.49	78.4	normal	simulator
2026-11-01 13:35:48.220792+06	SUB-W1	851.6	229.43	66.5	normal	simulator
2026-11-01 13:35:48.220792+06	LOAD-W1	475.7	131.41	88.1	warning	simulator
2026-11-01 13:35:48.220792+06	LOAD-W2	481	130.49	92.5	warning	simulator
2026-11-01 13:35:48.220792+06	GEN-S1	1170	230.29	78.7	normal	simulator
2026-11-01 13:35:48.220792+06	SUB-S1	841.6	230.14	70.6	normal	simulator
2026-11-01 13:35:48.220792+06	LOAD-S1	545.3	131.52	89.4	warning	simulator
2026-11-01 13:35:48.220792+06	LOAD-S2	382.6	131.83	81.4	normal	simulator
2026-11-01 13:35:48.282152+06	GEN-N1	272.2	229.42	78.7	normal	simulator
2026-11-01 13:35:48.282152+06	SUB-N1	1029	230.65	62.3	normal	simulator
2026-11-01 13:35:48.282152+06	LOAD-N1	482.4	131.8	77.8	normal	simulator
2026-11-01 13:35:48.282152+06	LOAD-N2	337.9	131.93	70.4	normal	simulator
2026-11-01 13:35:48.282152+06	GEN-E1	842.8	230.51	79.8	normal	simulator
2026-11-01 13:35:48.282152+06	SUB-E1	954.9	230.04	64	normal	simulator
2026-11-01 13:35:48.282152+06	LOAD-E1	471.4	132.26	82.7	normal	simulator
2026-11-01 13:35:48.282152+06	LOAD-E2	306.9	132.3	68.2	normal	simulator
2026-11-01 13:35:48.282152+06	GEN-C1	1067.7	230.04	79.5	normal	simulator
2026-11-01 13:35:48.282152+06	SUB-C1	1112.6	229.74	71.4	normal	simulator
2026-11-01 13:35:48.282152+06	LOAD-C1	667.3	131.07	87.8	warning	simulator
2026-11-01 13:35:48.282152+06	LOAD-C2	290.2	131.87	74.4	normal	simulator
2026-11-01 13:35:48.282152+06	GEN-W1	202	230.34	79.7	normal	simulator
2026-11-01 13:35:48.282152+06	SUB-W1	1035.2	230.42	68.4	normal	simulator
2026-11-01 13:35:48.282152+06	LOAD-W1	403.9	131.33	74.8	normal	simulator
2026-11-01 13:35:48.282152+06	LOAD-W2	425.9	132.05	81.9	normal	simulator
2026-11-01 13:35:48.282152+06	GEN-S1	1194.6	230.16	79	normal	simulator
2026-11-01 13:35:48.282152+06	SUB-S1	1020.8	229.75	71.5	normal	simulator
2026-11-01 13:35:48.282152+06	LOAD-S1	486.2	132.44	79.7	normal	simulator
2026-11-01 13:35:48.282152+06	LOAD-S2	337.5	132.2	71.8	normal	simulator
2026-11-01 13:35:48.312698+06	GEN-N1	993.1	230.12	80.2	normal	simulator
2026-11-01 13:35:48.312698+06	SUB-N1	820.3	229.44	63.6	normal	simulator
2026-11-01 13:35:48.312698+06	LOAD-N1	479.3	132.1	77.3	normal	simulator
2026-11-01 13:35:48.312698+06	LOAD-N2	344.2	131.96	71.7	normal	simulator
2026-11-01 13:35:48.312698+06	GEN-E1	872.8	229.85	81.6	normal	simulator
2026-11-01 13:35:48.312698+06	SUB-E1	778.3	229.37	63.8	normal	simulator
2026-11-01 13:35:48.312698+06	LOAD-E1	461.1	132.55	80.9	normal	simulator
2026-11-01 13:35:48.312698+06	LOAD-E2	311.4	132.52	69.2	normal	simulator
2026-11-01 13:35:48.312698+06	GEN-C1	1046.2	229.81	80.6	normal	simulator
2026-11-01 13:35:48.312698+06	SUB-C1	0	229.6	72.4	critical	simulator
2026-11-01 13:35:48.312698+06	LOAD-C1	668.8	130.63	88	warning	simulator
2026-11-01 13:35:48.312698+06	LOAD-C2	282.8	132.56	72.5	normal	simulator
2026-11-01 13:35:48.312698+06	GEN-W1	685.9	230.65	78.2	normal	simulator
2026-11-01 13:35:48.312698+06	SUB-W1	829.8	230.25	66.3	normal	simulator
2026-11-01 13:35:48.312698+06	LOAD-W1	413.1	131.85	76.5	normal	simulator
2026-11-01 13:35:48.312698+06	LOAD-W2	433.2	132.24	83.3	normal	simulator
2026-11-01 13:35:48.312698+06	GEN-S1	1160.7	229.43	79	normal	simulator
2026-11-01 13:35:48.312698+06	SUB-S1	823.7	230.16	69.5	normal	simulator
2026-11-01 13:35:48.312698+06	LOAD-S1	497.1	132.2	81.5	normal	simulator
2026-11-01 13:35:48.312698+06	LOAD-S2	331.4	132.56	70.5	normal	simulator
2026-11-01 13:35:48.3419+06	GEN-N1	946.6	230.61	80.3	normal	simulator
2026-11-01 13:35:48.3419+06	SUB-N1	823.5	230.37	60.6	normal	simulator
2026-11-01 13:35:48.3419+06	LOAD-N1	495.4	132.25	79.9	normal	simulator
2026-11-01 13:35:48.3419+06	LOAD-N2	345.6	131.77	72	normal	simulator
2026-11-01 13:35:48.3419+06	GEN-E1	836.8	229.52	81	normal	simulator
2026-11-01 13:35:48.3419+06	SUB-E1	772.5	230.3	64.2	normal	simulator
2026-11-01 13:35:48.3419+06	LOAD-E1	458.3	131.65	80.4	normal	simulator
2026-11-01 13:35:48.3419+06	LOAD-E2	299.2	131.73	66.5	normal	simulator
2026-11-01 13:35:48.3419+06	GEN-C1	1024	230.09	81	normal	simulator
2026-11-01 13:35:48.3419+06	SUB-C1	951.6	230.11	71.9	normal	simulator
2026-11-01 13:35:48.3419+06	LOAD-C1	673.4	131.69	88.6	warning	simulator
2026-11-01 13:35:48.3419+06	LOAD-C2	286.6	132.61	73.5	normal	simulator
2026-11-01 13:35:48.3419+06	GEN-W1	706.6	229.94	79.8	normal	simulator
2026-11-01 13:35:48.3419+06	SUB-W1	846.3	229.92	65.3	normal	simulator
2026-11-01 13:35:48.3419+06	LOAD-W1	402.8	132.47	74.6	normal	simulator
2026-11-01 13:35:48.3419+06	LOAD-W2	432.1	131.92	83.1	normal	simulator
2026-11-01 13:35:48.3419+06	GEN-S1	1143.7	229.53	78.3	normal	simulator
2026-11-01 13:35:48.3419+06	SUB-S1	828.5	230.54	69.3	normal	simulator
2026-11-01 13:35:48.3419+06	LOAD-S1	487.4	132.54	79.9	normal	simulator
2026-11-01 13:35:48.3419+06	LOAD-S2	343.6	132.34	73.1	normal	simulator
2026-11-01 13:36:06.712044+06	GEN-N1	990.9	229.83	80.1	normal	simulator
2026-11-01 13:36:06.712044+06	SUB-N1	821.7	230.18	60.4	normal	simulator
2026-11-01 13:36:06.712044+06	LOAD-N1	557.4	131.39	89.9	warning	simulator
2026-11-01 13:36:06.712044+06	LOAD-N2	389.8	132.24	81.2	normal	simulator
2026-11-01 13:36:06.712044+06	GEN-E1	849.1	230.28	80.1	normal	simulator
2026-11-01 13:36:06.712044+06	SUB-E1	769.7	230.5	65	normal	simulator
2026-11-01 13:36:06.712044+06	LOAD-E1	525	130.96	92.1	warning	simulator
2026-11-01 13:36:06.712044+06	LOAD-E2	351.9	131.59	78.2	normal	simulator
2026-11-01 13:36:06.712044+06	GEN-C1	1069.3	230.26	80.1	normal	simulator
2026-11-01 13:36:06.712044+06	SUB-C1	945.1	230.67	71.5	normal	simulator
2026-11-01 13:36:06.712044+06	LOAD-C1	760	130.19	100	critical	simulator
2026-11-01 13:36:06.712044+06	LOAD-C2	335.4	131.68	86	warning	simulator
2026-11-01 13:36:06.712044+06	GEN-W1	700.7	229.91	80.1	normal	simulator
2026-11-01 13:36:06.712044+06	SUB-W1	851.1	230.37	67.3	normal	simulator
2026-11-01 13:36:06.712044+06	LOAD-W1	479	131.32	88.7	warning	simulator
2026-11-01 13:36:06.712044+06	LOAD-W2	489.3	130.41	94.1	warning	simulator
2026-11-01 13:36:06.712044+06	GEN-S1	1163.1	229.99	79.9	normal	simulator
2026-11-01 13:36:06.712044+06	SUB-S1	827.9	229.4	70.3	normal	simulator
2026-11-01 13:36:06.712044+06	LOAD-S1	563	130.12	92.3	warning	simulator
2026-11-01 13:36:06.712044+06	LOAD-S2	395.3	131.03	84.1	normal	simulator
2026-11-01 13:36:06.746431+06	GEN-N1	982.9	229.36	80.7	normal	simulator
2026-11-01 13:36:06.746431+06	SUB-N1	947.2	229.31	63.3	normal	simulator
2026-11-01 13:36:06.746431+06	LOAD-N1	601.4	130.15	97	critical	simulator
2026-11-01 13:36:06.746431+06	LOAD-N2	426.2	131.25	88.8	warning	simulator
2026-11-01 13:36:06.746431+06	GEN-E1	834.2	229.34	80.7	normal	simulator
2026-11-01 13:36:06.746431+06	SUB-E1	876.9	229.5	64.2	normal	simulator
2026-11-01 13:36:06.746431+06	LOAD-E1	563.2	129.59	98.8	critical	simulator
2026-11-01 13:36:06.746431+06	LOAD-E2	394.6	130.73	87.7	warning	simulator
2026-11-01 13:36:06.746431+06	GEN-C1	1043.1	229.9	81.7	normal	simulator
2026-11-01 13:36:06.746431+06	SUB-C1	1095.4	230.48	71.9	normal	simulator
2026-11-01 13:36:06.746431+06	LOAD-C1	760	129.14	100	critical	simulator
2026-11-01 13:36:06.746431+06	LOAD-C2	353.3	130.15	90.6	warning	simulator
2026-11-01 13:36:06.746431+06	GEN-W1	704.7	230.61	80.6	normal	simulator
2026-11-01 13:36:06.746431+06	SUB-W1	968.3	229.54	66.8	normal	simulator
2026-11-01 13:36:06.746431+06	LOAD-W1	506.5	130.09	93.8	warning	simulator
2026-11-01 13:36:06.746431+06	LOAD-W2	517.9	129.54	99.6	critical	simulator
2026-11-01 13:36:06.746431+06	GEN-S1	1157.7	230.27	80.9	normal	simulator
2026-11-01 13:36:06.746431+06	SUB-S1	958.3	229.95	70.2	normal	simulator
2026-11-01 13:36:06.746431+06	LOAD-S1	595.4	129.99	97.6	critical	simulator
2026-11-01 13:36:06.746431+06	LOAD-S2	422.5	131.44	89.9	warning	simulator
2026-11-01 13:36:06.776948+06	GEN-N1	275.7	229.36	79.9	normal	simulator
2026-11-01 13:36:06.776948+06	SUB-N1	1027.6	230.28	61.4	normal	simulator
2026-11-01 13:36:06.776948+06	LOAD-N1	489.8	132.29	79	normal	simulator
2026-11-01 13:36:06.776948+06	LOAD-N2	348.5	131.7	72.6	normal	simulator
2026-11-01 13:36:06.776948+06	GEN-E1	837.8	229.52	80.8	normal	simulator
2026-11-01 13:36:06.776948+06	SUB-E1	957.8	230.09	65.8	normal	simulator
2026-11-01 13:36:06.776948+06	LOAD-E1	474.8	132.1	83.3	normal	simulator
2026-11-01 13:36:06.776948+06	LOAD-E2	300.6	132.53	66.8	normal	simulator
2026-11-01 13:36:06.776948+06	GEN-C1	1036	230.18	80.1	normal	simulator
2026-11-01 13:36:06.776948+06	SUB-C1	1113.3	229.84	71.5	normal	simulator
2026-11-01 13:36:06.776948+06	LOAD-C1	666.5	130.8	87.7	warning	simulator
2026-11-01 13:36:06.776948+06	LOAD-C2	283.5	131.38	72.7	normal	simulator
2026-11-01 13:36:06.776948+06	GEN-W1	196.7	230.39	79.9	normal	simulator
2026-11-01 13:36:06.776948+06	SUB-W1	1024.4	230.26	66.7	normal	simulator
2026-11-01 13:36:06.776948+06	LOAD-W1	408.8	132.58	75.7	normal	simulator
2026-11-01 13:36:06.776948+06	LOAD-W2	436.8	131.21	84	normal	simulator
2026-11-01 13:36:06.776948+06	GEN-S1	1185.2	229.34	80.7	normal	simulator
2026-11-01 13:36:06.776948+06	SUB-S1	1017.9	229.64	70.6	normal	simulator
2026-11-01 13:36:06.776948+06	LOAD-S1	491.7	132.07	80.6	normal	simulator
2026-11-01 13:36:06.776948+06	LOAD-S2	335.1	131.94	71.3	normal	simulator
2026-11-01 13:36:06.80979+06	GEN-N1	971.1	229.92	78.7	normal	simulator
2026-11-01 13:36:06.80979+06	SUB-N1	838.3	230.28	62	normal	simulator
2026-11-01 13:36:06.80979+06	LOAD-N1	488.6	132.53	78.8	normal	simulator
2026-11-01 13:36:06.80979+06	LOAD-N2	344.2	131.44	71.7	normal	simulator
2026-11-01 13:36:06.80979+06	GEN-E1	860.9	230.04	78.4	normal	simulator
2026-11-01 13:36:06.80979+06	SUB-E1	775.4	230.44	64.4	normal	simulator
2026-11-01 13:36:06.80979+06	LOAD-E1	465.7	131.9	81.7	normal	simulator
2026-11-01 13:36:06.80979+06	LOAD-E2	306.9	131.95	68.2	normal	simulator
2026-11-01 13:36:06.80979+06	GEN-C1	1073.3	229.88	81.1	normal	simulator
2026-11-01 13:36:06.80979+06	SUB-C1	0	230.51	71.9	critical	simulator
2026-11-01 13:36:06.80979+06	LOAD-C1	671.1	130.48	88.3	warning	simulator
2026-11-01 13:36:06.80979+06	LOAD-C2	287.8	132.46	73.8	normal	simulator
2026-11-01 13:36:06.80979+06	GEN-W1	687.9	229.72	80.9	normal	simulator
2026-11-01 13:36:06.80979+06	SUB-W1	845.6	230.35	66.2	normal	simulator
2026-11-01 13:36:06.80979+06	LOAD-W1	412.6	132.07	76.4	normal	simulator
2026-11-01 13:36:06.80979+06	LOAD-W2	436.8	132.09	84	normal	simulator
2026-11-01 13:36:06.80979+06	GEN-S1	1157.6	229.62	79.3	normal	simulator
2026-11-01 13:36:06.80979+06	SUB-S1	826.8	230.55	69.1	normal	simulator
2026-11-01 13:36:06.80979+06	LOAD-S1	491.1	131.83	80.5	normal	simulator
2026-11-01 13:36:06.80979+06	LOAD-S2	343.1	132.49	73	normal	simulator
2026-11-01 13:36:06.836628+06	GEN-N1	949.5	230.39	79.3	normal	simulator
2026-11-01 13:36:06.836628+06	SUB-N1	832.8	229.92	60.3	normal	simulator
2026-11-01 13:36:06.836628+06	LOAD-N1	497.2	131.29	80.2	normal	simulator
2026-11-01 13:36:06.836628+06	LOAD-N2	332.6	131.44	69.3	normal	simulator
2026-11-01 13:36:06.836628+06	GEN-E1	834.7	230.52	78.2	normal	simulator
2026-11-01 13:36:06.836628+06	SUB-E1	772.6	229.67	66.8	normal	simulator
2026-11-01 13:36:06.836628+06	LOAD-E1	470.8	132.27	82.6	normal	simulator
2026-11-01 13:36:06.836628+06	LOAD-E2	304.6	132.6	67.7	normal	simulator
2026-11-01 13:36:06.836628+06	GEN-C1	1026.8	229.33	79.8	normal	simulator
2026-11-01 13:36:06.836628+06	SUB-C1	958.9	230.27	71.4	normal	simulator
2026-11-01 13:36:06.836628+06	LOAD-C1	661.2	131.39	87	warning	simulator
2026-11-01 13:36:06.836628+06	LOAD-C2	295.6	132.48	75.8	normal	simulator
2026-11-01 13:36:06.836628+06	GEN-W1	721.4	229.86	78.8	normal	simulator
2026-11-01 13:36:06.836628+06	SUB-W1	849.4	230.14	65.7	normal	simulator
2026-11-01 13:36:06.836628+06	LOAD-W1	413.6	132.01	76.6	normal	simulator
2026-11-01 13:36:06.836628+06	LOAD-W2	428.5	131.86	82.4	normal	simulator
2026-11-01 13:36:06.836628+06	GEN-S1	1157.7	230.08	79	normal	simulator
2026-11-01 13:36:06.836628+06	SUB-S1	834.2	229.64	69.3	normal	simulator
2026-11-01 13:36:06.836628+06	LOAD-S1	486.2	132.54	79.7	normal	simulator
2026-11-01 13:36:06.836628+06	LOAD-S2	330.4	132.36	70.3	normal	simulator
\.


--
-- Data for Name: grid_node_readings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.grid_node_readings (observed_at, node_id, source, generation_mw, demand_mw, gas_mw, coal_mw, solar_mw, hydro_mw, wind_mw, imports_mw, voltage_kv, load_percent, capacity_mw, status) FROM stdin;
\.


--
-- Data for Name: grid_nodes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.grid_nodes (node_id, name, tier, parent_node_id, division_code, created_at, distribution_weight) FROM stdin;
BD-NATIONAL	Bangladesh National Grid	national	\N	\N	2026-11-01 13:22:07.252617+06	\N
BD-DHAKA	Dhaka	division	BD-NATIONAL	DHA	2026-11-01 13:22:07.252617+06	\N
BD-CHATTOGRAM	Chattogram	division	BD-NATIONAL	CTG	2026-11-01 13:22:07.252617+06	\N
BD-RAJSHAHI	Rajshahi	division	BD-NATIONAL	RAJ	2026-11-01 13:22:07.252617+06	\N
BD-KHULNA	Khulna	division	BD-NATIONAL	KHU	2026-11-01 13:22:07.252617+06	\N
BD-BARISHAL	Barishal	division	BD-NATIONAL	BAR	2026-11-01 13:22:07.252617+06	\N
BD-SYLHET	Sylhet	division	BD-NATIONAL	SYL	2026-11-01 13:22:07.252617+06	\N
BD-RANGPUR	Rangpur	division	BD-NATIONAL	RAN	2026-11-01 13:22:07.252617+06	\N
BD-MYMENSINGH	Mymensingh	division	BD-NATIONAL	MYM	2026-11-01 13:22:07.252617+06	\N
\.


--
-- Data for Name: national_grid_readings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.national_grid_readings (observed_at, source, generation_mw, demand_mw, gas_mw, coal_mw, solar_mw, hydro_mw, wind_mw, imports_mw) FROM stdin;
\.


--
-- Data for Name: telemetry; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.telemetry (observed_at, node_id, load_mw, voltage_kv, load_percent, status, source) FROM stdin;
\.


--
-- Name: bgw_job_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: -
--

SELECT pg_catalog.setval('_timescaledb_catalog.bgw_job_id_seq', 1000, false);


--
-- Name: chunk_column_stats_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: -
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_column_stats_id_seq', 1, false);


--
-- Name: chunk_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: -
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_id_seq', 1, true);


--
-- Name: dimension_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: -
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_id_seq', 3, true);


--
-- Name: dimension_slice_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: -
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_slice_id_seq', 1, true);


--
-- Name: hypertable_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: -
--

SELECT pg_catalog.setval('_timescaledb_catalog.hypertable_id_seq', 3, true);


--
-- Name: _hyper_1_1_chunk 1_telemetry_pkey; Type: CONSTRAINT; Schema: _timescaledb_internal; Owner: -
--

ALTER TABLE ONLY _timescaledb_internal._hyper_1_1_chunk
    ADD CONSTRAINT "1_telemetry_pkey" PRIMARY KEY (observed_at, node_id);


--
-- Name: grid_node_readings grid_node_readings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grid_node_readings
    ADD CONSTRAINT grid_node_readings_pkey PRIMARY KEY (observed_at, node_id, source);


--
-- Name: grid_nodes grid_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grid_nodes
    ADD CONSTRAINT grid_nodes_pkey PRIMARY KEY (node_id);


--
-- Name: national_grid_readings national_grid_readings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.national_grid_readings
    ADD CONSTRAINT national_grid_readings_pkey PRIMARY KEY (observed_at, source);


--
-- Name: telemetry telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telemetry
    ADD CONSTRAINT telemetry_pkey PRIMARY KEY (observed_at, node_id);


--
-- Name: _hyper_1_1_chunk_telemetry_observed_at_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: -
--

CREATE INDEX _hyper_1_1_chunk_telemetry_observed_at_idx ON _timescaledb_internal._hyper_1_1_chunk USING btree (observed_at DESC);


--
-- Name: grid_node_readings_observed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX grid_node_readings_observed_at_idx ON public.grid_node_readings USING btree (observed_at DESC);


--
-- Name: national_grid_readings_observed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX national_grid_readings_observed_at_idx ON public.national_grid_readings USING btree (observed_at DESC);


--
-- Name: telemetry_observed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX telemetry_observed_at_idx ON public.telemetry USING btree (observed_at DESC);


--
-- Name: grid_node_readings grid_node_readings_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grid_node_readings
    ADD CONSTRAINT grid_node_readings_node_id_fkey FOREIGN KEY (node_id) REFERENCES public.grid_nodes(node_id) ON DELETE RESTRICT;


--
-- Name: grid_nodes grid_nodes_parent_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grid_nodes
    ADD CONSTRAINT grid_nodes_parent_node_id_fkey FOREIGN KEY (parent_node_id) REFERENCES public.grid_nodes(node_id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict NkThzyU0zAdAQVxNSwtkgG2IK9exSauKW1wsRspqinZ7xsUTeRjeLL8ECkOTH8W

