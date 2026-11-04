"use client";

import { useState } from "react";
import { Activity, ArrowDownRight, ArrowUpRight, Radio, ShieldCheck, Zap } from "lucide-react";
import LoadChart from "@/components/dashboard/LoadChart";
import ForecastChart from "@/components/dashboard/ForecastChart";
import GenerationMixChart from "@/components/dashboard/GenerationMixChart";
import AlertPanel from "@/components/alerts/AlertPanel";
import GridHierarchyMap from "@/components/grid/GridHierarchyMap";
import GridMap from "@/components/grid/GridMap";
import GridLegend from "@/components/grid/GridLegend";
import LiveSourcePanel from "@/components/dashboard/LiveSourcePanel";
import { useGridData, type ScenarioKey } from "@/hooks/useGridData";
import { useRealDashboardData } from "@/hooks/useRealDashboardData";
import type { DashboardMode } from "@/types/realDashboard";

const scenarioOptions: { key: ScenarioKey; name: string; caption: string }[] = [
  { key: "heatwave", name: "Heatwave", caption: "Higher demand across zones" },
  { key: "demand_spike", name: "Demand spike", caption: "Sudden consumer surge" },
  { key: "solar_failure", name: "Solar failure", caption: "Renewable output loss" },
  { key: "node_failure", name: "Node failure", caption: "Substation outage" },
];

const compact = (value: number | null | undefined) => value == null ? "—" : Math.round(value).toLocaleString();

