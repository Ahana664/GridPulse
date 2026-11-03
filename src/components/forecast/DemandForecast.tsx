"use client";

import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { useGridData } from "@/hooks/useGridData";

export default function DemandForecast() {
  const { data } = useGridData();
  const forecastData = data.forecast;

  return (
    <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
      <div className="mb-4">
        <h2 className="text-lg font-semibold text-white">
          24-Hour Load Forecast
        </h2>

        <p className="mt-1 text-sm text-slate-400">
          AI-based predicted grid demand
        </p>
      </div>

      <div className="h-[300px] w-full">
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
                  offset="5%"
                  stopColor="#1f8a70"
                  stopOpacity={0.35}
                />

                <stop
                  offset="95%"
                  stopColor="#1f8a70"
                  stopOpacity={0}
                />
              </linearGradient>
            </defs>

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
              domain={[2500, 5000]}
              tick={{ fill: "#6b7785", fontSize: 12 }}
              axisLine={{ stroke: "#1c273344" }}
              tickLine={false}
              unit=" MW"
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
              formatter={(value) => [`${value} MW`, "Forecast Load"]}
            />

            <Area
              type="monotone"
              dataKey="load"
              stroke="#1f8a70"
              strokeWidth={2}
              fill="url(#forecastGradient)"
              activeDot={{ r: 5 }}
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}