"use client";

interface DemandSpikeButtonProps {
  selected?: boolean;
  onClick?: () => void;
}

export default function DemandSpikeButton({
  selected = false,
  onClick,
}: DemandSpikeButtonProps) {
  return (
    <button
      onClick={onClick}
      className={`w-full rounded-xl border p-4 text-left transition ${
        selected
          ? "border-blue-500 bg-blue-500/10"
          : "border-slate-800 bg-[#0b1728] hover:border-slate-700"
      }`}
    >
      <div className="flex items-start gap-3">
        <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-slate-700/50 text-xl">
          📈
        </div>

        <div>
          <h3 className="text-sm font-semibold text-white">
            Demand Spike
          </h3>

          {selected && (
            <p className="mt-1 text-xs text-blue-400">
              Selected
            </p>
          )}

          <p className="mt-3 text-xs leading-5 text-slate-400">
            Simulate a sudden increase in electricity demand.
          </p>
        </div>
      </div>
    </button>
  );
}