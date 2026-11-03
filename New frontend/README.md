# GridPulse UI Prototype

This directory contains a standalone Next.js UI prototype, separate from the primary application in the repository root. It runs its own simulator-backed demo data by default and is not included in the root Docker Compose stack.

## Run locally

Requires Node.js 22 or newer and npm. From this directory:

```bash
npm ci
npm run dev
```

Open <http://localhost:3000>. Do not run this prototype and the root frontend on the same port at the same time. To create a production build, run `npm run build` and then `npm start`.

## Data behavior

The prototype generates synthetic 20-node grid telemetry in `lib/useGrid.js`; it does not represent real grid measurements. An optional `NEXT_PUBLIC_WS_URL` can provide a compatible WebSocket stream. The root FastAPI service uses a separate API contract, so integration requires an explicit adapter before connecting the two applications.

The `files/` directory retains alternate UI experiment files. The active page entry currently renders `files/page2.jsx`.
