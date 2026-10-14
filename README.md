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
- **Demand forecast:** 24 future hourly points from a gradient-boosted model trained on generated sample patterns. XGBoost is used when available; scikit-learn is the fallback.
- **Alerts and safety:** threshold-based load, voltage, frequency, and renewable-generation alerts, plus node and transmission-line limit checks. The safety endpoint validates a proposed flow without applying it.
- **Scenario simulator:** heatwave, demand spike, solar failure, and node failure scenarios with impact summaries.
- **Reports:** generate and download a JSON summary from recent simulated telemetry; report work can be queued through Celery when enabled.
- **Operator UI:** reports, settings, and profile pages are included in the dashboard.

All measurements and scenarios are generated for demonstration purposes.

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
	API -->|report jobs| Redis[(Redis)]
	Redis --> Worker[Celery report worker]
	Worker --> Redis
```

The API owns the simulator and emits a full snapshot on a configurable interval (three seconds by default). The browser loads `/api/v1/state`, then subscribes to `/api/v1/ws/live`; it reconnects if the stream is interrupted and can show bundled demo data while the API is unavailable. PostgreSQL persistence is optional for local development. Redis is used by Celery for queued report generation; WebSocket updates are sent directly by FastAPI.

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

The Compose file uses a development-only database password. Do not reuse it outside a local environment.

## Run locally without Docker

You need Node.js 22 or newer, npm, Python 3.12, and (optionally) PostgreSQL/TimescaleDB and Redis. The API can run without those optional services in in-memory mode.

### Frontend

```bash
npm ci
npm run dev
```

The development site is <http://localhost:3000>. For a production build, run `npm run build` and then `npm start`.

### Backend API

From the repository root, create an isolated Python environment and install the backend requirements:

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

## Configuration

The root [.env.example](.env.example) documents the available settings. Copy it to `.env.local` for Next.js, and export the backend values in the shell that runs Uvicorn (or configure them in your process manager). `.env*` files are ignored by Git except for `.env.example`.

| Variable                   | Used by        | Default                                       | Purpose                                                                                                     |
| -------------------------- | -------------- | --------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `NEXT_PUBLIC_API_BASE_URL` | Frontend       | `http://localhost:8000/api/v1`                | HTTP API base URL, compiled into the frontend bundle.                                                       |
| `NEXT_PUBLIC_WS_URL`       | Frontend       | `ws://localhost:8000/api/v1/ws/live`          | Live telemetry WebSocket URL, compiled into the frontend bundle.                                            |
| `DATABASE_URL`             | Backend        | unset                                         | Async SQLAlchemy connection URL, for example `postgresql+asyncpg://user:password@localhost:5432/gridpulse`. |
| `REDIS_URL`                | Backend/worker | `redis://localhost:6379/0`                    | Celery broker and result backend.                                                                           |
| `CELERY_ENABLED`           | Backend        | `false`                                       | Queue report generation instead of generating reports inline.                                               |
| `GRID_TICK_SECONDS`        | Backend        | `3`                                           | Telemetry simulator interval in seconds (minimum effective interval: one second).                           |
| `CORS_ORIGINS`             | Backend        | `http://localhost:3000,http://127.0.0.1:3000` | Comma-separated browser origins allowed by the API.                                                         |

In Docker Compose, frontend URLs are supplied as Docker build arguments, while the backend service URLs are set in the Compose service environment.

## HTTP and WebSocket API

All HTTP routes are under `/api/v1`.

| Method | Path                       | Description                                                                                                        |
| ------ | -------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `GET`  | `/health`                  | API status, node count, database mode, and connected WebSocket clients.                                            |
| `GET`  | `/state`                   | Current full snapshot: summary, nodes, connections, history, forecast, alerts, safety checks, and latest scenario. |
| `GET`  | `/telemetry?limit=48`      | Recent aggregate simulator history; the requested limit is bounded to 1–96.                                        |
| `GET`  | `/alerts`                  | Current anomaly alerts.                                                                                            |
| `GET`  | `/safety`                  | Current node/line checks and counts by status.                                                                     |
| `POST` | `/safety/validate`         | Validate a proposed flow against a connection capacity; no grid action is taken.                                   |
| `POST` | `/simulations`             | Apply one of the four supported scenarios and return a snapshot.                                                   |
| `POST` | `/reports/generate`        | Generate a report inline or enqueue it with Celery.                                                                |
| `GET`  | `/reports/tasks/{task_id}` | Retrieve queued report status and its result when complete.                                                        |
| `WS`   | `/ws/live`                 | Initial snapshot followed by simulator snapshots.                                                                  |

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
│   │   ├── celery_app.py       # Celery broker/result configuration
│   │   ├── database.py         # Optional TimescaleDB setup and telemetry writes
│   │   ├── forecasting.py      # Synthetic training data and 24-step forecast
│   │   ├── main.py             # FastAPI routes, lifecycle, telemetry loop, WebSocket
│   │   ├── settings.py         # Backend environment configuration
│   │   ├── simulator.py        # Grid model, scenarios, alerts, safety, reports
│   │   └── tasks.py            # Background report task
│   ├── tests/
│   │   ├── test_api.py
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

## Development and tests

Run frontend lint and production compilation from the repository root:

```bash
npm run lint
npm run build
```

Run backend tests from the backend directory after installing `backend/requirements.txt`:

```bash
cd backend
../backend/.venv/bin/python -m pytest
```

The backend tests cover the state and report APIs, scenario validation, the safety validation endpoint, simulator telemetry, and safety-check counts.

## Known limitations

- The simulator is the source of current state and its rolling history is held in memory. TimescaleDB receives telemetry writes, but the current state/history/report endpoints do not query historical rows back from the database; restarting the API resets the in-memory simulation history.
- Report downloads are JSON. The current report implementation provides load-history summary metrics; report types are accepted as labels but do not yet represent separate alert/analytics datasets.
- Settings and profile pages are UI demonstrations; they do not provide authenticated accounts or persist user preferences/profile edits.
- Redis and Celery are optional for local development. Without Celery, reports are generated synchronously by the API.
- Forecasts, grid values, thresholds, and scenario effects are illustrative, not validated engineering models.

## Safety and intended use

GridPulse is for coursework, prototyping, and software demonstrations. It is not an operational grid-management system, a safety certification tool, or engineering guidance. Never connect it to physical grid equipment or use its output to make real-world dispatch, protection, or infrastructure decisions.
