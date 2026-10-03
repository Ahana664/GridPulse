export default function RiskIndicator() {
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

          <p className="mt-1 text-2xl font-semibold text-green-400">
            Low
          </p>
        </div>

        <div className="flex h-12 w-12 items-center justify-center rounded-full bg-green-500/10">
          <span className="h-3 w-3 rounded-full bg-green-500" />
        </div>
      </div>

      <div className="mt-4 space-y-3">
        <div className="flex items-center justify-between rounded-lg bg-slate-900/60 p-3">
          <span className="text-sm text-slate-400">
            Transformer Risk
          </span>

          <span className="text-sm font-medium text-green-400">
            Normal
          </span>
        </div>

        <div className="flex items-center justify-between rounded-lg bg-slate-900/60 p-3">
          <span className="text-sm text-slate-400">
            Load Risk
          </span>

          <span className="text-sm font-medium text-yellow-400">
            Moderate
          </span>
        </div>

        <div className="flex items-center justify-between rounded-lg bg-slate-900/60 p-3">
          <span className="text-sm text-slate-400">
            Frequency Risk
          </span>

          <span className="text-sm font-medium text-green-400">
            Normal
          </span>
        </div>
      </div>
    </div>
  );
}