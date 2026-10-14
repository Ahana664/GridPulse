export type GridNode = {
  id: string;
  name: string;
  type: "generation" | "load" | "substation";
  zone: string;
  x: number;
  y: number;
  voltage: number;
  load: number;
  power: number;
  capacity?: number;
  status: "normal" | "warning" | "critical";
};

export type GridConnection = {
  id: string;
  source: string;
  target: string;
  power: number;
  loadPercentage: number;
  capacity?: number;
  status: "normal" | "warning" | "critical";
};

export const gridNodes: GridNode[] = [
  {
    id: "GEN-N1",
    name: "North Solar Plant",
    type: "generation",
    zone: "North Zone",
    x: 260,
    y: 100,
    voltage: 230,
    load: 42,
    power: 620,
    status: "normal",
  },

  {
    id: "SUB-N1",
    name: "North Substation",
    type: "substation",
    zone: "North Zone",
    x: 450,
    y: 150,
    voltage: 230,
    load: 72,
    power: 785,
    status: "normal",
  },

  {
    id: "LOAD-N1",
    name: "North Load Center",
    type: "load",
    zone: "North Zone",
    x: 650,
    y: 100,
    voltage: 132,
    load: 89,
    power: 785,
    status: "warning",
  },

  {
    id: "GEN-W1",
    name: "West Wind Farm",
    type: "generation",
    zone: "West Zone",
    x: 180,
    y: 300,
    voltage: 230,
    load: 38,
    power: 540,
    status: "normal",
  },

  {
    id: "SUB-C1",
    name: "Central Substation",
    type: "substation",
    zone: "Central Zone",
    x: 450,
    y: 330,
    voltage: 230,
    load: 68,
    power: 1230,
    status: "normal",
  },

  {
    id: "LOAD-W1",
    name: "West Load Center",
    type: "load",
    zone: "West Zone",
    x: 180,
    y: 480,
    voltage: 132,
    load: 58,
    power: 643,
    status: "normal",
  },

  {
    id: "LOAD-E1",
    name: "East Load Center",
    type: "load",
    zone: "East Zone",
    x: 720,
    y: 320,
    voltage: 132,
    load: 82,
    power: 952,
    status: "warning",
  },

  {
    id: "GEN-S1",
    name: "South Hydro Plant",
    type: "generation",
    zone: "South Zone",
    x: 360,
    y: 550,
    voltage: 230,
    load: 51,
    power: 850,
    status: "normal",
  },

  {
    id: "SUB-S1",
    name: "South Substation",
    type: "substation",
    zone: "South Zone",
    x: 560,
    y: 520,
    voltage: 230,
    load: 74,
    power: 1202,
    status: "normal",
  },

  {
    id: "LOAD-S1",
    name: "South Load Center",
    type: "load",
    zone: "South Zone",
    x: 760,
    y: 500,
    voltage: 132,
    load: 76,
    power: 1202,
    status: "normal",
  },
  { id: "LOAD-N2", name: "North Industrial Park", type: "load", zone: "North Zone", x: 790, y: 80, voltage: 132, load: 71, power: 341, capacity: 480, status: "normal" },
  { id: "GEN-E1", name: "East Wind Farm", type: "generation", zone: "East Zone", x: 120, y: 205, voltage: 230, load: 77, power: 858, capacity: 1100, status: "normal" },
  { id: "SUB-E1", name: "East Substation", type: "substation", zone: "East Zone", x: 390, y: 205, voltage: 230, load: 65, power: 663, capacity: 1400, status: "normal" },
  { id: "LOAD-E2", name: "East Residential Load", type: "load", zone: "East Zone", x: 790, y: 205, voltage: 132, load: 68, power: 306, capacity: 450, status: "normal" },
  { id: "GEN-C1", name: "Central Hydro Plant", type: "generation", zone: "Central Zone", x: 120, y: 330, voltage: 230, load: 84, power: 1134, capacity: 1350, status: "normal" },
  { id: "LOAD-C1", name: "Central Business District", type: "load", zone: "Central Zone", x: 650, y: 330, voltage: 132, load: 88, power: 669, capacity: 760, status: "warning" },
  { id: "LOAD-C2", name: "Central Hospital District", type: "load", zone: "Central Zone", x: 790, y: 330, voltage: 132, load: 74, power: 289, capacity: 390, status: "normal" },
  { id: "SUB-W1", name: "West Substation", type: "substation", zone: "West Zone", x: 390, y: 455, voltage: 230, load: 67, power: 1060, capacity: 1250, status: "normal" },
  { id: "LOAD-W2", name: "West Data Center", type: "load", zone: "West Zone", x: 790, y: 455, voltage: 132, load: 83, power: 432, capacity: 520, status: "normal" },
  { id: "LOAD-S2", name: "South Residential Load", type: "load", zone: "South Zone", x: 790, y: 580, voltage: 132, load: 72, power: 338, capacity: 470, status: "normal" },
];

