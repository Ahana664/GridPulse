"use client";

import { useCallback, useEffect, useState } from "react";
import type { RealDashboardData } from "@/types/realDashboard";

const apiBase = (process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api/v1").replace(/\/$/, "");

export function useRealDashboardData() {
  const [data, setData] = useState<RealDashboardData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    try {
      const response = await fetch(`${apiBase}/real-data/dashboard`, { cache: "no-store" });
      if (!response.ok) throw new Error(`Real-data endpoint returned ${response.status}`);
      setData(await response.json() as RealDashboardData);
      setError(null);
    } catch (reason) {
      setError(reason instanceof Error ? reason.message : "Unable to load real national data.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const timer = setTimeout(() => void refresh(), 0);
    const interval = setInterval(() => void refresh(), 60_000);
    return () => {
      clearTimeout(timer);
      clearInterval(interval);
    };
  }, [refresh]);

  return { data, loading, error, refresh };
}
