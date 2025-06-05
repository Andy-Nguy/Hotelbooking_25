import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';

class HotelDetailsScreen extends StatefulWidget {
  final int hotelId;
  final String hotelName;

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
  Map<String, dynamic>? _hotelFullDetails;
  int _currentIndex = 0; // Chỉ số của tab hiện tại

  @override
  void initState() {
    super.initState();
    _loadHotelFullDetails();
  }

  Future<void> _loadHotelFullDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final dbHelper = DatabaseHelper.instance;
    try {
      _hotelFullDetails = await dbHelper.getFullHotelDetails(widget.hotelId);
      print("HotelDetailsScreen: Loaded hotel details: $_hotelFullDetails");
    } catch (e) {
      print('Lỗi khi tải chi tiết khách sạn ID ${widget.hotelId}: $e');
      _hotelFullDetails = null;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImageGallery(
    List<dynamic>? gallery, {
    double height = 180,
    required String placeholderType,
  }) {
    if (gallery == null || gallery.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Không có ảnh $placeholderType.'),
      );
    }
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gallery.length,
        itemBuilder: (context, index) {
          final image = gallery[index] as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.only(right: 10.0),
            clipBehavior: Clip.antiAlias,
            child:
                image['UrlAnh'] != null &&
                        (image['UrlAnh'] as String).isNotEmpty
                    ? Image.asset(
                      image['UrlAnh'],
                      width: 250,
                      height: height,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print(
                          'Lỗi tải ảnh gallery: ${image['UrlAnh']}: $error',
                        );
                        return Container(
                          width: 250,
                          height: height,
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          ),
                        );
                      },
                    )
                    : Container(
                      width: 250,
                      height: height,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildAmenitiesList(List<dynamic>? amenities) {
    if (amenities == null || amenities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Không có thông tin tiện nghi.'),
      );
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children:
          amenities.map<Widget>((amenity) {
            final amenityMap = amenity as Map<String, dynamic>;
            return Chip(
              avatar:
                  amenityMap['TenIcon'] != null
                      ? Icon(
                        _getIconData(amenityMap['TenIcon'] as String),
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      )
                      : null,
              label: Text(amenityMap['TenTienNghi'] as String? ?? 'N/A'),
            );
          }).toList(),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'pool':
        return Icons.pool;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_parking':
        return Icons.local_parking;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'spa':
        return Icons.spa;
      case 'kitchen':
        return Icons.kitchen;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'tv':
        return Icons.tv;
      default:
        return Icons.help_outline;
    }
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Điều hướng đến các màn hình tương ứng
    switch (index) {
      case 0:
        // Điều hướng đến Trang chủ
        print('Điều hướng đến Trang chủ');
        // Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Điều hướng đến Tìm kiếm
        print('Điều hướng đến Tìm kiếm');
        // Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        // Điều hướng đến Đặt phòng
        print('Điều hướng đến Đặt phòng');
        // Navigator.pushReplacementNamed(context, '/bookings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("HotelDetailsScreen: _hotelFullDetails = $_hotelFullDetails");
    return Scaffold(
      appBar: AppBar(
        title: Text(_hotelFullDetails?['TenKhachSan'] ?? widget.hotelName),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hotelFullDetails == null
              ? const Center(child: Text('Không thể tải thông tin khách sạn.'))
              : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Ảnh chính khách sạn
                  if (_hotelFullDetails!['UrlAnhChinh'] != null &&
                      (_hotelFullDetails!['UrlAnhChinh'] as String).isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        _hotelFullDetails!['UrlAnhChinh'],
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                      ),
                    )
                  else
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.hotel_rounded,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Tên và thông tin cơ bản
                  Text(
                    _hotelFullDetails!['TenKhachSan'] ?? 'Tên Khách Sạn',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_hotelFullDetails!['DiaChi'] ?? 'N/A'}, ${_hotelFullDetails!['ThanhPho'] ?? 'N/A'}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(_hotelFullDetails!['SoDienThoaiKhachSan'] ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_hotelFullDetails!['XepHangSao'] != null)
                    Row(
                      children: [
                        Text(
                          '${_hotelFullDetails!['XepHangSao']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (_hotelFullDetails!['MoTa'] != null &&
                      (_hotelFullDetails!['MoTa'] as String).isNotEmpty)
                    Text(
                      _hotelFullDetails!['MoTa'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                  // Thư viện ảnh khách sạn
                  if (_hotelFullDetails!['gallery'] != null &&
                      (_hotelFullDetails!['gallery'] as List).isNotEmpty) ...[
                    _buildSectionTitle(context, 'Thư Viện Ảnh Khách Sạn'),
                    _buildImageGallery(
                      _hotelFullDetails!['gallery'] as List<dynamic>?,
                      placeholderType: 'khách sạn',
                    ),
                  ],

                  // Tiện nghi khách sạn
                  if (_hotelFullDetails!['amenities'] != null &&
                      (_hotelFullDetails!['amenities'] as List).isNotEmpty) ...[
                    _buildSectionTitle(context, 'Tiện Nghi Khách Sạn'),
                    _buildAmenitiesList(
                      _hotelFullDetails!['amenities'] as List<dynamic>?,
                    ),
                  ],

                  // Danh sách loại phòng
                  _buildSectionTitle(context, 'Các Loại Phòng'),
                  if (_hotelFullDetails!['room_types'] == null ||
                      (_hotelFullDetails!['room_types'] as List).isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Hiện chưa có thông tin loại phòng cho khách sạn này.',
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          (_hotelFullDetails!['room_types'] as List).length,
                      itemBuilder: (context, index) {
                        final roomType =
                            (_hotelFullDetails!['room_types'] as List)[index]
                                as Map<String, dynamic>;
                        print(
                          "HotelDetailsScreen: Hiển thị loại phòng: $roomType",
                        );
                        final roomsSpecific =
                            roomType['rooms_specific'] as List<dynamic>? ?? [];
                        final availableRooms =
                            roomsSpecific
                                .where((room) => room['DangTrong'] == 1)
                                .toList();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ảnh loại phòng
                                if (roomType['UrlAnhChinh'] != null &&
                                    (roomType['UrlAnhChinh'] as String)
                                        .isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      roomType['UrlAnhChinh'],
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 180,
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                    ),
                                  ),
                                const SizedBox(height: 12),

                                // Chi tiết loại phòng
                                Text(
                                  roomType['TenLoaiPhong'] ?? 'N/A',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                if (roomType['MoTa'] != null &&
                                    (roomType['MoTa'] as String).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Text(
                                      roomType['MoTa'],
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                Text(
                                  'Tối đa: ${roomType['SoKhachToiDa'] ?? 'N/A'} khách',
                                ),
                                Text(
                                  'Giá: ${roomType['GiaCoBanMoiDem']?.toStringAsFixed(0) ?? 'N/A'} VND/đêm',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),

                                // Thư viện ảnh loại phòng
                                if (roomType['gallery'] != null &&
                                    (roomType['gallery'] as List)
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Thư viện ảnh loại phòng:',
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                  _buildImageGallery(
                                    roomType['gallery'] as List<dynamic>?,
                                    height: 100,
                                    placeholderType: 'loại phòng',
                                  ),
                                ],

                                // Tiện nghi loại phòng
                                if (roomType['amenities'] != null &&
                                    (roomType['amenities'] as List)
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tiện nghi loại phòng:',
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                  _buildAmenitiesList(
                                    roomType['amenities'] as List<dynamic>?,
                                  ),
                                ],

                                // Tình trạng phòng
                                const SizedBox(height: 12),
                                Text(
                                  'Phòng còn trống: ${availableRooms.length}/${roomsSpecific.length}',
                                  style: TextStyle(
                                    color:
                                        availableRooms.isNotEmpty
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                availableRooms.isNotEmpty
                                    ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          40,
                                        ),
                                      ),
                                      onPressed: () {
                                        print(
                                          'Chọn loại phòng: ${roomType['TenLoaiPhong']} của KS ID: ${widget.hotelId}',
                                        );
                                        // TODO: Điều hướng đến trang chọn phòng
                                      },
                                      child: const Text('Chọn & Đặt Phòng Này'),
                                    )
                                    : const Text(
                                      'Hết phòng',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Đặt phòng',
          ),
        ],
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