export const gridConnections: GridConnection[] = [
  {
    id: "C1",
    source: "GEN-N1",
    target: "SUB-N1",
    power: 620,
    loadPercentage: 42,
    status: "normal",
  },

  {
    id: "C2",
    source: "SUB-N1",
    target: "LOAD-N1",
    power: 785,
    loadPercentage: 89,
    status: "warning",
  },

  {
    id: "C3",
    source: "GEN-W1",
    target: "SUB-C1",
    power: 540,
    loadPercentage: 38,
    status: "normal",
  },

  {
    id: "C4",
    source: "SUB-N1",
    target: "SUB-C1",
    power: 785,
    loadPercentage: 72,
    status: "normal",
  },

  {
    id: "C5",
    source: "SUB-C1",
    target: "LOAD-E1",
    power: 952,
    loadPercentage: 82,
    status: "warning",
  },

  {
    id: "C6",
    source: "SUB-C1",
    target: "LOAD-W1",
    power: 643,
    loadPercentage: 58,
    status: "normal",
  },

  {
    id: "C7",
    source: "GEN-S1",
    target: "SUB-S1",
    power: 850,
    loadPercentage: 51,
    status: "normal",
  },

  {
    id: "C8",
    source: "SUB-C1",
    target: "SUB-S1",
    power: 1202,
    loadPercentage: 74,
    status: "normal",
  },

  {
    id: "C9",
    source: "SUB-S1",
    target: "LOAD-S1",
    power: 1202,
    loadPercentage: 76,
    status: "normal",
  },
  { id: "C10", source: "SUB-N1", target: "LOAD-N2", power: 341, loadPercentage: 71, capacity: 480, status: "normal" },
  { id: "C11", source: "GEN-E1", target: "SUB-E1", power: 858, loadPercentage: 78, capacity: 1100, status: "normal" },
  { id: "C12", source: "SUB-E1", target: "LOAD-E1", power: 467, loadPercentage: 82, capacity: 570, status: "warning" },
  { id: "C13", source: "SUB-E1", target: "LOAD-E2", power: 306, loadPercentage: 68, capacity: 450, status: "normal" },
  { id: "C14", source: "GEN-C1", target: "SUB-C1", power: 1134, loadPercentage: 84, capacity: 1350, status: "normal" },
  { id: "C15", source: "SUB-C1", target: "LOAD-C1", power: 669, loadPercentage: 88, capacity: 760, status: "warning" },
  { id: "C16", source: "SUB-C1", target: "LOAD-C2", power: 289, loadPercentage: 74, capacity: 390, status: "normal" },
  { id: "C17", source: "GEN-W1", target: "SUB-W1", power: 540, loadPercentage: 60, capacity: 900, status: "normal" },
  { id: "C18", source: "SUB-W1", target: "LOAD-W1", power: 643, loadPercentage: 58, capacity: 1100, status: "normal" },
  { id: "C19", source: "SUB-W1", target: "LOAD-W2", power: 432, loadPercentage: 83, capacity: 520, status: "normal" },
  { id: "C20", source: "SUB-S1", target: "LOAD-S2", power: 338, loadPercentage: 72, capacity: 470, status: "normal" },
];