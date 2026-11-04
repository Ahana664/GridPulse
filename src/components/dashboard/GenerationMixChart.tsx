"use client";

import {
  Cell,
  Legend,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
} from "recharts";
import { useGridData } from "@/hooks/useGridData";
import type { DashboardMode, RealDashboardData } from "@/types/realDashboard";

const COLORS = [
  "#1f8a70",
  "#c9871a",
  "#547f70",
  "#e4572e",
  "#6b7785",
];

export default function GenerationMixChart({ mode = "simulated", realData }: { mode?: DashboardMode; realData?: RealDashboardData | null }) {
  const { data: grid } = useGridData();
  const latest = realData?.latest;
  const realMix = [
    ["Gas", latest?.gas_mw],
    ["Liquid fuel", latest?.liquid_fuel_mw],
    ["Coal", latest?.coal_mw],
    ["Hydro", latest?.hydro_mw],
    ["Solar", latest?.solar_mw],
    ["Wind", latest?.wind_mw],
    ["Imports", latest?.imports_mw],
  ] as const;
  const data = mode === "real"
    ? realMix.flatMap(([name, value]) => typeof value === "number" && value > 0
      ? [{ name, value, percentage: 0 }]
      : [])
    : grid.nodes
      .filter((node) => node.type === "generation")
      .map((node) => ({ name: node.name, value: node.power, percentage: 0 }));
  const total = data.reduce((sum, item) => sum + item.value, 0);
  data.forEach((item) => {
    item.percentage = total === 0 ? 0 : Math.round((item.value / total) * 100);
  });
  return (
    <div className="h-[280px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={data}
            dataKey="value"
            nameKey="name"
            cx="35%"
            cy="50%"
            innerRadius={55}
            outerRadius={90}
            paddingAngle={2}
          >
            {data.map((entry, index) => (
              <Cell
                key={entry.name}
                fill={COLORS[index % COLORS.length]}
              />
            ))}
          </Pie>

          <Tooltip
            contentStyle={{
              backgroundColor: "#fbf8f1",
              border: "1px solid #1c273355",
              borderRadius: "8px",
              color: "#1c2733",
            }}
            formatter={(value) => [`${value} MW`, "Generation"]}
          />

         <Legend
  layout="vertical"
  wrapperStyle={{
    position: "absolute",
    right: 0,
    top: "50%",
    transform: "translateY(-50%)",
    fontSize: "12px",
    color: "#6b7785",
  }}
  formatter={(value) => {
    const item = data.find((entry) => entry.name === value);
    return `${value} ${item?.percentage ?? 0}%`;
  }}
/>
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}