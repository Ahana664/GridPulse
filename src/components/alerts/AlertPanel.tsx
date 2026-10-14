"use client";
import { useGridData } from "@/hooks/useGridData";

function AlertIcon({ type }: { type: string }) {
  if (type === "critical") {
    return (
      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-red-500/10">
        <span className="text-lg text-red-400">⚠</span>
      </div>
    );
  }

  return (
    <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-yellow-500/10">
      <span className="text-lg text-yellow-400">⚠</span>
    </div>
  );
}

export default function AlertPanel() {
  const { data, isConnected } = useGridData();
  const alerts = data.alerts;

  return (
    <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">

      {/* Header */}
      <div className="mb-4 flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-white">
            Recent Alerts
          </h2>

          <p className="mt-1 text-sm text-slate-400">
            Latest grid system alerts
          </p>
        </div>

        <span className="rounded-full bg-slate-800 px-2.5 py-1 text-xs text-slate-300">
          {alerts.length} active
        </span>
      </div>

      {/* Alerts */}
      <div className="space-y-1">
        {alerts.length === 0 && (
          <p className="py-8 text-center text-sm text-slate-500">No active grid anomalies.</p>
        )}
        {alerts.map((alert) => (
          <div
            key={alert.id}
            className="flex items-center gap-3 border-b border-slate-800/70 py-4 last:border-b-0"
          >
            <AlertIcon type={alert.type} />

            <div className="min-w-0 flex-1">
              <h3 className="truncate text-sm font-medium text-white">
                {alert.title}
              </h3>

              <p className="mt-1 truncate text-xs text-slate-400">
                {alert.message}
              </p>
            </div>

            <span className="shrink-0 text-xs text-slate-500">
              {isConnected ? new Date(alert.time).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }) : "Demo"}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}