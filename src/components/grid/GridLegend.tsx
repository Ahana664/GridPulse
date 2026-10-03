export default function GridLegend() {
  return (
    <div className="mt-4 rounded-xl border border-slate-800 bg-[#081525] p-4">
      <h3 className="mb-3 text-sm font-semibold text-white">
        Grid Legend
      </h3>

      <div className="flex flex-wrap items-center gap-x-6 gap-y-3">
        
        {/* Node Types */}
        <div className="flex items-center gap-2">
          <span className="h-3 w-3 rounded-full bg-green-500" />
          <span className="text-xs text-slate-300">
            Generation
          </span>
        </div>

        <div className="flex items-center gap-2">
          <span className="h-3 w-3 rounded-full border-2 border-green-400 bg-slate-200" />
          <span className="text-xs text-slate-300">
            Substation
          </span>
        </div>

        <div className="flex items-center gap-2">
          <span className="h-3 w-3 rounded-full bg-blue-500" />
          <span className="text-xs text-slate-300">
            Load Center
          </span>
        </div>

        {/* Status */}
        <div className="h-5 w-px bg-slate-700" />

        <div className="flex items-center gap-2">
          <span className="h-2.5 w-2.5 rounded-full bg-green-500" />
          <span className="text-xs text-slate-300">
            Normal
          </span>
        </div>

        <div className="flex items-center gap-2">
          <span className="h-2.5 w-2.5 rounded-full bg-orange-500" />
          <span className="text-xs text-slate-300">
            Warning
          </span>
        </div>

        <div className="flex items-center gap-2">
          <span className="h-2.5 w-2.5 rounded-full bg-red-500" />
          <span className="text-xs text-slate-300">
            Critical
          </span>
        </div>
      </div>
    </div>
  );
}