export default function Home() {
  const { data, isConnected, error, runScenario } = useGridData();
  const { data: realData, loading: realLoading, error: realError } = useRealDashboardData();
  const [mode, setMode] = useState<DashboardMode>("real");
  const [scenarioPending, setScenarioPending] = useState<ScenarioKey | null>(null);
  const [scenarioError, setScenarioError] = useState("");
  const selectedForecast = mode === "real" ? (realData?.forecast ?? []) : data.forecast;
  const peak = selectedForecast.reduce((best, point) => point.load > best.load ? point : best, selectedForecast[0] ?? { time: "—", load: 0 });
  const warnings = data.safetyChecks.filter((check) => check.status !== "pass").length;
  const national = data.nationalData;
  const realReading = realData?.latest;
  const realDemand = realReading?.demand_is_inferred ? null : realReading?.demand_mw ?? null;
  const realGeneration = realReading?.generation_mw ?? null;
  const realBalance = realGeneration != null && realDemand != null ? realGeneration - realDemand : null;
  const realRenewables = (realReading?.solar_mw ?? 0) + (realReading?.wind_mw ?? 0);
  const realRenewableShare = realGeneration ? (realRenewables / realGeneration) * 100 : null;

  async function activateScenario(scenario: ScenarioKey) {
    setScenarioPending(scenario);
    setScenarioError("");
    try {
      await runScenario(scenario);
    } catch (reason) {
      setScenarioError(reason instanceof Error ? reason.message : "Unable to run scenario.");
    } finally {
      setScenarioPending(null);
    }
  }

  return (
    <div className="gp-overview">
      <header className="gp-hero">
        <div>
          <div className="gp-live-line"><i className={isConnected ? "gp-live-dot" : "gp-idle-dot"} />
            {mode === "real" ? (realReading ? "LIVE NATIONAL SOURCE" : "WAITING FOR NATIONAL SOURCE") : (isConnected ? "LIVE SIMULATOR STREAM" : "SIMULATOR STREAM DISCONNECTED")}
            <span>·</span>{mode === "real" ? (realData?.historyStorage === "postgresql" ? "POSTGRESQL HISTORY" : realData?.historyStorage === "supabase-rest" ? "SUPABASE HISTORY" : "HISTORY UNAVAILABLE") : national ? "NATIONAL TREND ATTACHED" : "SIMULATED BASELINE"}
          </div>
          <h1 className="gp-wordmark">Grid<span>Pulse</span></h1>
          <p>AI-driven load forecasting & predictive anomaly analysis</p>
        </div>
        <div className="gp-hero-meta">
          <div className="gp-source-pill"><Radio size={16} /> {mode === "real" ? (realReading?.source ?? realData?.source ?? "Awaiting PGCB data") : "20 virtual nodes"}</div>
          <div className="gp-mono gp-updated">Updated {new Date(data.timestamp).toLocaleTimeString()}</div>
        </div>
      </header>

      <section className="gp-mode-switch" aria-label="Dashboard data mode">
        <div><strong>Dashboard mode</strong><span>Choose which data powers the metrics, charts, forecasts, and AI analysis.</span></div>
        <div className="gp-mode-options" role="group" aria-label="Select dashboard data mode">
          <button type="button" className={mode === "real" ? "is-active" : ""} onClick={() => setMode("real")}>Real PGCB data</button>
          <button type="button" className={mode === "simulated" ? "is-active" : ""} onClick={() => setMode("simulated")}>20-node simulation</button>
        </div>
      </section>

      {mode === "simulated" && error && <div className="gp-notice" role="status">{error} · Showing the clearly labeled simulator baseline until the API reconnects.</div>}
      {mode === "real" && realError && <div className="gp-notice" role="status">{realError} · Real-mode values are unavailable until the national-data API reconnects.</div>}

      <section className="gp-kpis" aria-label="Current grid summary">
        {mode === "real" ? (
          <>
            <article className="gp-card gp-kpi">
              <span className="gp-eyebrow">NATIONAL GENERATION · PGCB</span>
              <strong>{compact(realGeneration)} <small>MW</small></strong>
              <span className="gp-kpi-note"><Zap size={14} /> {realReading?.observed_at ? `Observed ${new Date(realReading.observed_at).toLocaleTimeString()}` : "Waiting for source reading"}</span>
            </article>
            <article className="gp-card gp-kpi">
              <span className="gp-eyebrow">NATIONAL DEMAND · PGCB</span>
              <strong>{compact(realDemand)} <small>MW</small></strong>
              <span className="gp-kpi-note"><Activity size={14} /> {realDemand == null ? "Demand not present in the source table" : `${realData?.historyCount ?? 0} actual history samples`}</span>
            </article>
            <article className="gp-card gp-kpi">
              <span className="gp-eyebrow">SUPPLY BALANCE · PGCB</span>
              <strong>{compact(realBalance)} <small>MW</small></strong>
              <span className="gp-kpi-note">{realBalance == null ? "Unavailable · no measured demand field" : "Generation minus measured demand"}</span>
            </article>
            <article className="gp-card gp-kpi">
              <span className="gp-eyebrow">SOLAR + WIND SHARE</span>
              <strong>{realRenewableShare == null ? "—" : `${realRenewableShare.toFixed(1)}`} <small>{realRenewableShare == null ? "" : "%"}</small></strong>
              <span className="gp-kpi-note"><Radio size={14} /> {realReading?.source ?? "Awaiting source"}</span>
            </article>
          </>
        ) : (
          <>
        <article className="gp-card gp-kpi">
          <span className="gp-eyebrow">SIMULATED GENERATION</span>
          <strong>{compact(data.summary.totalGeneration)} <small>MW</small></strong>
          <span className="gp-kpi-note"><Zap size={14} /> {data.summary.generationReserve >= 0 ? `${compact(data.summary.generationReserve)} MW reserve` : `${compact(Math.abs(data.summary.generationReserve))} MW deficit`}</span>
        </article>
        <article className="gp-card gp-kpi">
          <span className="gp-eyebrow">SIMULATED DEMAND</span>
          <strong>{compact(data.summary.totalLoad)} <small>MW</small></strong>
          <span className="gp-kpi-note"><Activity size={14} /> {data.summary.nodeCount} virtual nodes</span>
        </article>
        <article className="gp-card gp-kpi">
          <span className="gp-eyebrow">SYSTEM FREQUENCY</span>
          <strong>{data.summary.frequency.toFixed(3)} <small>Hz</small></strong>
          <span className="gp-kpi-note">Nominal target · 50 Hz</span>
        </article>
        <article className="gp-card gp-kpi">
          <span className="gp-eyebrow">RULE CHECKS NEED REVIEW</span>
          <strong>{warnings} <small>items</small></strong>
          <span className="gp-kpi-note"><ShieldCheck size={14} /> {data.safetyChecks.length} deterministic checks</span>
        </article>
          </>
        )}
      </section>

      <section className="gp-main-grid">
        <article className="gp-card gp-map-card">
          <div className="gp-card-heading"><div><span className="gp-eyebrow">01 / {mode === "real" ? "NATIONAL SOURCE" : "VIRTUAL GRID"}</span><h2 className="gp-serif gp-section-title">{mode === "real" ? "National hierarchy" : "20-node topology"}</h2></div></div>
          {mode === "real" ? <div className="gp-map-frame"><GridHierarchyMap /></div> : <div className="gp-sim-map-layout"><div className="gp-map-frame"><GridMap /></div><GridLegend /></div>}
        </article>

        <div className="gp-side-stack">
          <LiveSourcePanel mode={mode} realData={realData} />
          <article className="gp-card gp-generation-card">
            <div className="gp-card-heading"><div><span className="gp-eyebrow">02 / SUPPLY</span><h2 className="gp-serif gp-section-title">{mode === "real" ? "PGCB national generation mix" : "Simulated generation mix"}</h2></div></div>
            <GenerationMixChart mode={mode} realData={realData} />
          </article>
        </div>
      </section>

      <section className="gp-charts-grid">
        <article className="gp-card gp-chart-card">
          <div className="gp-card-heading"><div><span className="gp-eyebrow">03 / {mode === "real" ? "PGCB HISTORY" : "SIMULATION"}</span><h2 className="gp-serif gp-section-title">{mode === "real" ? `National ${realData?.forecastTarget ?? "demand"} history & forecast` : "20-node demand & generation"}</h2></div><span className="gp-small-tag">{mode === "real" ? "ACTUAL SOURCE + REAL-TRAINED MODEL" : "SIMULATED · NOT PGCB"}</span></div>
          <LoadChart mode={mode} realData={realData} />
        </article>
        <article className="gp-card gp-chart-card">
          <div className="gp-card-heading"><div><span className="gp-eyebrow">04 / {mode === "real" ? "REAL-DATA FORECAST" : "SIMULATION FORECAST"}</span><h2 className="gp-serif gp-section-title">{mode === "real" ? `Bangladesh national ${realData?.forecastTarget ?? ""} · next 24 hours` : "Virtual grid · next 24 hours"}</h2></div><span className="gp-small-tag">{mode === "real" ? (realData?.forecastModel ?? "LOADING").toUpperCase() : data.mlModel.toUpperCase()}</span></div>
          {selectedForecast.length > 0 ? <div className="gp-peak-strip"><span>Predicted peak</span><strong>{compact(peak.load)} MW</strong><span>at {peak.time}</span></div> : <p className="gp-muted">{mode === "real" ? (realData?.forecastNotice ?? (realLoading ? "Loading actual history and training the forecast…" : "Waiting for sufficient real history.")) : "Forecast unavailable."}</p>}
          <ForecastChart mode={mode} realData={realData} />
        </article>
      </section>

      {mode === "simulated" ? <section className="gp-bottom-grid">
        <article className="gp-card gp-scenarios-card">
          <div className="gp-card-heading"><div><span className="gp-eyebrow">05 / WHAT-IF TESTING</span><h2 className="gp-serif gp-section-title">Shock simulator</h2></div><span className="gp-small-tag">NO PHYSICAL ACTIONS</span></div>
          <div className="gp-scenario-grid">
            {scenarioOptions.map((option) => (
              <button key={option.key} type="button" className={`gp-scenario ${data.scenario === option.key ? "is-active" : ""}`} disabled={scenarioPending !== null} onClick={() => void activateScenario(option.key)}>
                <span className="gp-serif">{scenarioPending === option.key ? "Running…" : option.name}</span>
                <small>{option.caption}</small>
              </button>
            ))}
          </div>
          {scenarioError && <p className="gp-error" role="alert">{scenarioError}</p>}
          {data.scenarioResult && <div className="gp-scenario-result"><strong>{data.scenarioResult.name.replaceAll("_", " ")}</strong> · demand {data.scenarioResult.loadImpact} · frequency {data.scenarioResult.frequency} · risk {data.scenarioResult.risk}</div>}
        </article>
        <article className="gp-card gp-safety-card">
          <div className="gp-card-heading"><div><span className="gp-eyebrow">06 / SAFETY ENFORCER</span><h2 className="gp-serif gp-section-title">Rules decide</h2></div><ShieldCheck size={20} /></div>
          <p className="gp-muted">Predictions and AI advice never bypass deterministic node and line limits. Proposed flows are validated separately; the simulator does not control infrastructure.</p>
          <div className="gp-safety-counts">
            <span><b>{data.safetyChecks.filter((item) => item.status === "pass").length}</b><small>PASS</small></span>
            <span><b>{data.safetyChecks.filter((item) => item.status === "warning").length}</b><small>WARNING</small></span>
            <span><b>{data.safetyChecks.filter((item) => item.status === "critical").length}</b><small>CRITICAL</small></span>
          </div>
          <div className="gp-reserve-line"><span>Supply balance</span><strong className={data.summary.generationReserve >= 0 ? "gp-positive" : "gp-negative"}>{data.summary.generationReserve >= 0 ? <ArrowUpRight size={16} /> : <ArrowDownRight size={16} />}{compact(data.summary.generationReserve)} MW</strong></div>
        </article>
      </section> : null}

      {mode === "real" && <section className="gp-card gp-source-scope"><span className="gp-eyebrow">REAL SOURCE SCOPE</span><h2 className="gp-serif gp-section-title">National aggregate telemetry</h2><p className="gp-muted">KPIs, generation history/mix, and the 24-hour generation trend forecast use PGCB/Supabase source records. The current source table does not include a separate demand column, so demand and supply balance are intentionally shown as unavailable. It also does not provide verified node-level voltage, frequency, line status, or regional measurements. Switch to 20-node simulation for virtual safety rules, alerts, and what-if scenarios.</p></section>}

      {mode === "simulated" && <section className="gp-alerts-wrap"><AlertPanel /></section>}
      <footer className="gp-footer">GRIDPULSE · EDUCATIONAL SIMULATION & DECISION SUPPORT · NOT CONNECTED TO A PHYSICAL GRID</footer>
    </div>
  );
}
