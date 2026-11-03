"use client";
import { useEffect, useMemo, useState } from "react";
import * as d3 from "d3";
import { sankey, sankeyLinkHorizontal } from "d3-sankey";
import { AreaChart, Area, LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, ReferenceLine, CartesianGrid } from "recharts";
import { useGrid, NODES } from "../lib/useGrid";

const COL = { normal: "#22e5ff", warning: "#ffb020", critical: "#ff2e63", offline: "#5b6478" };
const TYPE = { gen: "#7cffb2", sub: "#b388ff", load: "#22e5ff" };
const colorFor = d3.scaleLinear().domain([0, 70, 88, 100]).range(["#22e5ff", "#22e5ff", "#ffb020", "#ff2e63"]).clamp(true);
const nodeColor = (n) => (n.status === "offline" ? COL.offline : colorFor(n.pct));
const f = (v, d = 0) => Number(v).toFixed(d);
const TT = { background: "#050a18", border: "1px solid #22e5ff55", borderRadius: 8, fontSize: 11 };
const LIMIT = 688; // safe capacity line (80% of installed generation)

const Panel = ({ title, tag, children, className = "" }) => (
  <section className={`glass p-4 ${className}`}>
    <header className="mb-3 flex items-center justify-between">
      <h2 className="orb text-[11px] uppercase tracking-[.28em] text-cyan-300/90">{title}</h2>
      {tag && <span className="text-[10px] text-slate-400">{tag}</span>}
    </header>
    {children}
  </section>
);
const Kpi = ({ label, value, unit, color, sub }) => (
  <div className="glass relative overflow-hidden p-4" style={{ color }}>
    <div className="text-[10px] uppercase tracking-[.25em] text-slate-400">{label}</div>
    <div className="mt-1 flex items-baseline gap-1">
      <span className="orb text-3xl font-bold tabular-nums" style={{ textShadow: `0 0 18px ${color}` }}>{value}</span>
      <span className="text-xs text-slate-400">{unit}</span>
    </div>
    <div className="mt-1 text-[11px] text-slate-500">{sub}</div>
    <i className="kpi-bar" style={{ background: color }} />
  </div>
);

const link = d3.linkHorizontal().x((d) => d[0]).y((d) => d[1]);
const arc = d3.arc();
const edgePath = (e) => {
  const A = NODES[e.a], B = NODES[e.b];
  if (A.x !== B.x) return link({ source: [A.x, A.y], target: [B.x, B.y] });
  const dy = B.y - A.y, bx = A.x + (Math.abs(dy) > 150 ? -110 : 50);
  return `M${A.x},${A.y}Q${bx},${(A.y + B.y) / 2} ${B.x},${B.y}`;
};

