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
    <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5 gp-route-card">
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
              stroke="#1c273322"
            />

            <XAxis
              dataKey="time"
              tick={{ fill: "#6b7785", fontSize: 12 }}
              axisLine={{ stroke: "#1c273344" }}
              tickLine={false}
            />

            <YAxis
              domain={[220, 235]}
              tick={{ fill: "#6b7785", fontSize: 12 }}
              axisLine={{ stroke: "#1c273344" }}
              tickLine={false}
              unit=" kV"
            />

            <Tooltip
              contentStyle={{
                backgroundColor: "#fbf8f1",
                border: "1px solid #1c273355",
                borderRadius: "8px",
                color: "#1c2733",
              }}
              labelStyle={{
                color: "#6b7785",
              }}
              formatter={(value) => [`${value} kV`, "Voltage"]}
            />

            <Line
              type="monotone"
              dataKey="voltage"
              stroke="#1f8a70"
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