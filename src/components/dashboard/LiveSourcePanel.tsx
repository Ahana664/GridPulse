"use client";

import { useCallback, useEffect, useState } from "react";
import { BrainCircuit, Database, RefreshCw, Radio } from "lucide-react";

const apiBase = (process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api/v1").replace(/\/$/, "");
type SourceStatus = {
  configured: boolean;
  status: "live" | "stale" | "waiting" | "not-configured" | "error" | "disconnected";
  lastSuccess: string | null;
  reading: {
    observed_at: string | null;
    generation_mw: number | null;
    demand_mw: number | null;
    gas_mw: number | null;
    liquid_fuel_mw?: number | null;
    coal_mw: number | null;
    solar_mw: number | null;
    hydro_mw: number | null;
    wind_mw: number | null;
    imports_mw: number | null;
    adani_mw?: number | null;
    measured: boolean;
  } | null;
};
type HierarchyStatus = {
  database: "connected" | "disconnected" | "error";
  parent: {
    observed_at: string | null;
    source: string | null;
    generation_mw: number | null;
    demand_mw: number | null;
    gas_mw: number | null;
    liquid_fuel_mw?: number | null;
    coal_mw: number | null;
    solar_mw: number | null;
    hydro_mw: number | null;
    wind_mw: number | null;
    imports_mw: number | null;
    adani_mw?: number | null;
    measured: boolean;
  } | null;
};
type HistorySummary = {
  sample_count: number;
  avg_demand_mw?: number | null;
  max_demand_mw?: number | null;
  night_trough_mw?: number | null;
  evening_peak_mw?: number | null;
  renewable_share_percent?: number | null;
};
type AiAnalysis = {
  analysis: string;
  suggestedFlow: { connection_id: string; proposed_mw: number } | null;
  safetyValidation: { accepted: boolean | null; message: string; connectionId?: string; proposedMw?: number; capacityMw?: number | null };
};

const mw = (value: string | number | null | undefined) =>
  value == null ? "—" : Number(value).toLocaleString(undefined, { maximumFractionDigits: 0 });

export default function LiveSourcePanel() {
  const [source, setSource] = useState<SourceStatus | null>(null);
  const [history, setHistory] = useState<HistorySummary | null>(null);
  const [analysis, setAnalysis] = useState<AiAnalysis | null>(null);
  const [loadingAnalysis, setLoadingAnalysis] = useState(false);
  const [error, setError] = useState("");

  const refresh = useCallback(async () => {
    try {
      const [sourceResponse, historyResponse] = await Promise.all([
        fetch(`${apiBase}/grid/hierarchy?parent_node_id=BD-NATIONAL`, { cache: "no-store" }),
        fetch(`${apiBase}/history/summary`, { cache: "no-store" }),
      ]);
      if (!sourceResponse.ok || !historyResponse.ok) throw new Error("Live-data service is unreachable.");
      const hierarchy = await sourceResponse.json() as HierarchyStatus;
      const reading = hierarchy.parent?.measured ? hierarchy.parent : null;
      const readingAge = reading?.observed_at ? Date.now() - new Date(reading.observed_at).getTime() : Infinity;
      const staleAfterMs = 2 * 60 * 60 * 1000;
      setSource({
        configured: hierarchy.database === "connected",
        status: hierarchy.database !== "connected" ? hierarchy.database : !reading ? "waiting" : readingAge > staleAfterMs ? "stale" : "live",
        lastSuccess: reading?.observed_at ?? null,
        reading,
      });
      setHistory((await historyResponse.json()) as HistorySummary);
    } catch (reason) {
      setError(reason instanceof Error ? reason.message : "Unable to read data-source status.");
    }
  }, []);

  useEffect(() => {
    const initial = setTimeout(() => void refresh(), 0);
    const timer = setInterval(() => void refresh(), 30_000);
    return () => {
      clearTimeout(initial);
      clearInterval(timer);
    };
  }, [refresh]);

  async function runAnalysis() {
    setLoadingAnalysis(true);
    setError("");
    try {
      const response = await fetch(`${apiBase}/ai/analyze`, { method: "POST" });
      const payload = await response.json();
      if (!response.ok) throw new Error(payload.detail ?? "AI analysis failed.");
      setAnalysis(payload as AiAnalysis);
    } catch (reason) {
      setError(reason instanceof Error ? reason.message : "AI analysis failed.");
    } finally {
      setLoadingAnalysis(false);
    }
  }

  const reading = source?.reading;
  const connected = source?.status === "live";
  const sourceLabel = connected ? "SOURCE LIVE" : source?.status === "stale" ? "DATA STALE" : source?.status === "error" || source?.status === "disconnected" ? "DB OFFLINE" : "AWAITING SOURCE";

  return (
    <section className="gp-card gp-source-card">
      <header className="gp-card-heading">
        <div>
          <span className="gp-eyebrow">NATIONAL DATA BRIDGE</span>
          <h2 className="gp-serif gp-section-title">Live source & history</h2>
        </div>
        <span className={`gp-status ${connected ? "is-live" : "is-idle"}`}>
          <i />{sourceLabel}
        </span>
      </header>

      <div className="gp-source-values">
        <div><span>Generation</span><strong>{mw(reading?.generation_mw)} <small>MW</small></strong></div>
        <div><span>National demand</span><strong>{mw(reading?.demand_mw)} <small>MW</small></strong></div>
        <div><span>Gas · coal</span><strong className="gp-fuel">{mw(reading?.gas_mw)} · {mw(reading?.coal_mw)} <small>MW</small></strong></div>
        <div><span>Solar · hydro · wind</span><strong className="gp-fuel">{mw(reading?.solar_mw)} · {mw(reading?.hydro_mw)} · {mw(reading?.wind_mw)} <small>MW</small></strong></div>
        <div><span>Last reading</span><strong className="gp-time">{source?.lastSuccess ? new Date(source.lastSuccess).toLocaleString() : "Not received"}</strong></div>
      </div>

      <p className="gp-disclosure">
        <Radio size={15} /> National readings shown here come from stored source records. The separate 20-node simulator is modeled data, never a physical control system.
      </p>

      <div className="gp-history-box">
        <div className="gp-history-title"><Database size={15} /> PERSISTED NATIONAL HISTORY <span>last 180 days</span></div>
        <div className="gp-history-stats">
          <span>{history?.sample_count ?? 0}<small>hourly samples</small></span>
          <span>{mw(history?.avg_demand_mw)}<small>avg demand · MW</small></span>
          <span>{mw(history?.max_demand_mw)}<small>peak demand · MW</small></span>
          <span>{history?.renewable_share_percent == null ? "—" : `${history.renewable_share_percent}%`}<small>solar + wind share</small></span>
        </div>
        {history?.sample_count === 0 && <p className="gp-muted">No historical records yet. The summary fills as hourly source readings are collected.</p>}
      </div>

      <div className="gp-ai-row">
        <div><span className="gp-eyebrow">AI ADVISORY · GEMINI</span><p className="gp-muted">Uses current state and stored history; advice is never executed.</p></div>
        <button className="gp-button" type="button" onClick={runAnalysis} disabled={loadingAnalysis}>
          {loadingAnalysis ? <RefreshCw size={15} className="gp-spin" /> : <BrainCircuit size={16} />}
          {loadingAnalysis ? "Analyzing" : "Run analysis"}
        </button>
      </div>
      {analysis && (
        <div className="gp-analysis" role="status">
          <p>{analysis.analysis}</p>
          {analysis.suggestedFlow && (
            <p className={analysis.safetyValidation.accepted ? "gp-positive" : "gp-negative"}>
              Safety check {analysis.safetyValidation.accepted ? "passed" : "blocked"}: {analysis.safetyValidation.message}
              {analysis.safetyValidation.capacityMw != null && ` (${analysis.safetyValidation.proposedMw} / ${analysis.safetyValidation.capacityMw} MW)`}
              . No action was applied.
            </p>
          )}
        </div>
      )}
      {error && <p className="gp-error" role="alert">{error}</p>}
    </section>
  );
}
