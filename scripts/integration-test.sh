#!/usr/bin/env bash
# ============================================================
# scripts/integration-test.sh
# TuneChain — Script tự động hoá tích hợp Hardhat + Frontend
# Người thực hiện: M4 — Tích hợp + Docs
# Phiên bản: 1.0.0
# Ngày tạo: 2026-05-16
# ============================================================
#
# Mục đích:
#   1. Khởi động Hardhat node local (cổng 8545)
#   2. Deploy contract TuneChain lên local network
#   3. Ghi địa chỉ contract vào frontend/.env
#   4. Copy ABI file để Frontend sử dụng
#   5. In ra màn hình thông tin tài khoản test
#
# Cách dùng:
#   chmod +x scripts/integration-test.sh
#   ./scripts/integration-test.sh
# ============================================================

set -e  # Dừng script ngay nếu có lệnh nào thất bại

# ── Màu sắc terminal ─────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Đường dẫn project ────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$PROJECT_ROOT/Frontend"
FRONTEND_ENV="$FRONTEND_DIR/.env"
ABI_SRC="$PROJECT_ROOT/artifacts/contracts/TuneChain.sol/TuneChain.json"
ABI_DEST="$FRONTEND_DIR/src/abi/TuneChain.json"

# ── Cấu hình mạng ────────────────────────────────────────────
HARDHAT_PORT=8545
HARDHAT_CHAIN_ID=31337
RPC_URL="http://127.0.0.1:$HARDHAT_PORT"

# ── Tài khoản test mặc định của Hardhat (private keys) ──────
# CẢNH BÁO: Chỉ dùng cho môi trường LOCAL. KHÔNG commit lên GitHub ở production!
ACCOUNT_0_PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
ACCOUNT_1_PRIVATE_KEY="0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
ACCOUNT_0_ADDRESS="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
ACCOUNT_1_ADDRESS="0x70997970C51812dc3A010C7d01b50e0d17dc79C8"

# ── Hàm in tiêu đề ───────────────────────────────────────────
print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}========================================${RESET}"
    echo -e "${BOLD}${BLUE}  TuneChain — Integration Test Script   ${RESET}"
    echo -e "${BOLD}${BLUE}========================================${RESET}"
    echo ""
}

# ── Hàm kiểm tra prerequisites ───────────────────────────────
check_prerequisites() {
    echo -e "${CYAN}[1/5] Kiểm tra môi trường...${RESET}"

    # Kiểm tra Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js chưa được cài đặt. Vui lòng cài đặt Node.js >= 18${RESET}"
        exit 1
    fi
    echo -e "${GREEN}  ✓ Node.js: $(node --version)${RESET}"

    # Kiểm tra npx
    if ! command -v npx &> /dev/null; then
        echo -e "${RED}❌ npx không tìm thấy. Chạy: npm install -g npx${RESET}"
        exit 1
    fi
    echo -e "${GREEN}  ✓ npx: OK${RESET}"

    # Kiểm tra thư mục Frontend tồn tại
    if [ ! -d "$FRONTEND_DIR" ]; then
        echo -e "${RED}❌ Không tìm thấy thư mục Frontend tại: $FRONTEND_DIR${RESET}"
        exit 1
    fi
    echo -e "${GREEN}  ✓ Thư mục Frontend: OK${RESET}"

    echo ""
}

# ── Bước 1: Dừng Hardhat node cũ nếu đang chạy ──────────────
stop_existing_node() {
    echo -e "${CYAN}[2/5] Dừng Hardhat node cũ (nếu có)...${RESET}"

    # Tìm và kill process đang dùng port 8545
    if lsof -Pi :$HARDHAT_PORT -sTCP:LISTEN -t &>/dev/null 2>&1; then
        echo -e "${YELLOW}  ⚠ Đang dừng process cũ trên port $HARDHAT_PORT...${RESET}"
        kill $(lsof -Pi :$HARDHAT_PORT -sTCP:LISTEN -t) 2>/dev/null || true
        sleep 2
        echo -e "${GREEN}  ✓ Đã dừng process cũ${RESET}"
    else
        echo -e "${GREEN}  ✓ Không có Hardhat node nào đang chạy${RESET}"
    fi

    echo ""
}

