"use client";

import { useState } from "react";

export default function ProfilePage() {
  const [name, setName] = useState("Admin");
  const [email, setEmail] = useState("admin@gridpulse.com");

  return (
    <div className="p-6">
      <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
        {/* Profile Card */}
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-6">
          <div className="flex flex-col items-center text-center">
            <div className="flex h-24 w-24 items-center justify-center rounded-full bg-blue-600/20">
              <span className="text-3xl font-semibold text-blue-400">
                A
              </span>
            </div>

            <h2 className="mt-4 text-xl font-semibold text-white">
              {name}
            </h2>

            <p className="mt-1 text-sm text-slate-400">
              System Operator
            </p>

            <span className="mt-4 rounded-full bg-green-500/10 px-3 py-1 text-xs font-medium text-green-400">
              Active
            </span>
          </div>

          <div className="mt-6 border-t border-slate-800 pt-5">
            <div className="flex items-center justify-between">
              <span className="text-sm text-slate-400">
                Account Type
              </span>

              <span className="text-sm text-white">
                Administrator
              </span>
            </div>

            <div className="mt-4 flex items-center justify-between">
              <span className="text-sm text-slate-400">
                Access Level
              </span>

              <span className="text-sm text-blue-400">
                Full Access
              </span>
            </div>
          </div>
        </div>

        {/* Profile Information */}
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-6 xl:col-span-2">
          <div className="mb-5">
            <h2 className="text-lg font-semibold text-white">
              Profile Information
            </h2>

            <p className="mt-1 text-sm text-slate-400">
              Update your operator account information.
            </p>
          </div>

          <div className="space-y-5">
            {/* Name */}
            <div>
              <label className="text-sm font-medium text-white">
                Full Name
              </label>

              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="mt-2 w-full rounded-lg border border-slate-700 bg-[#081525] px-4 py-3 text-sm text-white outline-none transition focus:border-blue-500"
              />
            </div>

            {/* Email */}
            <div>
              <label className="text-sm font-medium text-white">
                Email Address
              </label>

              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="mt-2 w-full rounded-lg border border-slate-700 bg-[#081525] px-4 py-3 text-sm text-white outline-none transition focus:border-blue-500"
              />
            </div>

            {/* Role */}
            <div>
              <label className="text-sm font-medium text-white">
                Role
              </label>

              <input
                type="text"
                value="System Operator"
                readOnly
                className="mt-2 w-full rounded-lg border border-slate-700 bg-[#081525] px-4 py-3 text-sm text-slate-400 outline-none"
              />
            </div>

            <button className="rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-medium text-white transition hover:bg-blue-500">
              Save Changes
            </button>
          </div>
        </div>

        {/* Account Status */}
        <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-6 xl:col-span-3">
          <div className="mb-5">
            <h2 className="text-lg font-semibold text-white">
              Account Status
            </h2>

            <p className="mt-1 text-sm text-slate-400">
              Current GridPulse operator account information.
            </p>
          </div>

          <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
            <div className="rounded-lg bg-slate-900/50 p-4">
              <p className="text-xs text-slate-400">
                Account Status
              </p>

              <p className="mt-2 text-sm font-medium text-green-400">
                Active
              </p>
            </div>

            <div className="rounded-lg bg-slate-900/50 p-4">
              <p className="text-xs text-slate-400">
                System Role
              </p>

              <p className="mt-2 text-sm font-medium text-white">
                System Operator
              </p>
            </div>

            <div className="rounded-lg bg-slate-900/50 p-4">
              <p className="text-xs text-slate-400">
                Dashboard Access
              </p>

              <p className="mt-2 text-sm font-medium text-blue-400">
                Full Access
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}