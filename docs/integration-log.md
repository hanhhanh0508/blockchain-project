# 📔 TuneChain — Integration Log

**Dự án:** TuneChain  
**Người thực hiện:** M4  
**Môi trường:** Hardhat Local (chainId 31337)  
**Ngày bắt đầu:** 2026-05-16  

---

## Thông tin môi trường

| Thông tin | Giá trị |
|-----------|---------|
| Contract Address | `<điền sau khi deploy>` |
| RPC URL | `http://127.0.0.1:8545` |
| Chain ID | `31337` |
| Hardhat Version | `<npx hardhat --version>` |
| Node.js Version | `<node --version>` |
| Browser | Chrome / Firefox |
| MetaMask Version | `<điền>` |

---

## 🎵 UC-02 — Upload Track (Luồng thử nghiệm)

### Phiên test ngày: ___________

| # | Bước | Kết quả | Ghi chú | Bug Issue # |
|---|------|---------|---------|-------------|
| 1.1 | Chọn file nhạc `.mp3` < 5MB | ⬜ Pass / ⬜ Fail | | |
| 1.2 | Chọn ảnh bìa `.jpg` / `.png` | ⬜ Pass / ⬜ Fail | | |
| 1.3 | `uploadTrackFiles()` trả về CID hợp lệ | ⬜ Pass / ⬜ Fail | CID: `Qm...` | |
| 2.1 | MetaMask hiện popup xác nhận `uploadTrack()` | ⬜ Pass / ⬜ Fail | | |
| 2.2 | Ký giao dịch → Tx Hash xuất hiện trong `TxStatus.tsx` | ⬜ Pass / ⬜ Fail | TxHash: `0x...` | |
| 2.3 | Event `TrackUploaded` emit trên Hardhat terminal | ⬜ Pass / ⬜ Fail | | |
| 2.4 | `trackId` mới xuất hiện khi gọi `getAllTracks()` | ⬜ Pass / ⬜ Fail | trackId: | |
| 3.1 | UI điều hướng sang trang chi tiết track | ⬜ Pass / ⬜ Fail | | |

#### CID nhận được từ Pinata:
```
<Dán CID nhận được vào đây — bắt đầu bằng "Qm" hoặc "bafy">
```

#### Hardhat Terminal log (sao chép event):
```
<Dán output từ terminal Hardhat vào đây>
```

---

## 💰 UC-04 — Tipping (Luồng thử nghiệm)

### Phiên test ngày: ___________

> **Điều kiện:** Track `trackId = 1` đã được upload ở bước UC-02

| # | Bước | Kết quả | Ghi chú | Bug Issue # |
|---|------|---------|---------|-------------|
| **Bước 1 — Approve TuneToken** | | | | |
| 1.1 | Chuyển MetaMask sang `Account #1 (Listener)` | ⬜ Pass / ⬜ Fail | | |
| 1.2 | Mở TipModal cho track vừa upload | ⬜ Pass / ⬜ Fail | | |
| 1.3 | Nhập số lượng: `10 TTK` | ⬜ Pass / ⬜ Fail | | |
| 1.4 | MetaMask hiện popup `approve()` → Ký | ⬜ Pass / ⬜ Fail | | |
| 1.5 | `allowance(listener, contract) == 10 TTK` | ⬜ Pass / ⬜ Fail | | |
| **Bước 2 — Gọi tip()** | | | | |
| 2.1 | Sau approve, tự động/thủ công gọi `tip()` | ⬜ Pass / ⬜ Fail | | |
| 2.2 | MetaMask hiện popup `tip()` → Ký | ⬜ Pass / ⬜ Fail | | |
| 2.3 | `escrowBalance[trackId]` tăng đúng 10 TTK | ⬜ Pass / ⬜ Fail | | |
| 2.4 | `escrowTimestamp[trackId]` được ghi đúng | ⬜ Pass / ⬜ Fail | Timestamp: | |
| 2.5 | `TxStatus.tsx` hiển thị `"Tip thành công! 🎵"` | ⬜ Pass / ⬜ Fail | | |
| **Bước 3 — Kiểm tra withdrawTips()** | | | | |
| 3.1 | Chuyển sang `Account #0 (Artist)` | ⬜ Pass / ⬜ Fail | | |
| 3.2 | Thử rút ngay → revert với message BR-07 | ⬜ Pass / ⬜ Fail | | |
| 3.3 | Giả lập 24h: `hardhat_increaseTime(86401)` | ⬜ Pass / ⬜ Fail | | |
| 3.4 | Gọi `withdrawTips()` thành công | ⬜ Pass / ⬜ Fail | | |
| 3.5 | `escrowBalance[trackId]` về `0` | ⬜ Pass / ⬜ Fail | | |
| 3.6 | Balance ví artist tăng 10 TTK | ⬜ Pass / ⬜ Fail | | |

#### Script giả lập thời gian (Hardhat RPC):
```javascript
// Chạy trong Hardhat console hoặc test script
await ethers.provider.send("hardhat_increaseTime", [86401]); // +24h1s
await ethers.provider.send("evm_mine", []);
```

---

## 🐛 Danh sách Bug phát sinh

| Bug # | Bước phát hiện | Mô tả ngắn | Assignee | GitHub Issue | Trạng thái |
|-------|----------------|------------|---------|--------------|-----------|
| BUG-001 | | | | | ⬜ Open / ⬜ Fixed |
| BUG-002 | | | | | ⬜ Open / ⬜ Fixed |

---

## 📎 Template tạo GitHub Issue khi phát sinh bug

Khi phát hiện lỗi, tạo GitHub Issue với template `.github/ISSUE_TEMPLATE/bug_report.md`:

```
Title: [BUG] UC-02 - <mô tả ngắn gọn lỗi>
Labels: bug, integration, P1
Assignees:
  - M1 (nếu lỗi smart contract / on-chain)
  - M2 (nếu lỗi UI / frontend)
  - M3 (nếu lỗi IPFS / backend)
  - M4 (nếu lỗi tích hợp / script)
```

---

## 📊 Tổng kết phiên test

| Chỉ số | Giá trị |
|--------|---------|
| Tổng bước kiểm tra | 24 |
| Số bước Pass | `/24` |
| Số bước Fail | `/24` |
| Số Bug tạo Issue | |
| Trạng thái tổng thể | ⬜ PASS ⬜ FAIL ⬜ BLOCKED |

### Nhận xét chung:
```
<Điền nhận xét, ghi chú, điểm cần cải thiện sau phiên test>
```

---

*Log này được cập nhật sau mỗi phiên tích hợp. Lưu trữ theo ngày.*
