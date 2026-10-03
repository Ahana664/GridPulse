import { ReactNode } from "react";

interface StatCardProps {
  title: string;
  value: string;
  unit?: string;
  change?: string;
  subtitle?: string;
  icon?: ReactNode;
  iconColor?: string;
}

export default function StatCard({
  title,
  value,
  unit,
  change,
  subtitle,
  icon,
  iconColor = "text-blue-400",
}: StatCardProps) {
  return (
    <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-5">
      <div className="flex items-start justify-between">
        
        <div>
          <p className="text-sm text-slate-400">
            {title}
          </p>

          <div className="mt-2 flex items-baseline gap-2">
            <h2 className="text-3xl font-bold text-white">
              {value}
            </h2>

            {unit && (
              <span className="text-sm text-slate-400">
                {unit}
              </span>
            )}
          </div>

          {change && (
            <p className="mt-2 text-sm text-green-400">
              {change}
            </p>
          )}

          {subtitle && (
            <p className="mt-2 text-xs text-slate-500">
              {subtitle}
            </p>
          )}
        </div>

        {icon && (
          <div
            className={`flex h-12 w-12 items-center justify-center rounded-full bg-slate-800 ${iconColor}`}
          >
            {icon}
          </div>
        )}
      </div>
    </div>
  );
}