"use client";

import TelemetryTable from "@/components/monitor/TelemetryTable";
import VoltageChart from "@/components/monitor/VoltageChart";
import LoadMonitor from "@/components/monitor/LoadMonitor";
import { useGridData } from "@/hooks/useGridData";

export default function MonitorPage() {
  const { data } = useGridData();
  const { summary } = data;

  return (
    <div className="p-6">
      
      {/* Summary Cards */}
      <div className="mb-6 grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
        
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Grid Frequency
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            {summary.frequency.toFixed(3)} Hz
          </p>

          <p className="mt-1 text-xs text-green-400">
            {Math.abs(summary.frequency - 50) <= 0.05 ? "Stable" : "Deviation"}
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Average Voltage
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            {summary.averageVoltage.toFixed(1)} kV
          </p>

          <p className="mt-1 text-xs text-green-400">
            Normal
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Total Load
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            {Math.round(summary.totalLoad).toLocaleString()} MW
          </p>

          <p className="mt-1 text-xs text-blue-400">
            Live
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            System Status
          </p>

          <p className="mt-2 text-2xl font-semibold text-green-400">
            {summary.risk.toUpperCase()}
          </p>

          <p className="mt-1 text-xs text-slate-400">
            All systems operational
          </p>
        </div>
      </div>

      {/* Charts */}
      <div className="mb-6 grid grid-cols-1 gap-6 xl:grid-cols-2">
        <VoltageChart />
        <LoadMonitor />
      </div>

      {/* Telemetry Table */}
      <TelemetryTable />
    </div>
  );
}