"use client";

import { useState } from "react";

import HeatWaveButton from "@/components/simulator/HeatWaveButton";
import DemandSpikeButton from "@/components/simulator/DemandSpikeButton";
import SolarFailureButton from "@/components/simulator/SolarFailureButton";
import NodeFailureButton from "@/components/simulator/NodeFailureButton";
import ScenarioResult from "@/components/simulator/ScenarioResult";

type Scenario =
  | "Heatwave"
  | "Demand Spike"
  | "Solar Failure"
  | "Node Failure";

const scenarioResults = {
  Heatwave: {
    loadImpact: "+18%",
    frequency: "49.82 Hz",
    generationImpact: "-4%",
    risk: "High",
  },
  "Demand Spike": {
    loadImpact: "+25%",
    frequency: "49.70 Hz",
    generationImpact: "-2%",
    risk: "High",
  },
  "Solar Failure": {
    loadImpact: "+8%",
    frequency: "49.91 Hz",
    generationImpact: "-22%",
    risk: "High",
  },
  "Node Failure": {
    loadImpact: "+12%",
    frequency: "49.76 Hz",
    generationImpact: "-15%",
    risk: "Critical",
  },
};

export default function SimulatorPage() {
  const [selectedScenario, setSelectedScenario] =
    useState<Scenario>("Heatwave");

  const [result, setResult] = useState(
    scenarioResults.Heatwave
  );

  const handleRunSimulation = () => {
    setResult(scenarioResults[selectedScenario]);
  };

  return (
    <div className="p-6">
      {/* Scenario Selection */}
      <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
        <div className="mb-5">
          <h2 className="text-lg font-semibold text-white">
            Select Shock Scenario
          </h2>

          <p className="mt-1 text-sm text-slate-400">
            Choose a scenario to simulate its effect on the power grid.
          </p>
        </div>

        {/* Scenario Buttons */}
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
          <HeatWaveButton
            selected={selectedScenario === "Heatwave"}
            onClick={() => setSelectedScenario("Heatwave")}
          />

          <DemandSpikeButton
            selected={selectedScenario === "Demand Spike"}
            onClick={() => setSelectedScenario("Demand Spike")}
          />

          <SolarFailureButton
            selected={selectedScenario === "Solar Failure"}
            onClick={() => setSelectedScenario("Solar Failure")}
          />

          <NodeFailureButton
            selected={selectedScenario === "Node Failure"}
            onClick={() => setSelectedScenario("Node Failure")}
          />
        </div>

        {/* Selected Scenario */}
        <div className="mt-5 flex flex-col gap-4 rounded-xl border border-slate-800 bg-[#081525] p-4 md:flex-row md:items-center md:justify-between">
          <div>
            <p className="text-sm font-medium text-white">
              Selected Scenario
            </p>

            <p className="mt-1 text-sm text-blue-400">
              {selectedScenario}
            </p>
          </div>

          <button
            onClick={handleRunSimulation}
            className="rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-medium text-white transition hover:bg-blue-500"
          >
            Run Simulation
          </button>
        </div>
      </div>

      {/* Simulation Results */}
      <div className="mt-7">
        <div className="mb-5">
          <h2 className="text-lg font-semibold text-white">
            Simulation Results
          </h2>

          <p className="mt-1 text-sm text-slate-400">
            Estimated impact of the selected shock scenario.
          </p>
        </div>

        <ScenarioResult
          loadImpact={result.loadImpact}
          frequency={result.frequency}
          generationImpact={result.generationImpact}
          risk={result.risk}
        />
      </div>

      {/* Simulation Explanation */}
      <div className="mt-6 rounded-xl border border-slate-800 bg-[#0b1728] p-5">
        <h2 className="text-lg font-semibold text-white">
          Scenario Analysis
        </h2>

        <p className="mt-2 text-sm leading-6 text-slate-400">
          The simulator estimates how the selected grid shock could affect
          electricity demand, generation, frequency stability, and overall
          grid risk.
        </p>
      </div>
    </div>
  );
}