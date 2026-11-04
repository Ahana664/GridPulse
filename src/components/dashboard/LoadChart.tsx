"use client";

import {
  CartesianGrid,
  Legend,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { useGridData } from "@/hooks/useGridData";
import type { DashboardMode, RealDashboardData } from "@/types/realDashboard";

interface LoadTooltipEntry {
  dataKey?: string | number;
  value?: number | string | null;
}

interface LoadTooltipProps {
  active?: boolean;
  payload?: LoadTooltipEntry[];
  label?: string | number;
  mode?: DashboardMode;
}

function CustomTooltip({
  active,
  payload,
  label,
  mode = "simulated",
}: LoadTooltipProps) {
  if (!active || !payload || payload.length === 0) {
    return null;
  }

  return (
    <div className="rounded-lg border border-slate-700 bg-[#0f172a] px-4 py-3 shadow-xl gp-chart-tooltip">
      <p className="mb-2 text-sm font-semibold text-white">
        {String(label ?? "")}
      </p>

      {payload.map((item) => {
        let name = "Capacity";

        if (item.dataKey === "actual") {
          name = mode === "real" ? "PGCB Generation" : "Actual Load";
        }

        if (item.dataKey === "forecast") {
          name = mode === "real" ? "Generation Forecast" : "Forecast Load";
        }

        if (item.dataKey === "capacity") {
          name = "Capacity";
        }

        return (
          <div
            key={item.dataKey}
            className="flex items-center justify-between gap-6 text-sm"
          >
            <span className="text-slate-400">
              {name}
            </span>

            <span className="font-medium text-white">
              {item.value !== null && item.value !== undefined
                ? `${item.value} MW`
                : "—"}
            </span>
          </div>
        );
      })}
    </div>
  );
}

export default function LoadChart({ mode = "simulated", realData }: { mode?: DashboardMode; realData?: RealDashboardData | null }) {
  const { data: grid } = useGridData();
  type ChartPoint = { time: string; actual: number | null; forecast: number | null; capacity: number | null };
  const simulatedSeries: ChartPoint[] = [
    ...grid.history.slice(-12).map((point) => ({
      time: point.time.includes("T")
        ? new Date(point.time).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: false })
        : point.time,
      actual: point.actual,
      forecast: null,
      capacity: point.capacity,
    })),
    ...grid.forecast.map((point) => ({
      time: point.time,
      actual: null,
      forecast: point.load,
      capacity: 6_000,
    })),
  ];
  const realSeries: ChartPoint[] = [
    ...(realData?.history ?? []).slice(-36).map((point) => ({
      time: new Date(point.observed_at).toLocaleString([], { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" }),
      actual: point.actual_mw ?? (point.demand_is_inferred ? point.generation_mw : point.demand_mw) ?? null,
      forecast: null,
      capacity: null,
    })),
    ...(realData?.forecast ?? []).map((point) => ({
      time: point.time,
      actual: null,
      forecast: point.load,
      capacity: null,
    })),
  ];
  const data = mode === "real" ? realSeries : simulatedSeries;

  return (
    <div className="h-[320px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <LineChart
          data={data}
          margin={{
            top: 10,
            right: 10,
            left: 0,
            bottom: 0,
          }}
        >
          <CartesianGrid
            strokeDasharray="3 3"
            stroke="#1c273322"
          />

          <XAxis
            dataKey="time"
            tick={{ fill: "#6b7785", fontSize: 12 }}
            axisLine={{ stroke: "#1c273344" }}
            tickLine={false}
          />

          <YAxis
            domain={mode === "real" ? ["auto", "auto"] : [0, 6000]}
            tick={{ fill: "#6b7785", fontSize: 12 }}
            axisLine={false}
            tickLine={false}
            tickFormatter={(value) => `${value / 1000}K`}
          />

          <Tooltip content={<CustomTooltip mode={mode} />} />

          <Legend
            wrapperStyle={{
              color: "#6b7785",
              fontSize: "12px",
            }}
          />

          <Line
            type="monotone"
            dataKey="actual"
            name={mode === "real" ? "PGCB Generation" : "Actual Load"}
            stroke="#1f8a70"
            strokeWidth={2.5}
            dot={false}
            connectNulls={false}
          />

          <Line
            type="monotone"
            dataKey="forecast"
            name={mode === "real" ? "Generation Forecast" : "Forecast Load"}
            stroke="#c9871a"
            strokeWidth={2}
            strokeDasharray="6 4"
            dot={false}
            connectNulls={false}
          />

          {mode === "simulated" && <Line
            type="monotone"
            dataKey="capacity"
            name="Capacity"
            stroke="#64748b"
            strokeWidth={1}
            strokeDasharray="3 3"
            dot={false}
          />}
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}