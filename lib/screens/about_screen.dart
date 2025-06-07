import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  final bool hasBooking;
  const AboutScreen({super.key, required this.hasBooking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        title: const Text(
          'Về JW Marriott',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Gradient
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4A90E2), Color(0xFF7BB3F0)],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hotel, size: 60, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'JW Marriott Hotels',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Luxury Beyond Compare',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  _buildSectionCard(
                    title: 'Về Chúng Tôi',
                    content:
                        'JW Marriott là thương hiệu khách sạn hạng sang hàng đầu thế giới, mang đến trải nghiệm nghỉ dưỡng đẳng cấp với dịch vụ tận tâm và tiện nghi hiện đại. Chúng tôi cam kết tạo ra những kỷ niệm khó quên cho mỗi vị khách.',
                    icon: Icons.info_outline,
                    color: const Color(0xFF4A90E2),
                  ),

                  const SizedBox(height: 20),

                  // Locations Section
                  _buildSectionCard(
                    title: 'Vị Trí Chiến Lược',
                    content: '',
                    icon: Icons.location_on,
                    color: const Color(0xFF5BA0F2),
                    child: Column(
                      children: [
                        _buildLocationItem(
                          'JW Marriott Saigon',
                          'Thành phố Hồ Chí Minh',
                          Icons.business,
                        ),
                        _buildLocationItem(
                          'JW Marriott Hanoi',
                          'Thủ đô Hà Nội',
                          Icons.account_balance,
                        ),
                        _buildLocationItem(
                          'JW Marriott Phu Quoc',
                          'Đảo Ngọc Phú Quốc',
                          Icons.beach_access,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Services Section
                  _buildSectionCard(
                    title: 'Dịch Vụ Nổi Bật',
                    content: '',
                    icon: Icons.star,
                    color: const Color(0xFF7BB3F0),
                    child: Column(
                      children: [
                        _buildServiceItem(
                          'Spa & Wellness',
                          'Thư giãn tuyệt đối',
                          Icons.spa,
                        ),
                        _buildServiceItem(
                          'Fine Dining',
                          'Ẩm thực cao cấp',
                          Icons.restaurant,
                        ),
                        _buildServiceItem(
                          'Business Center',
                          'Dịch vụ doanh nhân',
                          Icons.business_center,
                        ),
                        _buildServiceItem(
                          'Pool & Fitness',
                          'Thể thao & giải trí',
                          Icons.pool,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Achievements Section
                  _buildSectionCard(
                    title: 'Thành Tựu & Giải Thưởng',
                    content: '',
                    icon: Icons.emoji_events,
                    color: const Color(0xFF9AC5F4),
                    child: Column(
                      children: [
                        _buildAchievementItem(
                          'World Travel Awards',
                          '2023 - Best Luxury Hotel',
                        ),
                        _buildAchievementItem(
                          'TripAdvisor',
                          'Certificate of Excellence',
                        ),
                        _buildAchievementItem(
                          'AAA Diamond Award',
                          '5 Diamond Rating',
                        ),
                        _buildAchievementItem(
                          'Forbes Travel Guide',
                          '5-Star Rating',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Contact Section
                  _buildSectionCard(
                    title: 'Liên Hệ',
                    content: '',
                    icon: Icons.contact_support,
                    color: const Color(0xFFB8D4F1),
                    child: const Column(
                      children: [
                        _ContactItem(
                          icon: Icons.phone,
                          title: 'Hotline',
                          content: '1900 xxxx',
                        ),
                        _ContactItem(
                          icon: Icons.email,
                          title: 'Email',
                          content: 'info@jwmarriott.com',
                        ),
                        _ContactItem(
                          icon: Icons.language,
                          title: 'Website',
                          content: 'www.marriott.com',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // App Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Text(
                            'JW Marriott Booking App',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ],
          if (child != null) ...[const SizedBox(height: 16), child],
        ],
      ),
    );
  }

  Widget _buildLocationItem(String name, String location, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A90E2), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String name, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7BB3F0), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String award, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.military_tech, color: Color(0xFF9AC5F4), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  award,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
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

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB8D4F1), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
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
