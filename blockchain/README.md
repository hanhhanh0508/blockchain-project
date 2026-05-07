# Blockchain

Đây là phần blockchain của workspace, tách riêng khỏi frontend và backend để dễ maintain.

## Cấu trúc

- `contracts/`: smart contract Solidity
- `test/`: test contract
- `scripts/`: script vận hành / gửi tx
- `ignition/`: module deploy
- `hardhat.config.ts`: cấu hình Hardhat
- `package.json`: dependency và script cho blockchain

## Lệnh cơ bản

```shell
cd blockchain
npm install
npx hardhat test
npx hardhat compile
```