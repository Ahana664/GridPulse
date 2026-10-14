"use client";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { useGridData } from "@/hooks/useGridData";

export default function VoltageChart() {
  const { data: grid } = useGridData();
  const voltageData = grid.history.slice(-12).map((point) => ({
    time: point.time.includes("T")
      ? new Date(point.time).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
      : point.time,
    voltage: point.voltage ?? grid.summary.averageVoltage,
  }));

  return (
    <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
      <div className="mb-4">
        <h2 className="text-lg font-semibold text-white">
          Voltage Trend
        </h2>

        <p className="mt-1 text-sm text-slate-400">
          Real-time grid voltage monitoring
        </p>
      </div>

      <div className="h-[280px] w-full">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart
            data={voltageData}
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
              domain={[220, 235]}
              tick={{ fill: "#94a3b8", fontSize: 12 }}
              axisLine={{ stroke: "#334155" }}
              tickLine={false}
              unit=" kV"
            />

            <Tooltip
              contentStyle={{
                backgroundColor: "#0f1d31",
                border: "1px solid #334155",
                borderRadius: "8px",
                color: "#fff",
              }}
              labelStyle={{
                color: "#94a3b8",
              }}
              formatter={(value) => [`${value} kV`, "Voltage"]}
            />

            <Line
              type="monotone"
              dataKey="voltage"
              stroke="#22c55e"
              strokeWidth={2}
              dot={{ r: 3 }}
              activeDot={{ r: 5 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}