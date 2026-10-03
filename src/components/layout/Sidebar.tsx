"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Activity,
  BarChart3,
  Bell,
  FileText,
  Home,
  Map,
  Settings,
  SlidersHorizontal,
  User,
  Zap,
} from "lucide-react";

const menuItems = [
  { name: "Overview", href: "/", icon: Home },
  { name: "Grid Map", href: "/grid-map", icon: Map },
  { name: "Real-time Monitor", href: "/monitor", icon: Activity },
  { name: "Forecast & Analytics", href: "/forecast", icon: BarChart3 },
  { name: "Alerts", href: "/alerts", icon: Bell },
  { name: "Simulator", href: "/simulator", icon: SlidersHorizontal },
  { name: "Reports", href: "/reports", icon: FileText },
  { name: "Settings", href: "/settings", icon: Settings },
  { name: "User Profile", href: "/profile", icon: User },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="fixed left-0 top-0 z-40 flex h-screen w-64 flex-col border-r border-slate-800 bg-[#06101e]">
      
      {/* Logo */}
      <div className="flex h-20 items-center gap-3 border-b border-slate-800 px-6">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-600/20">
          <Zap className="h-6 w-6 text-blue-500" />
        </div>

        <div>
          <h1 className="text-lg font-bold text-white">
            GridPulse
          </h1>
          <p className="text-xs text-slate-400">
            Smart Grid Dashboard
          </p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 space-y-1 px-3 py-5">
        {menuItems.map((item) => {
          const Icon = item.icon;

          const isActive =
            item.href === "/"
              ? pathname === "/"
              : pathname.startsWith(item.href);

          return (
            <Link
              key={item.name}
              href={item.href}
              className={`flex items-center gap-3 rounded-lg px-4 py-3 text-sm transition ${
                isActive
                  ? "bg-blue-600 text-white"
                  : "text-slate-400 hover:bg-slate-800 hover:text-white"
              }`}
            >
              <Icon className="h-5 w-5" />

              <span>{item.name}</span>

              {item.name === "Alerts" && (
                <span className="ml-auto flex h-5 min-w-5 items-center justify-center rounded-full bg-red-500 px-1.5 text-xs font-semibold text-white">
                  3
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      {/* System Status */}
      <div className="border-t border-slate-800 p-4">
        <div className="rounded-xl border border-slate-800 bg-slate-900/50 p-4">
          
          <div className="mb-2 flex items-center gap-2">
            <span className="h-2.5 w-2.5 rounded-full bg-green-500" />

            <span className="text-sm font-medium text-white">
              System Status
            </span>
          </div>

          <p className="text-xs text-green-400">
            All Systems Operational
          </p>

        </div>
      </div>
    </aside>
  );
}