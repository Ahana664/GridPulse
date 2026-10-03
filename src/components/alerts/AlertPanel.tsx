"use client";

const alerts = [
  {
    id: 1,
    type: "critical",
    title: "High Load - North Zone",
    message: "Load has reached 89% of capacity",
    time: "11:43 AM",
  },
  {
    id: 2,
    type: "warning",
    title: "Voltage Fluctuation",
    message: "Voltage variation detected in East Zone",
    time: "11:37 AM",
  },
  {
    id: 3,
    type: "warning",
    title: "Frequency Deviation",
    message: "Frequency deviated from nominal range",
    time: "11:28 AM",
  },
];

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

        <button className="text-sm text-blue-400 transition hover:text-blue-300">
          View All
        </button>
      </div>

      {/* Alerts */}
      <div className="space-y-1">
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
              {alert.time}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}