import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';

class ThongTinPhongPage extends StatefulWidget {
  const ThongTinPhongPage({super.key});

  @override
  State<ThongTinPhongPage> createState() => _ThongTinPhongPageState();
}

class _ThongTinPhongPageState extends State<ThongTinPhongPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _filteredRooms = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tất cả'; // 'Tất cả', 'Trống', 'Đang thuê'

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      // Truy vấn tất cả phòng từ bảng Phong
      final rooms = await _dbHelper.query(
        'Phong',
        columns: [
          'IDPhong',
          'IDKhachSan',
          'IDLoaiPhong',
          'SoPhong',
          'DangTrong',
        ],
      );
      // Tạo danh sách mới với thông tin bổ sung
      final updatedRooms = await Future.wait(
        rooms.map((room) async {
          final khachSan = await _dbHelper.getKhachSanById(room['IDKhachSan']);
          final loaiPhong = await _dbHelper.query(
            'LoaiPhong',
            where: 'IDLoaiPhong = ?',
            whereArgs: [room['IDLoaiPhong']],
          );
          return {
            ...room,
            'TenKhachSan': khachSan?['TenKhachSan'] ?? 'Không xác định',
            'TenLoaiPhong':
                loaiPhong.isNotEmpty
                    ? loaiPhong.first['TenLoaiPhong']
                    : 'Không xác định',
          };
        }).toList(),
      );
      setState(() {
        _rooms = updatedRooms;
        _filteredRooms = updatedRooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải danh sách phòng: $e')));
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Tất cả') {
        _filteredRooms = _rooms;
      } else if (filter == 'Trống') {
        _filteredRooms =
            _rooms.where((room) => room['DangTrong'] == 1).toList();
      } else if (filter == 'Đang thuê') {
        _filteredRooms =
            _rooms.where((room) => room['DangTrong'] == 0).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Thông tin phòng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải thông tin phòng...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : _filteredRooms.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.filter_list_off,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFilter == 'Tất cả'
                          ? 'Không có phòng nào trong hệ thống'
                          : 'Không có phòng nào phù hợp với bộ lọc',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Header thống kê
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[600]!, Colors.blue[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _applyFilter('Tất cả'),
                            child: _buildStatCard(
                              'Tổng phòng',
                              '${_rooms.length}',
                              Icons.hotel,
                              _selectedFilter == 'Tất cả'
                                  ? Colors.white
                                  : Colors.blue[50]!,
                              isSelected: _selectedFilter == 'Tất cả',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _applyFilter('Trống'),
                            child: _buildStatCard(
                              'Phòng trống',
                              '${_rooms.where((room) => room['DangTrong'] == 1).length}',
                              Icons.check_circle,
                              _selectedFilter == 'Trống'
                                  ? Colors.green[100]!
                                  : Colors.blue[50]!,
                              isSelected: _selectedFilter == 'Trống',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _applyFilter('Đang thuê'),
                            child: _buildStatCard(
                              'Đang thuê',
                              '${_rooms.where((room) => room['DangTrong'] == 0).length}',
                              Icons.person,
                              _selectedFilter == 'Đang thuê'
                                  ? Colors.orange[100]!
                                  : Colors.blue[50]!,
                              isSelected: _selectedFilter == 'Đang thuê',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Danh sách phòng
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredRooms.length,
                      itemBuilder: (context, index) {
                        final room = _filteredRooms[index];
                        final isAvailable = room['DangTrong'] == 1;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color:
                                    isAvailable
                                        ? Colors.green[50]
                                        : Colors.red[50],
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color:
                                      isAvailable
                                          ? Colors.green[200]!
                                          : Colors.red[200]!,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                isAvailable
                                    ? Icons.hotel
                                    : Icons.hotel_outlined,
                                color:
                                    isAvailable
                                        ? Colors.green[600]
                                        : Colors.red[600],
                                size: 24,
                              ),
                            ),
                            title: Text(
                              'Phòng ${room['SoPhong']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.grey[800],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.category_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        room['TenLoaiPhong'],
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.business_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        room['TenKhachSan'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isAvailable
                                        ? Colors.green[50]
                                        : Colors.red[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      isAvailable
                                          ? Colors.green[200]!
                                          : Colors.red[200]!,
                                ),
                              ),
                              child: Text(
                                isAvailable ? 'Trống' : 'Đang thuê',
                                style: TextStyle(
                                  color:
                                      isAvailable
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color bgColor, {
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border:
            isSelected ? Border.all(color: Colors.blue[800]!, width: 2) : null,
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue[800] : Colors.blue[700],
            size: isSelected ? 26 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isSelected ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue[800] : Colors.blue[700],
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue[800] : Colors.blue[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
