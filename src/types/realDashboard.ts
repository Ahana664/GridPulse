export type DashboardMode = "real" | "simulated";

export interface NationalReading {
  observed_at: string;
  source?: string;
  demand_is_inferred?: boolean;
  actual_mw?: number | null;
  generation_mw?: number | null;
  demand_mw?: number | null;
  gas_mw?: number | null;
  liquid_fuel_mw?: number | null;
  coal_mw?: number | null;
  solar_mw?: number | null;
  hydro_mw?: number | null;
  wind_mw?: number | null;
  imports_mw?: number | null;
  india_mw?: number | null;
  nepal_mw?: number | null;
  adani_mw?: number | null;
}

export interface RealDashboardData {
  mode: "real";
  source: string;
  databaseConnected: boolean;
  latest: NationalReading | null;
  history: NationalReading[];
  historyCount: number;
  historyStorage: "postgresql" | "supabase-rest" | "none";
  forecast: { time: string; load: number }[];
  forecastAvailable: boolean;
  forecastTarget: "generation" | "demand";
  forecastModel: string;
  forecastNotice: string | null;
}
