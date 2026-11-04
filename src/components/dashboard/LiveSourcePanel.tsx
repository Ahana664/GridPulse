"use client";

import { useCallback, useEffect, useState } from "react";
import { BrainCircuit, Database, RefreshCw, Radio } from "lucide-react";
import type { DashboardMode, RealDashboardData } from "@/types/realDashboard";

const apiBase = (process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api/v1").replace(/\/$/, "");
type SourceStatus = {
  configured: boolean;
  status: "live" | "stale" | "waiting" | "not-configured" | "error" | "disconnected";
  lastSuccess: string | null;
  lastError: string | null;
  reading: {
    observed_at: string | null;
    generation_mw: number | null;
    demand_mw: number | null;
    demand_is_inferred?: boolean;
    gas_mw: number | null;
    liquid_fuel_mw?: number | null;
    coal_mw: number | null;
    solar_mw: number | null;
    hydro_mw: number | null;
    wind_mw: number | null;
    imports_mw: number | null;
    adani_mw?: number | null;
  } | null;
};
type HistorySummary = {
  sample_count: number;
  demand_available?: boolean;
  history_source?: "postgresql" | "supabase" | "none";
  persistence_available?: boolean;
  avg_demand_mw?: number | null;
  max_demand_mw?: number | null;
  night_trough_mw?: number | null;
  evening_peak_mw?: number | null;
  renewable_share_percent?: number | null;
  avg_generation_mw?: number | null;
  max_generation_mw?: number | null;
};
type AiAnalysis = {
  analysis: string;
  mode: DashboardMode;
  forecast?: string;
  anomalies?: string[];
  recommendation?: string;
  suggestedFlow: { connection_id: string; proposed_mw: number } | null;
  safetyValidation: { accepted: boolean | null; message: string; connectionId?: string; proposedMw?: number; capacityMw?: number | null };
};

const mw = (value: string | number | null | undefined) =>
  value == null ? "—" : Number(value).toLocaleString(undefined, { maximumFractionDigits: 0 });

export default function LiveSourcePanel({ mode = "simulated", realData }: { mode?: DashboardMode; realData?: RealDashboardData | null }) {
  const [source, setSource] = useState<SourceStatus | null>(null);
  const [history, setHistory] = useState<HistorySummary | null>(null);
  const [analysis, setAnalysis] = useState<AiAnalysis | null>(null);
  const [loadingAnalysis, setLoadingAnalysis] = useState(false);
  const [loadingSync, setLoadingSync] = useState(false);
  const [error, setError] = useState("");

  const refresh = useCallback(async () => {
    try {
      const [sourceResponse, historyResponse] = await Promise.all([
        fetch(`${apiBase}/live-data`, { cache: "no-store" }),
        fetch(`${apiBase}/history/summary`, { cache: "no-store" }),
      ]);
      if (!sourceResponse.ok || !historyResponse.ok) throw new Error("Live-data service is unreachable.");
      const liveStatus = await sourceResponse.json() as SourceStatus;
      setSource(liveStatus);
      setError(liveStatus.lastError ?? "");
      setHistory((await historyResponse.json()) as HistorySummary);
    } catch (reason) {
      setError(reason instanceof Error ? reason.message : "Unable to read data-source status.");
    }
  }, []);

  async function syncLiveData() {
    setLoadingSync(true);
    setError("");
    try {
      const response = await fetch(`${apiBase}/live-data/sync`, { method: "POST" });
      const payload = await response.json();
      if (!response.ok) throw new Error(payload.detail ?? "Live-data synchronization failed.");
      await refresh();
    } catch (reason) {
      setError(reason instanceof Error ? reason.message : "Live-data synchronization failed.");
    } finally {
      setLoadingSync(false);
    }
  }

  useEffect(() => {
    const initial = setTimeout(() => void refresh(), 0);
    const timer = setInterval(() => void refresh(), 30_000);
    return () => {
      clearTimeout(initial);
      clearInterval(timer);
    };
  }, [refresh]);

  async function runAnalysis() {
    const requestedMode = mode;
    setLoadingAnalysis(true);
    setError("");
    try {
      const response = await fetch(`${apiBase}/ai/analyze?mode=${mode}`, { method: "POST" });
      const payload = await response.json();
      if (!response.ok) throw new Error(payload.detail ?? "AI analysis failed.");
      if (requestedMode === mode) setAnalysis(payload as AiAnalysis);
    } catch (reason) {
      if (requestedMode === mode) setError(reason instanceof Error ? reason.message : "AI analysis failed.");
    } finally {
      setLoadingAnalysis(false);
    }
  }

  const reading = mode === "real" && realData?.latest ? realData.latest : source?.reading;
  const connected = source?.status === "live";
  const sourceLabel = connected ? "SOURCE LIVE" : source?.status === "stale" ? "DATA STALE" : source?.status === "error" || source?.status === "disconnected" ? "SOURCE ERROR" : source?.status === "not-configured" ? "NOT CONFIGURED" : reading ? "LAST SOURCE RECORD" : "AWAITING SOURCE";

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
        <div><span>National demand</span><strong>{reading?.demand_is_inferred ? "Not supplied" : <>{mw(reading?.demand_mw)} <small>MW</small></>}</strong></div>
        <div><span>Gas · coal</span><strong className="gp-fuel">{mw(reading?.gas_mw)} · {mw(reading?.coal_mw)} <small>MW</small></strong></div>
        <div><span>Solar · hydro · wind</span><strong className="gp-fuel">{mw(reading?.solar_mw)} · {mw(reading?.hydro_mw)} · {mw(reading?.wind_mw)} <small>MW</small></strong></div>
        <div><span>Last reading</span><strong className="gp-time">{reading?.observed_at ? new Date(reading.observed_at).toLocaleString() : source?.lastSuccess ? new Date(source.lastSuccess).toLocaleString() : "Not received"}</strong></div>
      </div>

      <p className="gp-disclosure">
        <Radio size={15} /> National readings come from the configured PGCB/Supabase source. Persisted history uses the separate PostgreSQL database; the 20-node simulator is modeled data, never a physical control system.
      </p>
      <button className="gp-button" type="button" onClick={syncLiveData} disabled={loadingSync || !source?.configured}>
        <RefreshCw size={15} className={loadingSync ? "gp-spin" : ""} />
        {loadingSync ? "Syncing source" : "Sync live source now"}
      </button>

      <div className="gp-history-box">
        <div className="gp-history-title"><Database size={15} /> NATIONAL HISTORY <span>{history?.history_source === "supabase" ? "live Supabase source" : history?.history_source === "postgresql" ? "PostgreSQL" : "last 180 days"}</span></div>
        <div className="gp-history-stats">
          <span>{history?.sample_count ?? 0}<small>hourly samples</small></span>
          <span>{mw(history?.demand_available ? history.avg_demand_mw : history?.avg_generation_mw)}<small>{history?.demand_available ? "avg demand · MW" : "avg generation · MW"}</small></span>
          <span>{mw(history?.demand_available ? history.max_demand_mw : history?.max_generation_mw)}<small>{history?.demand_available ? "peak demand · MW" : "peak generation · MW"}</small></span>
          <span>{history?.renewable_share_percent == null ? "—" : `${history.renewable_share_percent}%`}<small>solar + wind share</small></span>
        </div>
        {history?.sample_count === 0 && <p className="gp-muted">No historical records are available. Confirm Supabase table access and database connectivity.</p>}
        {!!history?.sample_count && history.persistence_available === false && <p className="gp-muted">Showing source history fetched from Supabase; it is not persisted to PostgreSQL until the database connection is restored.</p>}
      </div>

      <div className="gp-ai-row">
        <div><span className="gp-eyebrow">AI ADVISORY · GEMINI · {mode === "real" ? "REAL NATIONAL DATA" : "20-NODE SIMULATION"}</span><p className="gp-muted">Analyzes only the selected mode; advice is never executed.</p></div>
        <button className="gp-button" type="button" onClick={runAnalysis} disabled={loadingAnalysis}>
          {loadingAnalysis ? <RefreshCw size={15} className="gp-spin" /> : <BrainCircuit size={16} />}
          {loadingAnalysis ? "Analyzing" : "Run analysis"}
        </button>
      </div>
      {analysis?.mode === mode && (
        <div className="gp-analysis" role="status">
          {analysis.forecast || analysis.recommendation || analysis.anomalies ? (
            <>
              {analysis.forecast && <p><strong>3–6h outlook:</strong> {analysis.forecast}</p>}
              {!!analysis.anomalies?.length && <p><strong>Anomalies:</strong> {analysis.anomalies.join("; ")}</p>}
              {analysis.recommendation && <p><strong>Recommendation:</strong> {analysis.recommendation}</p>}
            </>
          ) : <p>{analysis.analysis}</p>}
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
