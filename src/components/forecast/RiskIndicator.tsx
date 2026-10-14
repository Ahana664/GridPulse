"use client";

import { useGridData } from "@/hooks/useGridData";

export default function RiskIndicator() {
  const { data } = useGridData();
  const riskColor = data.summary.risk === "critical" || data.summary.risk === "high"
    ? "text-red-400"
    : data.summary.risk === "moderate"
      ? "text-yellow-400"
      : "text-green-400";

  return (
    <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
      <div className="mb-5">
        <h2 className="text-lg font-semibold text-white">
          Grid Risk Analysis
        </h2>

        <p className="mt-1 text-sm text-slate-400">
          Current forecast-based system risk
        </p>
      </div>

      <div className="flex items-center justify-between rounded-lg border border-green-500/20 bg-green-500/5 p-4">
        <div>
          <p className="text-sm text-slate-400">
            Overall Grid Risk
          </p>

          <p className={`mt-1 text-2xl font-semibold capitalize ${riskColor}`}>
            {data.summary.risk}
          </p>
        </div>

        <div className="flex h-12 w-12 items-center justify-center rounded-full bg-green-500/10">
          <span className={`h-3 w-3 rounded-full ${data.summary.risk === "low" ? "bg-green-500" : data.summary.risk === "moderate" ? "bg-yellow-500" : "bg-red-500"}`} />
        </div>
      </div>

      <div className="mt-4 space-y-3">
        <div className="flex items-center justify-between rounded-lg bg-slate-900/60 p-3">
          <span className="text-sm text-slate-400">
            Transformer Risk
          </span>

          <span className="text-sm font-medium text-green-400">
            {data.nodes.some((node) => node.status === "critical") ? "Critical" : "Normal"}
          </span>
        </div>

        <div className="flex items-center justify-between rounded-lg bg-slate-900/60 p-3">
          <span className="text-sm text-slate-400">
            Load Risk
          </span>

          <span className="text-sm font-medium text-yellow-400">
            {data.nodes.some((node) => node.type === "load" && node.load >= 85) ? "Elevated" : "Normal"}
          </span>
        </div>

        <div className="flex items-center justify-between rounded-lg bg-slate-900/60 p-3">
          <span className="text-sm text-slate-400">
            Frequency Risk
          </span>

          <span className="text-sm font-medium text-green-400">
            {Math.abs(data.summary.frequency - 50) > 0.05 ? "Elevated" : "Normal"}
          </span>
        </div>
      </div>
    </div>
  );
}