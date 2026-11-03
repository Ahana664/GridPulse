"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { Bell, ChevronDown, Settings, UserRound } from "lucide-react";
import { useGridData } from "@/hooks/useGridData";

const pageInfo: Record<string, { title: string; description: string; index: string }> = {
  "/": { title: "Grid overview", description: "A live read on the virtual Bangladesh grid.", index: "01" },
  "/grid-map": { title: "Grid topology", description: "Nodes, substations and simulated power pathways.", index: "02" },
  "/monitor": { title: "Live monitor", description: "Telemetry, voltage and load across the model.", index: "03" },
  "/forecast": { title: "Forecast & analytics", description: "Demand signals and predictive risk outlook.", index: "04" },
  "/alerts": { title: "Alerts & safety", description: "Anomalies, operating thresholds and validation.", index: "05" },
  "/simulator": { title: "Scenario lab", description: "Explore simulated grid shocks safely.", index: "06" },
  "/reports": { title: "Reports", description: "Build a concise record of grid performance.", index: "07" },
  "/settings": { title: "Preferences", description: "Configure this local dashboard experience.", index: "08" },
  "/profile": { title: "Operator profile", description: "Your local operator workspace.", index: "09" },
};

export default function Navbar() {
  const pathname = usePathname();
  const { data, isConnected, error } = useGridData();
  const [menu, setMenu] = useState<"alerts" | "profile" | null>(null);
  const page = pageInfo[pathname] ?? pageInfo["/"];

  return (
    <header className="gp-masthead">
      <div className="gp-mobile-brand"><span className="gp-brand-mark"><span>G</span></span><strong>Grid<span>Pulse</span></strong></div>
      <div className="gp-page-heading">
        <span className="gp-eyebrow">CONTROL ROOM / {page.index}</span>
        <h1 className="gp-serif">{page.title}</h1>
        <p>{page.description}</p>
      </div>
      <div className="gp-masthead-actions">
        <div className="gp-stream-state">
          <i className={isConnected ? "is-online" : "is-offline"} />
          <span><strong>{isConnected ? "STREAM LIVE" : error ? "LOCAL PREVIEW" : "CONNECTING"}</strong><small>{isConnected ? "Virtual telemetry" : "Simulation workspace"}</small></span>
        </div>
        <div className="gp-menu-wrap">
          <button type="button" className={`gp-icon-button ${menu === "alerts" ? "is-open" : ""}`} aria-label="Toggle alert notifications" aria-expanded={menu === "alerts"} onClick={() => setMenu(menu === "alerts" ? null : "alerts")}>
            <Bell size={17} /><span className="gp-notification-count">{data.alerts.length}</span>
          </button>
          {menu === "alerts" && <div className="gp-popover gp-alert-popover">
            <div className="gp-popover-heading"><strong>Recent signals</strong><span>{data.alerts.length} active</span></div>
            <div className="gp-popover-list">{data.alerts.length === 0 ? <p>No active anomalies.</p> : data.alerts.slice(0, 5).map((alert) => <div key={alert.id}><b className={alert.type === "critical" ? "gp-critical-text" : "gp-warning-text"}>{alert.title}</b><p>{alert.message}</p></div>)}</div>
            <Link href="/alerts" onClick={() => setMenu(null)}>Open alert desk <span>↗</span></Link>
          </div>}
        </div>
        <div className="gp-menu-wrap">
          <button type="button" className="gp-operator-button" aria-expanded={menu === "profile"} onClick={() => setMenu(menu === "profile" ? null : "profile")}>
            <span className="gp-avatar">O</span><span className="gp-operator-copy"><strong>Operator</strong><small>Research workspace</small></span><ChevronDown size={14} />
          </button>
          {menu === "profile" && <div className="gp-popover gp-profile-popover">
            <Link href="/profile" onClick={() => setMenu(null)}><UserRound size={15} /> Operator profile</Link>
            <Link href="/settings" onClick={() => setMenu(null)}><Settings size={15} /> Preferences</Link>
          </div>}
        </div>
      </div>
    </header>
  );
}
