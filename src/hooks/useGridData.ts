"use client";

import { createContext, createElement, useCallback, useContext, useEffect, useMemo, useState } from "react";

import { gridConnections, gridNodes } from "@/data/mockGrid";
import type { GridConnection, GridNode } from "@/data/mockGrid";

export type ScenarioKey = "heatwave" | "demand_spike" | "solar_failure" | "node_failure";

export interface GridSummary {
  totalGeneration: number;
  totalLoad: number;
  frequency: number;
  averageVoltage: number;
  systemHealth: number;
  risk: "low" | "moderate" | "high" | "critical";
  nodeCount: number;
  generationReserve: number;
}

export interface HistoryPoint {
  time: string;
  actual: number;
  forecast: number | null;
  capacity: number;
  voltage?: number;
  frequency?: number;
}

export interface GridAlert {
  id: string;
  type: "warning" | "critical";
  title: string;
  message: string;
  time: string;
  nodeId?: string;
  active: boolean;
}

export interface SafetyCheck {
  id: string;
  subject: string;
  measured: number;
  limit: number;
  unit: string;
  status: "pass" | "warning" | "critical";
  message: string;
}

export interface GridSnapshot {
  timestamp: string;
  summary: GridSummary;
  nodes: GridNode[];
  connections: GridConnection[];
  history: HistoryPoint[];
  forecast: { time: string; load: number }[];
  alerts: GridAlert[];
  safetyChecks: SafetyCheck[];
  scenario: ScenarioKey | null;
  scenarioResult: {
    name: ScenarioKey;
    loadImpact: string;
    frequency: string;
    generationImpact: string;
    risk: string;
    description: string;
  } | null;
  mlModel: string;
  nationalData: {
    observed_at: string;
    source: string;
    generation_mw?: number | null;
    demand_mw?: number | null;
    gas_mw?: number | null;
    coal_mw?: number | null;
    solar_mw?: number | null;
    hydro_mw?: number | null;
    wind_mw?: number | null;
    imports_mw?: number | null;
  } | null;
  dataProvenance: "simulator-only" | "live-national-trend-scaled-simulation";
  nationalDemandScale: number;
  nationalGenerationScale: number;
}

const demoTimestamp = "2026-01-01T12:00:00.000Z";
const fallbackSnapshot: GridSnapshot = {
  timestamp: demoTimestamp,
  summary: {
    totalGeneration: 4_812,
    totalLoad: 4_352,
    frequency: 50.02,
    averageVoltage: 230,
    systemHealth: 98.6,
    risk: "low",
    nodeCount: gridNodes.length,
    generationReserve: 460,
  },
  nodes: gridNodes,
  connections: gridConnections,
  history: Array.from({ length: 13 }, (_, index) => {
    const hour = index * 2;
    return {
      time: `${String(hour).padStart(2, "0")}:00`,
      actual: Math.round(3_700 + 680 * Math.sin(((hour - 7) / 24) * Math.PI * 2)),
      forecast: null,
      capacity: 6_000,
    };
  }),
  forecast: Array.from({ length: 13 }, (_, index) => {
    const hour = index * 2;
    return {
      time: `${String(hour).padStart(2, "0")}:00`,
      load: Math.round(3_700 + 680 * Math.sin(((hour - 7) / 24) * Math.PI * 2)),
    };
  }),
  alerts: [
    {
      id: "seed-high-load",
      type: "warning",
      title: "High load — North Load Center",
      message: "The North Zone load is approaching its operating threshold.",
      time: demoTimestamp,
      active: true,
    },
  ],
  safetyChecks: [],
  scenario: null,
  scenarioResult: null,
  mlModel: "Demo data",
  nationalData: null,
  dataProvenance: "simulator-only",
  nationalDemandScale: 1,
  nationalGenerationScale: 1,
};

interface GridDataContextValue {
  data: GridSnapshot;
  isConnected: boolean;
  lastUpdated: Date | null;
  error: string | null;
  runScenario: (scenario: ScenarioKey) => Promise<GridSnapshot>;
  resetScenario: () => Promise<GridSnapshot>;
}

const GridDataContext = createContext<GridDataContextValue | null>(null);
const apiBase = (process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api/v1").replace(/\/$/, "");
const wsUrl = process.env.NEXT_PUBLIC_WS_URL ?? "ws://localhost:8000/api/v1/ws/live";

export function GridDataProvider({ children }: { children: React.ReactNode }) {
  const [data, setData] = useState(fallbackSnapshot);
  const [isConnected, setIsConnected] = useState(false);
  const [lastUpdated, setLastUpdated] = useState<Date | null>(null);
  const [error, setError] = useState<string | null>(null);

  const acceptSnapshot = useCallback((snapshot: GridSnapshot) => {
    setData(snapshot);
    setLastUpdated(new Date(snapshot.timestamp));
    setError(null);
  }, []);

  useEffect(() => {
    let disposed = false;
    let socket: WebSocket | null = null;
    let reconnectTimer: ReturnType<typeof setTimeout> | undefined;

    const loadInitialState = async () => {
      try {
        const response = await fetch(`${apiBase}/state`, { cache: "no-store" });
        if (!response.ok) throw new Error(`Grid API returned ${response.status}`);
        acceptSnapshot((await response.json()) as GridSnapshot);
      } catch {
        if (!disposed) setError("API unavailable — showing demo telemetry");
      }
    };

    const connect = () => {
      if (disposed) return;
      socket = new WebSocket(wsUrl);
      socket.onopen = () => {
        if (!disposed) setIsConnected(true);
      };
      socket.onmessage = (event) => {
        try {
          const message = JSON.parse(event.data) as { type?: string; data?: GridSnapshot };
          if (message.type === "snapshot" && message.data) acceptSnapshot(message.data);
        } catch {
          setError("Received an invalid telemetry update");
        }
      };
      socket.onerror = () => socket?.close();
      socket.onclose = () => {
        if (disposed) return;
        setIsConnected(false);
        reconnectTimer = setTimeout(connect, 2500);
      };
    };

    const initialConnectTimer = setTimeout(connect, 50);
    void loadInitialState();

    return () => {
      disposed = true;
      clearTimeout(initialConnectTimer);
      if (reconnectTimer) clearTimeout(reconnectTimer);
      socket?.close();
    };
  }, [acceptSnapshot]);

  const runScenario = useCallback(async (scenario: ScenarioKey) => {
    const response = await fetch(`${apiBase}/simulations`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ scenario }),
    });
    if (!response.ok) throw new Error("The simulation service could not run this scenario.");
    const snapshot = (await response.json()) as GridSnapshot;
    acceptSnapshot(snapshot);
    return snapshot;
  }, [acceptSnapshot]);

  const resetScenario = useCallback(async () => {
    const response = await fetch(`${apiBase}/simulations/reset`, { method: "POST" });
    if (!response.ok) throw new Error("The simulation service could not reset the scenario.");
    const snapshot = (await response.json()) as GridSnapshot;
    acceptSnapshot(snapshot);
    return snapshot;
  }, [acceptSnapshot]);

  const value = useMemo(
    () => ({ data, isConnected, lastUpdated, error, runScenario, resetScenario }),
    [data, isConnected, lastUpdated, error, runScenario, resetScenario],
  );

  return createElement(GridDataContext.Provider, { value }, children);
}

export function useGridData(): GridDataContextValue {
  const value = useContext(GridDataContext);
  if (!value) throw new Error("useGridData must be used inside GridDataProvider");
  return value;
}
