export default function PeakPrediction() {
  return (
    <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
      <div className="mb-5">
        <h2 className="text-lg font-semibold text-white">
          Peak Load Prediction
        </h2>

        <p className="mt-1 text-sm text-slate-400">
          Expected maximum grid demand
        </p>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="rounded-lg bg-slate-900/60 p-4">
          <p className="text-xs text-slate-400">
            Predicted Peak
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            4,850 MW
          </p>
        </div>

        <div className="rounded-lg bg-slate-900/60 p-4">
          <p className="text-xs text-slate-400">
            Expected Time
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            18:00
          </p>
        </div>
      </div>

      <div className="mt-4 flex items-center justify-between rounded-lg border border-orange-500/20 bg-orange-500/5 p-4">
        <div>
          <p className="text-sm font-medium text-orange-400">
            Peak Demand Alert
          </p>

          <p className="mt-1 text-xs text-slate-400">
            Higher demand is expected during the evening peak period.
          </p>
        </div>

        <span className="rounded-full bg-orange-500/10 px-3 py-1 text-xs font-medium text-orange-400">
          Moderate
        </span>
      </div>
    </div>
  );
}