--
-- PostgreSQL database dump
--

\restrict D4oslAUBmD1VRfqY178PqHPksez0bQzH8yZGbWK1YArBmNJdM0dGrvfSlfM04hH

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

\unrestrict D4oslAUBmD1VRfqY178PqHPksez0bQzH8yZGbWK1YArBmNJdM0dGrvfSlfM04hH

