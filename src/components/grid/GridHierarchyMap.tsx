"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import * as d3 from "d3";
import { ChevronRight, Database, MapPinned, RefreshCw } from "lucide-react";

const apiBase = (process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api/v1").replace(/\/$/, "");
type Tier = "national" | "division" | "district" | "feeder";
type GridNode = {
  node_id: string;
  name: string;
  tier: Tier;
  parent_node_id: string | null;
  division_code: string | null;
  distribution_weight: number | null;
  child_count: number;
  observed_at: string | null;
  source: string | null;
  generation_mw: number | null;
  demand_mw: number | null;
  gas_mw: number | null;
  coal_mw: number | null;
  solar_mw: number | null;
  hydro_mw: number | null;
  wind_mw: number | null;
  imports_mw: number | null;
  voltage_kv: number | null;
  load_percent: number | null;
  capacity_mw: number | null;
  status: string | null;
  measured: boolean;
  estimated: boolean;
  estimated_generation_mw: number | null;
  estimated_demand_mw: number | null;
};
type HierarchyParent = Pick<GridNode, "node_id" | "name" | "tier" | "parent_node_id" | "division_code"> & Partial<GridNode>;
type HierarchyResponse = {
  database: "connected" | "disconnected" | "error";
  parent: HierarchyParent | null;
  nodes: GridNode[];
  allocation?: { ready: boolean; method: string; weight_sum: number; message: string };
};

const tierNames: Record<Tier, string> = {
  national: "National grid",
  division: "Regional hub · division",
  district: "District substation",
  feeder: "Local feeder cluster",
};
const numberText = (value: number | null | undefined, digits = 0) => value == null ? "—" : Number(value).toLocaleString(undefined, { maximumFractionDigits: digits });
const levelColor = (node: GridNode) => {
  if (node.estimated) return "#c9871a";
  if (!node.measured) return "#8c8a80";
  if (node.status === "critical" || (node.load_percent ?? 0) >= 95) return "#e4572e";
  if (node.status === "warning" || (node.load_percent ?? 0) >= 85) return "#c9871a";
  return "#1f8a70";
};

export default function GridHierarchyMap() {
  const svgRef = useRef<SVGSVGElement | null>(null);
  const [parents, setParents] = useState<{ node_id: string; name: string; tier: Tier }[]>([]);
  const [payload, setPayload] = useState<HierarchyResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [refreshKey, setRefreshKey] = useState(0);
  const currentId = parents.at(-1)?.node_id ?? "BD-NATIONAL";

  const fetchLevel = useCallback(async (parentNodeId: string) => {
    setLoading(true);
    setError("");
    try {
      const response = await fetch(`${apiBase}/grid/hierarchy?parent_node_id=${encodeURIComponent(parentNodeId)}`, { cache: "no-store" });
      if (!response.ok) throw new Error(`Hierarchy endpoint returned ${response.status}`);
      setPayload(await response.json() as HierarchyResponse);
    } catch (reason) {
      setPayload(null);
      setError(reason instanceof Error ? reason.message : "Could not load the grid hierarchy.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const timer = setTimeout(() => void fetchLevel(currentId), 0);
    return () => clearTimeout(timer);
  }, [currentId, fetchLevel, refreshKey]);

  const canDrill = useCallback((node: GridNode) => node.tier !== "feeder", []);
  const drill = useCallback((node: GridNode) => {
    if (!canDrill(node)) return;
    setParents((current) => [...current, { node_id: node.node_id, name: node.name, tier: node.tier }]);
  }, [canDrill]);

  const layout = useMemo(() => {
    const nodes = payload?.nodes ?? [];
    const rows = Math.ceil(nodes.length / 2);
    const height = Math.max(390, rows * 104 + 80);
    return { nodes, height, parentY: height / 2 };
  }, [payload]);

  useEffect(() => {
    const element = svgRef.current;
    if (!element || !payload?.parent) return;
    const svg = d3.select(element);
    svg.selectAll("*").remove();
    const width = 1000;
    const height = layout.height;
    const root = svg.append("g");
    svg.call(d3.zoom<SVGSVGElement, unknown>().scaleExtent([0.75, 2.2]).on("zoom", (event) => root.attr("transform", event.transform)));
    root.append("rect").attr("width", width).attr("height", height).attr("rx", 14).attr("fill", "#f7f2e9");

    const parentY = layout.parentY;
    root.append("text").attr("x", 135).attr("y", parentY - 61).attr("text-anchor", "middle").attr("fill", "#6b7785").attr("font-family", "IBM Plex Mono, monospace").attr("font-size", 10).attr("letter-spacing", 1).text("CURRENT LEVEL");
    const parent = root.append("g").attr("transform", `translate(35,${parentY - 48})`);
    parent.append("rect").attr("width", 205).attr("height", 96).attr("rx", 12).attr("fill", "#fbf8f1").attr("stroke", "#1c2733").attr("stroke-width", 1.5);
    parent.append("text").attr("x", 14).attr("y", 27).attr("fill", "#1c2733").attr("font-family", "Instrument Serif, Georgia, serif").attr("font-size", 22).text(payload.parent.name);
    parent.append("text").attr("x", 14).attr("y", 51).attr("fill", "#6b7785").attr("font-family", "IBM Plex Mono, monospace").attr("font-size", 9).text(tierNames[payload.parent.tier]);
    parent.append("text").attr("x", 14).attr("y", 75).attr("fill", payload.parent.measured ? "#1f8a70" : "#8c8a80").attr("font-family", "IBM Plex Mono, monospace").attr("font-size", 9)
      .text(payload.parent.measured
        ? `GEN ${numberText(payload.parent.generation_mw)} · DEMAND ${numberText(payload.parent.demand_mw)} MW`
        : "NO READING · NOT IMPORTED");

    if (!layout.nodes.length) return () => { svg.interrupt(); svg.on(".zoom", null); };

    const positions = layout.nodes.map((node, index) => ({
      node,
      x: 310 + (index % 2) * 335,
      y: 30 + Math.floor(index / 2) * 104,
    }));
    root.append("text").attr("x", 474).attr("y", 18).attr("fill", "#6b7785").attr("font-family", "IBM Plex Mono, monospace").attr("font-size", 10).attr("letter-spacing", 1).text("DIRECT CHILD NODES · CLICK A TIER TO DRILL IN");

    for (const { y } of positions) {
      root.append("path")
        .attr("d", `M240,${parentY} C275,${parentY} 275,${y + 36} 306,${y + 36}`)
        .attr("fill", "none")
        .attr("stroke", "#1c273333")
        .attr("stroke-width", 1.5);
    }

    const cards = root.selectAll<SVGGElement, (typeof positions)[number]>(".hierarchy-node")
      .data(positions, (entry) => entry.node.node_id)
      .join("g")
      .attr("class", "hierarchy-node")
      .attr("transform", (entry) => `translate(${entry.x},${entry.y})`)
      .style("cursor", (entry) => canDrill(entry.node) ? "pointer" : "default")
      .on("click", (_event, entry) => drill(entry.node));

    cards.append("rect")
      .attr("width", 292).attr("height", 76).attr("rx", 11)
      .attr("fill", "#fbf8f1")
      .attr("stroke", (entry) => levelColor(entry.node))
      .attr("stroke-width", 1.6);
    cards.append("circle").attr("cx", 18).attr("cy", 20).attr("r", 4).attr("fill", (entry) => levelColor(entry.node));
    cards.append("text").attr("x", 31).attr("y", 23).attr("fill", "#1c2733").attr("font-family", "Instrument Serif, Georgia, serif").attr("font-size", 19).text((entry) => entry.node.name);
    cards.append("text").attr("x", 14).attr("y", 43).attr("fill", "#6b7785").attr("font-family", "IBM Plex Mono, monospace").attr("font-size", 8.5)
      .text((entry) => `${tierNames[entry.node.tier].toUpperCase()} · ${entry.node.measured ? entry.node.source?.toUpperCase() ?? "SOURCE" : entry.node.estimated ? `WEIGHTED ESTIMATE · ${(Number(entry.node.distribution_weight ?? 0) * 100).toFixed(1)}%` : "AWAITING SOURCE DATA"}`);
    cards.append("text").attr("x", 14).attr("y", 63).attr("font-family", "IBM Plex Mono, monospace").attr("font-size", 10)
      .attr("fill", (entry) => entry.node.measured || entry.node.estimated ? "#1c2733" : "#8c8a80")
      .text((entry) => entry.node.measured
        ? `GEN ${numberText(entry.node.generation_mw)} · DEMAND ${numberText(entry.node.demand_mw)} MW`
        : entry.node.estimated
          ? `EST. GEN ${numberText(entry.node.estimated_generation_mw)} · DEMAND ${numberText(entry.node.estimated_demand_mw)} MW`
        : entry.node.child_count > 0 ? `${entry.node.child_count} CHILD NODES · NO MEASUREMENTS` : "NO READING · NOT IMPORTED");
    cards.filter((entry) => canDrill(entry.node)).append("text").attr("x", 278).attr("y", 22).attr("fill", "#6b7785").attr("font-size", 15).text("›");

    return () => { svg.selectAll("*").interrupt(); svg.on(".zoom", null); };
  }, [payload, layout, canDrill, drill]);

  const childTierLabel = payload?.parent?.tier === "national"
    ? "divisions"
    : payload?.parent?.tier === "division"
      ? "district nodes"
      : payload?.parent?.tier === "district"
        ? "feeder nodes"
        : "child nodes";
  const measuredCount = payload?.nodes.filter((node) => node.measured).length ?? 0;
  const estimatedCount = payload?.nodes.filter((node) => node.estimated).length ?? 0;

  function navigateBack(index: number) {
    setParents((current) => current.slice(0, index));
  }

  return (
    <section className="gp-hierarchy-panel">
      <header className="gp-hierarchy-header">
        <div>
          <span className="gp-eyebrow">NATIONAL → REGIONAL → DISTRICT → FEEDER</span>
          <h2 className="gp-serif gp-section-title">Grid hierarchy</h2>
          <p>Topology records and measured values come from PostgreSQL. No synthetic regional readings are shown.</p>
        </div>
        <div className={`gp-hierarchy-db ${payload?.database === "connected" ? "is-connected" : ""}`}><Database size={15} />{payload?.database === "connected" ? "POSTGRESQL" : payload?.database === "error" ? "QUERY ERROR" : "DATABASE OFFLINE"}</div>
      </header>

      <nav className="gp-hierarchy-breadcrumb" aria-label="Grid hierarchy level">
        <button type="button" onClick={() => navigateBack(0)} disabled={parents.length === 0}>Bangladesh</button>
        {parents.map((parent, index) => <span key={parent.node_id} className="gp-breadcrumb-part"><ChevronRight size={13} /><button type="button" onClick={() => navigateBack(index + 1)}>{parent.name}</button></span>)}
        <button className="gp-hierarchy-refresh" type="button" onClick={() => setRefreshKey((key) => key + 1)} aria-label="Refresh actual grid data"><RefreshCw size={14} /></button>
      </nav>

      {loading && <div className="gp-hierarchy-empty"><RefreshCw size={18} className="gp-spin" /> Loading topology records…</div>}
      {!loading && error && <div className="gp-hierarchy-empty gp-hierarchy-error" role="alert">{error}</div>}
      {!loading && !error && payload?.database === "disconnected" && <div className="gp-hierarchy-empty">PostgreSQL is not connected. Hierarchical source readings will appear here after the database and ingestion script are configured.</div>}
      {!loading && !error && payload?.database === "connected" && payload.parent && layout.nodes.length > 0 && (
        <>
          {payload.allocation && payload.parent.tier === "national" && <p className="gp-allocation-note">{payload.allocation.message} Configured weight total: {(payload.allocation.weight_sum * 100).toFixed(1)}%.</p>}
          <div className="gp-hierarchy-canvas"><svg ref={svgRef} viewBox={`0 0 1000 ${layout.height}`} role="img" aria-label={`Grid hierarchy under ${payload.parent.name}`} /></div>
        </>
      )}
      {!loading && !error && payload?.database === "connected" && payload.parent && layout.nodes.length === 0 && (
        <div className="gp-hierarchy-empty"><MapPinned size={20} /><div><strong>No child records under {payload.parent.name}</strong><p>District substation and feeder topology has not been imported. Provide the PGCB processing script and its mapping format to populate these levels. No placeholder measurements are generated.</p></div></div>
      )}

      <footer className="gp-hierarchy-footer">
        <span>{tierNames[payload?.parent?.tier ?? "national"]}</span>
        <span>{layout.nodes.length} {childTierLabel} · {measuredCount} measured · {estimatedCount} estimated</span>
      </footer>
      <p className="gp-hierarchy-note">Diagram shows parent/child topology, not geographic locations. Regional values remain blank until actual source records are imported.</p>
    </section>
  );
}
