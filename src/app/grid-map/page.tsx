"use client";

import { useState } from "react";
import GridHierarchyMap from "@/components/grid/GridHierarchyMap";
import GridMap from "@/components/grid/GridMap";
import GridLegend from "@/components/grid/GridLegend";
import EnergyFlow from "@/components/grid/EnergyFlow";
import { Layers, Network, GitBranch, ArrowRightLeft } from "lucide-react";

export default function GridMapPage() {
  const [activeTab, setActiveTab] = useState<"hierarchy" | "topology" | "flow">("hierarchy");

  return (
    <div className="p-6 max-w-[1600px] mx-auto space-y-6">
      {/* View Switcher Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border-b border-[#1c273322] pb-5">
        <div>
          <span className="font-mono text-xs uppercase tracking-wider text-[#6b7785] flex items-center gap-2">
            <Layers size={14} className="text-[#1f8a70]" />
            Smart Grid Visualizer · Macro-to-Micro Digital Twin
          </span>
          <h1 className="text-3xl font-serif text-[#1c2733] mt-1">
            {activeTab === "hierarchy"
              ? "National 3-Tier Grid Hierarchy"
              : activeTab === "topology"
                ? "20-Node Grid Network Topology"
                : "Dynamic Energy Flow (Sankey Model)"}
          </h1>
          <p className="text-sm text-[#6b7785] mt-0.5">
            {activeTab === "hierarchy"
              ? "Browse national, regional, district, and feeder topology. Measurements and calibrated allocation appear when connected and available."
              : activeTab === "topology"
                ? "Interactive visual network map showing simulated power flows, substation lines, and real-time node voltages."
                : "Generation sources and cross-border imports cascading down to regional consumption hubs."}
          </p>
        </div>

        {/* Tab Controls */}
        <div className="flex items-center gap-1.5 p-1 bg-[#f4efe4] border border-[#1c273333] rounded-xl self-start sm:self-center">
          <button
            type="button"
            onClick={() => setActiveTab("hierarchy")}
            className={`flex items-center gap-2 px-3.5 py-2 rounded-lg text-xs font-mono transition-all ${
              activeTab === "hierarchy"
                ? "bg-[#1c2733] text-white shadow-sm font-medium"
                : "text-[#6b7785] hover:text-[#1c2733] hover:bg-[#1c273311]"
            }`}
          >
            <GitBranch size={13} />
            3-Tier Hierarchy
          </button>
          <button
            type="button"
            onClick={() => setActiveTab("topology")}
            className={`flex items-center gap-2 px-3.5 py-2 rounded-lg text-xs font-mono transition-all ${
              activeTab === "topology"
                ? "bg-[#1c2733] text-white shadow-sm font-medium"
                : "text-[#6b7785] hover:text-[#1c2733] hover:bg-[#1c273311]"
            }`}
          >
            <Network size={13} />
            20-Node Topology
          </button>
          <button
            type="button"
            onClick={() => setActiveTab("flow")}
            className={`flex items-center gap-2 px-3.5 py-2 rounded-lg text-xs font-mono transition-all ${
              activeTab === "flow"
                ? "bg-[#1c2733] text-white shadow-sm font-medium"
                : "text-[#6b7785] hover:text-[#1c2733] hover:bg-[#1c273311]"
            }`}
          >
            <ArrowRightLeft size={13} />
            Energy Flow
          </button>
        </div>
      </div>

      {/* Main Content Area */}
      {activeTab === "hierarchy" ? (
        <div className="space-y-4">
          <GridHierarchyMap />
        </div>
      ) : activeTab === "topology" ? (
        <div className="space-y-4">
          <div className="bg-[#fbf8f1] border border-[#1c273326] rounded-2xl p-6 shadow-sm">
            <div className="flex flex-col lg:flex-row gap-6">
              <div className="flex-1 overflow-x-auto">
                <GridMap />
              </div>
              <div className="lg:w-72 shrink-0">
                <GridLegend />
              </div>
            </div>
          </div>
        </div>
      ) : (
        <div className="space-y-4">
          <EnergyFlow />
        </div>
      )}
    </div>
  );
}
