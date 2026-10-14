"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { Bell, ChevronDown } from "lucide-react";
import { useGridData } from "@/hooks/useGridData";

const pageInfo: Record<string, { title: string; description: string }> = {
  "/": {
    title: "Overview",
    description: "Real-time overview of power grid performance",
  },

  "/grid-map": {
    title: "Grid Map",
    description: "Real-time grid topology and energy flow",
  },

  "/monitor": {
    title: "Real-time Monitor",
    description:
      "Monitor real-time grid telemetry and system performance",
  },

  "/forecast": {
    title: "Forecast & Analytics",
    description:
      "AI-powered load forecasting and grid risk analysis",
  },

  "/alerts": {
    title: "Alerts",
    description:
      "Monitor grid anomalies, warnings, and critical events",
  },

  "/simulator": {
    title: "Shock Scenario Simulator",
    description:
      "Simulate grid shock scenarios and analyze their potential impact",
  },

  "/reports": {
    title: "Reports",
    description:
      "View grid performance and analytical reports",
  },

  "/settings": {
    title: "Settings",
    description:
      "Configure GridPulse system preferences",
  },

  "/profile": {
    title: "User Profile",
    description:
      "Manage your GridPulse operator profile",
  },
};

export default function Navbar() {
  const pathname = usePathname();
  const { data, isConnected, error } = useGridData();
  const activeAlerts = data.alerts;

  const [showNotifications, setShowNotifications] =
    useState(false);

  const [showProfileMenu, setShowProfileMenu] =
    useState(false);

  const currentPage =
    pageInfo[pathname] || pageInfo["/"];

  return (
    <header className="flex h-20 items-center justify-between border-b border-slate-800 bg-[#07111f] px-8">

      {/* =========================
          PAGE INFORMATION
      ========================== */}
      <div>
        <h2 className="text-xl font-semibold text-white">
          {currentPage.title}
        </h2>

        <p className="text-sm text-slate-400">
          {currentPage.description}
        </p>
      </div>


      {/* =========================
          RIGHT SIDE
      ========================== */}
      <div className="flex items-center gap-5">


        {/* =========================
            LIVE STATUS
        ========================== */}
        <div className="hidden items-center gap-3 rounded-xl border border-slate-800 bg-slate-900/60 px-4 py-2 md:flex">

          <span className={`h-2.5 w-2.5 rounded-full ${isConnected ? "bg-green-500" : "bg-amber-400"}`} />

          <div>
            <p className="text-sm font-medium text-white">
              {isConnected ? "Live" : error ? "Demo" : "Connecting"}
            </p>

            <p className="text-xs text-slate-400">
              {isConnected ? "Grid stream connected" : error ? "Using demo telemetry" : "Waiting for grid stream"}
            </p>
          </div>

        </div>


        {/* =========================
            NOTIFICATIONS
        ========================== */}
        <div className="relative">

          <button
            type="button"
            onClick={() => {
              setShowNotifications(!showNotifications);
              setShowProfileMenu(false);
            }}
            className="relative flex h-10 w-10 items-center justify-center rounded-full border border-slate-800 bg-slate-900 text-slate-300 transition hover:bg-slate-800"
          >

            <Bell className="h-5 w-5" />

            {/* Notification Count */}
            <span className="absolute -right-1 -top-1 flex h-5 min-w-5 items-center justify-center rounded-full bg-red-500 px-1 text-xs font-bold text-white">
              {activeAlerts.length}
            </span>

          </button>


          {/* =========================
              NOTIFICATION DROPDOWN
          ========================== */}
          {showNotifications && (
            <div className="absolute right-0 top-12 z-50 w-80 rounded-xl border border-slate-800 bg-[#0b1728] shadow-2xl">

              {/* Notification Header */}
              <div className="flex items-center justify-between border-b border-slate-800 px-4 py-3">

                <div>
                  <h3 className="text-sm font-semibold text-white">
                    Notifications
                  </h3>

                  <p className="text-xs text-slate-400">
                    {activeAlerts.length} active alerts
                  </p>
                </div>

                <span className="rounded-full bg-red-500/10 px-2 py-1 text-xs text-red-400">
                  {activeAlerts.length} Active
                </span>

              </div>


              {/* Notification List */}
              <div className="max-h-80 divide-y divide-slate-800 overflow-y-auto">
                {activeAlerts.length === 0 && (
                  <p className="px-4 py-5 text-sm text-slate-500">No active anomalies.</p>
                )}
                {activeAlerts.slice(0, 5).map((alert) => (
                  <div key={alert.id} className="px-4 py-3 transition hover:bg-slate-800/40">
                    <p className={`text-sm font-medium ${alert.type === "critical" ? "text-red-400" : "text-yellow-400"}`}>
                      {alert.title}
                    </p>
                    <p className="mt-1 text-xs text-slate-400">{alert.message}</p>
                    <p className="mt-1 text-[11px] text-slate-500">
                      {isConnected ? new Date(alert.time).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }) : "Demo sample"}
                    </p>
                  </div>
                ))}
              </div>


              {/* View All Alerts */}
              <div className="border-t border-slate-800 p-3">

                <Link
                  href="/alerts"
                  onClick={() =>
                    setShowNotifications(false)
                  }
                  className="block rounded-lg bg-blue-600 px-3 py-2 text-center text-sm font-medium text-white transition hover:bg-blue-500"
                >
                  View All Alerts
                </Link>

              </div>

            </div>
          )}

        </div>


        {/* =========================
            ADMIN PROFILE
        ========================== */}
        <div className="relative">

          <button
            type="button"
            onClick={() => {
              setShowProfileMenu(!showProfileMenu);
              setShowNotifications(false);
            }}
            className="flex items-center gap-3 rounded-xl border border-slate-800 bg-slate-900/60 px-3 py-2 transition hover:bg-slate-800"
          >

            {/* Avatar */}
            <div className="flex h-9 w-9 items-center justify-center rounded-full bg-slate-700">

              <span className="text-sm font-semibold text-white">
                A
              </span>

            </div>


            {/* User Information */}
            <div className="hidden text-left md:block">

              <p className="text-sm font-medium text-white">
                Admin
              </p>

              <p className="text-xs text-slate-400">
                System Operator
              </p>

            </div>


            {/* Arrow */}
            <ChevronDown
              className={`h-4 w-4 text-slate-400 transition-transform ${
                showProfileMenu
                  ? "rotate-180"
                  : ""
              }`}
            />

          </button>


          {/* =========================
              PROFILE DROPDOWN
          ========================== */}
          {showProfileMenu && (
            <div className="absolute right-0 top-14 z-50 w-56 rounded-xl border border-slate-800 bg-[#0b1728] p-2 shadow-2xl">


              {/* View Profile */}
              <Link
                href="/profile"
                onClick={() =>
                  setShowProfileMenu(false)
                }
                className="block rounded-lg px-3 py-2.5 text-sm text-slate-300 transition hover:bg-slate-800 hover:text-white"
              >
                👤 View Profile
              </Link>


              {/* Settings */}
              <Link
                href="/settings"
                onClick={() =>
                  setShowProfileMenu(false)
                }
                className="block rounded-lg px-3 py-2.5 text-sm text-slate-300 transition hover:bg-slate-800 hover:text-white"
              >
                ⚙️ Settings
              </Link>


              {/* Divider */}
              <div className="my-2 border-t border-slate-800" />


              {/* Sign Out */}
              <button
                type="button"
                onClick={() => {
                  setShowProfileMenu(false);

                  alert(
                    "Sign out is not connected to authentication yet."
                  );
                }}
                className="block w-full rounded-lg px-3 py-2.5 text-left text-sm text-red-400 transition hover:bg-red-500/10"
              >
                🚪 Sign Out
              </button>

            </div>
          )}

        </div>

      </div>

    </header>
  );
}