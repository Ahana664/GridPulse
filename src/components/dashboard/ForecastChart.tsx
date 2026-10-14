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

interface ForecastTooltipProps {
  active?: boolean;
  payload?: { value?: number | string | null }[];
  label?: string | number;
}

function ForecastTooltip({
  active,
  payload,
  label,
}: ForecastTooltipProps) {
  if (!active || !payload || payload.length === 0) {
    return null;
  }

  return (
    <div className="rounded-lg border border-slate-700 bg-[#0f172a] px-4 py-3 shadow-xl">
      <p className="mb-1 text-sm font-semibold text-white">
        {String(label ?? "")}
      </p>

      <p className="text-sm text-emerald-400">
        Forecast Load:{" "}
        <span className="font-semibold text-white">
          {payload[0].value ?? "—"} MW
        </span>
      </p>
    </div>
  );
}

export default function ForecastChart() {
  const { data } = useGridData();
  const forecastData = data.forecast;

  return (
    <div className="h-[230px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart
          data={forecastData}
          margin={{
            top: 10,
            right: 10,
            left: 0,
            bottom: 0,
          }}
        >
          <defs>
            <linearGradient
              id="forecastGradient"
              x1="0"
              y1="0"
              x2="0"
              y2="1"
            >
              <stop
                offset="0%"
                stopColor="#22c55e"
                stopOpacity={0.35}
              />

              <stop
                offset="100%"
                stopColor="#22c55e"
                stopOpacity={0.02}
              />
            </linearGradient>
          </defs>

          <CartesianGrid
            strokeDasharray="3 3"
            stroke="#1e293b"
          />

          <XAxis
            dataKey="time"
            tick={{
              fill: "#94a3b8",
              fontSize: 11,
            }}
            axisLine={{
              stroke: "#334155",
            }}
            tickLine={false}
          />

          <YAxis
            domain={[0, 6000]}
            tick={{
              fill: "#94a3b8",
              fontSize: 11,
            }}
            axisLine={false}
            tickLine={false}
            tickFormatter={(value) => `${value / 1000}K`}
          />

          <Tooltip
            content={<ForecastTooltip />}
          />

          <Area
            type="monotone"
            dataKey="load"
            stroke="#22c55e"
            strokeWidth={2.5}
            fill="url(#forecastGradient)"
            dot={false}
            activeDot={{
              r: 5,
            }}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}