import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/screens/hotel_details_screen.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';

// --- BenefitItem Widget ---
class BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const BenefitItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            border: Border(
              right:
                  constraints.maxWidth < double.infinity
                      ? const BorderSide(width: 0.5, color: Colors.grey)
                      : BorderSide.none,
              bottom: const BorderSide(width: 0.5, color: Colors.grey),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 25.0, color: Colors.grey[600]),
              const SizedBox(height: 10.0),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- HomeScreen Widget ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  bool _isLoadingHotels = true;
  List<Map<String, dynamic>> _displayedHotels = [];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadInitialHotels();
  }

  Future<void> _loadInitialHotels() async {
    setState(() {
      _isLoadingHotels = true;
    });
    final dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> allHotels = await dbHelper.getAllHotels();
    print("HomeScreen: Dữ liệu khách sạn lấy được: $allHotels");
    if (!mounted) return;
    setState(() {
      _displayedHotels = allHotels.take(3).toList();
      print("HomeScreen: Dữ liệu hiển thị: $_displayedHotels");
      _isLoadingHotels = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    '☰',
                    style: TextStyle(fontSize: 24.0, color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Image.asset(
                    'assets/image/logo.jpg',
                    height: 55,
                    width: 150,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(
                    Icons.person_outline,
                    size: 20.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Hero-Section
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 6.0),
                constraints: const BoxConstraints(minHeight: 500),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: const DecorationImage(
                    image: AssetImage('assets/image/hcm.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 10.0,
                      ),
                      margin: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.location_on,
                                  color: Color(0xFFFF5A5F),
                                  size: 16.0,
                                ),
                                SizedBox(width: 8.0),
                                Flexible(
                                  child: Text(
                                    'Điểm đến tiếp theo',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1.0,
                            height: 20.0,
                            color: Colors.black54,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.blue,
                                  size: 16.0,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'Thêm ngày',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 180),
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ưu đãi giới hạn',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 2.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          const Text(
                            'Khám phá & Tiết kiệm tại Hồ Chí Minh',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 2.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          const Text(
                            'Tận hưởng ưu đãi đặc biệt cho kỳ nghỉ của bạn.',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                              height: 1.5,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 2.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.all(10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: const Text(
                                'Đặt ngay',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Khách Sạn Nổi Bật Section
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khách Sạn Nổi Bật',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15.0),
                _isLoadingHotels
                    ? const Center(child: CircularProgressIndicator())
                    : _displayedHotels.isEmpty
                    ? const Center(child: Text('Không có khách sạn nào.'))
                    : SizedBox(
                      height: 350.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _displayedHotels.length,
                        itemBuilder: (context, index) {
                          final hotel = _displayedHotels[index];
                          final int hotelId = hotel['IDKhachSan'] as int;
                          final String hotelName =
                              hotel['TenKhachSan'] ?? 'Khách sạn';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => HotelDetailsScreen(
                                        hotelId: hotelId,
                                        hotelName: hotelName,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              width: 300.0,
                              margin: const EdgeInsets.only(right: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 2),
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8.0),
                                      ),
                                      child:
                                          hotel['UrlAnhChinh'] != null
                                              ? Image.asset(
                                                hotel['UrlAnhChinh'],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return const SizedBox(
                                                    height: 200,
                                                    child: Center(
                                                      child: Text(
                                                        'Không thể tải ảnh',
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                              : const Icon(
                                                Icons.hotel,
                                                size: 100,
                                                color: Colors.grey,
                                              ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hotelName,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        const Align(
                                          alignment: Alignment.bottomRight,
                                          child: Icon(
                                            Icons.arrow_forward,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              ],
            ),
          ),
          // Benefits Section
          Container(
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                const Text(
                  'Tại sao nên chọn Marriott Bonvoy?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Tận hưởng những lợi ích độc quyền khi bạn là thành viên của chúng tôi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.0, color: Colors.black54),
                ),
                const SizedBox(height: 10.0),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 1.0,
                  children: const [
                    BenefitItem(
                      icon: Icons.hotel,
                      text: 'Ưu đãi lưu trú tốt nhất',
                    ),
                    BenefitItem(
                      icon: Icons.restaurant,
                      text: 'Giảm giá ẩm thực',
                    ),
                    BenefitItem(icon: Icons.spa, text: 'Ưu đãi spa & thư giãn'),
                    BenefitItem(icon: Icons.wifi, text: 'Wi-Fi miễn phí'),
                  ],
                ),
                const SizedBox(height: 15.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    child: const Text(
                      'Đăng kí',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.all(12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      side: const BorderSide(color: Colors.black87),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
