"use client";
import { useEffect, useMemo, useState } from "react";
import * as d3 from "d3";
import { sankey, sankeyLinkHorizontal } from "d3-sankey";
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, ReferenceLine, CartesianGrid } from "recharts";
import { useGrid, NODES } from "../lib/useGrid";

const C = { ink: "#1c2733", soft: "#6b7785", card: "#fbf8f1", warn: "#c9871a", crit: "#e4572e", ok: "#1f8a70" };
const f = (v, d = 0) => Number(v).toFixed(d);
const sc = (s) => ({ critical: C.crit, warning: C.warn, offline: C.soft }[s] || C.ink);
const rc = (r) => (r >= 0.9 ? C.crit : r >= 0.75 ? C.warn : C.ink);
const LIMIT = 688; // safe capacity line (80% of installed generation)
const TT = { background: C.card, border: `1.5px solid ${C.ink}`, borderRadius: 10, fontSize: 11, fontFamily: "IBM Plex Mono" };
const ax = { tick: { fill: C.soft, fontSize: 10 }, tickLine: false, axisLine: false };
const short = (n) => n.name.replace(" Plant", "").replace("Substation ", "").replace("Zone ", "");

const Card = ({ n, title, tag, children, className = "", i = 0 }) => (
  <section className={`card rise p-5 ${className}`} style={{ animationDelay: `${i * 70}ms` }}>
    <header className="mb-4 flex items-baseline justify-between gap-3">
      <div className="flex items-baseline gap-3"><span className="mono text-[11px] text-[#6b7785]">{n}</span><h2 className="serif text-2xl">{title}</h2></div>
      {tag && <span className="mono text-[10px] uppercase tracking-wider text-[#6b7785]">{tag}</span>}
    </header>
    {children}
  </section>
);
const Spark = ({ d, c }) => {
  const [a, b] = d3.extent(d), x = d3.scaleLinear([0, Math.max(1, d.length - 1)], [0, 120]), y = d3.scaleLinear([a, b === a ? a + 1 : b], [26, 2]);
  return <svg viewBox="0 0 120 28" className="h-7 w-28"><path d={d3.line()(d.map((v, i) => [x(i), y(v)]))} fill="none" stroke={c} strokeWidth="1.5" strokeLinecap="round" /></svg>;
};
const Stat = ({ label, value, unit, sub, data, color = C.ink, i }) => (
  <div className="card rise flex items-end justify-between p-4" style={{ animationDelay: `${i * 70}ms` }}>
    <div>
      <div className="mono text-[10px] uppercase tracking-widest text-[#6b7785]">{label}</div>
      <div className="serif text-5xl leading-none" style={{ color }}>{value}<span className="mono ml-1 text-xs text-[#6b7785]">{unit}</span></div>
      <div className="mono mt-1 text-[11px] text-[#6b7785]">{sub}</div>
    </div>
    {data && <Spark d={data} c={color} />}
  </div>
);

const Tower = () => (
  <svg viewBox="0 0 260 130" className="w-[260px] max-w-full" fill="none" stroke={C.ink} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="214" cy="26" r="11" /><path d="M214 6v5M214 41v5M194 26h5M229 26h5M200 12l3 3M225 37l3 3M228 12l-3 3M203 37l-3 3" />
    <path d="M0 122H260M130 14L112 122M130 14L148 122M123.7 52H136.3M119 80H141M114.3 108H145.7M123.7 52L141 80M136.3 52L119 80M119 80L145.7 108M141 80L114.3 108M108 34H152M112 58H148" />
    <path d="M108 34Q60 50 0 40M152 34Q200 50 260 40M112 58Q70 74 0 64M148 58Q190 74 260 64" />
    <path d="M108 34Q60 50 0 40M152 34Q200 50 260 40" className="dots" stroke={C.ok} strokeWidth="3" />
  </svg>
);

