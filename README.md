# AVA-TIX: Next-Gen Event Ticketing Protocol on Avalanche

Dự án tham dự cuộc thi **UniHack Avalanche 2026** (Team1 Vietnam).  
Hạn nộp bài chính thức: **05:59 sáng ngày 25/11/2026 (GMT+7)**.

---

## 📁 Cấu Trúc Thư Mục
* `index.html` / `avatix_demo.html`: Ứng dụng Web Demo tương tác hoàn chỉnh. Chỉ cần click đúp mở trực tiếp trên mọi trình duyệt (Chrome, Safari, Edge, Firefox) mà không cần cài đặt Node.js hay web server!
* `contracts/`:
  * `AvaTicket.sol`: Hợp đồng vé NFT chuẩn Avalanche C-Chain có mã QR động TOTP.
  * `TicketMarketplace.sol`: Hợp đồng Atomic Swap sang nhượng vé khóa giá trần ($\le$ giá gốc).
* `docs/`:
  * `AVATIX_PROJECT_BLUEPRINT.md`: Kế hoạch hành động 14 ngày, kiến trúc kỹ thuật và kịch bản live demo 3 phút.
  * `STRATEGY_PIVOT_ANALYSIS.md`: Bản phân tích chiến lược kinh tế và bài học loại bỏ các lỗ hổng Web2.

---

## 🚀 Hướng Dẫn Sử Dụng Nhanh

### 1. Trải nghiệm Demo App
* Mở file `index.html` trong trình duyệt.
* Bạn có thể chuyển đổi linh hoạt 4 vai trò ở thanh Header:
  * **Khách Hàng A:** Săn vé mở bán, mở Dynamic QR xoay mỗi 15s, hoặc bấm pass vé lên sàn.
  * **Khách Hàng B:** Nạp tiền ví thông minh, mua lại vé trên sàn bằng cơ chế Atomic Swap (0.8s).
  * **Bảo Vệ Cổng:** Quét thử vé xịn (duyệt), quét ảnh chụp màn hình cũ (từ chối), quét vé trùng (chặn).
  * **Explorer:** Xem sổ cái giao dịch Avalanche Fuji thời gian thực.

### 2. Triển khai Smart Contract lên Avalanche Fuji Testnet
1. Mở [Remix Ethereum IDE](https://remix.ethereum.org/).
2. Copy 2 file trong thư mục `contracts/` vào Remix.
3. Chọn mạng **Injected Provider - MetaMask** (chọn mạng Avalanche Fuji Testnet - Chain ID: `43113`).
4. Lấy faucet AVAX testnet miễn phí tại [faucet.avax.network](https://faucet.avax.network/).
5. Deploy `AvaTicket.sol`, sau đó deploy `TicketMarketplace.sol` với địa chỉ contract `AvaTicket`.
6. Gọi hàm `setMarketplace()` trên `AvaTicket` trỏ về địa chỉ của `TicketMarketplace`.

---

## 🎯 Giá Trị Cốt Lõi Dự Án
1. **Chống 100% Lừa Đảo:** Mã QR động đổi sau 15 giây, ảnh chụp màn hình bị vô hiệu hóa.
2. **Chống Phe Vé Chợ Đen:** Khóa giá bán lại tối đa bằng giá gốc trên Smart Contract.
3. **Săn Vé 1-Chạm:** Nạp trước số dư vào ví thông minh, không lo sập cổng ngân hàng VNPAY/Napas.
4. **Tốc độ Sub-second:** Hoàn tất giao dịch và soát vé cổng chỉ mất 0.8 giây trên Avalanche.
