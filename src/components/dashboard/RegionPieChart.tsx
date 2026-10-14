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

const COLORS = [
  "#22c55e",
  "#06b6d4",
  "#eab308",
  "#8b5cf6",
  "#6366f1",
];

export default function RegionPieChart() {
  const { data: grid } = useGridData();
  const data = Array.from(
    grid.nodes
      .filter((node) => node.type === "load")
      .reduce((zones, node) => zones.set(node.zone, (zones.get(node.zone) ?? 0) + node.power), new Map<string, number>()),
    ([name, value]) => ({ name, value, percentage: 0 }),
  );
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