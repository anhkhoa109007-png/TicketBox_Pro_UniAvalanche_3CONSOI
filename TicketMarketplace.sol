// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AvaTicket.sol";

/**
 * @title TicketMarketplace
 * @dev Sàn giao dịch sơ cấp và thứ cấp khóa giá trần (Capped Resale)
 * Tự động thực thi Atomic Swap: Tiền về ví người bán, vé sang ví người mua trong 1 transaction duy nhất.
 */
contract TicketMarketplace {
    AvaTicket public ticketContract;
    address payable public platformTreasury;
    address payable public organizerTreasury;

    uint256 public constant PLATFORM_FEE_BPS = 500;   // 5% phí sàn
    uint256 public constant ROYALTY_FEE_BPS = 500;    // 5% phí bản quyền Ban Tổ Chức

    struct ResaleListing {
        uint256 ticketId;
        address payable seller;
        uint256 resalePrice;
        bool active;
    }

    mapping(uint256 => ResaleListing) public resaleListings;

    event TicketListedForResale(uint256 indexed ticketId, address indexed seller, uint256 price);
    event AtomicSwapSuccess(uint256 indexed ticketId, address indexed buyer, address indexed seller, uint256 price);

    constructor(address _ticketContract, address payable _organizerTreasury) {
        ticketContract = AvaTicket(_ticketContract);
        platformTreasury = payable(msg.sender);
        organizerTreasury = _organizerTreasury;
    }

    // Mua vé mở bán sơ cấp (Primary Drop)
    function buyPrimaryTicket(uint256 eventId, string memory seat) external payable returns (uint256) {
        require(msg.value > 0, "So tien thanh toan phai lon hon 0");
        uint256 ticketId = ticketContract.mint(msg.sender, eventId, msg.value, seat);
        organizerTreasury.transfer(msg.value);
        return ticketId;
    }

    // Treo bán lại vé với GIÁ TRẦN <= GIÁ GỐC (Chống phe vé chợ đen)
    function listResaleTicket(uint256 ticketId, uint256 resalePrice) external {
        AvaTicket.TicketData memory t = ticketContract.getTicket(ticketId);
        require(t.owner == msg.sender, "Ban khong phai chu so huu chiec ve nay");
        require(!t.isCheckedIn, "Ve da check-in khong the sang nhuong");
        require(resalePrice <= t.originalPrice, "Chong phe ve: Gia ban lai khong duoc vuot qua gia goc!");

        resaleListings[ticketId] = ResaleListing({
            ticketId: ticketId,
            seller: payable(msg.sender),
            resalePrice: resalePrice,
            active: true
        });

        emit TicketListedForResale(ticketId, msg.sender, resalePrice);
    }

    // Hoán đổi nguyên tử trong 1 giây (Atomic Swap)
    function buyResaleTicketAtomic(uint256 ticketId) external payable {
        ResaleListing storage listing = resaleListings[ticketId];
        require(listing.active, "Ve khong con duoc rao ban");
        require(msg.value == listing.resalePrice, "So tien thanh toan khong chinh xac");
        require(msg.sender != listing.seller, "Khong the tu mua ve cua chinh minh");

        listing.active = false;

        // Tính toán phân bổ tiền
        uint256 platformFee = (msg.value * PLATFORM_FEE_BPS) / 10000;
        uint256 royaltyFee = (msg.value * ROYALTY_FEE_BPS) / 10000;
        uint256 sellerAmount = msg.value - platformFee - royaltyFee;

        // 1. Chuyển tiền người bán (90%)
        listing.seller.transfer(sellerAmount);
        // 2. Chuyển phí bản quyền Ban Tổ Chức (5%)
        organizerTreasury.transfer(royaltyFee);
        // 3. Chuyển phí nền tảng (5%)
        platformTreasury.transfer(platformFee);

        // 4. Chuyển quyền sở hữu vé sang người mua mới
        ticketContract.transferOwnership(ticketId, msg.sender);

        emit AtomicSwapSuccess(ticketId, msg.sender, listing.seller, msg.value);
    }
}
