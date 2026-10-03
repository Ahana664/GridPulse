import LoadChart from "@/components/dashboard/LoadChart";
import {
  Activity,
  BarChart3,
  ShieldCheck,
  Zap,
} from "lucide-react";

import StatCard from "@/components/dashboard/StatCards";
import { mockStats } from "@/data/mockStats";
import RegionPieChart from "@/components/dashboard/RegionPieChart";
import GenerationMixChart from "@/components/dashboard/GenerationMixChart";
import ForecastChart from "@/components/dashboard/ForecastChart";
import AlertPanel from "@/components/alerts/AlertPanel";
import GridMap from "@/components/grid/GridMap";

export default function Home() {
  return (
    <div className="space-y-6">

      {/* Statistics */}
      <div className="grid grid-cols-1 gap-5 md:grid-cols-2 xl:grid-cols-4">

        <StatCard
          title={mockStats.totalGeneration.title}
          value={mockStats.totalGeneration.value}
          unit={mockStats.totalGeneration.unit}
          change={mockStats.totalGeneration.change}
          icon={<Zap className="h-6 w-6" />}
        />

        <StatCard
          title={mockStats.totalLoad.title}
          value={mockStats.totalLoad.value}
          unit={mockStats.totalLoad.unit}
          change={mockStats.totalLoad.change}
          icon={<BarChart3 className="h-6 w-6" />}
          iconColor="text-green-400"
        />

        <StatCard
          title={mockStats.gridFrequency.title}
          value={mockStats.gridFrequency.value}
          unit={mockStats.gridFrequency.unit}
          subtitle={mockStats.gridFrequency.subtitle}
          icon={<Activity className="h-6 w-6" />}
          iconColor="text-purple-400"
        />

        <StatCard
          title={mockStats.systemHealth.title}
          value={mockStats.systemHealth.value}
          unit={mockStats.systemHealth.unit}
          subtitle={mockStats.systemHealth.subtitle}
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
                5,210 MW
              </p>

              <p className="text-xs text-slate-500">
                at 18:00
              </p>
            </div>

            <div>
              <p className="text-xs text-slate-400">
                Expected Low
              </p>

              <p className="mt-1 text-xl font-semibold text-white">
                3,110 MW
              </p>

              <p className="text-xs text-slate-500">
                at 04:00
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
                All systems are running normally
              </p>

              <p className="mt-1 text-xs text-slate-400">
                GridPulse monitoring services are operational
              </p>
            </div>

          </div>

          <div className="mt-4 rounded-lg border border-slate-800 bg-slate-900/40 p-4">

            <p className="text-xs text-slate-500">
              Next maintenance window
            </p>

            <p className="mt-1 text-sm text-slate-300">
              16 Aug 2026, 01:00 AM - 04:00 AM
            </p>

          </div>

        </div>

      </div>

    </div>
  );
}