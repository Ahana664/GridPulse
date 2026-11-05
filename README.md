# GridPulse ⚡
### Smart Grid Operations Digital Twin & Decision-Support Platform

GridPulse is an academic smart-grid operations simulator and dashboard designed to demonstrate how modern software engineering, artificial intelligence, machine learning, and real-time data processing can support electrical grid monitoring and contingency analysis.

It models a 20-node virtual distribution grid across five zones, streams simulated telemetry, forecasts electricity demand, detects abnormal grid conditions, validates proposed power-routing suggestions against deterministic safety rules, and allows operators to explore different grid-shock scenarios.

GridPulse also supports optional integration with Bangladesh's national grid data through Power Grid Company of Bangladesh (PGCB) data sources, providing national-level generation, demand, and fuel-mix information.

**GridPulse is a simulation and decision-support platform only. It does not connect to, monitor, or control physical circuit breakers, relays, switchgear, substations, or transmission infrastructure.**

---

## Table of Contents

- [Abstract](#abstract)
- [Project Objectives](#project-objectives)
- [Scope and Limitations](#scope-and-limitations)
- [Key Features](#key-features)
- [Software Requirements Specification](#software-requirements-specification)
  - [Functional Requirements](#functional-requirements)
  - [Non-Functional Requirements](#non-functional-requirements)
- [Technical Stack](#technical-stack)
- [System Architecture](#system-architecture)
- [Architecture and Data Flow](#architecture-and-data-flow)
- [Grid Hierarchy](#grid-hierarchy)
- [Software Development Life Cycle](#software-development-life-cycle-sdlc)
- [System Design and UML](#system-design-and-uml)
  - [Use-Case Diagram](#use-case-diagram)
  - [Data Flow Diagram](#data-flow-diagram)
  - [Activity Diagram](#activity-diagram)
  - [Sequence Diagram](#sequence-diagram)
  - [Conceptual Class Diagram](#conceptual-class-diagram)
- [Testing Strategy](#testing-strategy)
  - [Testing Types](#testing-types)
  - [Equivalence Partitioning](#equivalence-partitioning-ep)
  - [Boundary Value Analysis](#boundary-value-analysis-bva)
- [Test Cases](#test-cases)
- [Installation and Setup](#installation-and-setup)
  - [Docker Compose](#run-with-docker-compose)
  - [Local Installation](#run-locally-without-docker)
- [Configuration](#configuration)
- [Supabase and Gemini Configuration](#configure-supabase-and-gemini)
- [PGCB Data Integration](#pgcb-data-integration)
- [Database Architecture](#database-architecture)
- [HTTP and WebSocket API](#http-and-websocket-api)
- [Development and Testing](#development-and-testing)
- [Known Limitations](#known-limitations)
- [Safety and Intended Use](#safety-and-intended-use)
- [Team Contributions](#team-contributions)
- [Conclusion](#conclusion)

---

## Abstract

Modern electrical power grids face significant operational challenges due to increasing intermittent renewable energy penetration, unpredictable consumer demand surges, and localized transmission infrastructure bottlenecks.

Traditional Supervisory Control and Data Acquisition (SCADA) systems primarily provide reactive monitoring without integrated predictive forecasting or safety-constrained autonomous mitigation.

GridPulse addresses these challenges through an interactive, full-stack smart-grid operations digital twin and decision-support web platform.

The platform features a dual-engine architecture combining artificial intelligence with deterministic engineering validation.

Its major capabilities include:

- An automated machine-learning pipeline using XGBoost Regressor, backed by Scikit-Learn HistGradientBoosting as a fallback, for 24-hour electricity-demand forecasting.
- An isolated, rule-based safety validation engine that verifies proposed power-routing suggestions against configured physical line capacities before operator presentation.
- A live bridge to Bangladesh national grid telemetry through PGCB data sources.
- A four-tier grid hierarchy: National → Division → District → Feeder.
- Real-time anomaly detection and alert generation.
- Dynamic shock scenario simulation, including heatwaves, demand spikes, solar failures, and substation failures.
- Asynchronous report compilation through Celery and Redis.
- Contextual decision advisory powered by Google Gemini API.

GridPulse is implemented using Next.js 16, React 19, TypeScript 5, Tailwind CSS 4, D3.js, Python 3.12, FastAPI, PostgreSQL 16 with TimescaleDB, and Docker Compose.

The platform demonstrates how modern reactive web architectures and AI-assisted analysis can support grid reliability while maintaining strict operational safety boundaries.

---

## Project Objectives

The primary objectives of GridPulse are:

1. To display simulated grid topology, electrical load, voltage, energy flow, and node status.
2. To detect abnormal telemetry and generate appropriate alerts.
3. To generate electricity-demand forecasts using available historical and simulated telemetry.
4. To validate predicted or simulated conditions against configured deterministic safety rules.
5. To simulate different grid-shock scenarios and analyse their potential effects.
6. To store and display relevant telemetry, alerts, predictions, and simulation results.
7. To integrate national-level electricity generation, demand, and fuel-mix information from available PGCB data sources.
8. To provide contextual decision support through AI-assisted analysis while keeping safety validation independent.

---

## Scope and Limitations

### Project Scope

The project includes:

- A 20-node virtual distribution grid across five zones.
- 20 high-voltage connections operating at designated 132 kV and 230 kV levels with configured MW limits.
- REST API and WebSocket communication.
- PostgreSQL 16 with TimescaleDB for time-series data persistence.
- PGCB national data ingestion.
- Machine-learning-based demand forecasting.
- Telemetry anomaly detection.
- Deterministic safety validation.
- Dynamic shock scenario simulation.
- Gemini-powered contextual advisory.
- Asynchronous JSON report generation.

### Limitations

- Node-level voltage and power readings are generated by a deterministic Python simulator, not live physical substation sensors.
- The application is a read-only decision-support system and does not actuate real grid equipment.
- National data availability depends on accessible public PGCB endpoints or authorized CSV backfill exports.
- When PostgreSQL is unavailable, the backend may use in-memory state, which resets after a process restart.
- Forecast quality depends on the availability and quality of historical hourly demand records.
- AI-generated suggestions are not automatically executed.

---

## Key Features

### 1. Overview Dashboard

- National generation and demand overview.
- Grid load and frequency monitoring.
- Regional demand and generation mix.
- Forecast visualization.
- Alert summaries.
- Interactive grid topology map.

### 2. Interactive Grid Mapping

- D3.js-powered visualization.
- Virtual nodes and transmission connections.
- Node status and line-loading information.
- Directional and animated energy flows.
- Individual node details.

### 3. Real-Time Telemetry Monitoring

- Simulated power, voltage, load percentage, and node status.
- WebSocket-based live updates.
- Configurable simulation interval.
- Voltage and load charts.
- Recent telemetry records.

### 4. AI-Based Demand Forecasting

- Forecasts the next 24 hourly demand values.
- XGBoost Regressor as the primary model.
- Scikit-Learn HistGradientBoosting as a fallback.
- Cyclic time features.
- National demand trend scaling when configured source data is available.

### 5. PGCB National Grid Integration

- Optional polling of public PGCB JSON, CSV, or HTML-table sources.
- National generation and demand normalization.
- Fuel-mix information.
- Historical national readings.
- Source-health monitoring.
- Four-tier grid hierarchy.

### 6. Anomaly Detection and Alerts

GridPulse detects configured abnormal conditions, including:

- Excessive grid loading.
- Low voltage.
- Frequency deviation.
- Renewable-generation abnormalities.

The documented default alert thresholds include:

| Parameter | Configured Condition |
|---|---|
| Load warning | Above 85% |
| Load critical | Above 95% |
| Voltage warning | Below 95% of nominal |
| Frequency deviation | \|f − 50\| ≥ 0.08 Hz |

These are application-configured simulation rules, not universal electrical safety standards.

### 7. Deterministic Safety Validation

- Validates proposed power-routing suggestions.
- Checks configured transmission-line capacities.
- Rejects negative values.
- Rejects unknown transmission lines.
- Rejects over-capacity proposals.
- Keeps safety validation separate from AI-generated suggestions.

The safety validation endpoint checks a proposal without applying it to physical infrastructure.

### 8. Dynamic Shock Scenario Simulator

GridPulse supports the following scenarios:

| Scenario | Simulation Effect |
|---|---|
| Heatwave | Consumer load increases by 11% |
| Demand Spike | Consumer load increases by 18% |
| Solar Failure | North/West solar generation drops to 28% |
| Substation Failure | SUB-C1 generation drops to 0 MW |

Operators can activate, evaluate, and reset supported scenarios to explore their simulated effects.

### 9. Contextual AI Advisory

- Google Gemini API integration.
- Analyses current telemetry, alerts, and historical context.
- Generates contextual decision-support recommendations.
- Any suggested power flow must pass deterministic safety validation before presentation.
- AI suggestions are never automatically executed.

### 10. Asynchronous Reporting

- Generates structured JSON reports.
- Compiles telemetry and analytics information.
- Supports inline report generation.
- Optional Celery/Redis background processing.
- Report download functionality.

### 11. Operator Interface

The dashboard also includes:

- Reports.
- Settings.
- Profile pages.
- Grid monitoring and simulation controls.

---

## Software Requirements Specification

### Functional Requirements

| ID | Requirement | Description |
|---|---|---|
| FR-01 | Real-Time Telemetry Streaming | Simulate and stream power, voltage, load percentage, and status for 20 nodes across five zones using WebSockets. Default interval: 3 seconds. |
| FR-02 | Topology and Energy Flow | Render a D3.js network map showing node status, line loading, and directional power flow. |
| FR-03 | ML Demand Forecasting | Forecast the next 24 hourly demand values using XGBoost or HistGradientBoosting fallback. |
| FR-04 | Anomaly Detection and Alerts | Generate warning/critical alerts for configured load, voltage, and frequency thresholds. |
| FR-05 | Deterministic Safety Validation | Validate proposed routing against line capacities. Reject negative, unknown-line, or over-capacity proposals. |
| FR-06 | Shock Scenario Sandbox | Activate, evaluate, and reset supported heatwave, demand spike, solar failure, and substation failure scenarios. |
| FR-07 | Asynchronous Reporting | Compile telemetry and analytics reports inline or through Celery/Redis and export JSON summaries. |
| FR-08 | PGCB National Grid Bridge | Poll and normalize JSON, CSV, or HTML data for national generation, demand, and fuel mix. |
| FR-09 | Hierarchical Grid Navigation | Support database-backed navigation from the national root through divisions, districts/substations, and feeders. |
| FR-10 | Contextual LLM Advisory | Use Gemini 2.5 Flash to synthesize current telemetry, alerts, and historical context; safety-check suggested power flows. |

### Non-Functional Requirements

| ID | Category | Requirement |
|---|---|---|
| NFR-01 | Performance | Target telemetry propagation below 50 ms after generation and 60 FPS during topology interaction. |
| NFR-02 | Reliability | Continue baseline simulation when PostgreSQL, Redis, or external PGCB feeds are unavailable, using configured fallback behaviour. |
| NFR-03 | Security | Keep Gemini and database credentials in backend environment variables and apply controlled CORS policies. |
| NFR-04 | Scalability | Use timestamp-partitioned TimescaleDB hypertables for time-series data. |
| NFR-05 | Usability | Provide a responsive Tailwind CSS 4 interface with a dark control-room theme. |

---

## Technical Stack

| Area | Technologies |
|---|---|
| Web Application | Next.js 16, React 19, TypeScript 5 |
| Styling | Tailwind CSS 4 |
| Visualization | D3.js 7, Recharts 3, Lucide React |
| Backend API | Python 3.12, FastAPI, Uvicorn, Pydantic |
| Simulation | NumPy, Pandas |
| Machine Learning | Scikit-Learn, XGBoost CPU |
| Live Updates | FastAPI WebSockets |
| Background Tasks | Celery 5, Redis |
| Database | PostgreSQL 16, TimescaleDB |
| Database Integration | SQLAlchemy Async, asyncpg |
| AI Advisory | Google Gemini API |
| Containerization | Docker Compose |
| Frontend Checks | ESLint 9, Next.js production build |
| Backend Testing | pytest, FastAPI TestClient, httpx |

Frontend dependency versions are declared in `package.json` and pinned through `package-lock.json`.

Backend dependencies are declared in `backend/requirements.txt`.

---

## System Architecture

GridPulse follows a modular full-stack architecture.

### Main System Components

| Component | Responsibility |
|---|---|
| Grid User / Infrastructure Manager | Views the dashboard and selects scenarios. |
| Dashboard | Displays topology, telemetry, forecasts, simulation results, and alerts. |
| Backend | Coordinates requests and data exchange between modules. |
| Grid Simulator | Generates simulated telemetry and applies shock scenarios. |
| AI Forecast / Analysis Module | Forecasts demand and analyses grid response. |
| Safety Rule Engine | Validates conditions against configured safety rules. |
| Database | Stores supported telemetry and result records. |

### Architecture Diagram

```mermaid
flowchart TD
    User[Grid User / Infrastructure Manager]
    Dashboard[Next.js Dashboard]
    API[FastAPI Backend]

    Simulator[20-Node Grid Simulator]
    Telemetry[Telemetry Processor]
    Forecast[ML Forecasting Module]
    Anomaly[Anomaly Detection]
    Safety[Deterministic Safety Engine]
    Shock[Shock Scenario Simulator]

    PGCB[PGCB Data Source]
    Gemini[Gemini AI Advisory]
    DB[(PostgreSQL / TimescaleDB)]
    Redis[(Redis)]
    Celery[Celery Worker]

    User --> Dashboard
    Dashboard <-->|HTTP / WebSocket| API

    API --> Simulator
    Simulator --> Telemetry
    Telemetry --> Anomaly
    Telemetry --> Forecast

    API --> Shock
    Shock --> Safety

    API --> Safety
    PGCB --> API
    API --> Gemini
    Gemini --> Safety

    API --> DB
    API --> Redis
    Redis --> Celery
    Celery --> Redis
```

### Architecture and Data Flow

The API owns the virtual 20-node simulator and emits telemetry snapshots at a configurable interval, three seconds by default.

The browser initially loads:

`/api/v1/state`

It then subscribes to:

`/api/v1/ws/live`

The frontend reconnects if the WebSocket stream is interrupted and labels its offline preview as demonstration data.

If `GRID_SOURCE_URL` is configured, a backend poller reads available national aggregates hourly, stores the readings, and applies a bounded trend factor to the simulation.

National aggregate values are not copied onto microgrid nodes or presented as node-level measurements.

PostgreSQL persistence is optional during local development. Virtual-node snapshots are sampled every five minutes by default, while national readings are stored during source polling.

Redis and Celery handle queued report generation. Gemini is called only when an operator requests analysis and the backend API key is configured.

---

## Grid Hierarchy

GridPulse supports a separate database-backed national grid hierarchy.

The hierarchy follows four levels:

```text
National
   |
   +-- Division
          |
          +-- District / Substation
                    |
                    +-- Feeder
```

The hierarchy includes:

1. National root.
2. Eight Bangladesh administrative division hubs.
3. Source-provided district substations.
4. Source-provided feeder clusters.

### Hierarchical Data Management

- PostgreSQL stores node identity and `parent_node_id` separately from time-series readings.
- Only the national root and division names are initialized locally.
- District and feeder information must originate from available source records.
- Nodes without source records are labelled as unmeasured.
- No district, feeder, capacity, demand, or generation values are invented.
- Optional division weights are NULL by default.
- Proportional estimates are only displayed when all eight explicit division weights sum to 100%.
- Actual division readings take precedence over proportional estimates.

The original 20-node digital twin remains clearly labelled as simulated data.

---

## Software Development Life Cycle (SDLC)

GridPulse follows an iterative Software Development Life Cycle (SDLC), allowing individual modules to be developed, tested, evaluated, and refined incrementally.

| SDLC Phase | GridPulse Activities | Deliverable |
|---|---|---|
| Planning | Define problem, users, scope, constraints, and schedule. | Project Plan |
| Requirements Analysis | Specify monitoring, forecasting, safety, simulation, dashboard, and storage requirements. | SRS |
| System Design | Create use-case, architecture, activity, sequence, and class diagrams. | Design Models |
| Implementation | Develop dashboard, backend, simulator, analysis/safety modules, and persistence. | Working Modules |
| Testing | Execute unit, integration, functional, and system tests. | Test Results |
| Deployment / Demo | Run the application in the intended demonstration environment. | Demo Build |
| Maintenance | Fix defects and revise rules or modules as needed. | Updated Version |

---

## System Design and UML

GridPulse uses UML-based system design to represent the interactions, workflows, and conceptual structure of the application.

### Use-Case Diagram

The use-case diagram represents interactions between the Grid User / Infrastructure Manager and the GridPulse platform.

The primary use cases include:

- View dashboard.
- Monitor grid topology.
- View real-time telemetry.
- View forecasts.
- Receive alerts.
- Select and run shock scenarios.
- View simulation results.
- Request AI advisory.
- View reports.

### Data Flow Diagram

The data flow represents communication between the dashboard, backend, simulator, analysis modules, safety engine, and database.

The main flow is:

1. The dashboard requests grid information.
2. The backend retrieves or generates simulated telemetry.
3. The telemetry processor analyses incoming data.
4. Forecasting and anomaly detection modules process relevant information.
5. The safety engine validates applicable conditions and proposals.
6. Results are stored where persistence is available.
7. The dashboard displays updated grid information and alerts.

### Activity Diagram

The activity workflow represents the general operational process:

1. Start application.
2. Initialize backend and simulator.
3. Generate simulated telemetry.
4. Process telemetry.
5. Detect abnormal conditions.
6. Generate forecasts.
7. Validate relevant conditions.
8. Store available results.
9. Update dashboard.
10. Continue monitoring or process a selected scenario.

### Sequence Diagram

The system includes three major sequence workflows.

**1. Live Dashboard and Alerts**

- Dashboard connects to the backend.
- Backend supplies telemetry.
- Telemetry processor evaluates the data.
- Anomaly detection identifies abnormal conditions.
- Alert information is returned to the dashboard.

**2. Shock Simulator**

- Operator selects a supported scenario.
- Backend activates the simulator.
- Simulator updates virtual grid conditions.
- Analysis and safety modules evaluate the results.
- Results are stored and displayed.

**3. Forecast and Safety-Gated Advisory**

- Dashboard requests an analysis.
- Backend retrieves relevant telemetry and historical context.
- Forecasting and AI advisory modules generate predictions or suggestions.
- Suggested power flows are submitted to the deterministic safety engine.
- Validated results are presented to the operator.

### Conceptual Class Diagram

The following conceptual classes represent the major responsibilities of the system.

| Class | Responsibilities |
|---|---|
| `GridNode` | Stores node ID, load, voltage, and status; updates telemetry. |
| `TelemetryProcessor` | Processes incoming telemetry and detects anomalies. |
| `ForecastModel` | Predicts future demand from input data. |
| `SafetyRuleEngine` | Validates grid conditions against configured rules. |
| `ShockSimulator` | Applies supported shock scenarios to the simulated grid. |
| `AlertManager` | Creates alert type and severity details from detected conditions. |
| `Dashboard` | Displays grid status, predictions, simulation results, and alerts. |

These are conceptual design classes. Their names and exact methods should be aligned with the implementation if different class names are used.

---

## Testing Strategy

The testing strategy covers individual functions, component communication, functional requirements, and complete application workflows.

### Testing Types

| Testing Type | Purpose | GridPulse Example |
|---|---|---|
| Unit Testing | Test one component in isolation. | Test safety threshold comparison. |
| Integration Testing | Verify communication between components. | Verify simulator telemetry reaches the backend and dashboard. |
| Functional Testing | Verify a function against its requirement. | Check that abnormal telemetry triggers an alert. |
| System Testing | Verify a complete workflow. | Run a shock scenario through analysis, safety validation, storage, and display. |
| Usability Testing | Check clarity of the user interface. | Confirm warnings and affected-node information are understandable. |

### Equivalence Partitioning (EP)

Equivalence Partitioning divides input values into representative valid and invalid classes.

For GridPulse, supported scenario names form a valid input class, while unsupported scenario names form an invalid input class.

| Test ID | Input Class | Example | Expected Result |
|---|---|---|---|
| EP-01 | Valid supported scenario | Sudden demand increase | Accept if parameters are valid. |
| EP-02 | Valid supported scenario | Node failure | Accept if supported by the simulator. |
| EP-03 | Invalid scenario | Unknown scenario name | Reject and show validation message. |
| EP-04 | Invalid parameter | Negative value when prohibited | Reject or request corrected input. |

### Boundary Value Analysis (BVA)

Boundary Value Analysis tests inputs around a configured threshold.

Let `T` represent a configured capacity or anomaly threshold.

The three important boundary conditions are:

- `T - 1`: Just below the threshold.
- `T`: Exactly at the threshold.
- `T + 1`: Just above the threshold.

| Test ID | Input | Purpose | Expected Result |
|---|---|---|---|
| BVA-01 | T − 1 unit | Below threshold | Follow configured below-threshold rule. |
| BVA-02 | T | Exactly at threshold | Follow documented boundary rule. |
| BVA-03 | T + 1 unit | Above threshold | Trigger warning if values above T are configured as abnormal. |

The exact threshold and whether equality is considered safe must be determined by the configured project rules.

---

## Test Cases

The following test cases are designed to evaluate the primary GridPulse functionalities.

**Note:** Actual Result and Status are intentionally left for completion during real test execution. Their presence in this documentation does not imply that all tests have passed.

### TC-01: Dashboard Display

| Field | Description |
|---|---|
| Test Case ID | TC-GP-BVA-01 |
| Test Scenario | Verify that the dashboard displays grid topology and current simulated grid information. |
| Preconditions | GridPulse is running; simulator and backend are available. |
| Test Steps | 1. Open dashboard. 2. Start simulator. 3. Observe topology, load, voltage, energy flow, and node status. 4. Compare displayed values with simulator output. |
| Input Data | Valid simulated telemetry for configured grid nodes. |
| Expected Result | Dashboard displays available grid topology and telemetry corresponding to simulator output. |
| Actual Result | To be completed during test execution. |
| Status | Pass / Fail |
| Remarks | Covers FR-01 and FR-02. |

### TC-02: Telemetry Processing

| Field | Description |
|---|---|
| Test Case ID | TC-GP-BVA-02 |
| Test Scenario | Verify that incoming simulated telemetry is processed and reflected in grid status. |
| Preconditions | Backend and telemetry processor are running. |
| Test Steps | 1. Start telemetry generation. 2. Submit/receive a known telemetry sample. 3. Check processing output. 4. Check dashboard value. |
| Input Data | Known sample containing node ID, load, voltage, and timestamp. |
| Expected Result | Sample is processed correctly and corresponding grid status is updated. |
| Actual Result | To be completed during test execution. |
| Status | Pass / Fail |
| Remarks | Integration test between simulator, backend, and dashboard. |

### TC-03: Anomaly Detection

| Field | Description |
|---|---|
| Test Case ID | TC-GP-BVA-03 |
| Test Scenario | Verify that abnormal telemetry is detected using configured anomaly rules. |
| Preconditions | Anomaly detection is active and thresholds are configured. |
| Test Steps | 1. Submit normal telemetry. 2. Confirm normal status. 3. Submit telemetry violating a configured rule. 4. Observe detection output and dashboard. |
| Input Data | One normal sample and one rule-violating sample. |
| Expected Result | Normal data is handled normally; abnormal data is flagged and an appropriate warning is available to the dashboard. |
| Actual Result | To be completed during test execution. |
| Status | Pass / Fail |
| Remarks | Use configured project rules rather than assuming universal electrical thresholds. |

### TC-04: AI Demand Forecasting

| Field | Description |
|---|---|
| Test Case ID | TC-GP-BVA-04 |
| Test Scenario | Verify that the forecast function generates a demand prediction from available telemetry. |
| Preconditions | Forecast model is available and sufficient input data exists. |
| Test Steps | 1. Open forecasting function. 2. Select/load grid telemetry. 3. Run forecast. 4. Inspect prediction and dashboard output. |
| Input Data | Historical/current simulated grid telemetry. |
| Expected Result | Model returns a prediction in the expected format and dashboard displays it with appropriate labels. |
| Actual Result | To be completed during test execution. |
| Status | Pass / Fail |
| Remarks | Prediction accuracy requires separate evaluation against a dataset and metric. |

### TC-05: Safety Rule Validation

| Field | Description |
|---|---|
| Test Case ID | TC-GP-05 |
| Test Scenario | Verify that the Safety Rule Engine validates a predicted or simulated grid condition. |
| Preconditions | Configured safety rules and thresholds are available. |
| Test Steps | 1. Submit a condition within configured limits. 2. Record status. 3. Submit a condition violating a configured rule. 4. Compare returned statuses. |
| Input Data | One within-limit condition and one rule-violating condition. |
| Expected Result | The first condition receives the configured safe status; the rule-violating condition receives the corresponding warning/unsafe status. |
| Actual Result | To be completed during test execution. |
| Status | Pass / Fail |
| Remarks | Decision-table tests can cover combinations of load, voltage, and node status. |

### TC-06: Shock Scenario Simulator

| Field | Description |
|---|---|
| Test Case ID | TC-GP-BVA-06 |
| Test Scenario | Verify the complete shock-scenario simulation workflow. |
| Preconditions | Application, simulator, backend, analysis module, safety engine, and database are available. |
| Test Steps | 1. Open Shock Scenario Simulator. 2. Select a supported scenario. 3. Start simulation. 4. Verify updated simulated telemetry. 5. Verify analysis. 6. Verify safety validation. 7. Verify result storage and dashboard display. |
| Input Data | Supported scenario such as sudden demand increase, heatwave, generation failure, or node failure; valid parameters. |
| Expected Result | Scenario is applied in the simulated grid; telemetry is generated; impact is analysed; safety status is produced; and results are stored and displayed. |
| Actual Result | To be completed during test execution. |
| Status | Pass / Fail |
| Remarks | End-to-end test; no physical grid control is performed. |

### TC-07: Dashboard and Alerts

| Field | Description |
|---|---|
| Test Case ID | TC-GP-BVA-07 |
| Test Scenario | Verify real-time grid information and alert display for abnormal conditions. |
| Preconditions | Dashboard, backend, simulator, telemetry processor, and anomaly/safety engine are available. |
| Test Steps | 1. Open dashboard. 2. Observe normal telemetry. 3. Submit abnormal telemetry that violates a configured rule. 4. Wait for processing. 5. Check alert message and affected node/condition. |
| Input Data | Normal telemetry followed by a rule-violating sample. |
| Expected Result | Grid information is displayed; normal input does not trigger an unnecessary alert; abnormal input triggers an appropriate alert matching the detected condition. |
| Actual Result | To be completed during test execution. |
| Status | Pass / Fail |
| Remarks | Covers monitoring, anomaly display, and safety alerts. |

### TC-08: Result Storage

| Field | Description |
|---|---|
| Test Case ID | TC-GP-BVA-08 |
| Test Scenario | Verify that generated simulation or alert results can be stored and retrieved. |
| Preconditions | Database connection is available and a result has been generated. |
| Test Steps | 1. Run a simulation or generate an alert. 2. Allow the backend to store the result. 3. Check storage confirmation. 4. Retrieve the record using the supported application/database view. |
| Input Data | Generated simulation result or alert record. |
| Expected Result | Record is stored with relevant identifying information and can be retrieved without being associated with the wrong scenario or node. |
| Actual Result | To be completed during test execution. |
| Status | Pass / Fail |
| Remarks | Confirm exact database fields against implementation. |

### TC-09: Invalid Shock Input

| Field | Description |
|---|---|
| Test Case ID | TC-GP-BVA-09 |
| Test Scenario | Verify that unsupported scenario names or invalid parameters are handled safely. |
| Preconditions | Shock Scenario Simulator is accessible. |
| Test Steps | 1. Open simulator. 2. Enter an unsupported scenario or invalid parameter. 3. Submit. 4. Observe response and application stability. |
| Input Data | Unsupported scenario type or parameter outside accepted range. |
| Expected Result | System rejects or safely handles invalid input, displays a clear message, and does not falsely report a successful simulation. |
| Actual Result | To be completed during test execution. |
| Status | Pass / Fail |
| Remarks | Negative functional test; accepted ranges must match the implementation. |

### TC-10: Alert Consistency

| Field | Description |
|---|---|
| Test Case ID | TC-GP-BVA-10 |
| Test Scenario | Verify that dashboard alert details match the backend detection result. |
| Preconditions | Anomaly detection is active and dashboard receives backend results. |
| Test Steps | 1. Generate a known abnormal condition. 2. Record backend alert type/severity and affected node. 3. Observe dashboard alert. 4. Compare details. |
| Input Data | Telemetry that triggers a known configured anomaly rule. |
| Expected Result | Dashboard displays the corresponding alert and affected condition/node consistently with the backend result. |
| Actual Result | To be completed during test execution. |
| Status | Pass / Fail |
| Remarks | Integration test for alert communication. |

---

## Installation and Setup

### Prerequisites

For local development:

- Node.js 22 or newer.
- npm.
- Python 3.12.
- Docker Engine or Docker Desktop with Compose plugin (for containerized setup).
- PostgreSQL/TimescaleDB (optional).
- Redis (optional).

The backend can run without PostgreSQL and Redis using configured in-memory fallback behaviour.

### Run with Docker Compose

The easiest way to start the complete application is through Docker Compose.

From the repository root:

```bash
docker compose up --build
```

Once the containers are running, access:

| Service | URL |
|---|---|
| Dashboard | http://localhost:3000 |
| FastAPI Swagger UI | http://localhost:8000/docs |
| FastAPI ReDoc | http://localhost:8000/redoc |
| API Health | http://localhost:8000/api/v1/health |

Docker Compose starts:

- Frontend.
- Backend API.
- Telemetry simulator.
- Redis.
- Celery worker.
- TimescaleDB.

The database volume is named `gridpulse-db`.

To stop services while preserving database contents:

```bash
docker compose down
```

To remove the database volume as well:

```bash
docker compose down -v
```

**Warning:** Removing the volume also deletes locally stored telemetry data.

The Compose file uses a development-only database password. Do not reuse it outside a local development environment.

### Run Locally Without Docker

#### 1. Frontend Setup

From the repository root:

```bash
npm ci
npm run dev
```

Open:

http://localhost:3000

For a production build:

```bash
npm run build
npm start
```

#### 2. Backend Setup

Create a Python virtual environment:

```bash
python3.12 -m venv backend/.venv
```

Install backend dependencies:

```bash
backend/.venv/bin/python -m pip install -r backend/requirements.txt
```

Start the FastAPI server from the repository root:

```bash
backend/.venv/bin/uvicorn app.main:app --reload --app-dir backend
```

The backend API is available at:

http://localhost:8000

#### 3. Optional Background Report Processing

Start PostgreSQL/TimescaleDB and Redis, configure the relevant environment variables, and run the Celery worker:

```bash
backend/.venv/bin/celery --workdir backend -A app.celery_app:celery_app worker --loglevel=INFO
```

Enable background report generation:

```env
CELERY_ENABLED=true
```

If Celery is unavailable when a report is submitted, the API attempts inline report generation.

#### 4. Local Database Dry Run

If PostgreSQL is installed locally, initialize a development database and configure `DATABASE_URL`.

Example:

```bash
cd backend
```

Generate and persist 48 hours of simulated telemetry:

```bash
DATABASE_URL='postgresql+asyncpg://gridpulse@127.0.0.1:55432/gridpulse' .venv/bin/python -m app.seed_simulation_history --hours 48
```

The command verifies and prints:

- Row count.
- Distinct hours.
- Node count.
- Timestamp range.

It inserts only `source='simulator'` telemetry. It does not fabricate PGCB history or train the national-demand forecaster.

Actual PGCB history must originate from an authorized feed or CSV backfill.

---

## Configuration

The root `.env.example` file documents the available configuration variables.

For local Uvicorn:

```bash
cp .env.example backend/.env
```

For Docker Compose:

```bash
cp .env.example .env
```

For frontend URL overrides, use `.env.local` where appropriate.

Environment files are ignored by Git except for `.env.example`.

### Environment Variables

| Variable | Used By | Default | Purpose |
|---|---|---|---|
| `NEXT_PUBLIC_API_BASE_URL` | Frontend | `http://localhost:8000/api/v1` | HTTP API base URL. |
| `NEXT_PUBLIC_WS_URL` | Frontend | `ws://localhost:8000/api/v1/ws/live` | Live telemetry WebSocket URL. |
| `DATABASE_URL` | Backend | Unset | Async SQLAlchemy database connection. |
| `GRID_SOURCE_URL` | Backend | Unset | Public PGCB JSON, CSV, or HTML-table endpoint. |
| `SUPABASE_URL` | Backend | Unset | Supabase project URL. |
| `SUPABASE_SERVICE_ROLE_KEY` | Backend | Unset | Backend-only Supabase API key. |
| `SUPABASE_ANON_KEY` | Backend | Unset | Optional Supabase API key when RLS allows access. |
| `SUPABASE_TABLE` | Backend | `hourly_generation` | Supabase REST table/view name. |
| `GRID_SOURCE_POLL_SECONDS` | Backend | `3600` | National source polling interval. Minimum 60 seconds. |
| `GRID_SOURCE_TIMEZONE` | Backend | `Asia/Dhaka` | Timezone for naive source timestamps. |
| `GRID_NATIONAL_BASELINE_DEMAND_MW` | Backend | `15000` | Reference national demand for trend scaling. |
| `GRID_PERSIST_INTERVAL_SECONDS` | Backend | `300` | Minimum interval between persisted simulator snapshots. |
| `GEMINI_API_KEY` | Backend | Unset | Optional Gemini API key. |
| `GEMINI_MODEL` | Backend | `gemini-3-flash-preview` | Configured Gemini model. |
| `REDIS_URL` | Backend/Worker | `redis://localhost:6379/0` | Celery broker and result backend. |
| `CELERY_ENABLED` | Backend | `false` | Enables queued report generation. |
| `GRID_TICK_SECONDS` | Backend | `3` | Simulator update interval. |
| `CORS_ORIGINS` | Backend | `http://localhost:3000,http://127.0.0.1:3000` | Allowed browser origins. |

In Docker Compose, frontend URLs are supplied as build arguments, while backend configuration is passed from the repository-root `.env`.

The frontend calls:

`POST /api/v1/live-data/sync`

when the operator selects **Sync live source now**.

The frontend never receives Supabase or Gemini credentials.

Gemini is called only when the operator selects **Run analysis**.

---

## Configure Supabase and Gemini

### Supabase REST Integration

1. Copy `.env.example` to `backend/.env` for local development or the repository-root `.env` for Docker Compose.
2. Set `SUPABASE_URL` to the Supabase project URL.
3. Set `SUPABASE_SERVICE_ROLE_KEY` to a backend-only key, or use `SUPABASE_ANON_KEY` if the table's Row Level Security policy permits reading.
4. Keep `SUPABASE_TABLE=hourly_generation` unless the table has another name.
5. Restart the backend after configuration changes.

The Supabase REST integration reads historical generation records from the configured table.

The current query expects a sortable `datetime` column.

### Gemini API Integration

Configure:

```env
GEMINI_API_KEY=your_api_key
GEMINI_MODEL=gemini-3-flash-preview
```

The Gemini API key must remain on the backend.

The frontend communicates with the backend analysis endpoint rather than accessing Gemini directly.

### Database Persistence

For historical persistence and the hierarchy explorer, configure:

```env
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/gridpulse
```

This can point to:

- Local Docker Compose TimescaleDB.
- A PostgreSQL instance.
- Supabase PostgreSQL.

Restart the API/container after changing the environment variables.

Verify the configuration using:

- http://localhost:8000/api/v1/health
- http://localhost:8000/api/v1/live-data
- http://localhost:8000/docs

A successful Supabase REST read does not automatically configure PostgreSQL persistence. These are separate settings.

---

## PGCB Data Integration

GridPulse supports optional national-level data ingestion from publicly accessible PGCB sources.

Configure:

```env
GRID_SOURCE_URL=your_public_source_endpoint
```

The reader recognizes common JSON field names, CSV headers, and HTML-table headers for:

- Total generation.
- Demand/load.
- Gas.
- Coal.
- Solar.
- Hydro.
- Wind.
- Imports.

Power values are interpreted in MW.

### Historical Data Backfill

An initial six-month dataset can be loaded from an authorized hourly CSV export containing timestamp/date and MW columns.

From the `backend` directory:

```bash
python -m app.import_history <hourly-history.csv>
```

The backend must have `DATABASE_URL` configured.

Newly polled readings continue the historical time series.

The historical-context endpoint summarizes the latest 180 days. The AI analysis explicitly has limited historical context until sufficient data is imported or collected.

### Important Data Source Restrictions

- PGCB ERP pages may require login or render information through JavaScript.
- The connector does not bypass authentication or browser-only protections.
- Only publicly accessible endpoints or authorized exports should be used.
- No unsupported national, district, or feeder measurements are fabricated.

---

## Hierarchical Data Ingestion Contract

An authorized PGCB processing script can import:

`save_hierarchical_readings`

from:

`app.database`

after the API/database schema has initialized.

Each reading must identify:

| Field | Description |
|---|---|
| `node_id` | Unique node identifier. |
| `node_name` | Node name. |
| `tier` | `national`, `division`, `district`, or `feeder`. |
| `parent_node_id` | Parent node identifier; null only for the national root. |
| `observed_at` | Observation timestamp. |
| `source` | Data source identifier. |

Optional fields may include:

- Generation.
- Demand.
- Fuel mix.
- Voltage.
- Capacity.
- Load percentage.
- Status.

These fields should only be populated when the actual source provides the relevant information.

---

## Database Architecture

GridPulse uses PostgreSQL 16 with TimescaleDB for telemetry persistence in the local Docker Compose environment.

There are two distinct database configuration mechanisms.

### 1. Supabase REST API

`SUPABASE_URL` and a Supabase API key read the scraper's `hourly_generation` table through the Supabase REST API.

At API startup:

- The most recent 500 rows are used for forecast training.
- Rows are upserted into `DATABASE_URL` when persistence is connected.
- Each subsequent poll stores the latest row.

### 2. GridPulse Database

`DATABASE_URL` is responsible for storing GridPulse's:

- National historical readings.
- Grid hierarchy.
- Simulator telemetry.
- Relevant result records.

If `DATABASE_URL` is unset or unreachable:

- Live national readings can still feed the simulator.
- Database-backed historical analysis becomes unavailable.
- The hierarchy explorer remains unavailable.
- The backend may use in-memory state.

Set `DATABASE_URL` to Supabase PostgreSQL if GridPulse records should be stored in the Supabase project. Otherwise, Docker Compose uses its local TimescaleDB instance.

### Supabase PostgreSQL

For GridPulse persistence, connect through SQLAlchemy/asyncpg rather than a browser-side client.

Example:

```env
DATABASE_URL=postgresql+asyncpg://user:password@host:5432/postgres?sslmode=require
```

The backend also normalizes standard `postgresql://` connection URIs.

Use the Supabase session pooler if the deployment environment cannot reach the direct database host.

The Supabase database uses standard PostgreSQL tables and does not require the TimescaleDB extension. The local Compose stack remains TimescaleDB-backed.

---

## HTTP and WebSocket API

GridPulse uses FastAPI for backend communication.

### Main HTTP Endpoints

| Endpoint | Purpose |
|---|---|
| `/api/v1/health` | Backend health and configuration status. |
| `/api/v1/state` | Current simulator state. |
| `/api/v1/live-data` | National source information and status. |
| `/api/v1/live-data/sync` | Trigger an immediate national-source synchronization. |
| `/api/v1/safety/validate` | Validate a proposed power-routing suggestion. |
| `/docs` | Swagger API documentation. |
| `/redoc` | ReDoc API documentation. |

### WebSocket

```text
/api/v1/ws/live
```

The WebSocket connection provides real-time simulated grid telemetry to the frontend.

The frontend reconnects when the connection is interrupted.

For the complete interactive API specification, visit:

http://localhost:8000/docs

---

## Development and Testing

### Frontend

Install dependencies:

```bash
npm ci
```

Run development server:

```bash
npm run dev
```

Create production build:

```bash
npm run build
```

### Backend

Install dependencies:

```bash
backend/.venv/bin/python -m pip install -r backend/requirements.txt
```

Run backend tests:

```bash
cd backend
pytest
```

The backend testing stack includes:

- pytest.
- FastAPI TestClient.
- httpx.

Frontend checks include ESLint and the Next.js production build.

---

## Known Limitations

1. The 20-node virtual grid is simulated rather than connected to physical infrastructure.
2. Node-level voltage and power measurements are generated by the Python simulator.
3. National-level readings depend on the availability of accessible or authorized PGCB data sources.
4. Historical forecasting accuracy depends on the quality and quantity of available hourly records.
5. Database persistence is optional during local development.
6. In-memory fallback state resets after a backend process restart.
7. AI advisory depends on Gemini API availability, credentials, and usage quotas.
8. Background reporting requires Redis and Celery to be configured.
9. Missing district and feeder data are not artificially generated.
10. The system provides decision support only and does not perform physical grid operations.

---

## Safety and Intended Use

GridPulse is developed strictly as an academic software engineering project and a smart-grid simulation environment.

Its intended uses include:

- Studying smart-grid monitoring workflows.
- Exploring simulated electrical grid conditions.
- Understanding demand forecasting.
- Analysing simulated grid-shock scenarios.
- Demonstrating anomaly detection.
- Exploring deterministic safety validation.
- Studying full-stack real-time system architecture.

**Important Safety Boundaries**

- GridPulse does not control physical electrical infrastructure.
- AI-generated suggestions are not automatically executed.
- Proposed power transfers are checked against configured line capacities.
- Simulated node measurements must not be interpreted as live sensor measurements.
- National aggregate data must not be confused with individual node measurements.
- The platform is not certified for real-world electrical engineering or operational decisions.

---

## Team Contributions

GridPulse was developed collaboratively by four team members.

| Team Member | Student ID | Contribution |
|---|---|---|
| Muntaha Binte Mostafa | 24524203140 | Developed and integrated the XGBoost-based 24-hour electricity-demand forecasting module. |
| Shafia Akter | 24524203148 | Developed grid mapping, virtual 20-node simulation, and dynamic energy-flow simulation. |
| Mahfuz Hossain Antor | 24524203158 | Developed the real-time data automation pipeline and backend. |
| Atia Mahmuda Ahana | 24524203164 | Developed the frontend and user interface. |

### Academic Information

| Field | Details |
|---|---|
| Course Title | Object Oriented Programming Language Laboratory-II |
| Course Code | CSE-3206 |
| Session | July–December 2026 |
| Submission Date | 5 November 2026 |
| Department | Computer Science and Engineering |
| Institution | Bangladesh University of Professionals |


---

## Conclusion

GridPulse demonstrates a full-stack smart-grid operations digital twin combining a 20-node virtual distribution grid, real-time telemetry, interactive topology visualization, demand forecasting, anomaly detection, shock-scenario simulation, PGCB national data integration, asynchronous reporting, and contextual AI advisory.

Its principal software-engineering contribution is the separation of AI-generated insights from deterministic engineering validation.

Proposed power transfers are checked against configured line capacities, ensuring that AI-generated recommendations are not automatically treated as operationally valid.

The project integrates modern frontend, backend, machine-learning, database, task-queue, and deployment technologies into a unified academic demonstration environment.

GridPulse provides a controlled environment for studying software workflows associated with grid monitoring, predictive analysis, and contingency simulation while maintaining a clear boundary between simulation and real-world electrical infrastructure.

---

<p align="center">
  **GridPulse — Smarter Monitoring. Predictive Insights. Safety-First Decisions.**
</p>

<p align="center">
  Built with dedication by the GridPulse Team.
</p>
