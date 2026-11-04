"use client";

import { useMemo } from "react";
import { useGridData } from "@/hooks/useGridData";
import { Flame, Sun, Wind, Droplets, Zap, Building2, Factory, Home } from "lucide-react";

export default function EnergyFlow() {
  const { data } = useGridData();
  const national = data.nationalData;
  const summary = data.summary;

  // Use live national data from Supabase/PGCB if available, otherwise fallback to virtual summary
  const totalGen = national?.generation_mw ?? summary.totalGeneration;
  const totalLoad = national?.demand_mw ?? summary.totalLoad;

  const fuels = useMemo(() => {
    if (national) {
      const gas = national.gas_mw ?? 0;
      const coal = national.coal_mw ?? 0;
      const liquid = national.liquid_fuel_mw ?? 0;
      const solar = national.solar_mw ?? 0;
      const hydro = national.hydro_mw ?? 0;
      const wind = national.wind_mw ?? 0;
      const imports = national.imports_mw ?? 0;
      return [
        { name: "Natural Gas", mw: gas, icon: Flame, color: "#1f8a70" },
        { name: "Coal Power", mw: coal, icon: Zap, color: "#475569" },
        { name: "Liquid Fuel (HFO/HSD)", mw: liquid, icon: Flame, color: "#ea580c" },
        { name: "Cross-Border Imports", mw: imports, icon: Zap, color: "#2563eb" },
        { name: "Solar Generation", mw: solar, icon: Sun, color: "#eab308" },
        { name: "Hydro Power", mw: hydro, icon: Droplets, color: "#06b6d4" },
        { name: "Wind Energy", mw: wind, icon: Wind, color: "#10b981" },
      ].filter((f) => f.mw > 0);
    }
    return [
      { name: "Central Hydro (GEN-C1)", mw: 1350, icon: Droplets, color: "#06b6d4" },
      { name: "North Solar Array (GEN-N1)", mw: 1250, icon: Sun, color: "#eab308" },
      { name: "South Thermal (GEN-S1)", mw: 1500, icon: Flame, color: "#1f8a70" },
      { name: "East Wind Farm (GEN-E1)", mw: 1100, icon: Wind, color: "#10b981" },
      { name: "West Solar Farm (GEN-W1)", mw: 900, icon: Sun, color: "#eab308" },
    ];
  }, [national]);

  const regionalShares = [
    { name: "Dhaka Metro & Industrial", share: 0.42, mw: Math.round(totalLoad * 0.42), icon: Factory },
    { name: "Chattogram Port & Industrial", share: 0.20, mw: Math.round(totalLoad * 0.20), icon: Building2 },
    { name: "Khulna & South-West", share: 0.10, mw: Math.round(totalLoad * 0.10), icon: Factory },
    { name: "Rajshahi & North-West", share: 0.09, mw: Math.round(totalLoad * 0.09), icon: Home },
    { name: "Rangpur Division", share: 0.06, mw: Math.round(totalLoad * 0.06), icon: Home },
    { name: "Sylhet Tea & Commercial", share: 0.05, mw: Math.round(totalLoad * 0.05), icon: Building2 },
    { name: "Mymensingh Division", share: 0.05, mw: Math.round(totalLoad * 0.05), icon: Home },
    { name: "Barishal Division", share: 0.03, mw: Math.round(totalLoad * 0.03), icon: Home },
  ];

  return (
    <div className="bg-[#fbf8f1] border border-[#1c273326] rounded-2xl p-6 shadow-sm space-y-6">
      {/* Header */}
      <div className="border-b border-[#1c273318] pb-4">
        <span className="font-mono text-xs uppercase tracking-wider text-[#6b7785] block">
          Dynamic Energy Flow Sankey Model
        </span>
        <h2 className="text-2xl font-serif text-[#1c2733] mt-0.5">
          Generation Sources → National Grid → Regional Distribution
        </h2>
        <p className="text-xs text-[#6b7785] font-mono mt-1">
          {national
            ? "Flow rates calculated from live PGCB Generation portal via Supabase pipeline."
            : "Flow rates calculated from active telemetry baseline."}
        </p>
      </div>

      {/* 3-Column Flow Layout */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 items-start font-mono text-xs">
        {/* Column 1: Sources */}
        <div className="space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-[#1c273320]">
            <span className="font-semibold text-[#1c2733] uppercase text-[11px]">Primary Fuel / Imports</span>
            <span className="text-[#1f8a70] font-bold">{Math.round(totalGen).toLocaleString()} MW</span>
          </div>
          <div className="space-y-2">
            {fuels.map((fuel) => {
              const Icon = fuel.icon;
              const pct = totalGen > 0 ? ((fuel.mw / totalGen) * 100).toFixed(1) : "0";
              return (
                <div key={fuel.name} className="p-2.5 rounded-xl bg-[#f4efe4] border border-[#1c273315] space-y-1">
                  <div className="flex items-center justify-between">
                    <span className="flex items-center gap-1.5 text-[#1c2733] font-medium text-[11px]">
                      <Icon size={13} style={{ color: fuel.color }} />
                      {fuel.name}
                    </span>
                    <span className="text-[#1c2733] font-semibold">{Math.round(fuel.mw).toLocaleString()} MW</span>
                  </div>
                  <div className="w-full bg-[#1c273315] h-1.5 rounded-full overflow-hidden">
                    <div
                      className="h-full rounded-full transition-all duration-500"
                      style={{ width: `${pct}%`, backgroundColor: fuel.color }}
                    />
                  </div>
                  <div className="flex justify-end text-[10px] text-[#6b7785]">{pct}% of supply</div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Column 2: National Backbone */}
        <div className="space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-[#1c273320]">
            <span className="font-semibold text-[#1c2733] uppercase text-[11px]">National Transmission Grid</span>
            <span className="text-[#2563eb] font-bold">400kV / 230kV</span>
          </div>
          <div className="p-4 rounded-xl bg-[#1c2733] text-white space-y-4 shadow-md">
            <div>
              <span className="text-[10px] uppercase text-[#94a3b8] tracking-wider block">Grid Frequency</span>
              <span className="text-2xl font-bold font-mono text-[#34d399]">{summary.frequency.toFixed(3)} Hz</span>
              <span className="text-[10px] text-[#94a3b8] block">Nominal reference: 50.000 Hz</span>
            </div>
            <div>
              <span className="text-[10px] uppercase text-[#94a3b8] tracking-wider block">Total Power Flow</span>
              <span className="text-xl font-bold font-mono text-white">{Math.round(totalLoad).toLocaleString()} MW</span>
            </div>
            <div>
              <span className="text-[10px] uppercase text-[#94a3b8] tracking-wider block">Operating Reserve</span>
              <span className="text-base font-bold font-mono text-[#60a5fa]">
                {Math.round(totalGen - totalLoad).toLocaleString()} MW
              </span>
            </div>
            <div className="pt-2 border-t border-[#334155] text-[10px] text-[#94a3b8]">
              Status: <span className="text-[#34d399] uppercase font-semibold">Synchronized</span>
            </div>
          </div>
        </div>

        {/* Column 3: Regional Hubs */}
        <div className="space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-[#1c273320]">
            <span className="font-semibold text-[#1c2733] uppercase text-[11px]">Regional Distribution Hubs</span>
            <span className="text-[#c9871a] font-bold">{Math.round(totalLoad).toLocaleString()} MW</span>
          </div>
          <div className="space-y-2">
            {regionalShares.map((region) => {
              const Icon = region.icon;
              const pct = (region.share * 100).toFixed(0);
              return (
                <div key={region.name} className="p-2.5 rounded-xl bg-[#f4efe4] border border-[#1c273315] space-y-1">
                  <div className="flex items-center justify-between">
                    <span className="flex items-center gap-1.5 text-[#1c2733] font-medium text-[11px]">
                      <Icon size={13} className="text-[#6b7785]" />
                      {region.name}
                    </span>
                    <span className="text-[#1c2733] font-semibold">{region.mw.toLocaleString()} MW</span>
                  </div>
                  <div className="w-full bg-[#1c273315] h-1.5 rounded-full overflow-hidden">
                    <div
                      className="h-full rounded-full bg-[#c9871a] transition-all duration-500"
                      style={{ width: `${pct}%` }}
                    />
                  </div>
                  <div className="flex justify-between text-[10px] text-[#6b7785]">
                    <span>Allocated Share</span>
                    <span>{pct}%</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}

