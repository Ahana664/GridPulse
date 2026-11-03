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
    <div className="dashboard-shell">
      <GridDataProvider>
        <Sidebar />
        <div className="dashboard-main">
          <Navbar />
          <main className="gp-page-container">{children}</main>
        </div>
      </GridDataProvider>
    </div>
  );
}