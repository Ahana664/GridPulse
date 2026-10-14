"use client";

import { useState } from "react";
import { ShieldCheck, ShieldAlert } from "lucide-react";
import { useGridData } from "@/hooks/useGridData";

const apiBase = (process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000/api/v1").replace(/\/$/, "");

export default function SafetyStatus() {
	const { data } = useGridData();
	const [selectedConnectionId, setSelectedConnectionId] = useState<string | null>(null);
	const [proposedMw, setProposedMw] = useState("1500");
	const [validation, setValidation] = useState<{ accepted: boolean; message: string; capacityMw: number } | null>(null);
	const [validationError, setValidationError] = useState<string | null>(null);
	const checks = data.safetyChecks;
	const passed = checks.filter((check) => check.status === "pass").length;
	const warnings = checks.filter((check) => check.status === "warning").length;
	const violations = checks.filter((check) => check.status === "critical").length;
	const selectedConnection = data.connections.find((connection) => connection.id === selectedConnectionId) ?? data.connections[0];
	const connectionId = selectedConnection?.id ?? "";

	async function validateProposal() {
		setValidation(null);
		setValidationError(null);
		try {
			const response = await fetch(`${apiBase}/safety/validate`, {
				method: "POST",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify({ connection_id: connectionId, proposed_mw: Number(proposedMw) }),
			});
			const result = await response.json() as { accepted?: boolean; message?: string; capacityMw?: number; detail?: string };
			if (!response.ok) throw new Error(result.detail ?? "Safety validation service is unavailable.");
			setValidation({
				accepted: Boolean(result.accepted),
				message: result.message ?? "Proposal checked.",
				capacityMw: result.capacityMw ?? 0,
			});
		} catch (reason) {
			setValidationError(reason instanceof Error ? reason.message : "Safety validation failed.");
		}
	}

	return (
		<section className="overflow-hidden rounded-xl border border-slate-800 bg-[#0b1728]">
			<div className="flex flex-wrap items-center justify-between gap-4 border-b border-slate-800 p-5">
				<div className="flex items-center gap-3">
					<div className="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-400">
						{violations ? <ShieldAlert className="h-5 w-5" /> : <ShieldCheck className="h-5 w-5" />}
					</div>
					<div>
						<h2 className="text-lg font-semibold text-white">Safety Rule Enforcer</h2>
						<p className="text-sm text-slate-400">Deterministic capacity checks; recommendations never control the grid.</p>
					</div>
				</div>
				<div className="flex gap-4 text-xs">
					<span className="text-emerald-400">{passed} passed</span>
					<span className="text-amber-400">{warnings} warnings</span>
					<span className="text-red-400">{violations} violations</span>
				</div>
			</div>
			<div className="max-h-96 overflow-auto">
				{checks.length === 0 ? (
					<p className="p-5 text-sm text-slate-500">Waiting for telemetry safety checks.</p>
				) : checks.map((check) => (
					<div key={check.id} className="flex flex-wrap items-center justify-between gap-3 border-b border-slate-800/70 px-5 py-3 last:border-0">
						<div>
							<p className="text-sm font-medium text-white">{check.subject}</p>
							<p className="mt-1 text-xs text-slate-500">{check.message}</p>
						</div>
						<div className="text-right">
							<p className="text-sm text-slate-200">{check.measured.toLocaleString()} / {check.limit.toLocaleString()} {check.unit}</p>
							<p className={`mt-1 text-xs font-semibold uppercase ${check.status === "pass" ? "text-emerald-400" : check.status === "warning" ? "text-amber-400" : "text-red-400"}`}>{check.status}</p>
						</div>
					</div>
				))}
			</div>
			<div className="border-t border-slate-800 p-5">
				<h3 className="text-sm font-semibold text-white">Validate a flow recommendation</h3>
				<p className="mt-1 text-xs text-slate-400">Checks a proposed transfer against a line limit. Validation never changes grid state.</p>
				<div className="mt-4 grid gap-3 md:grid-cols-[1fr_180px_auto]">
					  <select value={connectionId} onChange={(event) => setSelectedConnectionId(event.target.value)} className="rounded-lg border border-slate-700 bg-[#081525] px-3 py-2 text-sm text-slate-200">
						{data.connections.map((connection) => (
							<option key={connection.id} value={connection.id}>{connection.source} → {connection.target} · {connection.capacity ?? "—"} MW</option>
						))}
					</select>
					<input type="number" min="0" value={proposedMw} onChange={(event) => setProposedMw(event.target.value)} aria-label="Proposed flow in megawatts" className="rounded-lg border border-slate-700 bg-[#081525] px-3 py-2 text-sm text-white" />
					<button type="button" onClick={() => void validateProposal()} disabled={!selectedConnection || Number(proposedMw) < 0} className="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-500 disabled:opacity-50">Validate MW</button>
				</div>
				{validation && <p role="status" className={`mt-3 text-sm ${validation.accepted ? "text-emerald-400" : "text-red-400"}`}>{validation.message} · line limit {validation.capacityMw.toLocaleString()} MW</p>}
				{validationError && <p role="alert" className="mt-3 text-sm text-red-400">{validationError}</p>}
			</div>
		</section>
	);
}
