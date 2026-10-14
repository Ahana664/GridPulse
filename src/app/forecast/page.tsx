"use client";

import DemandForecast from "@/components/forecast/DemandForecast";
import PeakPrediction from "@/components/forecast/PeakPrediction";
import RiskIndicator from "@/components/forecast/RiskIndicator";
import { useGridData } from "@/hooks/useGridData";

export default function ForecastPage() {
  const { data } = useGridData();
  const peak = data.forecast.reduce(
    (highest, point) => point.load > highest.load ? point : highest,
    data.forecast[0] ?? { time: "—", load: 0 },
  );

  return (
    <div className="p-6">
    
      {/* Summary Cards */}
      <div className="mb-6 grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Predicted Peak
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            {Math.round(peak.load).toLocaleString()} MW
          </p>

          <p className="mt-1 text-xs text-orange-400">
            Expected at {peak.time}
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Current Load
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            {Math.round(data.summary.totalLoad).toLocaleString()} MW
          </p>

          <p className="mt-1 text-xs text-blue-400">
            Real-time
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Forecast Horizon
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            24 Hours
          </p>

          <p className="mt-1 text-xs text-slate-400">
            Next-day prediction
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Grid Risk
          </p>

          <p className="mt-2 text-2xl font-semibold text-green-400">
            {data.summary.risk.toUpperCase()}
          </p>

          <p className="mt-1 text-xs text-green-400">
            {data.summary.systemHealth.toFixed(1)}% health
          </p>
        </div>
      </div>

      {/* Forecast Chart */}
      <div className="mb-6">
        <DemandForecast />
      </div>

      {/* Prediction & Risk */}
      <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
        <PeakPrediction />
        <RiskIndicator />
      </div>
    </div>
  );
}