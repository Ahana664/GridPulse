"use client";

import { useState } from "react";
import { Download, FileBarChart, LoaderCircle } from "lucide-react";

const apiBase = (process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api/v1").replace(/\/$/, "");
const reportTypes = [
  { id: "performance", title: "Performance Report", description: "Grid generation and load performance" },
  { id: "analytics", title: "Analytics Report", description: "Forecast and demand analysis" },
  { id: "alerts", title: "Alert Report", description: "Grid alerts and anomaly summary" },
];

type Report = { id?: string; type?: string; generatedAt?: string; summary?: Record<string, number> };

export default function ReportGenerator() {
  const [generating, setGenerating] = useState<string | null>(null);
  const [report, setReport] = useState<Report | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function generate(reportType: string) {
    setGenerating(reportType);
    setError(null);
    setReport(null);
    try {
      const response = await fetch(`${apiBase}/reports/generate`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ report_type: reportType }),
      });
      if (!response.ok) throw new Error("The report service is unavailable.");
      let result = await response.json() as { status: string; report?: Report; taskId?: string };
      if (result.status === "queued" && result.taskId) {
        for (let attempt = 0; attempt < 60; attempt += 1) {
          await new Promise((resolve) => setTimeout(resolve, 1_000));
          const taskResponse = await fetch(`${apiBase}/reports/tasks/${result.taskId}`, { cache: "no-store" });
          if (!taskResponse.ok) throw new Error("Could not retrieve the generated report.");
          const task = await taskResponse.json() as { status: string; report?: Report; error?: string };
          if (task.status === "success" && task.report) {
            result = { status: "ready", report: task.report };
            break;
          }
          if (task.status === "failure") throw new Error(task.error ?? "Report generation failed.");
        }
      }
      if (!result.report) throw new Error("Report generation timed out. Please retry.");
      setReport(result.report);
    } catch (reason) {
      setError(reason instanceof Error ? reason.message : "Report generation failed.");
    } finally {
      setGenerating(null);
    }
  }

  function downloadReport() {
    if (!report) return;
    const blob = new Blob([JSON.stringify(report, null, 2)], { type: "application/json" });
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = `gridpulse-${report.type ?? "report"}-${report.id ?? "latest"}.json`;
    link.click();
    URL.revokeObjectURL(link.href);
  }

  return (
    <section className="mt-6 rounded-xl border border-slate-800 bg-[#0b1728] p-5">
      <div className="mb-5">
        <h2 className="text-lg font-semibold text-white">Generate New Report</h2>
        <p className="mt-1 text-sm text-slate-400">Create an analysis from the simulator telemetry history.</p>
      </div>
      <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
        {reportTypes.map((item) => (
          <button
            key={item.id}
            type="button"
            disabled={generating !== null}
            onClick={() => void generate(item.id)}
            className="rounded-lg border border-slate-700 bg-slate-900/50 p-4 text-left transition hover:border-blue-500 disabled:cursor-wait disabled:opacity-60"
          >
            <span className="flex items-center gap-2 text-sm font-medium text-white">
              {generating === item.id ? <LoaderCircle className="h-4 w-4 animate-spin" /> : <FileBarChart className="h-4 w-4 text-cyan-400" />}
              {generating === item.id ? "Generating…" : item.title}
            </span>
            <span className="mt-2 block text-xs text-slate-400">{item.description}</span>
          </button>
        ))}
      </div>
      {error && <p role="alert" className="mt-4 text-sm text-red-400">{error}</p>}
      {report && (
        <div className="mt-5 rounded-xl border border-emerald-500/20 bg-emerald-500/5 p-4">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div>
              <p className="text-sm font-semibold capitalize text-emerald-300">{report.type} report ready</p>
              <p className="mt-1 text-xs text-slate-400">Generated {report.generatedAt ? new Date(report.generatedAt).toLocaleString() : "just now"}</p>
            </div>
            <button type="button" onClick={downloadReport} className="inline-flex items-center gap-2 rounded-lg border border-slate-700 px-3 py-2 text-xs text-slate-200 hover:bg-slate-800">
              <Download className="h-4 w-4" /> Download JSON
            </button>
          </div>
          <dl className="mt-4 grid grid-cols-2 gap-3 md:grid-cols-4">
            {Object.entries(report.summary ?? {}).map(([key, value]) => (
              <div key={key} className="rounded-lg bg-slate-950/50 p-3">
                <dt className="text-xs capitalize text-slate-500">{key.replaceAll("_", " ")}</dt>
                <dd className="mt-1 text-lg font-semibold text-white">{Number(value).toLocaleString()}</dd>
              </div>
            ))}
          </dl>
        </div>
      )}
    </section>
  );
}
