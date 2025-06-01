import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "KhachSanDemo.db";
  static const _databaseVersion = 1;

  static const tableTaiKhoanNguoiDung = 'TaiKhoanNguoiDung';
  static const tableKhachSan = 'KhachSan';
  static const tableAnhKhachSan = 'AnhKhachSan';
  static const tableLoaiPhong = 'LoaiPhong';
  static const tableAnhLoaiPhong = 'AnhLoaiPhong';
  static const tablePhong = 'Phong';
  static const tableDatPhong = 'DatPhong';
  static const tableTienNghi = 'TienNghi';
  static const tableTienNghiKhachSan = 'TienNghiKhachSan';
  static const tableTienNghiLoaiPhong = 'TienNghiLoaiPhong';
  static const tableDanhGia = 'DanhGia';

  static Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    print("SQLite: Foreign keys PRAGMA đã được bật");
  }

  Future _onCreate(Database db, int version) async {
    print("--- SQLite: Bắt đầu tạo các bảng ---");
    Batch batch = db.batch();

    batch.execute('''
  CREATE TABLE $tableTaiKhoanNguoiDung (
    IDNguoiDung INTEGER PRIMARY KEY AUTOINCREMENT,
    HoTen TEXT NOT NULL,
    Email TEXT UNIQUE NOT NULL,
    MatKhauHash TEXT NOT NULL,
    SoDienThoai TEXT,
    NgayDangKy TEXT DEFAULT (STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW', 'localtime'))
  )
  ''');
    batch.execute('''
  CREATE TABLE $tableKhachSan (
    IDKhachSan INTEGER PRIMARY KEY AUTOINCREMENT,
    TenKhachSan TEXT NOT NULL,
    DiaChi TEXT,
    ThanhPho TEXT,
    MoTa TEXT,
    UrlAnhChinh TEXT,
    XepHangSao REAL,
    SoDienThoaiKhachSan TEXT
  )
  ''');
    batch.execute('''
  CREATE TABLE $tableAnhKhachSan (
    IDAnhKhachSan INTEGER PRIMARY KEY AUTOINCREMENT,
    IDKhachSan INTEGER NOT NULL,
    UrlAnh TEXT NOT NULL,
    ChuThich TEXT,
    FOREIGN KEY (IDKhachSan) REFERENCES $tableKhachSan (IDKhachSan) ON DELETE CASCADE
  )
  ''');
    batch.execute('''
  CREATE TABLE $tableLoaiPhong (
    IDLoaiPhong INTEGER PRIMARY KEY AUTOINCREMENT,
    IDKhachSan INTEGER NOT NULL,
    TenLoaiPhong TEXT NOT NULL,
    MoTa TEXT,
    SoKhachToiDa INTEGER,
    GiaCoBanMoiDem REAL,
    UrlAnhChinh TEXT,
    FOREIGN KEY (IDKhachSan) REFERENCES $tableKhachSan (IDKhachSan) ON DELETE CASCADE
  )
  ''');
    batch.execute('''
  CREATE TABLE $tableAnhLoaiPhong (
    IDAnhLoaiPhong INTEGER PRIMARY KEY AUTOINCREMENT,
    IDLoaiPhong INTEGER NOT NULL,
    UrlAnh TEXT NOT NULL,
    ChuThich TEXT,
    FOREIGN KEY (IDLoaiPhong) REFERENCES $tableLoaiPhong (IDLoaiPhong) ON DELETE CASCADE
  )
  ''');
    batch.execute('''
  CREATE TABLE $tablePhong (
    IDPhong INTEGER PRIMARY KEY AUTOINCREMENT,
    IDKhachSan INTEGER NOT NULL,
    IDLoaiPhong INTEGER NOT NULL,
    SoPhong TEXT NOT NULL,
    DangTrong INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (IDKhachSan) REFERENCES $tableKhachSan (IDKhachSan),
    FOREIGN KEY (IDLoaiPhong) REFERENCES $tableLoaiPhong (IDLoaiPhong) ON DELETE CASCADE,
    UNIQUE (IDKhachSan, SoPhong)
  )
  ''');
    batch.execute('''
  CREATE TABLE $tableDatPhong (
    IDDatPhong INTEGER PRIMARY KEY AUTOINCREMENT,
    IDNguoiDung INTEGER NOT NULL,
    IDPhong INTEGER NOT NULL,
    NgayNhanPhong TEXT NOT NULL,
    NgayTraPhong TEXT NOT NULL,
    SoDem INTEGER,
    GiaMoiDemKhiDat REAL,
    TongTien REAL,
    NgayDatPhong TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW', 'localtime')),
    TrangThai TEXT NOT NULL DEFAULT 'confirmed',
    YeuCauDacBiet TEXT,
    FOREIGN KEY (IDNguoiDung) REFERENCES $tableTaiKhoanNguoiDung (IDNguoiDung) ON DELETE CASCADE,
    FOREIGN KEY (IDPhong) REFERENCES $tablePhong (IDPhong)
  )
  ''');
    batch.execute('''
  CREATE TABLE $tableTienNghi (
    IDTienNghi INTEGER PRIMARY KEY AUTOINCREMENT,
    TenTienNghi TEXT NOT NULL UNIQUE,
    TenIcon TEXT
  )
  ''');
    batch.execute('''
  CREATE TABLE $tableTienNghiKhachSan (
    IDTienNghiKhachSan INTEGER PRIMARY KEY AUTOINCREMENT,
    IDKhachSan INTEGER NOT NULL,
    IDTienNghi INTEGER NOT NULL,
    FOREIGN KEY (IDKhachSan) REFERENCES $tableKhachSan (IDKhachSan) ON DELETE CASCADE,
    FOREIGN KEY (IDTienNghi) REFERENCES $tableTienNghi (IDTienNghi) ON DELETE CASCADE,
    UNIQUE (IDKhachSan, IDTienNghi)
  )
  ''');
    batch.execute('''
  CREATE TABLE $tableTienNghiLoaiPhong (
    IDTienNghiLoaiPhong INTEGER PRIMARY KEY AUTOINCREMENT,
    IDLoaiPhong INTEGER NOT NULL,
    IDTienNghi INTEGER NOT NULL,
    FOREIGN KEY (IDLoaiPhong) REFERENCES $tableLoaiPhong (IDLoaiPhong) ON DELETE CASCADE,
    FOREIGN KEY (IDTienNghi) REFERENCES $tableTienNghi (IDTienNghi) ON DELETE CASCADE,
    UNIQUE (IDLoaiPhong, IDTienNghi)
  )
  ''');
    batch.execute('''
  CREATE TABLE $tableDanhGia (
    IDDanhGia INTEGER PRIMARY KEY AUTOINCREMENT,
    IDDatPhong INTEGER NOT NULL UNIQUE,
    IDKhachSan INTEGER NOT NULL,
    IDNguoiDung INTEGER NOT NULL,
    XepHang INTEGER NOT NULL,
    BinhLuan TEXT,
    NgayDanhGia TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%d', 'NOW', 'localtime')),
    FOREIGN KEY (IDDatPhong) REFERENCES $tableDatPhong (IDDatPhong),
    FOREIGN KEY (IDKhachSan) REFERENCES $tableKhachSan (IDKhachSan) ON DELETE CASCADE,
    FOREIGN KEY (IDNguoiDung) REFERENCES $tableTaiKhoanNguoiDung (IDNguoiDung)
  )
  ''');
    await batch.commit(noResult: true);
    print("--- SQLite: Tất cả các bảng đã được tạo ---");
    await _seedData(db);
  }

  // Chèn dử liệu vào bảng KhachSan
  Future<void> _seedData(Database db) async {
    print("--- SQLite: Bắt đầu chèn dữ liệu mẫu ---");
    Batch batch = db.batch();

    // --- KhachSan ---
    print("SQLite: Chèn KhachSan...");
    batch.insert(tableKhachSan, {
      'TenKhachSan': 'Khách sạn JW Marriott Hotel & Suites Saigon',
      'DiaChi':
          'Góc Đường Hai Bà Trưng & Đại Lộ Lê Duẩn, Quận 1, Thành phố Hồ Chí Minh',
      'ThanhPho': 'Thành phố Hồ Chí Minh',
      'MoTa': 'Tọa lạc ngay giữa lòng thành phố...',
      'UrlAnhChinh': 'assets/image/jw_saigon_main.jpg',
      'XepHangSao': 5.0,
      'SoDienThoaiKhachSan': '+84 28-35209999',
    });
    batch.insert(tableKhachSan, {
      'TenKhachSan': 'JW Marriott Hotel Hanoi',
      'DiaChi': '8, Đỗ Đức Dục, Mễ Trì, Nam Từ Liêm, Hà Nội',
      'ThanhPho': 'Thành phố Hà Nội',
      'MoTa': 'Bên không gian ven hồ thơ mộng...',
      'UrlAnhChinh': 'assets/image/jw_hanoi_main.jpg',
      'XepHangSao': 5.0,
      'SoDienThoaiKhachSan': '+84 24 3833 5588',
    });
    batch.insert(tableKhachSan, {
      'TenKhachSan': 'Khách sạn JW Marriott Phu Quoc Emerald Bay',
      'DiaChi': 'Bãi Khem, An Thới, Phú Quốc, Kiên Giang',
      'ThanhPho': 'Tỉnh Kiên Giang',
      'MoTa': 'Cùng đắm chìm vào vẻ đẹp đậm sắc màu Đông Dương...',
      'UrlAnhChinh': 'assets/image/jw_phuquoc_main.jpg',
      'XepHangSao': 5.0,
      'SoDienThoaiKhachSan': '+84 297 377 9999',
    });
    await batch.commit(noResult: true);
    print("SQLite: Đã chèn KhachSan.");

    // Kiểm tra dữ liệu sau khi chèn
    List<Map<String, dynamic>> hotels = await db.query(tableKhachSan);
    print("SQLite: Dữ liệu trong bảng KhachSan: $hotels");
  }

  Future<List<Map<String, dynamic>>> getAllHotels() async {
    final db = await database;
    List<Map<String, dynamic>> hotels = await db.query('KhachSan');
    print("SQLite: Dữ liệu lấy từ getAllHotels: $hotels");
    return hotels;
  }
}
