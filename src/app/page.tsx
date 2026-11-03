"use client";

import { useMemo, useState } from "react";
import { Activity, ArrowDownRight, ArrowUpRight, Radio, ShieldCheck, Zap } from "lucide-react";
import LoadChart from "@/components/dashboard/LoadChart";
import ForecastChart from "@/components/dashboard/ForecastChart";
import GenerationMixChart from "@/components/dashboard/GenerationMixChart";
import AlertPanel from "@/components/alerts/AlertPanel";
import GridHierarchyMap from "@/components/grid/GridHierarchyMap";
import LiveSourcePanel from "@/components/dashboard/LiveSourcePanel";
import { useGridData, type ScenarioKey } from "@/hooks/useGridData";

const scenarioOptions: { key: ScenarioKey; name: string; caption: string }[] = [
  { key: "heatwave", name: "Heatwave", caption: "Higher demand across zones" },
  { key: "demand_spike", name: "Demand spike", caption: "Sudden consumer surge" },
  { key: "solar_failure", name: "Solar failure", caption: "Renewable output loss" },
  { key: "node_failure", name: "Node failure", caption: "Substation outage" },
];

const compact = (value: number) => Math.round(value).toLocaleString();

export default function Home() {
  const { data, isConnected, error, runScenario } = useGridData();
  const [scenarioPending, setScenarioPending] = useState<ScenarioKey | null>(null);
  const [scenarioError, setScenarioError] = useState("");
  const peak = useMemo(() => {
    const forecast = data.forecast ?? [];
    return forecast.reduce((best, point) => point.load > best.load ? point : best, forecast[0] ?? { time: "—", load: 0 });
  }, [data.forecast]);
  const warnings = data.safetyChecks.filter((check) => check.status !== "pass").length;
  const national = data.nationalData;

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
            {isConnected ? "LIVE SIMULATOR STREAM" : "SIMULATOR STREAM DISCONNECTED"}
            <span>·</span>{national ? "NATIONAL SOURCE ATTACHED" : "NATIONAL SOURCE PENDING"}
          </div>
          <h1 className="gp-wordmark">Grid<span>Pulse</span></h1>
          <p>AI-driven load forecasting & predictive anomaly analysis</p>
        </div>
        <div className="gp-hero-meta">
          <div className="gp-source-pill"><Radio size={16} /> {national ? "National trend linked" : "Awaiting source setup"}</div>
          <div className="gp-mono gp-updated">Updated {new Date(data.timestamp).toLocaleTimeString()}</div>
        </div>
      </header>

      {error && <div className="gp-notice" role="status">{error} · Showing the clearly labeled simulator baseline until the API reconnects.</div>}

      <section className="gp-kpis" aria-label="Current grid summary">
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
      </section>

      <section className="gp-main-grid">
        <article className="gp-card gp-map-card">
          <div className="gp-map-frame"><GridHierarchyMap /></div>
        </article>

        <div className="gp-side-stack">
          <LiveSourcePanel />
          <article className="gp-card gp-generation-card">
            <div className="gp-card-heading"><div><span className="gp-eyebrow">02 / SUPPLY</span><h2 className="gp-serif gp-section-title">Generation mix</h2></div></div>
            <GenerationMixChart />
          </article>
        </div>
      </section>

      <section className="gp-charts-grid">
        <article className="gp-card gp-chart-card">
          <div className="gp-card-heading"><div><span className="gp-eyebrow">03 / SIMULATION</span><h2 className="gp-serif gp-section-title">20-node demand & generation</h2></div><span className="gp-small-tag">SIMULATED · NOT PGCB</span></div>
          <LoadChart />
        </article>
        <article className="gp-card gp-chart-card">
          <div className="gp-card-heading"><div><span className="gp-eyebrow">04 / SIMULATION FORECAST</span><h2 className="gp-serif gp-section-title">Virtual grid · next 24 hours</h2></div><span className="gp-small-tag">{data.mlModel.toUpperCase()}</span></div>
          <div className="gp-peak-strip"><span>Predicted peak</span><strong>{compact(peak.load)} MW</strong><span>at {peak.time}</span></div>
          <ForecastChart />
        </article>
      </section>

      <section className="gp-bottom-grid">
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
      </section>

      <section className="gp-alerts-wrap"><AlertPanel /></section>
      <footer className="gp-footer">GRIDPULSE · EDUCATIONAL SIMULATION & DECISION SUPPORT · NOT CONNECTED TO A PHYSICAL GRID</footer>
    </div>
  );
}
