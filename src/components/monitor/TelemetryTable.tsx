"use client";

import { useGridData } from "@/hooks/useGridData";

export default function TelemetryTable() {
  const { data } = useGridData();

  return (
    <div className="overflow-hidden rounded-xl border border-slate-800 bg-[#0b1728]">
      <div className="border-b border-slate-800 p-5">
        <h2 className="text-lg font-semibold text-white">
          Live Telemetry
        </h2>

        <p className="mt-1 text-sm text-slate-400">
          Real-time grid node measurements
        </p>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm">
          <thead className="bg-slate-900/60 text-xs uppercase text-slate-400">
            <tr>
              <th className="px-5 py-4">Node</th>
              <th className="px-5 py-4">Type</th>
              <th className="px-5 py-4">Voltage</th>
              <th className="px-5 py-4">Load</th>
              <th className="px-5 py-4">Power</th>
              <th className="px-5 py-4">Status</th>
            </tr>
          </thead>

          <tbody className="divide-y divide-slate-800">
            {data.nodes.map((item) => (
              <tr
                key={item.id}
                className="transition hover:bg-slate-800/40"
              >
                <td className="px-5 py-4 font-medium text-white">
                  {item.name}
                </td>

                <td className="px-5 py-4 text-slate-400">
                  {item.type}
                </td>

                <td className="px-5 py-4 text-slate-300">
                  {item.voltage} kV
                </td>

                <td className="px-5 py-4 text-slate-300">
                  {item.load}%
                </td>

                <td className="px-5 py-4 text-slate-300">
                  {Math.round(item.power).toLocaleString()} MW
                </td>

                <td className="px-5 py-4">
                  <span
                    className={`inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-medium ${
                      item.status === "normal"
                        ? "bg-green-500/10 text-green-400"
                        : "bg-orange-500/10 text-orange-400"
                    }`}
                  >
                    <span
                      className={`h-2 w-2 rounded-full ${
                        item.status === "normal"
                          ? "bg-green-500"
                          : "bg-orange-500"
                      }`}
                    />

                    {item.status}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}