import GridMap from "@/components/grid/GridMap";
import GridLegend from "@/components/grid/GridLegend";

export default function GridMapPage() {
  return (
    <div className="p-6">
      <div className="rounded-xl border border-slate-800 bg-[#0b1728] p-4">
        <GridMap />
        <GridLegend />
      </div>
    </div>
  );
}