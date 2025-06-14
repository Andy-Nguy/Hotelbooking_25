# Ứng Dụng Đặt Phòng Khách Sạn (Flutter Demo)

Đây là một ứng dụng di động demo được xây dựng bằng Flutter và Dart, mô phỏng quy trình đặt phòng khách sạn. Ứng dụng sử dụng SQLite làm cơ sở dữ liệu cục bộ để quản lý thông tin khách sạn, loại phòng, tài khoản người dùng và đặt chỗ.

## Mục Lục

*   [Tính Năng Chính](#tính-năng-chính)
*   [Công Nghệ Sử Dụng](#công-nghệ-sử-dụng)
*   [Ảnh Chụp Màn Hình](#ảnh-chụp-màn-hình)
*   [Cấu Trúc Dự Án](#cấu-trúc-dự-án-(gợi-ý))
*   [Hướng Dẫn Cài Đặt và Chạy](#hướng-dẫn-cài-đặt-và-chạy)
*   [Kế Hoạch Phát Triển (Tương Lai)](#kế-hoạch-phát-triển-(tương-lai))
*   [Đóng Góp](#đóng-góp)
*   [Tác Giả](#tác-giả)

## Tính Năng Chính

*   **Xác Thực Người Dùng (Cục bộ):**
    *   **Đăng Ký:** Cho phép người dùng mới tạo tài khoản với thông tin cá nhân (Họ tên, Email, Mật khẩu, Số điện thoại). Mật khẩu được lưu trữ dưới dạng hash.
    *   **Đăng Nhập:** Cho phép người dùng đã có tài khoản đăng nhập vào ứng dụng.
*   **Trang Chủ:**
    *   Hiển thị các khách sạn nổi bật (lấy từ CSDL SQLite).
    *   Carousel khám phá các điểm đến (hiện tại là dữ liệu tĩnh, có thể nâng cấp).
    *   (Kế hoạch) Thanh tìm kiếm nhanh để tìm khách sạn theo điểm đến và ngày.
*   **Chi Tiết Khách Sạn:**
    *   Hiển thị thông tin chi tiết về khách sạn đã chọn (tên, địa chỉ, mô tả, sao, số điện thoại).
    *   Gallery ảnh của khách sạn.
    *   Danh sách các tiện nghi của khách sạn.
    *   Liệt kê các loại phòng có sẵn cùng thông tin chi tiết (ảnh, giá, số khách, tiện nghi loại phòng, số phòng còn trống).
    *   Nút "Đặt" cho mỗi loại phòng (dẫn đến quy trình đặt phòng).
*   **(Đang phát triển/Kế hoạch) Quản Lý Đặt Phòng:**
    *   Quy trình đặt phòng cho phép người dùng chọn phòng cụ thể (nếu còn trống) và xác nhận.
    *   Màn hình "Đặt Chỗ Của Tôi" để người dùng xem lịch sử các đặt phòng đã thực hiện (sắp tới, đã hoàn thành, đã hủy).
    *   Cho phép hủy đặt phòng (nếu điều kiện cho phép).
    *   Cho phép để lại đánh giá sau khi hoàn thành kỳ nghỉ.
*   **(Demo) Quản Lý Phòng:**
    *   Một màn hình đơn giản hiển thị danh sách tất cả các phòng cụ thể trong CSDL.
    *   Hiển thị thông tin: Số phòng, Tên loại phòng, Tên khách sạn, Trạng thái (Trống/Đã đặt).
    *   (Có thể có) Chức năng demo đơn giản để thay đổi trạng thái `DangTrong` của một phòng (chủ yếu để kiểm tra logic và dữ liệu).
*   **Quản Lý Dữ Liệu Cục Bộ:**
    *   Sử dụng SQLite để lưu trữ và truy vấn thông tin tài khoản, khách sạn, loại phòng, phòng cụ thể, tiện nghi, đặt phòng, đánh giá.
    *   Dữ liệu mẫu được tự động chèn khi khởi tạo ứng dụng lần đầu.

## Công Nghệ Sử Dụng

*   **Ngôn ngữ:** Dart
*   **Framework:** Flutter
*   **Cơ sở dữ liệu:** SQLite (thông qua plugin `sqflite`)
*   **Quản lý đường dẫn:** `path_provider`, `path`
*   **Quản lý trạng thái (có thể):** `Provider`, `Riverpod` (cho các trạng thái toàn cục như thông tin người dùng đăng nhập)
*   **(Các plugin khác nếu có)**

## Ảnh Chụp Màn Hình

*(Hãy chụp ảnh màn hình các trang chính của ứng dụng và đặt vào đây sau khi bạn đã xây dựng chúng)*

**Trang Đăng Ký:**
![Trang Đăng Ký](logo/dangky.jpg)

**Trang Đăng Nhập:**
![Trang Đăng Nhập](logo/dangnhap.jpg)

**Trang Chủ:**
![Trang Chủ 1](logo/trangchu1.jpg)
![Trang Chủ 2](logo/trangchu2.jpg)

**Trang Chi Tiết Khách Sạn:**
![Chi Tiết Khách Sạn 1](logo/trangchitiet1.jpg)
![Chi Tiết Khách Sạn 2](logo/trangchitiet2.jpg)

**Trang Quản Lý Phòng (Demo):**
![Quản Lý Phòng](logo/quanlyphong.jpg)
![Quản Lý Phòng - Chi tiết hơn](logo/quanlyphong1.jpg) <!-- Hoặc quanlyphong2.jpg -->

**Thông Tin Đặt Phòng (Ví dụ):**
![Thông Tin Đặt Phòng](logo/thongtindatphong.jpg)

## Cấu Trúc Dự Án (Gợi Ý)
