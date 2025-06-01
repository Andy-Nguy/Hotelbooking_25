// lib/screens/hotel_details/hotel_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';

class HotelDetailsScreen extends StatefulWidget {
  final int hotelId; // ID của khách sạn sẽ được truyền vào
  final String hotelName; // Tên khách sạn để hiển thị trên AppBar

  const HotelDetailsScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
  });

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _hotelDetails; // Thông tin chi tiết khách sạn
  List<Map<String, dynamic>> _roomTypes = []; // Danh sách các loại phòng

  @override
  void initState() {
    super.initState();
    _loadHotelData();
  }

  Future<void> _loadHotelData() async {
    setState(() {
      _isLoading = true;
    });
    final dbHelper = DatabaseHelper.instance;

    // Lấy thông tin chi tiết của khách sạn (bao gồm cả gallery, tiện nghi KS)
    // Sử dụng hàm getFullHotelDetails bạn đã có hoặc một hàm tương tự
    // Vì getFullHotelDetails trả về List, ta lấy phần tử đầu tiên
    // List<Map<String, dynamic>> hotelFullDetailsList = await dbHelper
    //     .getFullHotelDetails(widget.hotelId);
    // if (hotelFullDetailsList.isNotEmpty) {
    //   _hotelDetails = hotelFullDetailsList.first;
    //   // _roomTypes đã có sẵn trong _hotelDetails['room_types'] từ hàm getFullHotelDetails
    //   // Nếu getFullHotelDetails chưa trả về room_types như vậy, bạn cần query riêng:
    //   // _roomTypes = await dbHelper.getLoaiPhongByKhachSan(widget.hotelId);
    //   if (_hotelDetails!['room_types'] is List) {
    //     _roomTypes = List<Map<String, dynamic>>.from(
    //       _hotelDetails!['room_types'],
    //     );
    //   }
    // } else {
    //   // Xử lý trường hợp không tìm thấy khách sạn
    //   print("Không tìm thấy khách sạn với ID: ${widget.hotelId}");
    // }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotelName), // Hiển thị tên khách sạn
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hotelDetails == null
              ? const Center(child: Text('Không tìm thấy thông tin khách sạn.'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hiển thị ảnh chính của khách sạn
                    if (_hotelDetails!['UrlAnhChinh'] != null)
                      Image.asset(
                        _hotelDetails!['UrlAnhChinh'],
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _hotelDetails!['TenKhachSan'] ?? 'Tên Khách Sạn',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Địa chỉ: ${_hotelDetails!['DiaChi'] ?? 'N/A'}, ${_hotelDetails!['ThanhPho'] ?? 'N/A'}',
                    ),
                    Text(
                      'Xếp hạng: ${_hotelDetails!['XepHangSao'] ?? 'N/A'} sao',
                    ),
                    Text(
                      'Điện thoại: ${_hotelDetails!['SoDienThoaiKhachSan'] ?? 'N/A'}',
                    ),
                    const SizedBox(height: 8),
                    if (_hotelDetails!['MoTa'] != null)
                      Text(_hotelDetails!['MoTa']),

                    // --- Hiển thị Gallery ảnh khách sạn ---
                    if (_hotelDetails!['gallery'] != null &&
                        (_hotelDetails!['gallery'] as List).isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Thư viện ảnh khách sạn:",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (_hotelDetails!['gallery'] as List).length,
                          itemBuilder: (context, index) {
                            var image =
                                (_hotelDetails!['gallery'] as List)[index];
                            return Card(
                              child: Image.asset(
                                image['UrlAnh'],
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // --- Hiển thị Tiện nghi khách sạn ---
                    if (_hotelDetails!['amenities'] != null &&
                        (_hotelDetails!['amenities'] as List).isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Tiện nghi khách sạn:",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children:
                            (_hotelDetails!['amenities'] as List).map<Widget>((
                              amenity,
                            ) {
                              return Chip(
                                label: Text(amenity['TenTienNghi'] ?? 'N/A'),
                              );
                            }).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),
                    Text(
                      'Các Loại Phòng Có Sẵn:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _roomTypes.isEmpty
                        ? const Text(
                          'Hiện chưa có thông tin loại phòng cho khách sạn này.',
                        )
                        : ListView.builder(
                          shrinkWrap:
                              true, // Quan trọng khi ListView trong Column
                          physics:
                              const NeverScrollableScrollPhysics(), // Ngăn cuộn lồng nhau
                          itemCount: _roomTypes.length,
                          itemBuilder: (context, index) {
                            final roomType = _roomTypes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading:
                                    roomType['UrlAnhChinh'] != null
                                        ? Image.asset(
                                          roomType['UrlAnhChinh'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.room_preferences,
                                                    size: 40,
                                                  ),
                                        )
                                        : const Icon(
                                          Icons.room_preferences,
                                          size: 40,
                                        ),
                                title: Text(
                                  roomType['TenLoaiPhong'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tối đa: ${roomType['SoKhachToiDa'] ?? 'N/A'} khách',
                                    ),
                                    Text(
                                      'Giá: ${roomType['GiaCoBanMoiDem']?.toStringAsFixed(0) ?? 'N/A'} VND/đêm',
                                    ),
                                    // Hiển thị thêm mô tả ngắn hoặc các tiện nghi chính của loại phòng nếu muốn
                                    if (roomType['amenities'] != null &&
                                        (roomType['amenities'] as List)
                                            .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          'Tiện nghi phòng: ${(roomType['amenities'] as List).map((a) => a['TenTienNghi']).join(", ")}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  child: const Text('Đặt'),
                                  onPressed: () {
                                    // TODO: Điều hướng đến trang đặt phòng chi tiết
                                    // Truyền IDLoaiPhong, IDKhachSan, và các thông tin cần thiết khác
                                    print(
                                      'Đặt phòng: ${roomType['TenLoaiPhong']} của KS ID: ${widget.hotelId}',
                                    );
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen(...)));
                                  },
                                ),
                                onTap: () {
                                  // TODO: Có thể hiển thị chi tiết hơn về loại phòng này (ví dụ: mở dialog, hoặc trang chi tiết loại phòng)
                                  print(
                                    'Xem chi tiết loại phòng: ${roomType['TenLoaiPhong']}',
                                  );
                                },
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
    );
  }
}
