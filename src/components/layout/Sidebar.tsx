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
import { useGridData } from "@/hooks/useGridData";

const menuItems = [
  { name: "Overview", href: "/", icon: Home },
  { name: "Grid Map", href: "/grid-map", icon: Map },
  { name: "Live Monitor", href: "/monitor", icon: Activity },
  { name: "Forecast", href: "/forecast", icon: BarChart3 },
  { name: "Alerts", href: "/alerts", icon: Bell },
  { name: "Simulator", href: "/simulator", icon: SlidersHorizontal },
  { name: "Reports", href: "/reports", icon: FileText },
];

const utilityItems = [
  { name: "Settings", href: "/settings", icon: Settings },
  { name: "Operator profile", href: "/profile", icon: User },
];

export default function Sidebar() {
  const pathname = usePathname();
  const { data, isConnected, error } = useGridData();
  const alertCount = data.alerts.length;

  function renderLink(item: (typeof menuItems)[number] | (typeof utilityItems)[number]) {
    const Icon = item.icon;
    const active = item.href === "/" ? pathname === "/" : pathname.startsWith(item.href);
    return (
      <Link key={item.href} href={item.href} aria-label={item.name} title={item.name} className={`gp-nav-link ${active ? "is-active" : ""}`} aria-current={active ? "page" : undefined}>
        <Icon size={17} strokeWidth={1.7} />
        <span>{item.name}</span>
        {item.href === "/alerts" && alertCount > 0 && <span className="gp-nav-count">{alertCount}</span>}
      </Link>
    );
  }

  return (
    <aside className="gp-sidebar">
      <Link href="/" className="gp-brand">
        <span className="gp-brand-mark"><Zap size={21} fill="currentColor" /></span>
        <span><strong>Grid<span>Pulse</span></strong><small>GRID OPERATIONS / LAB</small></span>
      </Link>
      <div className="gp-nav-caption">WORKSPACE</div>
      <nav className="gp-navigation" aria-label="Main navigation">{menuItems.map(renderLink)}</nav>
      <div className="gp-nav-caption gp-tools-caption">PREFERENCES</div>
      <nav className="gp-navigation" aria-label="Preferences">{utilityItems.map(renderLink)}</nav>
      <div className="gp-sidebar-foot">
        <span className={`gp-sidebar-led ${isConnected ? "is-online" : ""}`} />
        <div><strong>{isConnected ? "Simulator online" : error ? "Preview mode" : "Connecting"}</strong><small>{isConnected ? "Telemetry stream active" : "Virtual grid environment"}</small></div>
      </div>
    </aside>
  );
}
