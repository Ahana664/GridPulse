const telemetryData = [
  {
    node: "North Solar Plant",
    type: "Generation",
    voltage: "230 kV",
    load: "42%",
    power: "620 MW",
    status: "Normal",
  },
  {
    node: "North Substation",
    type: "Substation",
    voltage: "230 kV",
    load: "58%",
    power: "810 MW",
    status: "Normal",
  },
  {
    node: "Central Substation",
    type: "Substation",
    voltage: "132 kV",
    load: "68%",
    power: "1,420 MW",
    status: "Normal",
  },
  {
    node: "West Wind Farm",
    type: "Generation",
    voltage: "132 kV",
    load: "51%",
    power: "540 MW",
    status: "Normal",
  },
  {
    node: "South Hydro Plant",
    type: "Generation",
    voltage: "132 kV",
    load: "47%",
    power: "730 MW",
    status: "Warning",
  },
];

export default function TelemetryTable() {
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
            {telemetryData.map((item) => (
              <tr
                key={item.node}
                className="transition hover:bg-slate-800/40"
              >
                <td className="px-5 py-4 font-medium text-white">
                  {item.node}
                </td>

                <td className="px-5 py-4 text-slate-400">
                  {item.type}
                </td>

                <td className="px-5 py-4 text-slate-300">
                  {item.voltage}
                </td>

                <td className="px-5 py-4 text-slate-300">
                  {item.load}
                </td>

                <td className="px-5 py-4 text-slate-300">
                  {item.power}
                </td>

                <td className="px-5 py-4">
                  <span
                    className={`inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-medium ${
                      item.status === "Normal"
                        ? "bg-green-500/10 text-green-400"
                        : "bg-orange-500/10 text-orange-400"
                    }`}
                  >
                    <span
                      className={`h-2 w-2 rounded-full ${
                        item.status === "Normal"
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