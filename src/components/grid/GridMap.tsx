"use client";

import { useEffect, useRef, useState } from "react";
import * as d3 from "d3";

import type { GridNode } from "@/data/mockGrid";
import { useGridData } from "@/hooks/useGridData";

const NODE_COLORS = {
  generation: "#22c55e",
  load: "#3b82f6",
  substation: "#e2e8f0",
};

const STATUS_COLORS = {
  normal: "#22c55e",
  warning: "#f59e0b",
  critical: "#ef4444",
};

export default function GridMap() {
  const svgRef = useRef<SVGSVGElement | null>(null);
  const { data } = useGridData();
  const gridNodes = data.nodes;
  const gridConnections = data.connections;

  const [selectedNode, setSelectedNode] =
    useState<GridNode | null>(null);

  useEffect(() => {
    if (!svgRef.current) return;

    const svg = d3.select(svgRef.current);

    svg.selectAll("*").remove();

    const width = 900;
    const height = 650;

    const container = svg
      .append("g")
      .attr("class", "zoom-container");

    const zoom = d3
      .zoom<SVGSVGElement, unknown>()
      .scaleExtent([0.7, 2.5])
      .on("zoom", (event) => {
        container.attr("transform", event.transform);
      });

    svg.call(zoom);

    // Background
    container
      .append("rect")
      .attr("width", width)
      .attr("height", height)
      .attr("fill", "#081426")
      .attr("rx", 16);

    // Zone labels
    const zones = [
      {
        name: "NORTH ZONE",
        x: 450,
        y: 45,
      },
      {
        name: "EAST ZONE",
        x: 450,
        y: 180,
      },
      {
        name: "CENTRAL ZONE",
        x: 450,
        y: 305,
      },
      {
        name: "WEST ZONE",
        x: 450,
        y: 430,
      },
      {
        name: "SOUTH ZONE",
        x: 450,
        y: 555,
      },
    ];

    container
      .selectAll(".zone-label")
      .data(zones)
      .enter()
      .append("text")
      .attr("class", "zone-label")
      .attr("x", (d) => d.x)
      .attr("y", (d) => d.y)
      .attr("text-anchor", "middle")
      .attr("fill", "#64748b")
      .attr("font-size", 12)
      .attr("font-weight", 600)
      .text((d) => d.name);

    // Connections
    const connectionsGroup = container
      .append("g")
      .attr("class", "connections");

    gridConnections.forEach((connection) => {
      const source = gridNodes.find(
        (node) => node.id === connection.source
      );

      const target = gridNodes.find(
        (node) => node.id === connection.target
      );

      if (!source || !target) return;

      const color =
        STATUS_COLORS[connection.status];

      connectionsGroup
        .append("line")
        .attr("x1", source.x)
        .attr("y1", source.y)
        .attr("x2", target.x)
        .attr("y2", target.y)
        .attr("stroke", color)
        .attr("stroke-width", 3)
        .attr("stroke-opacity", 0.65);

      // Energy flow animation
      connectionsGroup
        .append("circle")
        .attr("r", 4)
        .attr("fill", "#38bdf8")
        .attr("cx", source.x)
        .attr("cy", source.y)
        .attr("opacity", 0.9)
        .transition()
        .duration(1800)
        .ease(d3.easeLinear)
        .attr("cx", target.x)
        .attr("cy", target.y)
        .on("end", function repeat() {
          d3.select(this)
            .attr("cx", source.x)
            .attr("cy", source.y)
            .transition()
            .duration(1800)
            .ease(d3.easeLinear)
            .attr("cx", target.x)
            .attr("cy", target.y)
            .on("end", repeat);
        });
    });

    // Nodes
    const nodesGroup = container
      .append("g")
      .attr("class", "nodes");

    gridNodes.forEach((node) => {
      const group = nodesGroup
        .append("g")
        .attr("transform", `translate(${node.x}, ${node.y})`)
        .style("cursor", "pointer")
        .on("click", () => {
          setSelectedNode(node);
        });

      // Glow
      group
        .append("circle")
        .attr("r", 23)
        .attr("fill", STATUS_COLORS[node.status])
        .attr("opacity", 0.08);

      // Main node
      group
        .append("circle")
        .attr("r", 13)
        .attr(
          "fill",
          NODE_COLORS[node.type]
        )
        .attr("stroke", STATUS_COLORS[node.status])
        .attr("stroke-width", 3);

      // Node label
      group
        .append("text")
        .attr("y", 34)
        .attr("text-anchor", "middle")
        .attr("fill", "#cbd5e1")
        .attr("font-size", 10)
        .attr("font-weight", 500)
        .text(node.name);
    });
    return () => {
      svg.selectAll("*").interrupt();
      svg.on(".zoom", null);
    };
  }, [gridConnections, gridNodes]);

  return (
    <div className="relative overflow-hidden rounded-xl border border-slate-800 bg-[#081426]">

      <svg
        ref={svgRef}
        viewBox="0 0 900 650"
        className="h-auto min-h-[500px] w-full"
      />

      {/* Selected Node Panel */}
      {selectedNode && (
        <div className="absolute right-4 top-4 w-72 rounded-xl border border-slate-700 bg-[#0b1728]/95 p-4 shadow-2xl backdrop-blur">

          <div className="flex items-start justify-between">
            <div>
              <p className="text-xs uppercase tracking-wide text-slate-500">
                {selectedNode.type}
              </p>

              <h3 className="mt-1 text-base font-semibold text-white">
                {selectedNode.name}
              </h3>
            </div>

            <button
              onClick={() => setSelectedNode(null)}
              className="text-slate-500 hover:text-white"
            >
              ✕
            </button>
          </div>

          <div className="mt-4 grid grid-cols-2 gap-3">

            <div className="rounded-lg bg-slate-900/60 p-3">
              <p className="text-xs text-slate-500">
                Voltage
              </p>

              <p className="mt-1 text-sm font-semibold text-white">
                {selectedNode.voltage} kV
              </p>
            </div>

            <div className="rounded-lg bg-slate-900/60 p-3">
              <p className="text-xs text-slate-500">
                Power
              </p>

              <p className="mt-1 text-sm font-semibold text-white">
                {selectedNode.power} MW
              </p>
            </div>

            <div className="rounded-lg bg-slate-900/60 p-3">
              <p className="text-xs text-slate-500">
                Load
              </p>

              <p className="mt-1 text-sm font-semibold text-white">
                {selectedNode.load}%
              </p>
            </div>

            <div className="rounded-lg bg-slate-900/60 p-3">
              <p className="text-xs text-slate-500">
                Status
              </p>

              <p
                className="mt-1 text-sm font-semibold capitalize"
                style={{
                  color:
                    STATUS_COLORS[
                      selectedNode.status
                    ],
                }}
              >
                {selectedNode.status}
              </p>
            </div>

          </div>

          <div className="mt-4 border-t border-slate-800 pt-3">
            <p className="text-xs text-slate-500">
              Zone
            </p>

            <p className="mt-1 text-sm text-slate-300">
              {selectedNode.zone}
            </p>
          </div>
        </div>
      )}
    </div>
  );
}