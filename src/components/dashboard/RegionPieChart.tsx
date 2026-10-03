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
  { name: "North Zone", value: 1135, percentage: 26 },
  { name: "South Zone", value: 1202, percentage: 28 },
  { name: "East Zone", value: 952, percentage: 22 },
  { name: "Central Zone", value: 731, percentage: 17 },
  { name: "West Zone", value: 332, percentage: 7 },
];

const COLORS = [
  "#22c55e",
  "#06b6d4",
  "#eab308",
  "#8b5cf6",
  "#6366f1",
];

export default function RegionPieChart() {
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
            formatter={(value) => [`${value} MW`, "Load"]}
          />

          <Legend
            layout="vertical"
            verticalAlign="middle"
            align="right"
            wrapperStyle={{
              fontSize: "12px",
              color: "#94a3b8",
            }}
            formatter={(value) => {
              const item = data.find(
                (entry) => entry.name === value
              );

              return `${value} ${item?.percentage ?? 0}%`;
            }}
          />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}