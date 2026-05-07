# TuneChain Monorepo

Workspace này được tổ chức theo monorepo với 3 package độc lập:

- backend: API server (Express + MySQL + IPFS)
- blockchain: smart contracts (Hardhat)
- frontend: web app (React + Vite)

## Cấu trúc thư mục

- backend/
- blockchain/
- frontend/

Root package.json chỉ dùng để điều phối workspace bằng npm workspaces.

## Cài đặt dependency

Chạy duy nhất tại root:

```bash
npm install
```

## Các lệnh thường dùng

```bash
npm run dev:backend
npm run dev:frontend
npm run build
npm run test
npm run lint
```

Lệnh theo từng workspace:

```bash
npm run build -w backend
npm run compile -w blockchain
npm run build -w frontend
```
