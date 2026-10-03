export default function ReportsPage() {
  const reports = [
    {
      title: "Daily Grid Performance",
      description:
        "Summary of generation, load, frequency, and system health.",
      period: "Today",
      status: "Ready",
    },
    {
      title: "Load Analysis Report",
      description:
        "Detailed analysis of grid demand and peak load behavior.",
      period: "Last 24 Hours",
      status: "Ready",
    },
    {
      title: "Grid Health Report",
      description:
        "Overview of voltage, frequency, and infrastructure status.",
      period: "Last 24 Hours",
      status: "Ready",
    },
  ];

  return (
    <div>
      {/* Summary Cards */}
      <div className="mb-6 grid grid-cols-1 gap-4 md:grid-cols-3">
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Reports Generated
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            24
          </p>

          <p className="mt-1 text-xs text-green-400">
            This month
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Available Reports
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            3
          </p>

          <p className="mt-1 text-xs text-blue-400">
            Ready to view
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <p className="text-sm text-slate-400">
            Last Generated
          </p>

          <p className="mt-2 text-2xl font-semibold text-white">
            11:45 AM
          </p>

          <p className="mt-1 text-xs text-slate-400">
            Today
          </p>
        </div>
      </div>

      {/* Report List */}
      <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
        <div className="mb-5">
          <h2 className="text-lg font-semibold text-white">
            Available Reports
          </h2>

          <p className="mt-1 text-sm text-slate-400">
            View available grid performance and analytical reports.
          </p>
        </div>

        <div className="space-y-3">
          {reports.map((report) => (
            <div
              key={report.title}
              className="flex flex-col gap-4 rounded-lg border border-slate-800 bg-slate-900/40 p-4 md:flex-row md:items-center md:justify-between"
            >
              <div>
                <h3 className="text-sm font-medium text-white">
                  {report.title}
                </h3>

                <p className="mt-1 text-xs text-slate-400">
                  {report.description}
                </p>

                <div className="mt-2 flex items-center gap-3">
                  <span className="text-xs text-slate-500">
                    {report.period}
                  </span>

                  <span className="rounded-full bg-green-500/10 px-2.5 py-1 text-xs font-medium text-green-400">
                    {report.status}
                  </span>
                </div>
              </div>

              <button className="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white transition hover:bg-blue-500">
                View Report
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* Report Generation */}
      <div className="mt-6 rounded-xl border border-slate-800 bg-[#0b1728] p-5">
        <div className="mb-5">
          <h2 className="text-lg font-semibold text-white">
            Generate New Report
          </h2>

          <p className="mt-1 text-sm text-slate-400">
            Select a report type to generate a new analytical report.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
          <button className="rounded-lg border border-slate-700 bg-slate-900/50 p-4 text-left transition hover:border-blue-500">
            <p className="text-sm font-medium text-white">
              Performance Report
            </p>

            <p className="mt-1 text-xs text-slate-400">
              Grid generation and load performance
            </p>
          </button>

          <button className="rounded-lg border border-slate-700 bg-slate-900/50 p-4 text-left transition hover:border-blue-500">
            <p className="text-sm font-medium text-white">
              Analytics Report
            </p>

            <p className="mt-1 text-xs text-slate-400">
              Forecast and demand analysis
            </p>
          </button>

          <button className="rounded-lg border border-slate-700 bg-slate-900/50 p-4 text-left transition hover:border-blue-500">
            <p className="text-sm font-medium text-white">
              Alert Report
            </p>

            <p className="mt-1 text-xs text-slate-400">
              Grid alerts and anomaly summary
            </p>
          </button>
        </div>
      </div>
    </div>
  );
}