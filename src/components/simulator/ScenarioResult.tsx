interface ScenarioResultProps {
  loadImpact: string;
  frequency: string;
  generationImpact: string;
  risk: string;
}

export default function ScenarioResult({
  loadImpact,
  frequency,
  generationImpact,
  risk,
}: ScenarioResultProps) {
  return (
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
      <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
        <p className="text-sm text-slate-400">Load Impact</p>
        <p className="mt-2 text-2xl font-semibold text-orange-400">
          {loadImpact}
        </p>
        <p className="mt-1 text-xs text-slate-500">
          Expected load change
        </p>
      </div>

      <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
        <p className="text-sm text-slate-400">Grid Frequency</p>
        <p className="mt-2 text-2xl font-semibold text-white">
          {frequency}
        </p>
        <p className="mt-1 text-xs text-slate-500">
          Simulated frequency
        </p>
      </div>

      <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
        <p className="text-sm text-slate-400">
          Generation Impact
        </p>
        <p className="mt-2 text-2xl font-semibold text-red-400">
          {generationImpact}
        </p>
        <p className="mt-1 text-xs text-slate-500">
          Estimated generation change
        </p>
      </div>

      <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
        <p className="text-sm text-slate-400">Grid Risk</p>
        <p className="mt-2 text-2xl font-semibold text-orange-400">
          {risk}
        </p>
        <p className="mt-1 text-xs text-slate-500">
          Scenario risk level
        </p>
      </div>
    </div>
  );
}