const Icon = ({ n }) => {
  const p = { fill: "none", stroke: "currentColor", strokeWidth: 1.5, strokeLinecap: "round", strokeLinejoin: "round" };
  if (n.type === "load") return <g {...p}><path d="M-9 2L0 -9L9 2M-7 0V11H7V0M-2 11V5H2V11" /></g>;
  if (n.type === "sub") return <g {...p}><circle cx="-4.5" r="7" /><circle cx="4.5" r="7" /></g>;
  if (n.name.startsWith("Solar")) return <g {...p}><path d="M-10 10L-5 0H10L5 10ZM-7.5 5H7.5M0 0V10" /><circle cx="-7" cy="-8" r="3" /></g>;
  if (n.name.startsWith("Wind")) return <g {...p}><path d="M0 -1V12" /><g><path d="M0 -1V-12M0 -1L9.5 4.5M0 -1L-9.5 4.5" /><animateTransform attributeName="transform" type="rotate" from="0 0 -1" to="360 0 -1" dur={`${Math.max(2, 9 - n.pct / 12)}s`} repeatCount="indefinite" /></g></g>;
  if (n.name.startsWith("Gas")) return <g {...p}><path d="M-11 11H11M-9 11V1L-2 -3V11M2 11V-10H8V11" /></g>;
  return <g {...p}><path d="M-11 -9H11L7 11H-7ZM-6 0q3 -3 6 0t6 0M-5 5q2.5 -2.5 5 0t5 0" /></g>;
};

const link = d3.linkHorizontal().x((d) => d[0]).y((d) => d[1]), arc = d3.arc();
const edgePath = (e) => {
  const A = NODES[e.a], B = NODES[e.b];
  if (A.x !== B.x) return link({ source: [A.x, A.y], target: [B.x, B.y] });
  const dy = B.y - A.y;
  return `M${A.x},${A.y}Q${A.x + (Math.abs(dy) > 150 ? -110 : 50)},${(A.y + B.y) / 2} ${B.x},${B.y}`;
};

