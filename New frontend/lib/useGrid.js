"use client";
import { useEffect, useRef, useState } from "react";
// Simulated 20-node grid. Swap the interval below for a WebSocket by setting NEXT_PUBLIC_WS_URL
// (FastAPI should push {t,nodes,edges,hist,alerts} in the same shape that step() returns).
const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
const GN = ["Solar", "Wind", "Gas", "Hydro"];
export const NODES = Array.from({ length: 20 }, (_, i) => {
  const t = i < 4 ? "gen" : i < 9 ? "sub" : "load", k = t === "gen" ? i : t === "sub" ? i - 4 : i - 9;
  return { id: i, type: t, nom: t === "load" ? 11 : 33,
    cap: t === "gen" ? [220, 180, 260, 200][k] : t === "sub" ? [260, 200, 160, 210, 150][k] : [80, 110, 70, 120, 90, 76, 100, 84, 116, 72, 96][k],
    x: t === "gen" ? 70 : t === "sub" ? 330 : k % 2 ? 740 : 620,
    y: t === "gen" ? 90 + k * 115 : t === "sub" ? 55 + k * 100 : 35 + k * 44,
    name: t === "gen" ? `${GN[k]} Plant` : t === "sub" ? `Substation S${k + 1}` : `Zone C${k + 1}`,
  };
});
export const EDGES = [[0,4],[1,5],[2,6],[3,7],[2,8],[1,4],[4,5],[5,6],[6,7],[7,8],[8,4], ...Array.from({ length: 11 }, (_, k) => [4 + (k % 5), 9 + k])].map(([a, b], id) => {
  const kind = NODES[a].type === "gen" ? "gen" : NODES[b].type === "load" ? "load" : "ss";
  return { id, a, b, kind, cap: kind === "ss" ? 100 : 150 };
});
function step(prev, t, s, seen) {
  const L = {}, nz = (c) => (Math.random() - 0.5) * c;
  NODES.forEach((o) => {
    if (o.type === "sub") return;
    let b = o.type === "gen" ? o.id === 0 ? o.cap * clamp(0.55 + 0.4 * Math.sin(t / 25), 0.05, 1) : o.cap * (0.62 + 0.18 * Math.sin(t / 18 + o.id * 1.7)) : o.cap * (0.55 + 0.18 * Math.sin(t / 16 + o.id * 0.9));
    if (o.type === "load") { if (s.heat) b *= 1.32; if (s.surge && [10, 13, 16].includes(o.id)) b *= 1.7; }
    if (o.id === 0 && s.solar) b *= 0.08;
    L[o.id] = Math.max(0, b + nz(o.cap * 0.04));
  });
  NODES.filter((o) => o.type === "sub").forEach((o) => {
    let b = EDGES.filter((e) => e.a === o.id && NODES[e.b].type === "load").reduce((a, e) => a + L[e.b], 0);
    if (s.fail && [5, 7].includes(o.id)) b *= 1.3;
    L[o.id] = b + nz(4);
  });
  const nodes = NODES.map((o) => {
    const p = prev.nodes[o.id], off = s.fail && o.id === 6, load = off ? 0 : L[o.id], pct = (load / o.cap) * 100;
    const avg = p ? p.avg * 0.8 + load * 0.2 : load, vpu = off ? 0 : 1 - clamp((pct - 55) / 100, 0, 1) * 0.14 + nz(0.01);
    const pred = clamp(load + (load - avg) * 6, 0, o.cap * 1.3);
    return { ...o, load, pct, avg, vpu, v: vpu * o.nom, pred, ppct: (pred / o.cap) * 100, dp: p ? pct - p.pct : 0, status: off ? "offline" : pct >= 90 ? "critical" : pct >= 75 ? "warning" : "normal" };
  });
  const edges = EDGES.map((e) => {
    const A = nodes[e.a], B = nodes[e.b], off = A.status === "offline" || B.status === "offline";
    const f = e.kind === "gen" ? A.load / EDGES.filter((x) => x.a === A.id).length : e.kind === "load" ? B.load : 20 + (A.load + B.load) * 0.22;
    return { ...e, flow: off ? 0 : f };
  });
  const gen = nodes.filter((n) => n.type === "gen").reduce((a, n) => a + n.load, 0), demand = nodes.filter((n) => n.type === "load").reduce((a, n) => a + n.load, 0);
  const al = [...prev.alerts], now = Date.now();
  const push = (k, sev, name, msg) => { if (now - (seen[k] || 0) > 9000) { seen[k] = now; al.unshift({ id: k + now, ts: now, sev, node: name, msg }); } };
  nodes.forEach((n) => {
    if (n.status === "offline") return push("o" + n.id, "critical", n.name, "Node offline: load rerouted");
    if (n.pct >= 90) push("c" + n.id, "critical", n.name, `Capacity ${n.pct.toFixed(0)}%: critical`);
    else if (n.ppct >= 90) push("p" + n.id, "warning", n.name, `AI predicts overload (${n.ppct.toFixed(0)}%)`);
    if (n.dp > 12) push("d" + n.id, "warning", n.name, "Sudden load increase");
    if (n.vpu < 0.95) push("v" + n.id, "warning", n.name, `Unusual voltage drop (${(n.vpu * 100).toFixed(1)}%)`);
  });
  const pg = prev.hist.at(-1)?.gen;
  if (pg && gen < pg * 0.8) push("g", "critical", "Generation", "Unexpected reduction in generation");
  return { t, nodes, edges, hist: [...prev.hist, { t, gen, demand }].slice(-40), alerts: al.slice(0, 40) };
}
export function useGrid() {
  const [st, setSt] = useState(null), [shocks, setShocks] = useState({}), sh = useRef(shocks), seen = useRef({});
  sh.current = shocks;
  useEffect(() => {
    const url = process.env.NEXT_PUBLIC_WS_URL;
    if (url) { const ws = new WebSocket(url); ws.onmessage = (e) => setSt(JSON.parse(e.data)); return () => ws.close(); }
    setSt(step({ nodes: [], hist: [], alerts: [] }, 0, {}, seen.current));
    const iv = setInterval(() => setSt((p) => p && step(p, p.t + 1, sh.current, seen.current)), 1500);
    return () => clearInterval(iv);
  }, []);
  return { ...(st || {}), shocks, toggle: (k) => setShocks((s) => ({ ...s, [k]: !s[k] })), reset: () => setShocks({}) };
}