# ── Bước 2: Khởi động Hardhat node ───────────────────────────
start_hardhat_node() {
    echo -e "${CYAN}[3/5] Khởi động Hardhat local node...${RESET}"
    echo -e "${YELLOW}  → Chạy nền trên cổng $HARDHAT_PORT (chainId=$HARDHAT_CHAIN_ID)${RESET}"

    # Khởi động Hardhat node ở nền (background)
    cd "$PROJECT_ROOT"
    npx hardhat node --port $HARDHAT_PORT > /tmp/hardhat-node.log 2>&1 &
    HARDHAT_PID=$!

    echo -e "  → Hardhat PID: $HARDHAT_PID — Log: /tmp/hardhat-node.log"

    # Chờ node sẵn sàng (tối đa 30 giây)
    echo -e "${YELLOW}  → Đang chờ node khởi động...${RESET}"
    for i in $(seq 1 30); do
        if curl -s -X POST "$RPC_URL" \
            -H "Content-Type: application/json" \
            -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
            &>/dev/null; then
            echo -e "${GREEN}  ✓ Hardhat node đã sẵn sàng! (sau ${i}s)${RESET}"
            break
        fi
        if [ $i -eq 30 ]; then
            echo -e "${RED}❌ Hardhat node không khởi động được sau 30 giây${RESET}"
            echo -e "${YELLOW}  Xem log tại: /tmp/hardhat-node.log${RESET}"
            exit 1
        fi
        sleep 1
    done

    echo ""
}

# ── Bước 3: Deploy contract ───────────────────────────────────
deploy_contract() {
    echo -e "${CYAN}[4/5] Deploy TuneChain contract lên local network...${RESET}"
    cd "$PROJECT_ROOT"

    # Kiểm tra ignition module tồn tại
    if [ ! -f "ignition/modules/TuneChain.ts" ]; then
        echo -e "${YELLOW}  ⚠ Không tìm thấy ignition/modules/TuneChain.ts${RESET}"
        echo -e "${YELLOW}  → Thử deploy bằng scripts/deploy.ts...${RESET}"

        # Fallback: deploy bằng script thông thường
        DEPLOY_OUTPUT=$(npx hardhat run scripts/deploy.ts --network localhost 2>&1)
    else
        # Deploy bằng Hardhat Ignition
        DEPLOY_OUTPUT=$(npx hardhat ignition deploy ignition/modules/TuneChain.ts \
            --network localhost 2>&1)
    fi

    echo "$DEPLOY_OUTPUT"

    # Lấy địa chỉ contract từ output
    CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oE '0x[a-fA-F0-9]{40}' | head -1)

    if [ -z "$CONTRACT_ADDRESS" ]; then
        echo -e "${RED}❌ Không thể lấy địa chỉ contract từ output deploy${RESET}"
        echo -e "${YELLOW}  Output deploy:${RESET}"
        echo "$DEPLOY_OUTPUT"
        exit 1
    fi

    echo -e "${GREEN}  ✓ Contract đã deploy tại: $CONTRACT_ADDRESS${RESET}"
    echo ""
}

# ── Bước 4: Ghi địa chỉ vào frontend/.env ────────────────────
update_frontend_env() {
    echo -e "${CYAN}[5/5] Cập nhật Frontend .env...${RESET}"

    # Tạo file .env nếu chưa có
    touch "$FRONTEND_ENV"

    # Xoá dòng cũ nếu có
    if grep -q "VITE_CONTRACT_ADDRESS" "$FRONTEND_ENV"; then
        sed -i.bak '/VITE_CONTRACT_ADDRESS/d' "$FRONTEND_ENV"
    fi
    if grep -q "VITE_RPC_URL" "$FRONTEND_ENV"; then
        sed -i.bak '/VITE_RPC_URL/d' "$FRONTEND_ENV"
    fi
    if grep -q "VITE_CHAIN_ID" "$FRONTEND_ENV"; then
        sed -i.bak '/VITE_CHAIN_ID/d' "$FRONTEND_ENV"
    fi

    # Ghi biến mới vào .env
    echo "VITE_CONTRACT_ADDRESS=$CONTRACT_ADDRESS" >> "$FRONTEND_ENV"
    echo "VITE_RPC_URL=$RPC_URL" >> "$FRONTEND_ENV"
    echo "VITE_CHAIN_ID=$HARDHAT_CHAIN_ID" >> "$FRONTEND_ENV"

    echo -e "${GREEN}  ✓ Đã ghi VITE_CONTRACT_ADDRESS=$CONTRACT_ADDRESS${RESET}"
    echo -e "${GREEN}  ✓ Đã ghi VITE_RPC_URL=$RPC_URL${RESET}"
    echo -e "${GREEN}  ✓ Đã ghi VITE_CHAIN_ID=$HARDHAT_CHAIN_ID${RESET}"
    echo ""
}

