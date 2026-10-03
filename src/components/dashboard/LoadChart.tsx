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

const data = [
  { time: "00:00", actual: 2700, forecast: null, capacity: 6000 },
  { time: "02:00", actual: 2450, forecast: null, capacity: 6000 },
  { time: "04:00", actual: 2600, forecast: null, capacity: 6000 },
  { time: "06:00", actual: 3100, forecast: null, capacity: 6000 },
  { time: "08:00", actual: 3700, forecast: null, capacity: 6000 },
  { time: "10:00", actual: 4400, forecast: null, capacity: 6000 },
  { time: "12:00", actual: 4800, forecast: 4800, capacity: 6000 },
  { time: "14:00", actual: null, forecast: 4700, capacity: 6000 },
  { time: "16:00", actual: null, forecast: 4550, capacity: 6000 },
  { time: "18:00", actual: null, forecast: 4900, capacity: 6000 },
  { time: "20:00", actual: null, forecast: 4500, capacity: 6000 },
  { time: "22:00", actual: null, forecast: 4000, capacity: 6000 },
  { time: "24:00", actual: null, forecast: 3700, capacity: 6000 },
];

function CustomTooltip({
  active,
  payload,
  label,
}: any) {
  if (!active || !payload || payload.length === 0) {
    return null;
  }

  return (
    <div className="rounded-lg border border-slate-700 bg-[#0f172a] px-4 py-3 shadow-xl">
      <p className="mb-2 text-sm font-semibold text-white">
        {label}
      </p>

      {payload.map((item: any) => {
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