function Topology({ nodes, edges, sel, setSel }) {
  return (
    <svg viewBox="0 0 800 520" className="w-full">
      {[["GENERATION", 70], ["SUBSTATIONS", 330], ["CONSUMER ZONES", 680]].map(([t, x]) => (
        <text key={t} x={x} y="14" textAnchor="middle" fill="#22e5ff55" fontSize="9" letterSpacing="3">{t}</text>
      ))}
      {edges.map((e) => {
        const r = e.flow / e.cap, c = e.flow === 0 ? COL.offline : colorFor(r * 100), d = edgePath(e);
        return (
          <g key={e.id} style={{ color: c }}>
            <path d={d} fill="none" stroke={c} strokeOpacity=".18" strokeWidth={1 + r * 5} />
            {e.flow > 0 && <path d={d} fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" className="flow" style={{ animationDuration: `${Math.max(0.5, 2.6 - r * 2)}s` }} />}
          </g>
        );
      })}
      {nodes.map((n) => {
        const r = n.type === "load" ? 9 : n.type === "sub" ? 13 : 15, c = nodeColor(n);
        const common = { fill: c, fillOpacity: 0.18, stroke: c, strokeWidth: 1.6 };
        return (
          <g key={n.id} transform={`translate(${n.x},${n.y})`} className="node" style={{ color: c }} onClick={() => setSel(n.id)}>
            {(n.status === "critical" || n.status === "warning") && <circle r={r + 4} className="ring" fill="none" stroke={c} strokeWidth="1.5" />}
            {sel === n.id && <circle r={r + 12} className="sel" fill="none" stroke="#fff" strokeWidth="1" />}
            <path d={arc({ innerRadius: r + 5, outerRadius: r + 7.5, startAngle: 0, endAngle: Math.min(1, n.pct / 100) * 6.283 })} fill={c} />
            {n.type === "gen" ? <polygon {...common} points={d3.range(6).map((i) => [r * Math.cos((Math.PI / 3) * i), r * Math.sin((Math.PI / 3) * i)]).join(" ")} />
              : n.type === "sub" ? <rect {...common} x={-r * 0.8} y={-r * 0.8} width={r * 1.6} height={r * 1.6} rx="4" transform="rotate(45)" />
              : <circle {...common} r={r} />}
            <circle r="2.5" fill={c} />
            <text y={r + 20} className="lbl">{n.name.replace(" Plant", "").replace("Substation ", "").replace("Zone ", "")}</text>
          </g>
        );
      })}
    </svg>
  );
}

function Flow({ nodes, edges }) {
  const g = useMemo(() => sankey().nodeId((d) => d.id).nodeWidth(10).nodePadding(9).extent([[8, 8], [752, 352]])({
    nodes: nodes.map((n) => ({ id: n.id, name: n.name, type: n.type, status: n.status })),
    links: edges.filter((e) => e.kind !== "ss" && e.flow > 0.5).map((e) => ({ source: e.a, target: e.b, value: e.flow })),
  }), [nodes, edges]);
  const path = sankeyLinkHorizontal();
  return (
    <svg viewBox="0 0 760 360" className="w-full">
      {g.links.map((l, i) => (
        <g key={i} style={{ color: TYPE[l.source.type] }}>
          <path d={path(l)} fill="none" stroke={TYPE[l.source.type]} strokeOpacity=".28" strokeWidth={Math.max(1, l.width)} />
          <path d={path(l)} fill="none" stroke="#fff" strokeOpacity=".5" strokeWidth="1" className="flow" />
        </g>
      ))}
      {g.nodes.map((n) => <rect key={n.id} x={n.x0} y={n.y0} width={n.x1 - n.x0} height={Math.max(2, n.y1 - n.y0)} rx="2" fill={n.status === "offline" ? COL.offline : TYPE[n.type]} />)}
      {g.nodes.filter((n) => n.type !== "load" && n.y1 - n.y0 > 4).map((n) => (
        <text key={n.id} x={n.x1 + 5} y={(n.y0 + n.y1) / 2} dy=".35em" fontSize="9" fill="#cfe8ff" stroke="#04060d" strokeWidth="3" paintOrder="stroke">
          {n.name.replace(" Plant", "").replace("Substation ", "")}
        </text>
      ))}
    </svg>
  );
}

const SH = [["heat", "🔥", "Heatwave", "Demand +32% in all zones"], ["solar", "☀️", "Solar plant trip", "Solar output −92%"],
  ["surge", "⚡", "Sudden demand increase", "3 zones spike +70%"], ["fail", "💥", "Node failure", "Substation S3 goes offline"]];

function Dashboard({ nodes, edges, hist, alerts, shocks, toggle, reset }) {
  const [sel, setSel] = useState(4), [clock, setClock] = useState("");
  useEffect(() => { const u = () => setClock(new Date().toLocaleTimeString("en-GB")); u(); const i = setInterval(u, 1000); return () => clearInterval(i); }, []);
  const { gen, demand } = hist.at(-1), n = nodes[sel];
  const crit = nodes.filter((x) => x.status === "critical" || x.status === "offline").length;
  const recs = useMemo(() => nodes.filter((x) => x.type === "sub" && x.status !== "offline").sort((a, b) => b.ppct - a.ppct).slice(0, 3).map((x) => {
    const c = edges.filter((e) => e.kind === "ss" && (e.a === x.id || e.b === x.id)).map((e) => ({ e, to: nodes[e.a === x.id ? e.b : e.a] }))
      .filter((o) => o.to.status !== "offline").sort((a, b) => a.to.pct - b.to.pct)[0];
    if (!c) return null;
    const mw = Math.round(x.cap * 0.22), after = c.e.flow + mw;
    return { from: x, to: c.to, mw, after, cap: c.e.cap, ok: after <= c.e.cap };
  }).filter(Boolean), [nodes, edges]);
  const fc = useMemo(() => {
    const h = hist.slice(-24), k = h.slice(-8), sl = (k.at(-1).demand - k[0].demand) / Math.max(1, k.length - 1), last = h.at(-1).demand;
    const d = h.map((p, i) => ({ x: i - h.length + 1, actual: p.demand }));
    d[d.length - 1].pred = last;
    for (let i = 1; i <= 10; i++) d.push({ x: i, pred: last + sl * i * (1 + 0.04 * i) });
    return d;
  }, [hist]);
  const peak = Math.max(...fc.map((p) => p.pred ?? 0)), risky = [...nodes].sort((a, b) => b.ppct - a.ppct).slice(0, 4);
  const live = edges.filter((e) => e.a === n.id || e.b === n.id);
  const stats = [["LOAD", `${f(n.pct)}%`], ["POWER", `${f(n.load)} MW`], ["VOLTAGE", n.v ? `${f(n.v, 1)} kV` : "—"], ["AVG LOAD", `${f(n.avg)} MW`],
    ["FORECAST", `${f(n.ppct)}%`], ["LINKS", `${live.filter((e) => e.flow > 0).length}/${live.length} UP`], ["STATUS", n.status.toUpperCase()]];

  return (
    <main className="mx-auto max-w-[1500px] space-y-4 p-4 md:p-6">
      <header className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-4">
          <svg width="72" height="26" viewBox="0 0 72 26"><path className="ecg" d="M0 13H20L26 2L32 24L38 13H72" fill="none" stroke="#22e5ff" strokeWidth="2" /></svg>
          <div>
            <h1 className="orb title text-3xl font-black tracking-[.2em]">GRIDPULSE</h1>
            <p className="text-[10px] uppercase tracking-[.3em] text-slate-400">AI-Driven Smart Grid Load Balancer & Predictive Anomaly Engine</p>
          </div>
        </div>
        <div className="flex items-center gap-4 text-xs text-slate-300">
          <span className="glass px-3 py-1.5">SIMULATED GRID · 20 NODES</span>
          <span className="orb tabular-nums text-cyan-300">{clock}</span>
          <span className="flex items-center gap-2"><i className="live" />LIVE</span>
        </div>
      </header>

      <div className="grid grid-cols-2 gap-4 md:grid-cols-5">
        <Kpi label="Generation" value={f(gen)} unit="MW" color="#7cffb2" sub="4 sources online" />
        <Kpi label="Demand" value={f(demand)} unit="MW" color="#22e5ff" sub={`peak forecast ${f(peak)} MW`} />
        <Kpi label="Balance" value={`${gen - demand >= 0 ? "+" : ""}${f(gen - demand)}`} unit="MW" color={gen - demand >= 0 ? "#7cffb2" : "#ffb020"} sub={gen - demand >= 0 ? "surplus" : "deficit"} />
        <Kpi label="Critical nodes" value={crit} unit={`/ 20`} color={crit ? "#ff2e63" : "#7cffb2"} sub={`${nodes.filter((x) => x.status === "warning").length} in warning`} />
        <Kpi label="Safety blocks" value={recs.filter((r) => !r.ok).length} unit={`/ ${recs.length}`} color="#b388ff" sub="AI actions rejected" />
      </div>

      <div className="grid grid-cols-12 gap-4">
        <Panel title="Grid Topology" tag="click a node to inspect" className="col-span-12 xl:col-span-8">
          <Topology nodes={nodes} edges={edges} sel={sel} setSel={setSel} />
          <div className="mt-2 flex flex-wrap items-center gap-2 text-[10px] text-slate-400">
            {["normal", "warning", "critical", "offline"].map((s) => <span key={s} className="flex items-center gap-1 pr-2"><i className="inline-block h-2 w-2 rounded-full" style={{ background: COL[s], boxShadow: `0 0 8px ${COL[s]}` }} />{s}</span>)}
            <span className="ml-auto orb tracking-widest text-cyan-300">{n.name.toUpperCase()}</span>
          </div>
          <div className="mt-2 grid grid-cols-2 gap-2 sm:grid-cols-4 lg:grid-cols-7">
            {stats.map(([k, v]) => (
              <div key={k} className="border border-cyan-400/10 bg-black/30 p-2">
                <div className="text-[9px] tracking-widest text-slate-500">{k}</div>
                <div className="orb text-sm" style={{ color: k === "STATUS" ? COL[n.status] : "#e6f6ff" }}>{v}</div>
              </div>
            ))}
          </div>
        </Panel>

        <div className="col-span-12 space-y-4 xl:col-span-4">
          <Panel title="Anomalies & Alerts" tag={`${alerts.length} events`}>
            <ul className="max-h-[250px] space-y-1 overflow-y-auto pr-1">
              {alerts.length === 0 && <li className="text-xs text-slate-500">All systems nominal…</li>}
              {alerts.slice(0, 12).map((a) => (
                <li key={a.id} className="alert-in flex gap-2 border-l-2 py-1.5 pl-2 text-[11px]" style={{ borderColor: a.sev === "critical" ? COL.critical : COL.warning }}>
                  <span className="tabular-nums text-slate-500">{new Date(a.ts).toLocaleTimeString("en-GB")}</span>
                  <div><b style={{ color: a.sev === "critical" ? COL.critical : COL.warning }}>{a.node}</b><div className="text-slate-300">{a.msg}</div></div>
                </li>
              ))}
            </ul>
          </Panel>
          <Panel title="Safety Rule Enforcer" tag="AI → rules → grid">
            <div className="space-y-2">
              {recs.map((r, i) => (
                <div key={i} className="border bg-black/30 p-2 text-[11px]" style={{ borderColor: r.ok ? "#7cffb244" : "#ff2e6366" }}>
                  <div className="flex items-center justify-between">
                    <span>AI: shift <b className="text-cyan-300">{r.mw} MW</b> {r.from.name.replace("Substation ", "")} → {r.to.name.replace("Substation ", "")}</span>
                    <b className="orb text-[10px]" style={{ color: r.ok ? "#7cffb2" : "#ff2e63" }}>{r.ok ? "APPROVED" : "BLOCKED"}</b>
                  </div>
                  <div className="mt-1.5 h-1.5 w-full bg-white/10"><div className="h-full transition-all duration-700" style={{ width: `${Math.min(100, (r.after / r.cap) * 100)}%`, background: r.ok ? "#7cffb2" : "#ff2e63", boxShadow: `0 0 8px ${r.ok ? "#7cffb2" : "#ff2e63"}` }} /></div>
                  <div className="mt-1 text-slate-500">line load {f(r.after)} / {r.cap} MW limit</div>
                </div>
              ))}
            </div>
          </Panel>
        </div>

        <Panel title="Dynamic Energy Flow" tag="generation → substations → consumers" className="col-span-12 xl:col-span-7"><Flow nodes={nodes} edges={edges} /></Panel>

        <Panel title="Shock Scenario Simulator" tag={Object.values(shocks).some(Boolean) ? "● SCENARIO ACTIVE" : "idle"} className="col-span-12 xl:col-span-5">
          <div className="grid grid-cols-2 gap-3">
            {SH.map(([k, ic, t, d]) => (
              <button key={k} onClick={() => toggle(k)} className="border p-3 text-left transition hover:-translate-y-0.5"
                style={{ borderColor: shocks[k] ? "#ff2e63" : "#22e5ff33", background: shocks[k] ? "#ff2e6322" : "#00000040", boxShadow: shocks[k] ? "0 0 22px #ff2e6355" : "none" }}>
                <div className="text-xl">{ic}</div><div className="orb mt-1 text-[11px] tracking-wider">{t}</div><div className="text-[10px] text-slate-400">{d}</div>
              </button>
            ))}
          </div>
          <button onClick={reset} className="orb mt-3 w-full border border-cyan-400/30 py-2 text-[11px] tracking-[.3em] text-cyan-300 hover:bg-cyan-400/10">RESET GRID</button>
          <p className="mt-3 text-[11px] text-slate-400">Response: balance <b style={{ color: gen - demand >= 0 ? "#7cffb2" : "#ffb020" }}>{f(gen - demand)} MW</b>, {crit} critical node(s), {recs.filter((r) => !r.ok).length} AI action(s) blocked.</p>
        </Panel>

        <Panel title="Generation vs Demand" tag="MW · live telemetry" className="col-span-12 lg:col-span-6">
          <ResponsiveContainer width="100%" height={220}>
            <AreaChart data={hist}>
              <defs>{[["g", "#7cffb2"], ["d", "#22e5ff"]].map(([id, c]) => <linearGradient key={id} id={id} x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor={c} stopOpacity=".5" /><stop offset="100%" stopColor={c} stopOpacity="0" /></linearGradient>)}</defs>
              <CartesianGrid stroke="#ffffff10" vertical={false} /><XAxis dataKey="t" hide /><YAxis stroke="#64748b" fontSize={10} width={38} domain={[0, "auto"]} />
              <Tooltip contentStyle={TT} formatter={(v) => `${f(v)} MW`} labelFormatter={() => ""} />
              <Area dataKey="gen" name="Generation" stroke="#7cffb2" fill="url(#g)" strokeWidth={2} isAnimationActive={false} />
              <Area dataKey="demand" name="Demand" stroke="#22e5ff" fill="url(#d)" strokeWidth={2} isAnimationActive={false} />
            </AreaChart>
          </ResponsiveContainer>
        </Panel>

        <Panel title="AI Demand Forecast" tag="XGBoost · next 10 min (sim)" className="col-span-12 lg:col-span-6">
          <div className="grid grid-cols-3 gap-4">
            <div className="col-span-2">
              <ResponsiveContainer width="100%" height={220}>
                <LineChart data={fc}>
                  <CartesianGrid stroke="#ffffff10" vertical={false} />
                  <XAxis dataKey="x" type="number" domain={["dataMin", "dataMax"]} stroke="#64748b" fontSize={10} tickFormatter={(v) => (v === 0 ? "NOW" : v > 0 ? `+${v}` : "")} />
                  <YAxis stroke="#64748b" fontSize={10} width={38} domain={[(m) => Math.floor(m * 0.9), (m) => Math.max(LIMIT + 30, Math.ceil(m))]} />
                  <Tooltip contentStyle={TT} formatter={(v) => `${f(v)} MW`} labelFormatter={() => ""} />
                  <ReferenceLine y={LIMIT} stroke="#ff2e63" strokeDasharray="4 4" label={{ value: "SAFE LIMIT", fill: "#ff2e63", fontSize: 9, position: "insideTopLeft" }} />
                  <ReferenceLine x={0} stroke="#ffffff30" />
                  <Line dataKey="actual" stroke="#22e5ff" strokeWidth={2} dot={false} isAnimationActive={false} />
                  <Line dataKey="pred" stroke="#b388ff" strokeWidth={2.5} strokeDasharray="6 4" dot={false} isAnimationActive={false} />
                </LineChart>
              </ResponsiveContainer>
            </div>
            <div className="space-y-2">
              <div className="text-[10px] tracking-widest text-slate-500">LIKELY LOAD SPIKES</div>
              {risky.map((x) => (
                <div key={x.id} className="text-[11px]"><div className="flex justify-between"><span>{x.name.replace("Substation ", "").replace("Zone ", "")}</span><b style={{ color: colorFor(x.ppct) }}>{f(x.pct)}→{f(x.ppct)}%</b></div>
                  <div className="h-1 bg-white/10"><div className="h-full transition-all duration-700" style={{ width: `${Math.min(100, x.ppct)}%`, background: colorFor(x.ppct) }} /></div></div>
              ))}
            </div>
          </div>
        </Panel>
      </div>
      <footer className="pb-4 text-center text-[10px] tracking-widest text-slate-600">SIMULATION & DECISION-SUPPORT PLATFORM · NOT CONNECTED TO A PHYSICAL POWER GRID</footer>
    </main>
  );
}

export default function Page() {
  const g = useGrid();
  return g.nodes ? <Dashboard {...g} /> : <div className="boot orb">INITIALIZING GRID…</div>;
}
