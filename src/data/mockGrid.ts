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
  status: "normal" | "warning" | "critical";
};

export type GridConnection = {
  id: string;
  source: string;
  target: string;
  power: number;
  loadPercentage: number;
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
];