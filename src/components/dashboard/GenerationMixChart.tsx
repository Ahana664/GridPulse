"use client";

import {
  Cell,
  Legend,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
} from "recharts";

const data = [
  { name: "Hydro", value: 1829, percentage: 38 },
  { name: "Solar", value: 1058, percentage: 22 },
  { name: "Wind", value: 866, percentage: 18 },
  { name: "Thermal", value: 818, percentage: 17 },
  { name: "Other", value: 241, percentage: 5 },
];

const COLORS = [
  "#3b82f6",
  "#eab308",
  "#22c55e",
  "#f97316",
  "#8b5cf6",
];

export default function GenerationMixChart() {
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
                fill={COLORS[index]}
              />
            ))}
          </Pie>

          <Tooltip
            contentStyle={{
              backgroundColor: "#0f172a",
              border: "1px solid #334155",
              borderRadius: "8px",
              color: "#fff",
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
    color: "#94a3b8",
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