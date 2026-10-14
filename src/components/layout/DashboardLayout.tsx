import Sidebar from "./Sidebar";
import Navbar from "./Navbar";
import { GridDataProvider } from "@/hooks/useGridData";

interface DashboardLayoutProps {
  children: React.ReactNode;
}

export default function DashboardLayout({
  children,
}: DashboardLayoutProps) {
  return (
    <div className="min-h-screen bg-[#07111f] text-white">
      
      <GridDataProvider>
        <Sidebar />
        <div className="ml-64 min-h-screen">
          <Navbar />
          <main className="p-8">{children}</main>
        </div>
      </GridDataProvider>
    </div>
  );
}