function Topology({ nodes, edges, sel, setSel }) {
  return (
    <svg viewBox="0 0 800 520" className="w-full">
      {[200, 480].map((x) => <path key={x} d={`M${x} 24V500`} stroke={C.ink} strokeOpacity=".15" strokeDasharray="3 6" />)}
      {[["GENERATION", 70], ["SUBSTATIONS", 330], ["CONSUMERS", 680]].map(([t, x]) => <text key={t} x={x} y="14" textAnchor="middle" className="mono" fontSize="9" letterSpacing="2" fill={C.soft}>{t}</text>)}
      {edges.map((e) => {
        const r = e.flow / e.cap, d = edgePath(e);
        return (
          <g key={e.id}>
            <path d={d} fill="none" stroke={C.ink} strokeOpacity={e.flow === 0 ? 0.15 : 0.3} strokeDasharray={e.flow === 0 ? "2 4" : undefined} />
            {e.flow > 0 && <path d={d} fill="none" stroke={r >= 0.75 ? rc(r) : C.ok} strokeWidth={2 + r * 3} className="dots" style={{ animationDuration: `${Math.max(0.5, 2.2 - r * 1.8)}s` }} />}
          </g>
        );
      })}
      {nodes.map((n) => {
        const r = n.type === "load" ? 18 : 22, c = sc(n.status);
        return (
          <g key={n.id} transform={`translate(${n.x},${n.y})`} className="node" style={{ color: c }} onClick={() => setSel(n.id)}>
            {n.status === "critical" && <circle r={r + 10} fill="none" stroke={c} strokeWidth="1.5" strokeDasharray="3 5" className="rot" />}
            {n.status === "warning" && <circle r={r + 6} fill="none" stroke={c} className="pulse-ring" />}
            {sel === n.id && <circle r={r + 9} fill="none" stroke={C.ink} strokeDasharray="1 4" strokeLinecap="round" strokeWidth="2" />}
            <circle r={r} fill={C.card} stroke={c} strokeWidth="1.5" strokeDasharray={n.status === "offline" ? "3 3" : undefined} className="halo" />
            {n.status !== "offline" && <path d={arc({ innerRadius: r + 3, outerRadius: r + 5, startAngle: 0, endAngle: Math.min(1, n.pct / 100) * 6.283 })} fill={c} />}
            <g transform={n.type === "load" ? "scale(.78)" : undefined}><Icon n={n} /></g>
            <text y={r + 18} className="lbl">{short(n)}</text>
            <text y={r + 29} className="lbl" style={{ fill: c }}>{n.status === "offline" ? "OFFLINE" : `${f(n.pct)}%`}</text>
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
        <g key={i} fill="none">
          <path d={path(l)} stroke={C.ink} strokeOpacity=".75" strokeWidth={Math.max(1.5, l.width)} />
          <path d={path(l)} stroke={C.card} strokeWidth={Math.max(0, l.width - 1.6)} />
          <path d={path(l)} stroke={C.ok} strokeWidth="2" className="dots" />
        </g>
      ))}
      {g.nodes.map((n) => <rect key={n.id} x={n.x0} y={n.y0} width={n.x1 - n.x0} height={Math.max(2, n.y1 - n.y0)} rx="2" fill={C.card} stroke={sc(n.status)} strokeWidth="1.5" />)}
      {g.nodes.filter((n) => n.type !== "load" && n.y1 - n.y0 > 4).map((n) => (
        <text key={n.id} x={n.x1 + 5} y={(n.y0 + n.y1) / 2} dy=".35em" className="mono" fontSize="9" fill={C.ink} stroke={C.card} strokeWidth="3" paintOrder="stroke">{short(n)}</text>
      ))}
    </svg>
  );
}

const ICONS = { heat: "M14 4v10.5a4 4 0 1 1-4 0V4a2 2 0 0 1 4 0Z", solar: "M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4M12 8a4 4 0 1 0 0 8a4 4 0 0 0 0-8Z",
  surge: "M13 2L3 14h9l-1 8l10-12h-9l1-8Z", fail: "M12 2v10M18.4 6.6a9 9 0 1 1-12.8 0" };
const SH = [["heat", "Heatwave", "Demand +32% in all zones"], ["solar", "Solar plant trip", "Solar output −92%"], ["surge", "Demand surge", "3 zones spike +70%"], ["fail", "Node failure", "Substation S3 goes offline"]];

function Dashboard({ nodes, edges, hist, alerts, shocks, toggle, reset }) {
  const [sel, setSel] = useState(4), [clock, setClock] = useState("");
  useEffect(() => { const u = () => setClock(new Date().toLocaleTimeString("en-GB")); u(); const i = setInterval(u, 1000); return () => clearInterval(i); }, []);
  const { gen, demand } = hist.at(-1), n = nodes[sel];
  const bad = nodes.filter((x) => x.status !== "normal").length, crit = nodes.filter((x) => x.status === "critical" || x.status === "offline").length;
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
  const lk = edges.filter((e) => e.a === n.id || e.b === n.id);
  const rows = [["Load", `${f(n.pct)}%`], ["Power", `${f(n.load)} MW`], ["Voltage", n.v ? `${f(n.v, 1)} kV` : "—"], ["Average load", `${f(n.avg)} MW`],
    ["Forecast", `${f(n.ppct)}%`], ["Connections", `${lk.filter((e) => e.flow > 0).length} of ${lk.length} up`]];

  return (
    <main className="mx-auto max-w-[1400px] space-y-5 p-4 md:p-8">
      <header className="flex flex-wrap items-end justify-between gap-6">
        <div>
          <div className="mono mb-2 flex items-center gap-3 text-[11px] uppercase tracking-widest text-[#6b7785]"><i className="live" />Live · simulated 20-node grid · <span className="tabular-nums">{clock}</span></div>
          <h1 className="serif text-6xl leading-none md:text-7xl">Grid<em>Pulse</em></h1>
          <p className="mt-2 max-w-md text-sm text-[#6b7785]">AI-driven smart grid load balancer & predictive anomaly engine.</p>
        </div>
        <Tower />
      </header>

      <div className="grid grid-cols-2 gap-5 lg:grid-cols-4">
        <Stat i={0} label="Generation" value={f(gen)} unit="MW" sub="4 sources" data={hist.map((h) => h.gen)} color={C.ok} />
        <Stat i={1} label="Demand" value={f(demand)} unit="MW" sub={`forecast peak ${f(peak)} MW`} data={hist.map((h) => h.demand)} />
        <Stat i={2} label="Balance" value={`${gen - demand >= 0 ? "+" : ""}${f(gen - demand)}`} unit="MW" sub={gen - demand >= 0 ? "surplus" : "deficit"} color={gen - demand >= 0 ? C.ok : C.warn} />
        <Stat i={3} label="Nodes at risk" value={bad} unit="/ 20" sub={`${crit} critical`} color={crit ? C.crit : bad ? C.warn : C.ok} />
      </div>

      <div className="grid grid-cols-12 gap-5">
        <Card n="01" title="Grid map" tag="click any node" className="col-span-12 xl:col-span-8" i={4}>
          <Topology nodes={nodes} edges={edges} sel={sel} setSel={setSel} />
          <div className="mono mt-1 flex flex-wrap gap-5 text-[10px] uppercase tracking-wider text-[#6b7785]">
            {[["normal", C.ink], ["warning", C.warn], ["critical", C.crit], ["offline", C.soft]].map(([s, c]) => <span key={s} className="flex items-center gap-1.5"><i className="inline-block h-2.5 w-2.5 rounded-full border-[1.5px]" style={{ borderColor: c }} />{s}</span>)}
          </div>
        </Card>

        <div className="col-span-12 space-y-5 xl:col-span-4">
          <Card n="02" title="Inspector" tag={n.type === "gen" ? "generator" : n.type === "sub" ? "substation" : "consumer zone"} i={5}>
            <div className="serif text-4xl" style={{ color: sc(n.status) }}>{n.name}</div>
            <div className="mono mb-4 text-[11px] uppercase tracking-wider text-[#6b7785]">{n.status} · {n.cap} MW capacity · {n.nom} kV nominal</div>
            <div className="space-y-2 text-sm">
              {rows.map(([k, v]) => <div key={k} className="flex items-baseline gap-2"><span>{k}</span><i className="flex-1 border-b border-dotted border-[#1c273366]" /><b className="mono font-medium">{v}</b></div>)}
            </div>
            <div className="mt-4 h-2.5 rounded-full border-[1.5px] border-[#1c2733] p-px"><div className="h-full rounded-full transition-all duration-700" style={{ width: `${Math.min(100, n.pct)}%`, background: sc(n.status) }} /></div>
          </Card>
          <Card n="03" title="Alerts" tag={`${alerts.length} events`} i={6}>
            <ul className="max-h-[230px] space-y-2.5 overflow-y-auto pr-1">
              {alerts.length === 0 && <li className="text-sm text-[#6b7785]">All quiet on the grid.</li>}
              {alerts.slice(0, 12).map((a) => (
                <li key={a.id} className="rise flex gap-3 text-sm">
                  <i className="mt-1 h-3 w-3 shrink-0 rounded-full border-[1.5px]" style={{ borderColor: a.sev === "critical" ? C.crit : C.warn }} />
                  <div><b className="font-medium">{a.node}</b> <span className="text-[#6b7785]">{a.msg}</span><div className="mono text-[10px] text-[#6b7785]">{new Date(a.ts).toLocaleTimeString("en-GB")}</div></div>
                </li>
              ))}
            </ul>
          </Card>
        </div>

        <Card n="04" title="Energy flow" tag="generation → substations → zones" className="col-span-12 xl:col-span-7" i={7}><Flow nodes={nodes} edges={edges} /></Card>

        <Card n="05" title="Shock simulator" tag={Object.values(shocks).some(Boolean) ? "scenario active" : "idle"} className="col-span-12 xl:col-span-5" i={8}>
          <div className="grid grid-cols-2 gap-3">
            {SH.map(([k, t, d]) => (
              <button key={k} onClick={() => toggle(k)} className={`shock ${shocks[k] ? "on" : ""}`}>
                <svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d={ICONS[k]} /></svg>
                <div className="serif mt-2 text-xl leading-tight">{t}</div><div className="mono text-[10px] opacity-70">{d}</div>
              </button>
            ))}
          </div>
          <div className="mt-4 flex items-center justify-between gap-3">
            <p className="text-sm text-[#6b7785]">Balance <b className="mono text-[#1c2733]">{f(gen - demand)} MW</b> · {crit} critical · {recs.filter((r) => !r.ok).length} AI action(s) blocked</p>
            <button onClick={reset} className="btn mono text-[11px] uppercase tracking-wider">Reset</button>
          </div>
        </Card>

        <Card n="06" title="Generation & demand" tag="MW · live" className="col-span-12 lg:col-span-6" i={9}>
          <ResponsiveContainer width="100%" height={230}>
            <LineChart data={hist}>
              <CartesianGrid stroke={C.ink} strokeOpacity=".12" strokeDasharray="2 5" vertical={false} /><XAxis dataKey="t" hide /><YAxis {...ax} width={38} domain={[0, "auto"]} />
              <Tooltip contentStyle={TT} formatter={(v) => `${f(v)} MW`} labelFormatter={() => ""} />
              <Line dataKey="gen" name="Generation" stroke={C.ok} strokeWidth={2} dot={false} isAnimationActive={false} />
              <Line dataKey="demand" name="Demand" stroke={C.ink} strokeWidth={2} dot={false} isAnimationActive={false} />
            </LineChart>
          </ResponsiveContainer>
        </Card>

        <Card n="07" title="AI demand forecast" tag="XGBoost · next 10 min (sim)" className="col-span-12 lg:col-span-6" i={10}>
          <div className="grid grid-cols-3 gap-4">
            <div className="col-span-2">
              <ResponsiveContainer width="100%" height={230}>
                <LineChart data={fc}>
                  <CartesianGrid stroke={C.ink} strokeOpacity=".12" strokeDasharray="2 5" vertical={false} />
                  <XAxis dataKey="x" type="number" domain={["dataMin", "dataMax"]} {...ax} tickFormatter={(v) => (v === 0 ? "now" : v > 0 ? `+${v}` : "")} />
                  <YAxis {...ax} width={38} domain={[(m) => Math.floor(m * 0.9), (m) => Math.max(LIMIT + 30, Math.ceil(m))]} />
                  <Tooltip contentStyle={TT} formatter={(v) => `${f(v)} MW`} labelFormatter={() => ""} />
                  <ReferenceLine y={LIMIT} stroke={C.crit} strokeDasharray="4 4" label={{ value: "safe limit", fill: C.crit, fontSize: 10, position: "insideTopLeft" }} />
                  <Line dataKey="actual" stroke={C.ink} strokeWidth={2} dot={false} isAnimationActive={false} />
                  <Line dataKey="pred" stroke={C.warn} strokeWidth={2} strokeDasharray="6 4" dot={false} isAnimationActive={false} />
                </LineChart>
              </ResponsiveContainer>
            </div>
            <div className="space-y-3">
              <div className="mono text-[10px] uppercase tracking-widest text-[#6b7785]">Likely load spikes</div>
              {risky.map((x) => (
                <div key={x.id} className="text-sm"><div className="flex justify-between"><span>{short(x)}</span><b className="mono text-xs font-medium" style={{ color: rc(x.ppct / 100) }}>{f(x.pct)}→{f(x.ppct)}%</b></div>
                  <div className="mt-1 h-1.5 rounded-full border border-[#1c2733]"><div className="h-full rounded-full transition-all duration-700" style={{ width: `${Math.min(100, x.ppct)}%`, background: rc(x.ppct / 100) }} /></div></div>
              ))}
            </div>
          </div>
        </Card>

        <Card n="08" title="Safety rule enforcer" tag="AI suggests · rules decide" className="col-span-12" i={11}>
          <div className="grid gap-4 md:grid-cols-3">
            {recs.map((r, i) => (
              <div key={i} className="rounded-xl border-[1.5px] border-[#1c273355] p-4">
                <div className="mono text-[10px] uppercase tracking-widest text-[#6b7785]">AI suggests</div>
                <div className="serif text-2xl leading-tight">Shift {r.mw} MW from {short(r.from)} to {short(r.to)}</div>
                <div className="mt-3 h-2.5 rounded-full border-[1.5px] border-[#1c2733] p-px"><div className="h-full rounded-full transition-all duration-700" style={{ width: `${Math.min(100, (r.after / r.cap) * 100)}%`, background: r.ok ? C.ok : C.crit }} /></div>
                <div className="mt-2 flex items-center justify-between">
                  <span className="mono text-[11px] text-[#6b7785]">line {f(r.after)} / {r.cap} MW</span>
                  <span className="mono rounded-full border-[1.5px] px-3 py-0.5 text-[10px] uppercase tracking-wider" style={r.ok ? { borderColor: C.ok, color: C.ok } : { background: C.crit, borderColor: C.crit, color: "#fff" }}>{r.ok ? "approved" : "blocked"}</span>
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>
      <footer className="mono pb-6 pt-2 text-center text-[10px] uppercase tracking-widest text-[#6b7785]">Simulation & decision-support · not connected to a physical grid</footer>
    </main>
  );
}

export default function Page() {
  const g = useGrid();
  return g.nodes ? <Dashboard {...g} /> : <div className="boot">warming up the grid…</div>;
}
