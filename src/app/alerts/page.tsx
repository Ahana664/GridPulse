import AlertPanel from "@/components/alerts/AlertPanel";

export default function AlertsPage() {
  return (
    <div className="p-6">
      
      {/* Alert Summary Cards */}
      <div className="mb-6 grid grid-cols-1 gap-4 md:grid-cols-3">
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Total Alerts
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            3
          </p>

          <p className="mt-1 text-xs text-slate-400">
            Active system alerts
          </p>
        </div>

        <div className="rounded-xl border border-red-500/20 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Critical
          </p>

          <p className="mt-2 text-2xl font-semibold text-red-400">
            1
          </p>

          <p className="mt-1 text-xs text-red-400">
            Immediate attention required
          </p>
        </div>

        <div className="rounded-xl border border-yellow-500/20 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Warnings
          </p>

          <p className="mt-2 text-2xl font-semibold text-yellow-400">
            2
          </p>

          <p className="mt-1 text-xs text-yellow-400">
            Requires monitoring
          </p>
        </div>
      </div>

      {/* Recent Alerts */}
      <AlertPanel />
    </div>
  );
}