"use client";

import LoadChart from "@/components/dashboard/LoadChart";
import {
  Activity,
  BarChart3,
  ShieldCheck,
  Zap,
} from "lucide-react";

import StatCard from "@/components/dashboard/StatCards";
import RegionPieChart from "@/components/dashboard/RegionPieChart";
import GenerationMixChart from "@/components/dashboard/GenerationMixChart";
import ForecastChart from "@/components/dashboard/ForecastChart";
import AlertPanel from "@/components/alerts/AlertPanel";
import GridMap from "@/components/grid/GridMap";
import { useGridData } from "@/hooks/useGridData";

export default function Home() {
  const { data, isConnected } = useGridData();
  const { summary } = data;
  const predictedPeak = data.forecast.reduce(
    (peak, point) => point.load > peak.load ? point : peak,
    data.forecast[0] ?? { time: "—", load: 0 },
  );

  return (
    <div className="space-y-6">

      {/* Statistics */}
      <div className="grid grid-cols-1 gap-5 md:grid-cols-2 xl:grid-cols-4">

        <StatCard
          title="Total Generation"
          value={Math.round(summary.totalGeneration).toLocaleString()}
          unit="MW"
          change={`${summary.generationReserve >= 0 ? "+" : ""}${Math.round(summary.generationReserve).toLocaleString()} MW reserve`}
          icon={<Zap className="h-6 w-6" />}
        />

        <StatCard
          title="Total Load"
          value={Math.round(summary.totalLoad).toLocaleString()}
          unit="MW"
          change={`${summary.nodeCount} grid nodes reporting`}
          icon={<BarChart3 className="h-6 w-6" />}
          iconColor="text-green-400"
        />

        <StatCard
          title="Grid Frequency"
          value={summary.frequency.toFixed(3)}
          unit="Hz"
          subtitle={`Nominal: 50 Hz · ${isConnected ? "Live" : "Demo feed"}`}
          icon={<Activity className="h-6 w-6" />}
          iconColor="text-purple-400"
        />

        <StatCard
          title="System Health"
          value={summary.systemHealth.toFixed(1)}
          unit="%"
          subtitle={`${summary.risk.toUpperCase()} grid risk`}
          icon={<ShieldCheck className="h-6 w-6" />}
          iconColor="text-green-400"
        />

      </div>

      {/* Dashboard Content */}
      <div className="grid grid-cols-1 gap-5 xl:grid-cols-2">

        {/* Live Grid Map */}
        <div className="min-h-[400px] rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <div className="mb-4">
            <h2 className="text-lg font-semibold text-white">
              Live Grid Map
            </h2>

            <p className="mt-1 text-sm text-slate-400">
              Real-time grid topology and energy flow
            </p>
          </div>

          <div className="overflow-hidden rounded-lg">
            <GridMap />
          </div>
        </div>

        {/* Load Trend */}
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <div className="mb-4">
            <h2 className="text-lg font-semibold text-white">
              Load Trend
            </h2>

            <p className="mt-1 text-sm text-slate-400">
              Actual and forecasted grid load
            </p>
          </div>

          <LoadChart />
        </div>

      </div>

      {/* Load by Region & Generation Mix */}
      <div className="grid grid-cols-1 gap-5 xl:grid-cols-2">

        {/* Load by Region */}
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <h2 className="text-lg font-semibold text-white">
            Load by Region
          </h2>

          <p className="mt-1 text-sm text-slate-400">
            Current power demand by region
          </p>

          <RegionPieChart />
        </div>

        {/* Generation Mix */}
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <h2 className="text-lg font-semibold text-white">
            Generation Mix
          </h2>

          <p className="mt-1 text-sm text-slate-400">
            Current electricity generation sources
          </p>

          <GenerationMixChart />
        </div>

      </div>

      {/* Forecast */}
      <div className="mt-5 rounded-xl border border-slate-800 bg-[#0b1728] p-5">

        <div className="mb-4 flex flex-col justify-between gap-4 md:flex-row md:items-center">

          <div>
            <h2 className="text-lg font-semibold text-white">
              Forecast (Next 24h)
            </h2>

            <p className="mt-1 text-sm text-slate-400">
              Predicted grid demand based on forecast data
            </p>
          </div>

          <div className="flex gap-8">

            <div>
              <p className="text-xs text-slate-400">
                Expected Peak
              </p>

              <p className="mt-1 text-xl font-semibold text-white">
                {Math.round(predictedPeak.load).toLocaleString()} MW
              </p>

              <p className="text-xs text-slate-500">
                at {predictedPeak.time}
              </p>
            </div>

            <div>
              <p className="text-xs text-slate-400">
                Expected Low
              </p>

              <p className="mt-1 text-xl font-semibold text-white">
                {Math.round(Math.min(...data.forecast.map((point) => point.load))).toLocaleString()} MW
              </p>

              <p className="text-xs text-slate-500">
                at {data.forecast.find((point) => point.load === Math.min(...data.forecast.map((item) => item.load)))?.time ?? "—"}
              </p>
            </div>

          </div>
        </div>

        <ForecastChart />
      </div>

      {/* Alerts & System Notifications */}
      <div className="mt-5 grid grid-cols-1 gap-5 xl:grid-cols-2">

        {/* Recent Alerts */}
        <AlertPanel />

        {/* System Notifications */}
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">

          <h2 className="text-lg font-semibold text-white">
            System Notifications
          </h2>

          <p className="mt-1 text-sm text-slate-400">
            Current system status and scheduled activities
          </p>

          <div className="mt-6 flex items-center gap-4 rounded-lg border border-emerald-500/20 bg-emerald-500/5 p-4">

            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-emerald-500/10">
              <span className="text-xl text-emerald-400">
                ✓
              </span>
            </div>

            <div>
              <p className="text-sm font-medium text-white">
                {isConnected ? "Live monitoring is connected" : "Demo telemetry is active"}
              </p>

              <p className="mt-1 text-xs text-slate-400">
                {data.nodes.length} simulated grid nodes · {summary.risk} system risk
              </p>
            </div>

          </div>

          <div className="mt-4 rounded-lg border border-slate-800 bg-slate-900/40 p-4">

            <p className="text-xs text-slate-500">
              Next maintenance window
            </p>

            <p className="mt-1 text-sm text-slate-300">
              {data.timestamp.slice(11, 16)} UTC · {isConnected ? "Live telemetry" : "Demo feed"}
            </p>

          </div>

        </div>

      </div>

    </div>
  );
}