# ✅ TuneChain — Checklist Tích hợp Môi trường

**Dự án:** TuneChain  
**Người thực hiện:** M4  
**Mục đích:** Kiểm tra thủ công sau khi chạy `scripts/integration-test.sh`

---

## Điều kiện tiên quyết

Chạy script tự động trước khi thực hiện checklist này:

```bash
chmod +x scripts/integration-test.sh
./scripts/integration-test.sh
```

Script sẽ:
- Khởi động Hardhat node trên cổng 8545
- Deploy TuneChain contract lên local
- Ghi địa chỉ contract vào `Frontend/.env`
- Copy ABI vào `Frontend/src/abi/`

---

## 🦊 Phần 1 — Cấu hình MetaMask

### 1.1 Import tài khoản Artist (Account #0)

- [ ] Mở MetaMask → Click vào biểu tượng tài khoản → **Import Account**
- [ ] Chọn loại: **Private Key**
- [ ] Dán private key của Account #0:
  ```
  0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
  ```
- [ ] Đặt tên tài khoản: `TuneChain Artist (Local)`
- [ ] Xác nhận địa chỉ hiển thị: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`

### 1.2 Import tài khoản Listener (Account #1)

- [ ] Import Account với private key của Account #1:
  ```
  0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
  ```
- [ ] Đặt tên tài khoản: `TuneChain Listener (Local)`
- [ ] Xác nhận địa chỉ hiển thị: `0x70997970C51812dc3A010C7d01b50e0d17dc79C8`

---

## 🌐 Phần 2 — Thêm mạng Hardhat Local vào MetaMask

- [ ] Mở MetaMask → **Settings** → **Networks** → **Add Network**
- [ ] Điền thông tin mạng:

| Trường | Giá trị |
|--------|---------|
| **Network Name** | `Hardhat Local` |
| **New RPC URL** | `http://127.0.0.1:8545` |
| **Chain ID** | `31337` |
| **Currency Symbol** | `ETH` |
| **Block Explorer URL** | *(để trống)* |

- [ ] Nhấn **Save**
- [ ] Chuyển sang mạng `Hardhat Local` trong MetaMask
- [ ] Xác nhận số dư Account #0 hiển thị ≈ `10000 ETH` (số dư mặc định của Hardhat)

---

## ⚙️ Phần 3 — Kiểm tra Frontend `.env`

- [ ] Mở file `Frontend/.env` và kiểm tra có 3 biến sau:

```env
VITE_CONTRACT_ADDRESS=0x<địa_chỉ_contract_vừa_deploy>
VITE_RPC_URL=http://127.0.0.1:8545
VITE_CHAIN_ID=31337
```

- [ ] Đảm bảo `VITE_CONTRACT_ADDRESS` **khớp** với địa chỉ được in ra trong terminal khi chạy script
- [ ] Không có khoảng trắng hay ký tự lạ trong file `.env`

---

## 🚀 Phần 4 — Khởi động Frontend

- [ ] Mở terminal mới, vào thư mục Frontend:
  ```bash
  cd Frontend
  npm install   # nếu lần đầu hoặc thêm package mới
  npm run dev
  ```
- [ ] Không có lỗi build (không có `ERROR` đỏ trong terminal)
- [ ] Trình duyệt mở được tại `http://localhost:5173`
- [ ] Trang chủ hiển thị đúng (không bị lỗi layout hoặc blank)

---

## 🔌 Phần 5 — Kiểm tra kết nối MetaMask ↔ Frontend

- [ ] Click **"Connect Wallet"** trên frontend
- [ ] MetaMask hiện popup yêu cầu kết nối → Chấp nhận
- [ ] Địa chỉ ví hiển thị đúng trên header
- [ ] Network hiển thị là `Hardhat Local` hoặc `Chain 31337`
- [ ] Kiểm tra console trình duyệt (F12 → Console) — không có lỗi đỏ liên quan đến contract/ABI

---

## 📄 Phần 6 — Kiểm tra ABI đã được copy

- [ ] File `Frontend/src/abi/TuneChain.json` tồn tại
- [ ] File có nội dung hợp lệ (không rỗng, là JSON hợp lệ)
- [ ] ABI chứa các function: `uploadTrack`, `tipTrack`, `withdrawTips`, `getAllTracks`
  ```bash
  cat Frontend/src/abi/TuneChain.json | python -m json.tool | grep '"name"' | head -20
  ```

---

## 🔍 Phần 7 — Smoke Test nhanh

Chỉ cần làm sau khi tất cả bước trên đã pass:

- [ ] Mở `http://localhost:5173/upload`
- [ ] Form upload hiển thị đúng
- [ ] Không có lỗi `Contract not found` hay `ABI error` trong console
- [ ] Mở `http://localhost:5173/explore` (hoặc trang danh sách bài hát)
- [ ] Danh sách rỗng (do chưa upload bài nào) — **không bị crash**

---

## 📝 Ghi chú kết quả

| Phần | Kết quả | Lỗi phát sinh | Ghi chú |
|------|---------|----------------|---------|
| MetaMask Account #0 | ⬜ Pass / ⬜ Fail | | |
| MetaMask Account #1 | ⬜ Pass / ⬜ Fail | | |
| Network Hardhat Local | ⬜ Pass / ⬜ Fail | | |
| Frontend .env | ⬜ Pass / ⬜ Fail | | |
| npm run dev | ⬜ Pass / ⬜ Fail | | |
| Connect Wallet | ⬜ Pass / ⬜ Fail | | |
| ABI file | ⬜ Pass / ⬜ Fail | | |
| Smoke Test | ⬜ Pass / ⬜ Fail | | |

---

> ⚠️ **Lưu ý:** Private key trong checklist này chỉ dùng cho môi trường **Hardhat Local**.  
> **KHÔNG** import các private key này vào ví dùng cho mainnet hoặc testnet thật.

---

*Checklist này được duy trì bởi M4. Cập nhật khi có thay đổi cấu hình mạng hoặc deploy script.*
