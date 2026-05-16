# 📋 TuneChain — Tài liệu Test Cases

**Dự án:** TuneChain — Nền tảng âm nhạc phi tập trung  
**Người soạn:** M4 — Tích hợp + Docs  
**Phiên bản:** 1.0.0  
**Ngày tạo:** 2026-05-16  
**Stack:** Solidity · Hardhat · React · Ethers.js · Pinata/IPFS  

---

## Mục lục

- [UC-02 — Upload Track](#uc-02--upload-track)
- [UC-04 — Tipping](#uc-04--tipping)

---

## Business Rules tham chiếu

| ID | Quy tắc |
|----|---------|
| BR-01 | Phí upload tăng 50% mỗi lần vi phạm bản quyền trước đó |
| BR-04 | Giới hạn 1 lượt view/IP/24 giờ |
| BR-05 | Không được rút tiền (withdraw) nếu bài hát đang bị ẩn (`isActive = false`) |
| BR-07 | Phải chờ đủ 24 giờ sau lần tip cuối cùng mới được gọi `withdrawTips()` |

---

## UC-02 — Upload Track

> Upload bài hát lên IPFS và ghi metadata lên blockchain thông qua hàm `uploadTrack()`.

---

### TC UC02-TC01 — Upload thành công (Happy Path)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC02-TC01 |
| **Mô tả** | Artist upload bài hát với đầy đủ thông tin và số dư Token hợp lệ — giao dịch thành công |
| **Điều kiện tiên quyết** | • Artist đã connect MetaMask và chọn tài khoản `account[0]`<br>• Tài khoản có ≥ `uploadFee` TCT (Token phí upload)<br>• File nhạc `.mp3` hợp lệ, kích thước < 10MB<br>• Ảnh bìa `.jpg/.png` hợp lệ |
| **Bước thực hiện** | 1. Mở trang `/upload` trên Frontend<br>2. Nhập tên bài hát: `"Mùa Hạ Năm Ấy"`<br>3. Chọn file nhạc: `summer_test.mp3` (3.2MB)<br>4. Chọn ảnh bìa: `cover.jpg`<br>5. Nhấn nút **"Upload"**<br>6. `ipfsService.uploadTrackFiles()` được gọi — nhận CID từ Pinata<br>7. MetaMask hiện popup xác nhận giao dịch `uploadTrack()`<br>8. Nhấn **"Confirm"** trong MetaMask |
| **Dữ liệu đầu vào** | `title = "Mùa Hạ Năm Ấy"`, `file = summer_test.mp3`, `uploadFee = 10 TCT` |
| **Kết quả mong đợi** | • IPFS trả về CID hợp lệ bắt đầu bằng `"Qm"` hoặc `"bafy"`<br>• Tx hash xuất hiện trong `TxStatus.tsx`<br>• Event `TrackUploaded(trackId, creator, ipfsHash, title)` được emit<br>• `tracks[trackId].isActive == true`<br>• `tracks[trackId].ipfsHash == CID` đúng với giá trị Pinata trả về<br>• `getAllTracks()` trả về bài hát mới trong danh sách<br>• UI điều hướng sang trang chi tiết track |
| **Phân loại** | ✅ Happy Path |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-02 |

---

### TC UC02-TC02 — Không đủ số dư Token (Exception E1)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC02-TC02 |
| **Mô tả** | Artist không đủ TCT để trả phí upload — contract revert giao dịch |
| **Điều kiện tiên quyết** | • Artist đã connect MetaMask<br>• Tài khoản có `0 TCT` (số dư Token bằng 0) |
| **Bước thực hiện** | 1. Mở trang `/upload`<br>2. Nhập tên bài hát: `"Bài Thử Lỗi"`<br>3. Chọn file nhạc và ảnh bìa hợp lệ<br>4. Nhấn **"Upload"**<br>5. Upload IPFS thành công → Frontend gọi `uploadTrack()` |
| **Dữ liệu đầu vào** | `title = "Bài Thử Lỗi"`, `balance = 0 TCT`, `uploadFee = 10 TCT` |
| **Kết quả mong đợi** | • Contract revert với message: `"TuneChain: insufficient token balance"` hoặc tương đương<br>• MetaMask hiển thị lỗi gas estimation failed<br>• UI hiện thông báo đỏ: `"Không đủ TCT để upload. Hiện tại cần X TCT."`<br>• Không có event `TrackUploaded` nào được emit<br>• Số lượng track trên chain không thay đổi |
| **Phân loại** | ❌ Exception Flow |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-02, BR-01 |

---

### TC UC02-TC03 — Người dùng từ chối ký giao dịch (Exception E2)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC02-TC03 |
| **Mô tả** | Artist xem popup MetaMask nhưng nhấn "Reject" thay vì "Confirm" |
| **Điều kiện tiên quyết** | • Artist đã connect MetaMask<br>• Tài khoản có đủ TCT<br>• File nhạc và ảnh bìa hợp lệ |
| **Bước thực hiện** | 1. Mở trang `/upload`, điền đầy đủ thông tin<br>2. Nhấn **"Upload"** → Upload IPFS thành công<br>3. MetaMask hiện popup giao dịch `uploadTrack()`<br>4. Nhấn **"Reject"** trong MetaMask |
| **Dữ liệu đầu vào** | `title = "Bài Bị Từ Chối"`, hành động: từ chối MetaMask |
| **Kết quả mong đợi** | • Frontend bắt được lỗi `user rejected transaction`<br>• UI hiển thị thông báo: `"Giao dịch đã bị hủy bởi người dùng"`<br>• Không có Tx Hash nào xuất hiện<br>• Không có event `TrackUploaded` nào được emit<br>• Trang vẫn ở trạng thái form, cho phép thử lại |
| **Phân loại** | ❌ Exception Flow |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-02 |

---

### TC UC02-TC04 — Tác giả có vi phạm trước — phí tăng 50% (Exception E3)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC02-TC04 |
| **Mô tả** | Tài khoản artist có 1 vi phạm bản quyền từ trước → phí upload tự động tăng 50% theo BR-01 |
| **Điều kiện tiên quyết** | • Artist đã có 1 track bị report và xử lý vi phạm (`violationCount = 1`)<br>• Phí upload cơ bản `baseFee = 10 TCT`<br>• Tài khoản có ≥ 15 TCT |
| **Bước thực hiện** | 1. Mở trang `/upload`<br>2. Frontend gọi smart contract để lấy `currentFee` cho tài khoản này<br>3. UI hiển thị phí: `"Phí upload: 15 TCT (đã bao gồm +50% vi phạm)"`<br>4. Artist điền form và nhấn **"Upload"**<br>5. Xác nhận giao dịch trong MetaMask |
| **Dữ liệu đầu vào** | `title = "Bài Sau Vi Phạm"`, `violationCount = 1`, `baseFee = 10 TCT`, `expectedFee = 15 TCT` |
| **Kết quả mong đợi** | • UI hiển thị đúng phí 15 TCT trước khi upload<br>• `currentFee = baseFee * 150% = 15 TCT` được tính đúng<br>• Giao dịch thành công nếu đủ số dư<br>• Event `TrackUploaded` được emit bình thường<br>• Tiếp tục tăng thêm 50% nếu có vi phạm thứ 2 |
| **Phân loại** | ❌ Exception Flow |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-02, BR-01 |

---

### TC UC02-TC05 — File nhạc rỗng hoặc sai định dạng (Exception E4)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC02-TC05 |
| **Mô tả** | User chọn file không phải nhạc (`.txt`, `.exe`) hoặc file rỗng → Frontend ngăn chặn trước khi gọi contract |
| **Điều kiện tiên quyết** | • User đã connect MetaMask<br>• Form upload đang mở |
| **Bước thực hiện** | 1. Mở trang `/upload`<br>2. Nhập tên bài hát<br>3. Chọn file `malware.exe` hoặc `empty.mp3` (0 bytes)<br>4. Nhấn **"Upload"** |
| **Dữ liệu đầu vào** | `file = malware.exe` (sai định dạng) HOẶC `file = empty.mp3` (0 bytes) |
| **Kết quả mong đợi** | • Frontend validation chặn trước khi gọi `ipfsService`<br>• Không gọi Pinata API<br>• Không gọi contract<br>• UI hiển thị lỗi đỏ inline: `"Định dạng file không hợp lệ. Chỉ cho phép .mp3, .wav, .flac"`<br>• Hoặc: `"File âm thanh không được rỗng"` |
| **Phân loại** | ❌ Exception Flow |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-02 |

---

### TC UC02-TC06 — Upload thất bại do Pinata/IPFS lỗi

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC02-TC06 |
| **Mô tả** | Pinata API trả về lỗi khi upload (timeout, API key hết hạn, vượt quota) → UI thông báo và không gọi contract |
| **Điều kiện tiên quyết** | • Artist có đủ điều kiện để upload<br>• Pinata API key không hợp lệ / đã hết quota |
| **Bước thực hiện** | 1. Điền form upload đầy đủ<br>2. Nhấn **"Upload"**<br>3. `ipfsService.uploadTrackFiles()` được gọi<br>4. Pinata trả về HTTP 401 hoặc timeout |
| **Dữ liệu đầu vào** | `PINATA_API_KEY = "invalid_key"` |
| **Kết quả mong đợi** | • Lỗi được bắt tại `ipfsService`<br>• Không gọi `uploadTrack()` trên contract<br>• UI hiển thị: `"Upload lên IPFS thất bại. Vui lòng thử lại sau."`<br>• Console log in ra chi tiết lỗi để debug |
| **Phân loại** | ❌ Exception Flow |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-02 |

---

## UC-04 — Tipping

> Listener tip TCT cho một bài hát thông qua luồng 2 bước: `approve()` → `tip()`.  
> Artist có thể rút qua `withdrawTips()` sau 24 giờ kể từ lần tip cuối.

---

### TC UC04-TC01 — Tip thành công (Happy Path — 2 bước)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC04-TC01 |
| **Mô tả** | Listener approve Token rồi tip thành công cho bài hát — `escrowBalance` tăng đúng |
| **Điều kiện tiên quyết** | • Listener dùng `account[1]` có ≥ 10 TCT<br>• Bài `trackId = 1` đang `isActive = true`<br>• `TipModal` đang mở |
| **Bước thực hiện** | 1. Listener mở trang chi tiết track<br>2. Nhấn **"Tip"** → `TipModal` xuất hiện<br>3. Nhập số lượng: `10 TTK`<br>4. Nhấn **"Xác nhận"**<br>5. MetaMask hiện popup `approve()` → nhấn Confirm<br>6. Sau khi approve xong, `useTip` tự động gọi `tip()`<br>7. MetaMask hiện popup `tip()` → nhấn Confirm |
| **Dữ liệu đầu vào** | `trackId = 1`, `amount = 10 TTK`, `listener = account[1]` |
| **Kết quả mong đợi** | • Bước approve: `allowance(listener, contract) == 10 TTK`<br>• Bước tip: `escrowBalance[trackId]` tăng 10 TTK<br>• `escrowTimestamp[trackId]` được ghi lại timestamp hiện tại<br>• Event `TrackTipped(tipId, trackId, tipper, 10)` được emit<br>• `TxStatus.tsx` hiển thị: `"Tip thành công! 🎵"`<br>• `TipRecord` mới được lưu trên chain |
| **Phân loại** | ✅ Happy Path |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-04, BR-07 |

---

### TC UC04-TC02 — Từ chối approve() — tip() không được gọi (Exception E1)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC04-TC02 |
| **Mô tả** | Listener nhấn Reject khi MetaMask yêu cầu approve → bước tip() không được thực thi |
| **Điều kiện tiên quyết** | • Listener có đủ TCT<br>• Bài hát đang active |
| **Bước thực hiện** | 1. Mở `TipModal`, nhập `10 TTK`<br>2. Nhấn **"Xác nhận"**<br>3. MetaMask hiện popup `approve()` → Nhấn **Reject** |
| **Dữ liệu đầu vào** | `trackId = 1`, `amount = 10 TTK`, hành động: từ chối approve |
| **Kết quả mong đợi** | • Lỗi `user rejected transaction` được bắt trong `useTip`<br>• Hàm `tip()` **không được gọi**<br>• UI hiển thị: `"Phê duyệt Token bị hủy. Tip không thể thực hiện."`<br>• `escrowBalance` không thay đổi<br>• Không có event nào emit |
| **Phân loại** | ❌ Exception Flow |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-04 |

---

### TC UC04-TC03 — Không đủ Token sau approve (Exception E2)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC04-TC03 |
| **Mô tả** | Listener có 5 TCT nhưng cố tip 10 TTK — sau khi approve thì tip() bị revert |
| **Điều kiện tiên quyết** | • Listener có chính xác `5 TCT`<br>• Đã approve `10 TTK` cho contract (allowance > balance) |
| **Bước thực hiện** | 1. Listener nhập `10 TTK` vào TipModal<br>2. Approve thành công (allowance = 10 TTK)<br>3. `useTip` gọi `tip(trackId, 10)`<br>4. Contract kiểm tra `transferFrom()` → balance không đủ |
| **Dữ liệu đầu vào** | `amount = 10 TTK`, `balance = 5 TCT`, `allowance = 10 TTK` |
| **Kết quả mong đợi** | • `transferFrom()` revert với lỗi ERC20 insufficient balance<br>• UI hiển thị: `"Không đủ TCT trong ví. Số dư hiện tại: 5 TCT"`<br>• `escrowBalance` không thay đổi<br>• Allowance đã bị trừ cho lần approve (cần approve lại nếu muốn thử) |
| **Phân loại** | ❌ Exception Flow |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-04 |

---

### TC UC04-TC04 — Tip bài bị ẩn (Exception E3)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC04-TC04 |
| **Mô tả** | Listener cố tip một bài hát đã bị admin gỡ (`isActive = false`) — contract revert |
| **Điều kiện tiên quyết** | • Bài `trackId = 2` đã bị admin gỡ: `tracks[2].isActive = false`<br>• Listener có đủ TCT và đã approve |
| **Bước thực hiện** | 1. Admin gọi `resolveReport(reportId, removeTrack=true)` → `isActive = false`<br>2. Listener cố tình gọi `tip(2, 10)` trực tiếp qua script hoặc UI cũ |
| **Dữ liệu đầu vào** | `trackId = 2 (isActive=false)`, `amount = 10 TTK` |
| **Kết quả mong đợi** | • Contract revert với message: `"TuneChain: track is not active"` hoặc tương đương<br>• UI (nếu kiểm tra trước) hiển thị: `"Bài hát này đã bị gỡ khỏi nền tảng"`<br>• Không có event `TrackTipped` nào |
| **Phân loại** | ❌ Exception Flow |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-04, BR-05 |

---

### TC UC04-TC05 — Rút tiền khi chưa đủ 24h cooldown (Exception E4)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC04-TC05 |
| **Mô tả** | Artist cố gọi `withdrawTips()` ngay sau khi nhận tip — revert vì chưa đủ 24h (BR-07) |
| **Điều kiện tiên quyết** | • Đã có ít nhất 1 lần tip thành công trong vòng 24h gần nhất<br>• `escrowBalance[creator] > 0`<br>• `block.timestamp - escrowTimestamp < 24 hours` |
| **Bước thực hiện** | 1. Listener tip 10 TTK vào lúc `T`<br>2. Artist ngay lập tức gọi `withdrawTips()` tại thời điểm `T + 1h`<br>3. Contract kiểm tra cooldown |
| **Dữ liệu đầu vào** | `escrowTimestamp = T`, `withdrawTime = T + 3600` (1 giờ sau) |
| **Kết quả mong đợi** | • Contract revert với message: `"TuneChain: cooldown 24h chua du"` hoặc `"BR-07: withdraw cooldown not met"`<br>• UI hiển thị: `"Chưa đủ 24 giờ kể từ lần tip cuối. Vui lòng thử lại sau."`<br>• Countdown timer hiển thị thời gian còn lại đến khi có thể rút<br>• `escrowBalance` không thay đổi |
| **Phân loại** | ❌ Exception Flow |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-04, BR-07 |

---

### TC UC04-TC06 — Rút tiền thành công sau 24h (Happy Path — withdraw)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC04-TC06 |
| **Mô tả** | Artist rút tip thành công sau khi đủ 24h từ lần tip cuối |
| **Điều kiện tiên quyết** | • `escrowBalance[creator] = 10 TTK`<br>• `block.timestamp - escrowTimestamp >= 86400` (24h)<br>• Bài hát vẫn `isActive = true`<br>• Test dùng `vm.warp(block.timestamp + 86401)` hoặc `hardhat_increaseTime` |
| **Bước thực hiện** | 1. (Test) Chạy `hardhat_increaseTime` thêm 86401 giây<br>2. Artist nhấn nút **"Rút tiền"** trong Dashboard<br>3. MetaMask hiện popup `withdrawTips()` → Confirm |
| **Dữ liệu đầu vào** | `timeAdvance = 86401s`, `escrowBalance = 10 TTK` |
| **Kết quả mong đợi** | • Giao dịch thành công<br>• Event `TipWithdrawn(creator, 10)` được emit<br>• `escrowBalance[creator]` về `0`<br>• `balance` của artist wallet tăng 10 TTK<br>• UI hiển thị: `"Rút tiền thành công! Nhận được 10 TTK"` |
| **Phân loại** | ✅ Happy Path |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-04, BR-07 |

---

### TC UC04-TC07 — Rút tiền khi bài bị ẩn (Exception E5)

| Trường | Nội dung |
|--------|----------|
| **TC-ID** | UC04-TC07 |
| **Mô tả** | Bài hát bị admin gỡ sau khi đã có escrow → Artist không được rút (BR-05) |
| **Điều kiện tiên quyết** | • Bài `trackId = 3` đã có `escrowBalance = 20 TTK`<br>• Admin sau đó gỡ bài → `isActive = false`<br>• Đã đủ 24h cooldown |
| **Bước thực hiện** | 1. Admin gọi `resolveReport(reportId, removeTrack=true)`<br>2. Advance time 24h với `vm.warp` hoặc `hardhat_increaseTime`<br>3. Artist gọi `withdrawTips()` |
| **Dữ liệu đầu vào** | `trackId = 3 (isActive=false)`, `escrowBalance = 20 TTK` |
| **Kết quả mong đợi** | • Contract revert với message: `"TuneChain: cannot withdraw — track hidden"` hoặc `"BR-05: track inactive"`<br>• `escrowBalance` giữ nguyên (tiền bị khoá)<br>• UI hiển thị: `"Không thể rút tiền. Bài hát đang bị đình chỉ bởi admin."`<br>• Người dùng được hướng dẫn liên hệ admin |
| **Phân loại** | ❌ Exception Flow |
| **Người thực hiện** | M4 |
| **Liên kết** | UC-04, BR-05 |

---

## Tóm tắt

| Use Case | Happy Path | Exception Flow | Tổng |
|----------|-----------|----------------|------|
| UC-02 Upload Track | 1 (TC01) | 5 (TC02–TC06) | **6 TC** |
| UC-04 Tipping | 2 (TC01, TC06) | 5 (TC02–TC05, TC07) | **7 TC** |
| **Tổng cộng** | **3** | **10** | **13 TC** |

---

*File này được duy trì bởi M4. Cập nhật khi có thay đổi Business Rules hoặc phát sinh test case mới.*
