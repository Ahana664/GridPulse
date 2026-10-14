"use client";

import ReportGenerator from "@/components/reports/ReportGenerator";
import { useGridData } from "@/hooks/useGridData";

export default function ReportsPage() {
  const { data } = useGridData();

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Telemetry Samples
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            {data.history.length}
          </p>

          <p className="mt-1 text-xs text-green-400">
            Available for analysis
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Report Templates
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            3
          </p>

          <p className="mt-1 text-xs text-blue-400">
            Generated on demand
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Current Grid Risk
          </p>

          <p className="mt-2 text-2xl font-semibold capitalize text-white">
            {data.summary.risk}
          </p>

          <p className="mt-1 text-xs text-slate-400">
            {data.summary.systemHealth.toFixed(1)}% system health
          </p>
        </div>
      </div>

      <ReportGenerator />
    </div>
  );
}