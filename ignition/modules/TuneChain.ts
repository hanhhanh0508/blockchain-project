/**
 * ignition/modules/TuneChain.ts
 * ─────────────────────────────────────────────────────────────
 * Module Hardhat Ignition để deploy TuneToken + TuneChain
 * lên Hardhat local network.
 *
 * Thứ tự deploy:
 *   1. TuneToken  — ERC20 không có constructor đặc biệt
 *   2. TuneChain  — nhận địa chỉ TuneToken + mảng 4 admin
 *
 * Người thực hiện: M4 — Tích hợp + Docs
 * ─────────────────────────────────────────────────────────────
 */

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

/**
 * 4 địa chỉ admin mặc định của Hardhat local (accounts 0–3).
 * Đây là các địa chỉ test tĩnh, luôn được tạo ra bởi Hardhat
 * từ cùng mnemonic mặc định → dùng được cho mọi môi trường local.
 *
 * CẢNH BÁO: Chỉ dùng cho môi trường LOCAL / TESTNET.
 *           Không dùng private key này ở mainnet.
 */
const DEFAULT_HARDHAT_ADMINS: string[] = [
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", // account[0] — Artist / deployer
    "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", // account[1] — Listener
    "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC", // account[2] — Admin M3
    "0x90F79bf6EB2c4f870365E785982E1f101E93b906", // account[3] — Admin M4
];

export default buildModule("TuneChainModule", (m) => {
    // ── Tham số có thể override khi deploy ────────────────────────
    // Dùng m.getParameter() để cho phép truyền vào từ CLI nếu cần.
    // Mặc định: dùng 4 địa chỉ Hardhat local ở trên.
    const admin0 = m.getParameter("admin0", DEFAULT_HARDHAT_ADMINS[0]);
    const admin1 = m.getParameter("admin1", DEFAULT_HARDHAT_ADMINS[1]);
    const admin2 = m.getParameter("admin2", DEFAULT_HARDHAT_ADMINS[2]);
    const admin3 = m.getParameter("admin3", DEFAULT_HARDHAT_ADMINS[3]);

    // ── Bước 1: Deploy TuneToken ──────────────────────────────────
    // TuneToken không có tham số constructor.
    // Sau khi deploy, deployer nhận 1,000,000 TCT ban đầu.
    const tuneToken = m.contract("TuneToken", []);

    // ── Bước 2: Deploy TuneChain ──────────────────────────────────
    // Constructor: (address _tuneToken, address[] memory _admins)
    // Truyền địa chỉ TuneToken và mảng 4 admin vào.
    const tuneChain = m.contract("TuneChain", [
        tuneToken,       // _tuneToken: địa chỉ TuneToken vừa deploy
        [admin0, admin1, admin2, admin3], // _admins: mảng 4 thành viên nhóm
    ]);

    // ── Trả về cả hai contract để có thể tham chiếu sau deploy ────
    return { tuneToken, tuneChain };
});
