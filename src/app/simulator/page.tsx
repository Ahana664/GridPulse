"use client";

import { useState } from "react";
import { Activity, RotateCcw, Sun, Thermometer, TrendingUp, Workflow } from "lucide-react";
import { useGridData, type ScenarioKey } from "@/hooks/useGridData";

const scenarios: { key: ScenarioKey; title: string; detail: string; Icon: typeof Thermometer }[] = [
  { key: "heatwave", title: "Heatwave", detail: "Raise virtual demand across load nodes.", Icon: Thermometer },
  { key: "demand_spike", title: "Demand spike", detail: "Model a sudden step-up in consumer load.", Icon: TrendingUp },
  { key: "solar_failure", title: "Solar failure", detail: "Reduce output from virtual solar nodes.", Icon: Sun },
  { key: "node_failure", title: "Node failure", detail: "Simulate an outage at a virtual substation.", Icon: Workflow },
];

export default function SimulatorPage() {
  const { data, runScenario, resetScenario } = useGridData();
  const [selected, setSelected] = useState<ScenarioKey>("heatwave");
  const [pending, setPending] = useState(false);
  const [error, setError] = useState("");
  const result = data.scenarioResult?.name === selected ? data.scenarioResult : null;

  async function run() {
    setPending(true);
    setError("");
    try {
      await runScenario(selected);
    } catch (reason) {
      setError(reason instanceof Error ? reason.message : "Unable to run this scenario.");
    } finally {
      setPending(false);
    }
  }

  async function reset() {
    setPending(true);
    setError("");
    try {
      await resetScenario();
    } catch (reason) {
      setError(reason instanceof Error ? reason.message : "Unable to reset the simulation.");
    } finally {
      setPending(false);
    }
  }

  return (
    <div className="gp-route-stack gp-simulator-page">
      <section className="gp-card">
        <header className="gp-card-heading">
          <div><span className="gp-eyebrow">CONTROLLED EXPERIMENT / VIRTUAL GRID</span><h2 className="gp-serif gp-section-title">Choose a grid shock</h2></div>
          <span className="gp-small-tag">SIMULATION ONLY</span>
        </header>
        <p className="gp-muted">Each scenario changes only the 20-node software model. It has no connection to real electrical equipment.</p>
        <div className="gp-scenario-grid gp-simulator-options">
          {scenarios.map(({ key, title, detail, Icon }) => (
            <button key={key} type="button" className={`gp-scenario ${selected === key ? "is-active" : ""}`} aria-pressed={selected === key} disabled={pending} onClick={() => setSelected(key)}>
              <span className="gp-scenario-icon"><Icon size={20} strokeWidth={1.7} /></span>
              <span className="gp-serif">{title}</span>
              <small>{detail}</small>
            </button>
          ))}
        </div>
        <div className="gp-simulator-actions">
          <p>Selected scenario <strong>{scenarios.find((scenario) => scenario.key === selected)?.title}</strong></p>
          <div>
            <button type="button" className="gp-button" disabled={pending || (!data.scenario && !data.scenarioResult)} onClick={() => void reset()}><RotateCcw size={15} /> Reset model</button>
            <button type="button" className="gp-button gp-button-primary" disabled={pending} onClick={() => void run()}><Activity size={16} /> {pending ? "Working…" : "Run simulation"}</button>
          </div>
        </div>
        {error && <p className="gp-error" role="alert">{error}</p>}
      </section>

      <section className="gp-card">
        <header className="gp-card-heading">
          <div><span className="gp-eyebrow">MEASURED MODEL RESPONSE</span><h2 className="gp-serif gp-section-title">Scenario results</h2></div>
          <span className="gp-small-tag">{result ? "CALCULATED FROM API SNAPSHOT" : "AWAITING RUN"}</span>
        </header>
        {result ? (
          <>
            <p className="gp-muted">{result.description}</p>
            <div className="gp-result-grid">
              <article><span>DEMAND CHANGE</span><strong>{result.loadImpact}</strong></article>
              <article><span>MODEL FREQUENCY</span><strong>{result.frequency}</strong></article>
              <article><span>GENERATION CHANGE</span><strong>{result.generationImpact}</strong></article>
              <article><span>ASSESSED RISK</span><strong>{result.risk}</strong></article>
            </div>
          </>
        ) : (
          <div className="gp-empty-state"><Activity size={20} /><div><strong>No result for this selection yet</strong><p>Run the scenario to calculate its effect from the current virtual-grid state.</p></div></div>
        )}
      </section>
    </div>
  );
}
