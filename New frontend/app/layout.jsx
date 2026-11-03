import "../files/globals2.css";

export const metadata = {
  title: "GridPulse · Smart Grid Operations",
  description: "Interactive smart-grid monitoring and simulation dashboard.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
