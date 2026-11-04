"use client";

import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { useGridData } from "@/hooks/useGridData";
import type { DashboardMode, RealDashboardData } from "@/types/realDashboard";

interface ForecastTooltipProps {
  active?: boolean;
  payload?: { value?: number | string | null }[];
  label?: string | number;
  mode?: DashboardMode;
}

function ForecastTooltip({ active, payload, label, mode = "simulated" }: ForecastTooltipProps) {
  if (!active || !payload || payload.length === 0) return null;

  return (
    <div className="rounded-lg border border-slate-700 bg-[#0f172a] px-4 py-3 shadow-xl gp-chart-tooltip">
      <p className="mb-1 text-sm font-semibold text-white">{String(label ?? "")}</p>
      <p className="text-sm text-emerald-400">
        {mode === "real" ? "National forecast:" : "Forecast Load:"}{" "}
        <span className="font-semibold text-white">{payload[0].value ?? "—"} MW</span>
      </p>
    </div>
  );
}

export default function ForecastChart({ mode = "simulated", realData }: { mode?: DashboardMode; realData?: RealDashboardData | null }) {
  const { data } = useGridData();
  const forecastData = mode === "real" ? (realData?.forecast ?? []) : data.forecast;

  return (
    <div className="h-[230px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={forecastData} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
          <defs>
            <linearGradient id="forecastGradient" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#1f8a70" stopOpacity={0.35} />
              <stop offset="100%" stopColor="#1f8a70" stopOpacity={0.02} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="#1c273322" />
          <XAxis
            dataKey="time"
            tick={{ fill: "#6b7785", fontSize: 11 }}
            axisLine={{ stroke: "#1c273344" }}
            tickLine={false}
          />
          <YAxis
            domain={mode === "real" ? ["auto", "auto"] : [0, 6000]}
            tick={{ fill: "#6b7785", fontSize: 11 }}
            axisLine={false}
            tickLine={false}
            tickFormatter={(value) => `${value / 1000}K`}
          />
          <Tooltip content={<ForecastTooltip mode={mode} />} />
          <Area
            type="monotone"
            dataKey="load"
            stroke="#1f8a70"
            strokeWidth={2.5}
            fill="url(#forecastGradient)"
            dot={false}
            activeDot={{ r: 5 }}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}
