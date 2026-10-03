"use client";

import { useState } from "react";

export default function SettingsPage() {
  const [autoRefresh, setAutoRefresh] = useState(true);
  const [notifications, setNotifications] = useState(true);
  const [forecastAlerts, setForecastAlerts] = useState(true);

  return (
    <div className="p-6">
      <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
        {/* Monitoring Settings */}
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <div className="mb-5">
            <h2 className="text-lg font-semibold text-white">
              Monitoring Settings
            </h2>

            <p className="mt-1 text-sm text-slate-400">
              Configure how grid data is monitored.
            </p>
          </div>

          <div className="space-y-4">
            {/* Auto Refresh */}
            <div className="flex items-center justify-between rounded-lg bg-slate-900/50 p-4">
              <div>
                <p className="text-sm font-medium text-white">
                  Auto Refresh
                </p>

                <p className="mt-1 text-xs text-slate-400">
                  Automatically refresh dashboard data.
                </p>
              </div>

              <button
                onClick={() => setAutoRefresh(!autoRefresh)}
                className={`relative h-6 w-11 rounded-full transition ${
                  autoRefresh ? "bg-blue-600" : "bg-slate-700"
                }`}
              >
                <span
                  className={`absolute top-1 h-4 w-4 rounded-full bg-white transition ${
                    autoRefresh ? "left-6" : "left-1"
                  }`}
                />
              </button>
            </div>

            {/* Refresh Interval */}
            <div className="rounded-lg bg-slate-900/50 p-4">
              <label className="text-sm font-medium text-white">
                Refresh Interval
              </label>

              <select className="mt-3 w-full rounded-lg border border-slate-700 bg-[#081525] px-3 py-2 text-sm text-slate-300 outline-none focus:border-blue-500">
                <option>5 seconds</option>
                <option>10 seconds</option>
                <option>30 seconds</option>
                <option>1 minute</option>
              </select>
            </div>
          </div>
        </div>

        {/* Notification Settings */}
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <div className="mb-5">
            <h2 className="text-lg font-semibold text-white">
              Notification Settings
            </h2>

            <p className="mt-1 text-sm text-slate-400">
              Control grid alert notifications.
            </p>
          </div>

          <div className="space-y-4">
            {/* System Notifications */}
            <div className="flex items-center justify-between rounded-lg bg-slate-900/50 p-4">
              <div>
                <p className="text-sm font-medium text-white">
                  System Notifications
                </p>

                <p className="mt-1 text-xs text-slate-400">
                  Receive important grid system notifications.
                </p>
              </div>

              <button
                onClick={() => setNotifications(!notifications)}
                className={`relative h-6 w-11 rounded-full transition ${
                  notifications ? "bg-blue-600" : "bg-slate-700"
                }`}
              >
                <span
                  className={`absolute top-1 h-4 w-4 rounded-full bg-white transition ${
                    notifications ? "left-6" : "left-1"
                  }`}
                />
              </button>
            </div>

            {/* Forecast Alerts */}
            <div className="flex items-center justify-between rounded-lg bg-slate-900/50 p-4">
              <div>
                <p className="text-sm font-medium text-white">
                  Forecast Alerts
                </p>

                <p className="mt-1 text-xs text-slate-400">
                  Receive alerts about predicted peak demand.
                </p>
              </div>

              <button
                onClick={() => setForecastAlerts(!forecastAlerts)}
                className={`relative h-6 w-11 rounded-full transition ${
                  forecastAlerts ? "bg-blue-600" : "bg-slate-700"
                }`}
              >
                <span
                  className={`absolute top-1 h-4 w-4 rounded-full bg-white transition ${
                    forecastAlerts ? "left-6" : "left-1"
                  }`}
                />
              </button>
            </div>
          </div>
        </div>

        {/* Grid Configuration */}
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <div className="mb-5">
            <h2 className="text-lg font-semibold text-white">
              Grid Configuration
            </h2>

            <p className="mt-1 text-sm text-slate-400">
              Configure basic grid monitoring parameters.
            </p>
          </div>

          <div className="space-y-4">
            <div className="rounded-lg bg-slate-900/50 p-4">
              <label className="text-sm font-medium text-white">
                Nominal Frequency
              </label>

              <div className="mt-3 flex items-center gap-3">
                <input
                  type="text"
                  value="50.00"
                  readOnly
                  className="w-full rounded-lg border border-slate-700 bg-[#081525] px-3 py-2 text-sm text-slate-300 outline-none"
                />

                <span className="text-sm text-slate-400">
                  Hz
                </span>
              </div>
            </div>

            <div className="rounded-lg bg-slate-900/50 p-4">
              <label className="text-sm font-medium text-white">
                Voltage Level
              </label>

              <div className="mt-3 flex items-center gap-3">
                <input
                  type="text"
                  value="230"
                  readOnly
                  className="w-full rounded-lg border border-slate-700 bg-[#081525] px-3 py-2 text-sm text-slate-300 outline-none"
                />

                <span className="text-sm text-slate-400">
                  kV
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* System Information */}
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
          <div className="mb-5">
            <h2 className="text-lg font-semibold text-white">
              System Information
            </h2>

            <p className="mt-1 text-sm text-slate-400">
              GridPulse system information.
            </p>
          </div>

          <div className="space-y-3">
            <div className="flex items-center justify-between rounded-lg bg-slate-900/50 p-4">
              <span className="text-sm text-slate-400">
                System Status
              </span>

              <span className="flex items-center gap-2 text-sm text-green-400">
                <span className="h-2 w-2 rounded-full bg-green-500" />
                Operational
              </span>
            </div>

            <div className="flex items-center justify-between rounded-lg bg-slate-900/50 p-4">
              <span className="text-sm text-slate-400">
                Forecast Engine
              </span>

              <span className="text-sm text-blue-400">
                Active
              </span>
            </div>

            <div className="flex items-center justify-between rounded-lg bg-slate-900/50 p-4">
              <span className="text-sm text-slate-400">
                Dashboard Version
              </span>

              <span className="text-sm text-white">
                v1.0.0
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}