# ── Bước 5: Copy ABI ─────────────────────────────────────────
copy_abi() {
    echo -e "${CYAN}[+] Copy ABI file sang Frontend...${RESET}"

    # Đảm bảo thư mục abi tồn tại
    mkdir -p "$(dirname "$ABI_DEST")"

    if [ -f "$ABI_SRC" ]; then
        cp "$ABI_SRC" "$ABI_DEST"
        echo -e "${GREEN}  ✓ Đã copy ABI: $ABI_DEST${RESET}"
    elif [ -f "$PROJECT_ROOT/node_modules/.bin/hardhat" ] || command -v npx &>/dev/null; then
        # Dùng script copy-abi nếu có
        if [ -f "$SCRIPT_DIR/copy-abi.js" ]; then
            node "$SCRIPT_DIR/copy-abi.js"
            echo -e "${GREEN}  ✓ ABI đã được copy bằng copy-abi.js${RESET}"
        else
            echo -e "${YELLOW}  ⚠ Không tìm thấy ABI source. Compile contract trước:${RESET}"
            echo -e "${YELLOW}    npx hardhat compile${RESET}"
        fi
    fi

    echo ""
}

# ── In thông tin tóm tắt ──────────────────────────────────────
print_summary() {
    echo -e "${BOLD}${GREEN}========================================${RESET}"
    echo -e "${BOLD}${GREEN}  ✅ Tích hợp hoàn tất!                 ${RESET}"
    echo -e "${BOLD}${GREEN}========================================${RESET}"
    echo ""
    echo -e "${BOLD}📋 Thông tin contract:${RESET}"
    echo -e "  ${CYAN}Địa chỉ:${RESET}  $CONTRACT_ADDRESS"
    echo -e "  ${CYAN}Network:${RESET}  Hardhat Local"
    echo -e "  ${CYAN}ChainID:${RESET}  $HARDHAT_CHAIN_ID"
    echo -e "  ${CYAN}RPC URL:${RESET}  $RPC_URL"
    echo ""
    echo -e "${BOLD}🔑 Tài khoản test (chỉ dùng cho LOCAL):${RESET}"
    echo -e "  ${YELLOW}Account #0 (Artist — Admin):${RESET}"
    echo -e "    Address:     $ACCOUNT_0_ADDRESS"
    echo -e "    Private Key: $ACCOUNT_0_PRIVATE_KEY"
    echo ""
    echo -e "  ${YELLOW}Account #1 (Listener):${RESET}"
    echo -e "    Address:     $ACCOUNT_1_ADDRESS"
    echo -e "    Private Key: $ACCOUNT_1_PRIVATE_KEY"
    echo ""
    echo -e "${BOLD}📌 Bước tiếp theo:${RESET}"
    echo -e "  1. Import private key vào MetaMask"
    echo -e "  2. Thêm network Hardhat Local (xem docs/integration-checklist.md)"
    echo -e "  3. Chạy Frontend: cd Frontend && npm run dev"
    echo -e "  4. Mở trình duyệt tại http://localhost:5173"
    echo ""
    echo -e "${BOLD}📝 Log Hardhat node:${RESET} /tmp/hardhat-node.log"
    echo -e "${BOLD}📄 .env Frontend:${RESET}    $FRONTEND_ENV"
    echo ""
    echo -e "${YELLOW}⚠ Để dừng Hardhat node: kill $HARDHAT_PID${RESET}"
    echo ""
}

# ── Main flow ─────────────────────────────────────────────────
main() {
    print_header
    check_prerequisites
    stop_existing_node
    start_hardhat_node
    deploy_contract
    update_frontend_env
    copy_abi
    print_summary
}

# Chạy script
main "$@"
