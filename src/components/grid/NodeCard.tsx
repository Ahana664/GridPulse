"use client";

import type { GridNode } from "@/data/mockGrid";
import { Activity, Zap, Gauge, AlertTriangle, CheckCircle, ShieldAlert } from "lucide-react";

interface NodeCardProps {
  node: GridNode | null;
  onClose?: () => void;
}

export default function NodeCard({ node, onClose }: NodeCardProps) {
  if (!node) {
    return (
      <div className="bg-[#fbf8f1] border border-[#1c273326] rounded-xl p-5 text-center text-[#6b7785] font-mono text-xs">
        <Activity size={20} className="mx-auto mb-2 text-[#6b7785] opacity-60" />
        Select any node on the topology grid to inspect telemetry.
      </div>
    );
  }

  const isCritical = node.status === "critical" || node.load >= 95;
  const isWarning = node.status === "warning" || (node.load >= 85 && node.load < 95);

  const statusColor = isCritical ? "#e4572e" : isWarning ? "#c9871a" : "#1f8a70";
  const StatusIcon = isCritical ? ShieldAlert : isWarning ? AlertTriangle : CheckCircle;

  return (
    <div className="bg-[#fbf8f1] border border-[#1c273326] rounded-xl p-5 shadow-sm space-y-4">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <div className="flex items-center gap-2">
            <span
              className="inline-block w-2.5 h-2.5 rounded-full"
              style={{ backgroundColor: statusColor }}
            />
            <span className="font-mono text-[11px] uppercase tracking-wider text-[#6b7785]">
              {node.id} · {node.type.toUpperCase()}
            </span>
          </div>
          <h3 className="font-serif text-xl text-[#1c2733] mt-0.5">{node.name}</h3>
          <p className="font-mono text-xs text-[#6b7785]">{node.zone}</p>
        </div>

        {onClose && (
          <button
            type="button"
            onClick={onClose}
            className="text-[#6b7785] hover:text-[#1c2733] text-sm p-1"
          >
            ✕
          </button>
        )}
      </div>

      {/* Metrics Grid */}
      <div className="grid grid-cols-2 gap-2.5 font-mono text-xs">
        <div className="bg-[#f4efe4] p-2.5 rounded-lg border border-[#1c273315]">
          <span className="text-[#6b7785] flex items-center gap-1.5 text-[10px] uppercase">
            <Zap size={12} className="text-[#1f8a70]" /> Power Flow
          </span>
          <span className="text-base font-semibold text-[#1c2733] block mt-0.5">
            {node.power.toLocaleString()} <span className="text-[10px] font-normal text-[#6b7785]">MW</span>
          </span>
        </div>

        <div className="bg-[#f4efe4] p-2.5 rounded-lg border border-[#1c273315]">
          <span className="text-[#6b7785] flex items-center gap-1.5 text-[10px] uppercase">
            <Gauge size={12} className="text-[#c9871a]" /> Load Utilization
          </span>
          <span
            className="text-base font-semibold block mt-0.5"
            style={{ color: statusColor }}
          >
            {node.load.toFixed(1)}%
          </span>
        </div>

        <div className="bg-[#f4efe4] p-2.5 rounded-lg border border-[#1c273315]">
          <span className="text-[#6b7785] text-[10px] uppercase block">Bus Voltage</span>
          <span className="text-base font-semibold text-[#1c2733] block mt-0.5">
            {node.voltage.toFixed(1)} <span className="text-[10px] font-normal text-[#6b7785]">kV</span>
          </span>
        </div>

        <div className="bg-[#f4efe4] p-2.5 rounded-lg border border-[#1c273315]">
          <span className="text-[#6b7785] text-[10px] uppercase block">Rated Capacity</span>
          <span className="text-base font-semibold text-[#1c2733] block mt-0.5">
            {node.capacity ? node.capacity.toLocaleString() : "—"} <span className="text-[10px] font-normal text-[#6b7785]">MW</span>
          </span>
        </div>
      </div>

      {/* Status Banner */}
      <div
        className="flex items-center gap-2 p-2.5 rounded-lg text-xs font-mono"
        style={{
          backgroundColor: isCritical ? "#e4572e18" : isWarning ? "#c9871a18" : "#1f8a7018",
          color: statusColor,
        }}
      >
        <StatusIcon size={14} />
        <span className="capitalize font-medium">Status: {node.status}</span>
      </div>
    </div>
  );
}
