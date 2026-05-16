---
name: Bug Report — Integration
about: Dùng khi phát hiện lỗi trong quá trình tích hợp Frontend + Contract
title: "[BUG] UC-0X - <mô tả ngắn>"
labels: bug, integration
assignees: ''
---

## 📌 Mô tả lỗi
<!-- Mô tả rõ lỗi xảy ra ở đâu, khi nào, trong luồng nào (UC-02 Upload hay UC-04 Tipping) -->


## 🔁 Bước tái hiện
1. 
2. 
3. 

## ✅ Kết quả mong đợi
<!-- Mô tả hành vi đúng / expected behavior -->


## ❌ Kết quả thực tế
<!-- Mô tả hành vi sai / actual behavior -->


## 📸 Log / Screenshot
<!-- Paste terminal log, console error, hoặc đính kèm screenshot -->

```
<Dán log lỗi vào đây>
```

## 🔖 Phân loại
<!-- Tick vào loại lỗi phù hợp để assign đúng thành viên -->

- [ ] Lỗi Smart Contract — on-chain logic, revert sai, event sai (assign **M1**)
- [ ] Lỗi Frontend/UI — hiển thị sai, state lỗi, UX không đúng (assign **M2**)
- [ ] Lỗi IPFS/Backend — upload Pinata thất bại, API lỗi (assign **M3**)
- [ ] Lỗi tích hợp khác — script, .env, ABI, network config (assign **M4**)

## 🌐 Môi trường

| Thông tin | Giá trị |
|-----------|---------|
| **Network** | Hardhat Local / Testnet (điền) |
| **Browser** | Chrome / Firefox (điền version) |
| **MetaMask version** | |
| **Contract address** | `0x...` |
| **Node.js version** | |
| **Hardhat version** | |

## 📎 Liên kết liên quan

- Test Case liên quan: `UC0X-TCxx`
- Business Rule: `BR-xx` (nếu có)
- PR / Commit liên quan: (nếu có)

## 🎯 Mức độ ưu tiên

- [ ] 🔴 P1 — Blocker (không thể tiếp tục tích hợp)
- [ ] 🟠 P2 — Critical (ảnh hưởng luồng chính)
- [ ] 🟡 P3 — Major (ảnh hưởng một phần chức năng)
- [ ] 🟢 P4 — Minor (lỗi nhỏ, có workaround)
