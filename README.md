# GridPulse

GridPulse is an academic smart-grid operations simulator and dashboard. It models a 20-node virtual grid, streams generated telemetry, forecasts demand, flags simulated anomalies, evaluates deterministic safety rules, and lets an operator explore grid-shock scenarios. It is a demonstration and decision-support project only: it does not connect to, monitor, or control physical electrical infrastructure. 

## Contents

- [Capabilities](#capabilities)
- [Technical stack](#technical-stack)
- [Architecture and data flow](#architecture-and-data-flow)
- [Run with Docker Compose](#run-with-docker-compose)
- [Run locally without Docker](#run-locally-without-docker)
- [Configuration](#configuration)
- [HTTP and WebSocket API](#http-and-websocket-api)
- [Repository layout](#repository-layout)
- [Development and tests](#development-and-tests)
- [Known limitations](#known-limitations)
- [Safety and intended use](#safety-and-intended-use)

## Capabilities
 
- **Overview dashboard:** generation, load, frequency, health, regional demand, generation mix, forecasts, alerts, and a live topology map.
- **Grid map:** interactive D3 visualization of nodes and connections, with node details and animated flows.
- **Live monitoring:** simulated node and line telemetry, voltage/load charts, and a recent telemetry table.
- **Demand forecast:** 24 future hourly points from a gradient-boosted model. XGBoost is used when available; scikit-learn is the fallback. Live national trend data can adjust the simulated 20-node load and generation within bounded limits.
- **Live national-data bridge:** optional hourly polling of a public PGCB JSON, CSV, or HTML-table source, with normalized generation, demand, fuel mix, timestamps, and source-health status.
- **Historical context and Gemini advisory:** hourly national readings persist in PostgreSQL for 180-day summaries and recent trajectory context. With sufficient hourly samples, XGBoost/scikit-learn trains on the collected demand history. Gemini analysis is opt-in; any suggested simulated flow passes the deterministic line-capacity validator before display and is never executed.
- **Alerts and safety:** threshold-based load, voltage, frequency, and renewable-generation alerts, plus node and transmission-line limit checks. The safety endpoint validates a proposed flow without applying it.
- **Scenario simulator:** heatwave, demand spike, solar failure, and node failure scenarios with impact summaries.
- **Reports:** generate and download a JSON summary from recent simulated telemetry; report work can be queued through Celery when enabled.
- **Operator UI:** reports, settings, and profile pages are included in the dashboard.

Virtual node measurements and scenario outcomes are simulated. National aggregate readings are real only when an authorized external source is configured.

## Technical stack

| Area                       | Technologies                                                     |
| -------------------------- | ---------------------------------------------------------------- |
| Web application            | Next.js 16, React 19, TypeScript 5                               |
| Styling and visualization  | Tailwind CSS 4, D3.js 7, Recharts 3, Lucide React                |
| API                        | Python 3.12, FastAPI, Uvicorn, Pydantic                          |
| Simulation and forecasting | NumPy, Pandas, scikit-learn, XGBoost CPU (scikit-learn fallback) |
| Live updates               | FastAPI WebSockets                                               |
| Background reports         | Celery 5 with Redis broker/result backend                        |
| Telemetry persistence      | PostgreSQL 16 with TimescaleDB, SQLAlchemy async, asyncpg        |
| Web checks                 | ESLint 9, Next.js production build                               |
| Backend tests              | pytest, FastAPI TestClient, httpx                                |
| Container orchestration    | Docker Compose                                                   |

Frontend dependency version ranges are declared in [package.json](package.json) and pinned by [package-lock.json](package-lock.json). Backend dependency ranges are in [backend/requirements.txt](backend/requirements.txt).

## Architecture and data flow

```mermaid
flowchart LR
	Browser[Next.js dashboard] <-->|HTTP and WebSocket| API[FastAPI simulator]
	API --> Sim[20-node grid simulator]
	Sim --> Forecast[Gradient-boosted demand forecast]
	API -->|telemetry writes| DB[(PostgreSQL / TimescaleDB)]
	Source[Public PGCB data source] -->|hourly normalized aggregates| API
	API -->|national history and sampled telemetry| DB
	API -->|optional advisory request| Gemini[Gemini API]
	API -->|report jobs| Redis[(Redis)]
	Redis --> Worker[Celery report worker]
	Worker --> Redis
```

The API owns the virtual 20-node simulator and emits a full snapshot on a configurable interval (three seconds by default). If `GRID_SOURCE_URL` is configured, a backend poller reads public national aggregates hourly, stores each reading, and applies a bounded trend factor to the simulation. National values are not copied onto the microgrid nodes or presented as node-level measurements. The browser loads `/api/v1/state`, then subscribes to `/api/v1/ws/live`; it reconnects if the stream is interrupted and clearly labels its offline preview as demo data. PostgreSQL persistence is optional for local development. Hourly national data is retained for historical analysis; virtual-node snapshots are sampled every five minutes by default. Redis and Celery are used for queued report generation. Gemini is only called when an operator requests analysis and the backend key is configured.

The national grid page uses a **separate database-backed hierarchy**: national root → eight Bangladesh administrative division hubs → source-provided district substations → source-provided feeder clusters. PostgreSQL stores node identity and `parent_node_id` separately from time-series readings. Only the root and division names are initialized locally; no district, feeder, capacity, demand, or generation values are invented. The hierarchy browser drills into the next tier and labels nodes with no source record as unmeasured. Optional division weights are NULL by default; only when all eight explicit weights sum to 100% can the system show a clearly marked proportional estimate from a national aggregate. A real division reading always takes precedence. The original 20-node digital twin remains clearly labeled simulator data.

**There are two distinct database settings:** `SUPABASE_URL` plus a Supabase API key reads the scraper's `hourly_generation` table through the Supabase REST API. At API startup, the most recent 500 rows are used for forecast training and upserted into `DATABASE_URL` when persistence is connected; each subsequent poll stores the latest row. `DATABASE_URL` is where GridPulse persists its own national history, hierarchy, and simulator telemetry. If `DATABASE_URL` is unset or unreachable, live national readings can still feed the simulator, but database-backed history and the hierarchy view remain unavailable. Set `DATABASE_URL` to Supabase's PostgreSQL connection URI if you want those GridPulse records stored in the Supabase project; otherwise Docker Compose uses its local TimescaleDB.

## Run with Docker Compose

Prerequisites: Docker Engine or Docker Desktop with the Compose plugin. From the repository root:

```bash
docker compose up --build
```

Open:

- Dashboard: <http://localhost:3000>
- FastAPI Swagger UI: <http://localhost:8000/docs>
- FastAPI ReDoc: <http://localhost:8000/redoc>
- API health: <http://localhost:8000/api/v1/health>

Compose starts the frontend, API, telemetry simulator, Redis, Celery worker, and TimescaleDB. The database volume is named `gridpulse-db`. Stop services while preserving its contents with `docker compose down`. To remove the database volume too, use `docker compose down -v` (this deletes local telemetry data).

The Compose file uses a development-only database password. Do not reuse it outside a local environment. To configure Supabase/Gemini values for Compose, copy `.env.example` to the repository-root `.env` and set the values there; Compose passes backend settings to the API container. For a local Uvicorn run, copy `.env.example` to `backend/.env` instead. The backend also loads a repository-root `.env` when run locally. Restart the API after changing credentials. Never commit either `.env` file or put backend credentials in `NEXT_PUBLIC_*` variables.

## Run locally without Docker

You need Node.js 22 or newer, npm, Python 3.12, and (optionally) PostgreSQL/TimescaleDB and Redis. The API can run without those optional services in in-memory mode.

### Frontend

```bash
npm ci
npm run dev
```

The development site is <http://localhost:3000>. For a production build, run `npm run build` and then `npm start`.

### Backend API

From the repository root, create an isolated Python environment and install the backend requirements. Copy `.env.example` to `backend/.env` and edit the backend settings before starting the API if you want live data, persisted history, or Gemini analysis:

```bash
python3.12 -m venv backend/.venv
backend/.venv/bin/python -m pip install -r backend/requirements.txt
```

Start the API from the repository root:

```bash
backend/.venv/bin/uvicorn app.main:app --reload --app-dir backend
```

If using a different Python executable, substitute it for `python3.12`. The API is served at <http://localhost:8000>.

### Optional persistence and background reports

Start a PostgreSQL database with TimescaleDB and a Redis server, set the backend environment variables described below, then start the Celery worker from the repository root:

```bash
backend/.venv/bin/celery --workdir backend -A app.celery_app:celery_app worker --loglevel=INFO
```

The API connects to the database on startup and continues in in-memory mode if the database is unavailable. Set `CELERY_ENABLED=true` to queue report generation; if Celery cannot be reached at submission time, the API attempts inline report generation.

### Local database dry run (without Docker)

If PostgreSQL is installed locally, initialize a development database and export a backend `DATABASE_URL`, for example `postgresql+asyncpg://gridpulse@127.0.0.1:55432/gridpulse`. Then generate and persist 48 hourly snapshots of the 20-node simulator:

```bash
cd backend
DATABASE_URL='postgresql+asyncpg://gridpulse@127.0.0.1:55432/gridpulse' .venv/bin/python -m app.seed_simulation_history --hours 48
```

The seed command verifies and prints the row count, distinct hours, node count, and timestamp range. It inserts only `source='simulator'` telemetry; it does not fabricate PGCB history or train the national-demand forecaster. Actual PGCB history must come from an authorized feed or CSV backfill.

## Configuration

The root [.env.example](.env.example) documents the available settings. Copy it to `.env.local` only if you need to override frontend URLs; copy it to `backend/.env` for local Uvicorn or the repository-root `.env` for Docker Compose. `.env*` files are ignored by Git except for `.env.example`.

| Variable                           | Used by        | Default                                       | Purpose                                                                                                     |
| ---------------------------------- | -------------- | --------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `NEXT_PUBLIC_API_BASE_URL`         | Frontend       | `http://localhost:8000/api/v1`                | HTTP API base URL, compiled into the frontend bundle.                                                       |
| `NEXT_PUBLIC_WS_URL`               | Frontend       | `ws://localhost:8000/api/v1/ws/live`          | Live telemetry WebSocket URL, compiled into the frontend bundle.                                            |
| `DATABASE_URL`                     | Backend        | unset                                         | Async SQLAlchemy connection URL, for example `postgresql+asyncpg://user:password@localhost:5432/gridpulse`. |
| `GRID_SOURCE_URL`                  | Backend        | unset                                         | Public PGCB JSON, CSV, or readable HTML-table endpoint. Polling is disabled when unset.                     |
| `SUPABASE_URL`                     | Backend        | unset                                         | Supabase project URL; reads the latest row and history from `SUPABASE_TABLE` using the REST API.            |
| `SUPABASE_SERVICE_ROLE_KEY`        | Backend        | unset                                         | Backend-only Supabase API key. Keep secret; never expose it to the browser.                                 |
| `SUPABASE_ANON_KEY`                | Backend        | unset                                         | Optional alternative to the service-role key when the table's RLS policy allows reads.                      |
| `SUPABASE_TABLE`                   | Backend        | `hourly_generation`                           | Supabase REST table/view name; the current query expects a sortable `datetime` column.                      |
| `GRID_SOURCE_POLL_SECONDS`         | Backend        | `3600`                                        | Poll interval in seconds (minimum 60).                                                                      |
| `GRID_SOURCE_TIMEZONE`             | Backend        | `Asia/Dhaka`                                  | Timezone used for naive timestamps in PGCB feeds and imported history.                                      |
| `GRID_NATIONAL_BASELINE_DEMAND_MW` | Backend        | `15000`                                       | Reference demand used to calculate bounded national-to-simulation trend scaling.                            |
| `GRID_PERSIST_INTERVAL_SECONDS`    | Backend        | `300`                                         | Minimum interval between persisted 20-node snapshots; national source rows are stored at each poll.         |
| `GEMINI_API_KEY`                   | Backend        | unset                                         | Optional Gemini key for operator-triggered analysis. Never expose it to the browser.                        |
| `GEMINI_MODEL`                     | Backend        | `gemini-3-flash-preview`                      | Gemini model used by the advisory endpoint.                                                                 |
| `REDIS_URL`                        | Backend/worker | `redis://localhost:6379/0`                    | Celery broker and result backend.                                                                           |
| `CELERY_ENABLED`                   | Backend        | `false`                                       | Queue report generation instead of generating reports inline.                                               |
| `GRID_TICK_SECONDS`                | Backend        | `3`                                           | Telemetry simulator interval in seconds (minimum effective interval: one second).                           |
| `CORS_ORIGINS`                     | Backend        | `http://localhost:3000,http://127.0.0.1:3000` | Comma-separated browser origins allowed by the API.                                                         |

In Docker Compose, frontend URLs are supplied as Docker build arguments, while the backend settings are passed from the repository-root `.env` into the API container. The frontend calls `POST /api/v1/live-data/sync` when you select **Sync live source now**; it never receives Supabase or Gemini credentials. Gemini is called only when you select **Run analysis**.

### Configure Supabase and Gemini credentials

1. Copy the tracked `.env.example` to `backend/.env` for local Uvicorn, or to the repository-root `.env` for Docker Compose.
2. Set `SUPABASE_URL` to the project URL from Supabase, `SUPABASE_SERVICE_ROLE_KEY` to a backend-only key (or `SUPABASE_ANON_KEY` if table read access is explicitly allowed by RLS), and keep `SUPABASE_TABLE=hourly_generation` unless your table has another name.
3. Set `GEMINI_API_KEY` to a key enabled for the Gemini API. `GEMINI_MODEL` defaults to `gemini-3-flash-preview`; model availability and quotas can change. The key stays on the backend; the frontend only requests the backend's analysis endpoint.
4. For historical persistence and the hierarchy explorer, set `DATABASE_URL` to a PostgreSQL connection. It can be the local Compose database (default under Docker) or a Supabase PostgreSQL URI converted to `postgresql+asyncpg://...` with `?sslmode=require` as appropriate. The REST API key is not a PostgreSQL password.
5. Restart the API/container, then check `http://localhost:8000/api/v1/health`, `http://localhost:8000/api/v1/live-data`, and `http://localhost:8000/docs`. The health response reports whether Gemini and the source are configured without revealing credentials. Use the dashboard's sync button to test an immediate read.

The Supabase REST request orders rows by `datetime` and the payload parser recognizes the project scraper's generation/fuel columns. Ensure the table has a `datetime` column and its API/RLS permissions allow the selected key to `SELECT`. A successful REST read does not itself configure PostgreSQL persistence; that is the separate `DATABASE_URL` setting above.

### Supabase PostgreSQL

For GridPulse persistence, connect to Supabase PostgreSQL through SQLAlchemy/asyncpg, not through a browser-side client. Copy the PostgreSQL connection URI from Supabase's **Connect** panel and set it as the backend `DATABASE_URL`; use the SQLAlchemy asyncpg driver form, for example `postgresql+asyncpg://.../postgres?sslmode=require`. Separately, `SUPABASE_URL` and an API key read the scraper table through Supabase REST. The backend normalizes standard `postgresql://` URIs too. Use the Supabase session pooler if the deployment environment cannot reach the direct database host. Do not commit credentials. The schema uses standard PostgreSQL tables, so the Supabase database does not need the TimescaleDB extension; the local Compose stack remains TimescaleDB-backed.

### PGCB source and historical backfill

Set `GRID_SOURCE_URL` to a public endpoint that the backend can access without an interactive login. The reader recognizes common JSON field names, CSV headers, and HTML table headers for total generation, demand/load, gas, coal, solar, hydro, wind, and imports (values in MW). PGCB ERP pages may require a login or render data in JavaScript; this connector does not bypass authentication or browser-only protections. If the official portal has no public machine-readable feed, supply an authorized export or a documented public API endpoint before enabling polling.

An initial six-month dataset can be loaded from an authorized hourly CSV export with timestamp/date and MW columns using `python -m app.import_history <hourly-history.csv>` from the `backend` directory after setting `DATABASE_URL`. Newly polled readings then continue the time series. The historical-context endpoint summarizes the latest 180 days; the analysis will explicitly have limited context until data is imported/collected.

### Hierarchical data ingestion contract

The upcoming authorized PGCB processing script can import `save_hierarchical_readings` from `app.database` after the API/database schema has initialized. Each reading must identify `node_id`, `node_name`, `tier` (`national`, `division`, `district`, or `feeder`), `parent_node_id` (null only for the national root), `observed_at`, and `source`. It may include generation/demand/fuel mix, voltage, capacity, load percentage, and status when the source actually provides those fields. District and feeder nodes are upserted by the script with their parent relationships, then timestamped measurements are written to the TimescaleDB hypertable. `configure_division_distribution_weights` can be used only after the project team supplies and verifies all eight weights; there are no assumed shares. Send the actual Python script and a redacted sample row/schema next so its parser can be adapted to this contract.

## HTTP and WebSocket API

All HTTP routes are under `/api/v1`.

| Method | Path                                         | Description                                                                                                        |
| ------ | -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `GET`  | `/health`                                    | API status, node count, database mode, and connected WebSocket clients.                                            |
| `GET`  | `/state`                                     | Current full snapshot: summary, nodes, connections, history, forecast, alerts, safety checks, and latest scenario. |
| `GET`  | `/grid/hierarchy?parent_node_id=BD-NATIONAL` | Database-backed direct children and latest source readings; unmeasured values remain null.                         |
| `GET`  | `/live-data`                                 | National-source connection status, latest reading, provenance, and applied simulation trend factors.               |
| `GET`  | `/history/summary`                           | Aggregates from persisted national readings over the last 180 days and the recent hourly sequence.                 |
| `POST` | `/ai/analyze`                                | Optional Gemini analysis of live state and stored history; advisory only and never executes an action.             |
| `GET`  | `/telemetry?limit=48`                        | Recent aggregate simulator history; the requested limit is bounded to 1–96.                                        |
| `GET`  | `/alerts`                                    | Current anomaly alerts.                                                                                            |
| `GET`  | `/safety`                                    | Current node/line checks and counts by status.                                                                     |
| `POST` | `/safety/validate`                           | Validate a proposed flow against a connection capacity; no grid action is taken.                                   |
| `POST` | `/simulations`                               | Apply one of the four supported scenarios and return a snapshot.                                                   |
| `POST` | `/simulations/reset`                         | Clear the active scenario and return a new baseline simulation snapshot.                                           |
| `POST` | `/reports/generate`                          | Generate a report inline or enqueue it with Celery.                                                                |
| `GET`  | `/reports/tasks/{task_id}`                   | Retrieve queued report status and its result when complete.                                                        |
| `WS`   | `/ws/live`                                   | Initial snapshot followed by simulator snapshots.                                                                  |

Example scenario request:

```json
{ "scenario": "heatwave" }
```

Allowed scenario values are `heatwave`, `demand_spike`, `solar_failure`, and `node_failure`. Safety validation accepts `connection_id` and a non-negative `proposed_mw`. Report generation accepts `report_type`: `performance`, `analytics`, or `alerts`.

## Repository layout

```text
.
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── ai_advisor.py      # Optional Gemini advisory with deterministic flow checks
│   │   ├── celery_app.py       # Celery broker/result configuration
│   │   ├── database.py         # PostgreSQL/TimescaleDB schema, telemetry, and history queries
│   │   ├── forecasting.py      # Historical XGBoost/ sklearn training and 24-step fallback forecast
│   │   ├── import_history.py   # Authorized hourly CSV history backfill CLI
│   │   ├── live_data.py        # PGCB JSON/CSV/HTML normalization and polling
│   │   ├── main.py             # FastAPI routes, lifecycle, telemetry loop, WebSocket
│   │   ├── safety.py           # Shared deterministic flow-capacity validation
│   │   ├── seed_simulation_history.py # Clearly labeled simulator-history seed utility
│   │   ├── architecture_dry_run.py # API, WebSocket, safety, reports, and DB smoke test
│   │   ├── settings.py         # Backend environment configuration
│   │   ├── simulator.py        # Grid model, scenarios, alerts, safety, reports
│   │   └── tasks.py            # Background report task
│   ├── tests/
│   │   ├── test_api.py
│   │   ├── test_live_data.py
│   │   └── test_simulator.py
│   ├── Dockerfile
│   └── requirements.txt
├── public/                     # Static public assets
├── src/
│   ├── app/                    # Next.js routes: overview, map, monitor, forecast,
│   │                           # alerts, simulator, reports, settings, profile
│   ├── components/
│   │   ├── alerts/             # Alert cards, panel, anomaly indicator
│   │   ├── common/             # Shared badge, button, card, loading UI
│   │   ├── dashboard/          # Dashboard metrics and charts
│   │   ├── forecast/           # Demand, peak, and risk widgets
│   │   ├── grid/               # D3 grid map, flow, legend, node cards
│   │   ├── layout/             # Dashboard shell, navbar, sidebar
│   │   ├── monitor/            # Telemetry table and monitoring charts
│   │   ├── reports/            # Report generation and download UI
│   │   ├── safety/             # Safety rule/status UI
│   │   └── simulator/          # Scenario selectors and impact results
│   ├── data/                   # Demo/fallback grid, alert, forecast, and telemetry data
│   ├── hooks/                  # Shared data hooks and live grid context
│   ├── types/                  # Frontend data contracts
│   └── utils/                  # Shared constants, colors, and helpers
├── .env.example                # Documented environment variable template
├── docker-compose.yml          # Local multi-service stack
├── Dockerfile                  # Multi-stage Next.js production image
├── package.json                # Frontend scripts and dependencies
└── README.md
```

The production-oriented dashboard is the application at the repository root. A separate, simulator-backed UI prototype is in [New frontend/README.md](New%20frontend/README.md); it is not part of the root Docker Compose stack. The [Project Proposal - SDP.pdf](Project%20Proposal%20-%20SDP.pdf) is included as the project's academic proposal.

## Development and tests

Run frontend lint and production compilation from the repository root:

```bash
npm run lint
npm run build
```

Run backend tests from the backend directory after installing `backend/requirements.txt`:

```bash
cd backend
.venv/bin/python -m pytest
```

The backend tests cover the state and report APIs, scenario validation, the safety validation endpoint, simulator telemetry, and safety-check counts.

## Known limitations

- The 20-node digital twin remains simulated, even when it is scaled by live national trends. It is not a real-time monitor or controller for substations, lines, or feeders.
- PGCB polling is disabled until a reachable, authorized machine-readable `GRID_SOURCE_URL` is configured. A portal that requires interactive authentication or JavaScript rendering needs a supported export/API integration; the app does not bypass access controls.
- A six-month AI baseline is available after importing an authorized historical hourly CSV or collecting enough readings. The importer does not invent or reconstruct missing history.
- TimescaleDB/PostgreSQL stores hourly national readings and sampled virtual-node snapshots. The in-memory simulator's current scenario and state reset when the API restarts.
- Report downloads are JSON. The current report implementation provides load-history summary metrics; report types are accepted as labels but do not yet represent separate alert/analytics datasets.
- Settings and profile pages are UI demonstrations; they do not provide authenticated accounts or persist user preferences/profile edits.
- Redis and Celery are optional for local development. Without Celery, reports are generated synchronously by the API.
- Forecasts, national-to-local scaling, grid values, thresholds, and scenario effects are illustrative, not validated engineering models. Gemini is an optional language-model adviser and must not be used as an operational decision system.

## Safety and intended use

GridPulse is for coursework, prototyping, and software demonstrations. It is not an operational grid-management system, a safety certification tool, or engineering guidance. Never connect it to physical grid equipment or use its output to make real-world dispatch, protection, or infrastructure decisions.
