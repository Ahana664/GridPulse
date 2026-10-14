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

interface LoadTooltipEntry {
  dataKey?: string | number;
  value?: number | string | null;
}

interface LoadTooltipProps {
  active?: boolean;
  payload?: LoadTooltipEntry[];
  label?: string | number;
}

function CustomTooltip({
  active,
  payload,
  label,
}: LoadTooltipProps) {
  if (!active || !payload || payload.length === 0) {
    return null;
  }

  return (
    <div className="rounded-lg border border-slate-700 bg-[#0f172a] px-4 py-3 shadow-xl">
      <p className="mb-2 text-sm font-semibold text-white">
        {String(label ?? "")}
      </p>

      {payload.map((item) => {
        let name = "Capacity";

        if (item.dataKey === "actual") {
          name = "Actual Load";
        }

        if (item.dataKey === "forecast") {
          name = "Forecast Load";
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

export default function LoadChart() {
  const { data: grid } = useGridData();
  const data = [
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
            stroke="#1e293b"
          />

          <XAxis
            dataKey="time"
            tick={{ fill: "#94a3b8", fontSize: 12 }}
            axisLine={{ stroke: "#334155" }}
            tickLine={false}
          />

          <YAxis
            domain={[0, 6000]}
            tick={{ fill: "#94a3b8", fontSize: 12 }}
            axisLine={false}
            tickLine={false}
            tickFormatter={(value) => `${value / 1000}K`}
          />

          <Tooltip
            content={<CustomTooltip />}
          />

          <Legend
            wrapperStyle={{
              color: "#94a3b8",
              fontSize: "12px",
            }}
          />

          <Line
            type="monotone"
            dataKey="actual"
            name="Actual Load"
            stroke="#3b82f6"
            strokeWidth={2.5}
            dot={false}
            connectNulls={false}
          />

          <Line
            type="monotone"
            dataKey="forecast"
            name="Forecast Load"
            stroke="#22d3ee"
            strokeWidth={2}
            strokeDasharray="6 4"
            dot={false}
            connectNulls={false}
          />

          <Line
            type="monotone"
            dataKey="capacity"
            name="Capacity"
            stroke="#64748b"
            strokeWidth={1}
            strokeDasharray="3 3"
            dot={false}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}