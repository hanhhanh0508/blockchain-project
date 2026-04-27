// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TuneToken.sol";

/**
 * @title TuneChain
 * @author Mem 1 - Hạnh
 * @notice Hợp đồng chính: upload nhạc, tip, escrow, report vi phạm
 * @dev Skeleton tuần 1 — struct, mapping, events. Logic bổ sung tuần 2.
 */
contract TuneChain is ReentrancyGuard, Ownable {

    // ─── Token ───────────────────────────────────────────────────
    /// @notice Địa chỉ TuneToken (TCT) dùng để tip
    TuneToken public immutable tuneToken;

    // ─── Structs ─────────────────────────────────────────────────

    /**
     * @notice Thông tin một bài hát được upload lên chuỗi
     * @param trackId   ID duy nhất (tăng dần)
     * @param creator   Địa chỉ ví nhạc sĩ
     * @param ipfsHash  CID trỏ đến file nhạc trên IPFS/Pinata
     * @param title     Tên bài hát
     * @param totalTips Tổng TCT đã được tip
     * @param isActive  Bài hát còn hiệu lực không
     * @param createdAt Timestamp lúc upload
     */
    struct Track {
        uint256 trackId;
        address creator;
        string  ipfsHash;
        string  title;
        uint256 totalTips;
        bool    isActive;
        uint256 createdAt;
    }

    /**
     * @notice Thông tin một lần tip
     * @param tipper    Địa chỉ người tip
     * @param trackId   ID bài hát được tip
     * @param amount    Số TCT tip
     * @param timestamp Thời điểm tip
     */
    struct TipRecord {
        address tipper;
        uint256 trackId;
        uint256 amount;
        uint256 timestamp;
    }

    /**
     * @notice Báo cáo vi phạm bản quyền
     * @param reportId  ID báo cáo (tăng dần)
     * @param reporter  Địa chỉ người báo cáo
     * @param trackId   ID bài hát bị tố cáo
     * @param reason    Lý do vi phạm
     * @param resolved  Đã xử lý chưa
     * @param createdAt Timestamp lúc báo cáo
     */
    struct Report {
        uint256 reportId;
        address reporter;
        uint256 trackId;
        string  reason;
        bool    resolved;
        uint256 createdAt;
    }

    // ─── Mappings ─────────────────────────────────────────────────
    /// @notice trackId → Track
    mapping(uint256 => Track) public tracks;

    /// @notice tipId → TipRecord
    mapping(uint256 => TipRecord) public tipRecords;

    /// @notice reportId → Report
    mapping(uint256 => Report) public reports;

    /// @notice creator address → danh sách trackId
    mapping(address => uint256[]) public creatorTracks;

    /// @notice trackId → số lần bị report
    mapping(uint256 => uint256) public reportCount;

    // ─── Counters ─────────────────────────────────────────────────
    uint256 public nextTrackId;
    uint256 public nextTipId;
    uint256 public nextReportId;

    // ─── Events ───────────────────────────────────────────────────

    /// @notice Upload bài hát mới
    event TrackUploaded(
        uint256 indexed trackId,
        address indexed creator,
        string  ipfsHash,
        string  title
    );

    /// @notice Tip thành công
    event TrackTipped(
        uint256 indexed tipId,
        uint256 indexed trackId,
        address indexed tipper,
        uint256 amount
    );

    /// @notice Creator rút tip
    event TipWithdrawn(address indexed creator, uint256 amount);

    /// @notice Báo cáo vi phạm được gửi
    event TrackReported(
        uint256 indexed reportId,
        address indexed reporter,
        uint256 indexed trackId
    );

    /// @notice Admin xử lý báo cáo
    event ReportResolved(uint256 indexed reportId, bool removed);

    /// @notice Bài hát bị gỡ
    event TrackDeactivated(uint256 indexed trackId);

    // ─── Constructor ──────────────────────────────────────────────
    /// @param _tuneToken Địa chỉ contract TuneToken đã deploy
    constructor(address _tuneToken) Ownable(msg.sender) {
        require(_tuneToken != address(0), "TuneChain: zero token address");
        tuneToken = TuneToken(_tuneToken);
    }

    // ─── Placeholder functions (logic tuần 2) ────────────────────

    /// @notice Upload bài hát mới
    function uploadTrack(string calldata /*ipfsHash*/, string calldata /*title*/) external {
        revert("TuneChain: not implemented yet");
    }

    /// @notice Tip TCT cho một bài hát
    function tipTrack(uint256 /*trackId*/, uint256 /*amount*/) external nonReentrant {
        revert("TuneChain: not implemented yet");
    }

    /// @notice Creator rút tip
    function withdrawTips() external nonReentrant {
        revert("TuneChain: not implemented yet");
    }

    /// @notice Báo cáo vi phạm
    function reportTrack(uint256 /*trackId*/, string calldata /*reason*/) external {
        revert("TuneChain: not implemented yet");
    }

    /// @notice Admin xử lý báo cáo
    function resolveReport(uint256 /*reportId*/, bool /*removeTrack*/) external onlyOwner {
        revert("TuneChain: not implemented yet");
    }
}