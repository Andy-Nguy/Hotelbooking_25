import 'dart:io';
import 'package:flutter_hotelbooking_25/db/xylyadmin.dart'
    as instance
    show database;
import 'package:flutter_hotelbooking_25/models/datphong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    print("SQLite: Foreign keys PRAGMA đã được bật");
  }

  Future<void> _onCreate(Database db, int version) async {
    print("--- SQLite: Bắt đầu tạo các bảng ---");
    Batch batch = db.batch();

    batch.execute('''
  CREATE TABLE $tableTaiKhoanNguoiDung (
    IDNguoiDung INTEGER PRIMARY KEY AUTOINCREMENT,
    HoTen TEXT NOT NULL,
    Email TEXT UNIQUE NOT NULL,
    MatKhauHash TEXT NOT NULL,
    SoDienThoai TEXT,
    Role TEXT,
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
    //   batch.execute('''
    // CREATE TABLE $tableDatPhong (
    //   IDDatPhong INTEGER PRIMARY KEY AUTOINCREMENT,
    //   IDNguoiDung INTEGER NOT NULL,
    //   IDPhong INTEGER NOT NULL,
    //   NgayNhanPhong TEXT NOT NULL,
    //   NgayTraPhong TEXT NOT NULL,
    //   SoDem INTEGER,
    //   GiaMoiDemKhiDat REAL,
    //   TongTien REAL,
    //   NgayDatPhong TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW', 'localtime')),
    //   TrangThai TEXT NOT NULL DEFAULT 'confirmed',
    //   YeuCauDacBiet TEXT,
    //   FOREIGN KEY (IDNguoiDung) REFERENCES $tableTaiKhoanNguoiDung (IDNguoiDung) ON DELETE CASCADE,
    //   FOREIGN KEY (IDPhong) REFERENCES $tablePhong (IDPhong)
    // )
    // ''');
    batch.execute('''
  CREATE TABLE DatPhong (
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
    MaGiaoDich TEXT, -- Thêm cột này
    FOREIGN KEY (IDNguoiDung) REFERENCES TaiKhoanNguoiDung (IDNguoiDung) ON DELETE CASCADE,
    FOREIGN KEY (IDPhong) REFERENCES Phong (IDPhong)
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
    try {
      await batch.commit(noResult: true);
      print("--- SQLite: Tất cả các bảng đã được tạo ---");
    } catch (e) {
      print("SQLite: Lỗi khi tạo bảng: $e");
    }
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    print("--- SQLite: Bắt đầu chèn dữ liệu mẫu ---");

    // --- KhachSan ---
    Batch batchKhachSan = db.batch();
    batchKhachSan.insert(tableKhachSan, {
      'TenKhachSan': 'Khách sạn JW Marriott Hotel & Suites Saigon',
      'DiaChi':
          'Góc Đường Hai Bà Trưng & Đại Lộ Lê Duẩn, Quận 1, Thành phố Hồ Chí Minh',
      'ThanhPho': 'Thành phố Hồ Chí Minh',
      'MoTa': 'Tọa lạc ngay giữa lòng thành phố...',
      'UrlAnhChinh': 'assets/image/jw_saigon_main.jpg',
      'XepHangSao': 5.0,
      'SoDienThoaiKhachSan': '+84 28-35209999',
    });
    batchKhachSan.insert(tableKhachSan, {
      'TenKhachSan': 'Khách sạn JW Marriott Hotel Hanoi & Spa',
      'DiaChi': '8, Đỗ Đức Dục, Mễ Trì, Nam Từ Liêm, Hà Nội',
      'ThanhPho': 'Thành phố Hà Nội',
      'MoTa': 'Bên không gian ven hồ thơ mộng...',
      'UrlAnhChinh': 'assets/image/jw_hanoi_main.jpg',
      'XepHangSao': 5.0,
      'SoDienThoaiKhachSan': '+84 24 3833 5588',
    });
    batchKhachSan.insert(tableKhachSan, {
      'TenKhachSan': 'Khách sạn JW Marriott Phu Quoc Emerald Bay',
      'DiaChi': 'Bãi Khem, An Thới, Phú Quốc, Kiên Giang',
      'ThanhPho': 'Tỉnh Kiên Giang',
      'MoTa': 'Cùng đắm chìm vào vẻ đẹp đậm sắc màu Đông Dương...',
      'UrlAnhChinh': 'assets/image/jw_phuquoc_main.jpg',
      'XepHangSao': 5.0,
      'SoDienThoaiKhachSan': '+84 297 377 9999',
    });
    try {
      await batchKhachSan.commit(noResult: true);
      print("SQLite: Đã chèn KhachSan.");
    } catch (e) {
      print("SQLite: Lỗi chèn KhachSan: $e");
    }
    List<Map<String, dynamic>> hotels = await db.query(tableKhachSan);
    print("SQLite: Dữ liệu KhachSan: $hotels");
    if (hotels.isEmpty) {
      print("SQLite: LỖI - Bảng KhachSan rỗng!");
      return;
    }
    int jwSaigonId =
        hotels.firstWhere(
              (h) => h['TenKhachSan'].contains('Suites Saigon'),
            )['IDKhachSan']
            as int;
    int jwHanoiId =
        hotels.firstWhere(
              (h) => h['TenKhachSan'].contains('Hanoi'),
            )['IDKhachSan']
            as int;
    int jwPhuQuocId =
        hotels.firstWhere(
              (h) => h['TenKhachSan'].contains('Phu Quoc'),
            )['IDKhachSan']
            as int;
    print(
      "SQLite: IDs - Saigon: $jwSaigonId, Hanoi: $jwHanoiId, Phu Quoc: $jwPhuQuocId",
    );
    // --- TaiKhoanNguoiDung ---/
    // Chèn dữ liệu mẫu vào bảng TaiKhoanNguoiDung và lấy ID vừa chèn
    int id = await db.insert(tableTaiKhoanNguoiDung, {
      "HoTen": "Nguyễn Tô Duy Anh",
      'Email': "duyanh05012004@gmail.com",
      'MatKhauHash': "123456",
      'SoDienThoai': "0123456789",
      'NgayDangKy': DateTime.now().toIso8601String(),
    });
    await db.insert(tableTaiKhoanNguoiDung, {
      'HoTen': 'Tran Van B',
      'Email': 'nguyenvanb@gmail.com',
      'MatKhauHash': '123456', // Thay bằng hash thực tế (ví dụ: sử dụng bcrypt)
      'SoDienThoai': '0905123456',
      'Role': 'NhanVien',
      'NgayDangKy': DateTime.now().toIso8601String(),
    });

    print('Đã chèn dữ liệu mẫu vào bảng TaiKhoanNguoiDung: ID = $id');
    // Kiểm tra dữ liệu vừa chèn
    final insertedData = await db.query(
      tableTaiKhoanNguoiDung,
      where: 'IDNguoiDung = ?',
      whereArgs: [id],
    );
    print('Dữ liệu vừa chèn: $insertedData');

    // --- TienNghi ---
    Batch batchTienNghi = db.batch();
    batchTienNghi.insert(tableTienNghi, {
      'TenTienNghi': 'Wi-Fi Miễn phí',
      'TenIcon': 'wifi',
    });
    batchTienNghi.insert(tableTienNghi, {
      'TenTienNghi': 'Hồ bơi',
      'TenIcon': 'pool',
    });
    batchTienNghi.insert(tableTienNghi, {
      'TenTienNghi': 'Nhà Hàng',
      'TenIcon': 'restaurant',
    });
    batchTienNghi.insert(tableTienNghi, {
      'TenTienNghi': 'Bãi đỗ xe',
      'TenIcon': 'local_parking',
    });
    batchTienNghi.insert(tableTienNghi, {
      'TenTienNghi': 'Gym',
      'TenIcon': 'fitness_center',
    });
    batchTienNghi.insert(tableTienNghi, {
      'TenTienNghi': 'Spa',
      'TenIcon': 'spa',
    });
    batchTienNghi.insert(tableTienNghi, {
      'TenTienNghi': 'Ấm đun nước siêu tốc',
      'TenIcon': 'kitchen',
    });
    batchTienNghi.insert(tableTienNghi, {
      'TenTienNghi': 'Máy sấy tóc',
      'TenIcon': 'dryer',
    });
    batchTienNghi.insert(tableTienNghi, {
      'TenTienNghi': 'Điều Hòa Nhiệt Độ',
      'TenIcon': 'ac_unit',
    });
    batchTienNghi.insert(tableTienNghi, {
      'TenTienNghi': 'TV Màn Hình Phẳng',
      'TenIcon': 'tv',
    });
    try {
      await batchTienNghi.commit(noResult: true);
      print("SQLite: Đã chèn TienNghi.");
    } catch (e) {
      print("SQLite: Lỗi chèn TienNghi: $e");
    }
    List<Map<String, dynamic>> amenities = await db.query(tableTienNghi);
    print("SQLite: Dữ liệu TienNghi: $amenities");
    if (amenities.isEmpty) {
      print("SQLite: LỖI - Bảng TienNghi rỗng!");
      return;
    }
    int wifiId =
        amenities.firstWhere(
              (a) => a['TenTienNghi'] == 'Wi-Fi Miễn phí',
            )['IDTienNghi']
            as int;
    int poolId =
        amenities.firstWhere((a) => a['TenTienNghi'] == 'Hồ bơi')['IDTienNghi']
            as int;
    int restaurantId =
        amenities.firstWhere(
              (a) => a['TenTienNghi'] == 'Nhà Hàng',
            )['IDTienNghi']
            as int;
    int parkingId =
        amenities.firstWhere(
              (a) => a['TenTienNghi'] == 'Bãi đỗ xe',
            )['IDTienNghi']
            as int;
    int gymId =
        amenities.firstWhere((a) => a['TenTienNghi'] == 'Gym')['IDTienNghi']
            as int;
    int spaId =
        amenities.firstWhere((a) => a['TenTienNghi'] == 'Spa')['IDTienNghi']
            as int;
    int kettleId =
        amenities.firstWhere(
              (a) => a['TenTienNghi'] == 'Ấm đun nước siêu tốc',
            )['IDTienNghi']
            as int;
    int dryerId =
        amenities.firstWhere(
              (a) => a['TenTienNghi'] == 'Máy sấy tóc',
            )['IDTienNghi']
            as int;
    int acId =
        amenities.firstWhere(
              (a) => a['TenTienNghi'] == 'Điều Hòa Nhiệt Độ',
            )['IDTienNghi']
            as int;
    int tvId =
        amenities.firstWhere(
              (a) => a['TenTienNghi'] == 'TV Màn Hình Phẳng',
            )['IDTienNghi']
            as int;

    // --- AnhKhachSan ---
    Batch batchAnhKS = db.batch();
    //SaiGon
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwSaigonId,
      'UrlAnh': 'assets/image/jw_saigon_gallery.jpg',
      'ChuThich': 'Sảnh chờ sang trọng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwSaigonId,
      'UrlAnh': 'assets/image/jw_saigon_hoboi.jpg',
      'ChuThich': 'Hồ bơi tầng thượng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwSaigonId,
      'UrlAnh': 'assets/image/jw_saigon_phongngu1.jpg',
      'ChuThich': 'Phòng ngủ sang trọng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwSaigonId,
      'UrlAnh': 'assets/image/jw_saigon_phongngu2.jpg',
      'ChuThich': 'Phòng ngủ sang trọng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwSaigonId,
      'UrlAnh': 'assets/image/jw_saigon_phongngu3.jpg',
      'ChuThich': 'Phòng ngủ sang trọng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwSaigonId,
      'UrlAnh': 'assets/image/jw_saigon_view1.jpg',
      'ChuThich': 'View thành phố từ trên cao',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwSaigonId,
      'UrlAnh': 'assets/image/jw_saigon_phongan.jpg',
      'ChuThich': 'Khu vực nhà hàng 5 sao',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwSaigonId,
      'UrlAnh': 'assets/image/jw_saigon_phongan1.jpg',
      'ChuThich': 'Khu vực nhà hàng 5 sao',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwSaigonId,
      'UrlAnh': 'assets/image/jw_saigon_phongan2.jpg',
      'ChuThich': 'Khu vực nhà hàng 5 sao',
    });

    ///

    //Hanoi
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwHanoiId,
      'UrlAnh': 'assets/image/jw_hanoi_gallery_1.jpg',
      'ChuThich': 'Kiến trúc bên ngoài',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwHanoiId,
      'UrlAnh': 'assets/image/jw_hanoi_sanh2.jpg',
      'ChuThich': 'Sảnh chờ sang trọng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwHanoiId,
      'UrlAnh': 'assets/image/jw_hanoi_hoboi.jpg',
      'ChuThich': 'Hồ bơi tầng thượng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwHanoiId,
      'UrlAnh': 'assets/image/jw_hanoi_gym.jpg',
      'ChuThich': 'Phòng tập gym hiện đại',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwHanoiId,
      'UrlAnh': 'assets/image/jw_hanoi_phongngu1.jpg',
      'ChuThich': 'Phòng ngủ sang trọng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwHanoiId,
      'UrlAnh': 'assets/image/jw_hanoi_phongngu2.jpg',
      'ChuThich': 'Phòng ngủ sang trọng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwHanoiId,
      'UrlAnh': 'assets/image/jw_hanoi_phongngu3.jpg',
      'ChuThich': 'Phòng ngủ sang trọng',
    });

    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwHanoiId,
      'UrlAnh': 'assets/image/jw_hanoi_phongan1.jpg',
      'ChuThich': 'Nhà hàng sang trọng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwHanoiId,
      'UrlAnh': 'assets/image/jw_hanoi_phongan2.jpg',
      'ChuThich': 'Nhà hàng sang trọng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwHanoiId,
      'UrlAnh': 'assets/image/jw_hanoi_phongan3.jpg',
      'ChuThich': 'Nhà hàng sang trọng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwHanoiId,
      'UrlAnh': 'assets/image/jw_hanoi_phongan4.jpg',
      'ChuThich': 'Nhà hàng sang trọng',
    });

    ///
    //PhuQuoc
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_gallery_1.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_gallery_2.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_hoboi1.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_phongngu1.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_phongngu2.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_phongngu4.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_bien.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_phongan.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_phongan1.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_phongan2.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_hoboi1.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_phongngu5.jpg',
      'ChuThich': 'Bãi biển riêng',
    });

    ///
    try {
      await batchAnhKS.commit(noResult: true);
      print("SQLite: Đã chèn AnhKhachSan.");
    } catch (e) {
      print("SQLite: Lỗi chèn AnhKhachSan: $e");
    }
    List<Map<String, dynamic>> anhKhachSan = await db.query(tableAnhKhachSan);
    print("SQLite: Dữ liệu AnhKhachSan: $anhKhachSan");

    // --- TienNghiKhachSan ---
    Batch batchTienNghiKS = db.batch();
    batchTienNghiKS.insert(tableTienNghiKhachSan, {
      'IDKhachSan': jwSaigonId,
      'IDTienNghi': wifiId,
    });
    batchTienNghiKS.insert(tableTienNghiKhachSan, {
      'IDKhachSan': jwSaigonId,
      'IDTienNghi': poolId,
    });
    batchTienNghiKS.insert(tableTienNghiKhachSan, {
      'IDKhachSan': jwSaigonId,
      'IDTienNghi': gymId,
    });
    batchTienNghiKS.insert(tableTienNghiKhachSan, {
      'IDKhachSan': jwHanoiId,
      'IDTienNghi': wifiId,
    });
    batchTienNghiKS.insert(tableTienNghiKhachSan, {
      'IDKhachSan': jwHanoiId,
      'IDTienNghi': restaurantId,
    });
    batchTienNghiKS.insert(tableTienNghiKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'IDTienNghi': spaId,
    });
    batchTienNghiKS.insert(tableTienNghiKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'IDTienNghi': poolId,
    });
    try {
      await batchTienNghiKS.commit(noResult: true);
      print("SQLite: Đã chèn TienNghiKhachSan.");
    } catch (e) {
      print("SQLite: Lỗi chèn TienNghiKhachSan: $e");
    }
    List<Map<String, dynamic>> tienNghiKhachSan = await db.query(
      tableTienNghiKhachSan,
    );
    print("SQLite: Dữ liệu TienNghiKhachSan: $tienNghiKhachSan");

    // --- LoaiPhong ---
    Batch batchLoaiPhong = db.batch();
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwSaigonId,
      'TenLoaiPhong': 'Phòng Deluxe King',
      'MoTa': 'Diện tích 40m², giường King, view thành phố, tiện nghi cao cấp.',
      'SoKhachToiDa': 2,
      'GiaCoBanMoiDem': 5500000,
      'UrlAnhChinh': 'assets/image/jw_saigon_deluxe_king_main.jpg',
    });
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwSaigonId,
      'TenLoaiPhong': 'Phòng Executive Suite',
      'MoTa':
          'Diện tích 106m², phòng khách riêng,tiện nghi đầy đủ,hướng thành phố.',
      'SoKhachToiDa': 3,
      'GiaCoBanMoiDem': 9000000,
      'UrlAnhChinh': 'assets/image/jw_saigon_phongngu2.jpg',
    });
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwSaigonId,
      'TenLoaiPhong': 'apartment1',
      'MoTa':
          'Diện tích 80m²,Căn hộ có 1 phòng ngủ với 1 giường đôi lớn và Phòng liền kề, với không gian phòng khách và nhà bếp tách biệt, view thành phố.',
      'SoKhachToiDa': 4,
      'GiaCoBanMoiDem': 13000.000,
      'UrlAnhChinh': 'assets/image/jw_saigon_executive_canho_main.jpg',
    });
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwSaigonId,
      'TenLoaiPhong': 'apartment2',
      'MoTa':
          'Diện tích 120m²,Căn hộ có 2 phòng ngủ với không gian phòng khách và nhà bếp tách biệt, view thành phố.',
      'SoKhachToiDa': 4,
      'GiaCoBanMoiDem': 19000000,
      'UrlAnhChinh': 'assets/image/jw_saigon_executive_canho_main1.jpg',
    });

    ///
    ///
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwHanoiId,
      'TenLoaiPhong': 'Phòng Deluxe Lake View',
      'MoTa':
          'Diện tích 48m², giường đôi hoặc 2 giường đơn, tầm nhìn ra hồ gần Trung tâm Hội nghị Quốc gia.',
      'SoKhachToiDa': 3,
      'GiaCoBanMoiDem': 4650000,
      'UrlAnhChinh': 'assets/image/jw_hanoi_deluxe_lake_main.jpg',
    });
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwHanoiId,
      'TenLoaiPhong': 'Phòng Executive',
      'MoTa':
          'Diện tích 48m², 1 giường cỡ King, View hướng thành phố, Phòng Khách.',
      'SoKhachToiDa': 2,
      'GiaCoBanMoiDem': 5300000,
      'UrlAnhChinh': 'assets/image/jw_hanoi_executive_main.jpg',
    });
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwHanoiId,
      'TenLoaiPhong': 'Phòng Deluxe Suite',
      'MoTa':
          'Diện tích 48m², 2 giường đôi, Cảnh quan hồ, Quyền sử dụng Executive Lounge, Phòng Khách.',
      'SoKhachToiDa': 3,
      'GiaCoBanMoiDem': 5800000,
      'UrlAnhChinh': 'assets/image/jw_hanoi_deluxe_suite_main.jpg',
    });
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwHanoiId,
      'TenLoaiPhong': 'Phòng Grand Suite',
      'MoTa':
          'Diện tích 68m², 2 giường đôi, Cảnh quan hồ, Quyền sử dụng Executive Lounge, Ban công, Phòng Khách.',
      'SoKhachToiDa': 4,
      'GiaCoBanMoiDem': 7800000,
      'UrlAnhChinh': 'assets/image/jw_hanoi_grand_suite_main.jpg',
    });
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwHanoiId,
      'TenLoaiPhong': 'Phòng Presidential Suite',
      'MoTa':
          'Diện tích 320m²,1 giường cỡ King, Cảnh quan hồ, Toàn cảnh thành phố, Quyền sử dụng Executive Lounge, Góc, Presidential Suite.',
      'SoKhachToiDa': 3,
      'GiaCoBanMoiDem': 131800000,
      'UrlAnhChinh': 'assets/image/jw_hanoi_presidential_suite_main.jpg',
    });

    ///
    ///
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwPhuQuocId,
      'TenLoaiPhong': 'Emerald Bay View',
      'MoTa':
          'Diện tích 53m²,1 giường King ban công riêng nhìn ra Vịnh Ngọc Bích tuyệt đẹp.',
      'SoKhachToiDa': 3,
      'GiaCoBanMoiDem': 7500000,
      'UrlAnhChinh': 'assets/image/jw_phuquoc_emerald_bay_view_main.webp',
    });
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwPhuQuocId,
      'TenLoaiPhong': 'Emerald Bay View2',
      'MoTa': 'Diện tích 53m²,2 giường đơn ban công riêng nhìn ra bãi biển.',
      'SoKhachToiDa': 3,
      'GiaCoBanMoiDem': 7500000,
      'UrlAnhChinh': 'assets/image/jw_phuquoc_emerald_bay_view1_main.jpg',
    });
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwPhuQuocId,
      'TenLoaiPhong': 'Phòng Deluxe Emerald Bay View',
      'MoTa':
          'Diện tích 63m², quyền sử dụng mọi tiện nghi,ban công riêng nhìn ra Vịnh Ngọc Bích tuyệt đẹp.',
      'SoKhachToiDa': 4,
      'GiaCoBanMoiDem': 12500000,
      'UrlAnhChinh': 'assets/image/jw_phuquoc_phongngu1.jpg',
    });

    ///
    ///
    try {
      await batchLoaiPhong.commit(noResult: true);
      print("SQLite: Đã chèn LoaiPhong.");
    } catch (e) {
      print("SQLite: Lỗi chèn LoaiPhong: $e");
    }
    List<Map<String, dynamic>> roomTypes = await db.query(tableLoaiPhong);
    print("SQLite: Dữ liệu LoaiPhong: $roomTypes");
    if (roomTypes.isEmpty) {
      print("SQLite: LỖI - Bảng LoaiPhong rỗng!");
      return;
    }
    int jwSaigonDeluxeKingRTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'Phòng Deluxe King' &&
                  rt['IDKhachSan'] == jwSaigonId,
            )['IDLoaiPhong']
            as int;
    int jwSaigonExecSuiteRTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'Phòng Executive Suite' &&
                  rt['IDKhachSan'] == jwSaigonId,
            )['IDLoaiPhong']
            as int;
    int jwSaigonCanho1RTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'apartment1' &&
                  rt['IDKhachSan'] == jwSaigonId,
            )['IDLoaiPhong']
            as int;
    int jwSaigonCanho2RTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'apartment2' &&
                  rt['IDKhachSan'] == jwSaigonId,
            )['IDLoaiPhong']
            as int;
    int jwHanoiDeluxeLakeRTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'Phòng Deluxe Lake View' &&
                  rt['IDKhachSan'] == jwHanoiId,
            )['IDLoaiPhong']
            as int;
    int jwHanoiExecutiveRTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'Phòng Executive' &&
                  rt['IDKhachSan'] == jwHanoiId,
            )['IDLoaiPhong']
            as int;
    int jwHanoiDeluxeSuiteRTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'Phòng Deluxe Suite' &&
                  rt['IDKhachSan'] == jwHanoiId,
            )['IDLoaiPhong']
            as int;
    int jwHanoiGrandSuiteRTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'Phòng Grand Suite' &&
                  rt['IDKhachSan'] == jwHanoiId,
            )['IDLoaiPhong']
            as int;
    int jwHanoiPresidentialSuiteRTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'Phòng Presidential Suite' &&
                  rt['IDKhachSan'] == jwHanoiId,
            )['IDLoaiPhong']
            as int;
    int jwPhuQuocEmeraldRTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'Emerald Bay View' &&
                  rt['IDKhachSan'] == jwPhuQuocId,
            )['IDLoaiPhong']
            as int;
    int jwPhuQuocEmeral1dRTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'Emerald Bay View2' &&
                  rt['IDKhachSan'] == jwPhuQuocId,
            )['IDLoaiPhong']
            as int;
    int jwPhuQuocDeluxedRTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'Phòng Deluxe Emerald Bay View' &&
                  rt['IDKhachSan'] == jwPhuQuocId,
            )['IDLoaiPhong']
            as int;

    // --- AnhLoaiPhong ---
    Batch batchAnhLP = db.batch();
    //phòng deluxe king_saigon
    //
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'UrlAnh': 'assets/image/jw_saigon_deluxe_king_gallery1.jpg',
      'ChuThich': 'Giường King thoải mái',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'UrlAnh': 'assets/image/jw_saigon_deluxe_king_gallery2.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'UrlAnh': 'assets/image/jw_saigon_deluxe_king_gallery3.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'UrlAnh': 'assets/image/jw_saigon_deluxe_king_gallery4.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'UrlAnh': 'assets/image/jw_saigon_deluxe_king_gallery5.jpg',
      'ChuThich': 'Phòng',
    });
    //
    //phòng executive suite_saigon
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonExecSuiteRTId,
      'UrlAnh': 'assets/image/jw_saigon_executive_suite_gallery1.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonExecSuiteRTId,
      'UrlAnh': 'assets/image/jw_saigon_executive_suite_gallery2.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonExecSuiteRTId,
      'UrlAnh': 'assets/image/jw_saigon_executive_suite_gallery3.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonExecSuiteRTId,
      'UrlAnh': 'assets/image/jw_saigon_executive_suite_gallery4.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonExecSuiteRTId,
      'UrlAnh': 'assets/image/jw_saigon_executive_suite_gallery5.jpg',
      'ChuThich': 'Phòng',
    });
    //
    //canho gia đình_saigon
    // Căn hộ 1 phòng ngủ
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonCanho1RTId,
      'UrlAnh': 'assets/image/jw_saigon_canho1_gallery1.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonCanho1RTId,
      'UrlAnh': 'assets/image/jw_saigon_canho1_gallery2.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonCanho1RTId,
      'UrlAnh': 'assets/image/jw_saigon_canho1_gallery3.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonCanho1RTId,
      'UrlAnh': 'assets/image/jw_saigon_canho1_gallery4.jpg',
      'ChuThich': 'Phòng',
    });

    // Căn hộ 2 phòng ngủ
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonCanho2RTId,
      'UrlAnh': 'assets/image/jw_saigon_canho2_gallery1.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonCanho2RTId,
      'UrlAnh': 'assets/image/jw_saigon_canho2_gallery2.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonCanho2RTId,
      'UrlAnh': 'assets/image/jw_saigon_canho2_gallery3.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonCanho2RTId,
      'UrlAnh': 'assets/image/jw_saigon_canho2_gallery4.jpg',
      'ChuThich': 'Phòng',
    });
    //
    //phòng deluxe lake view_hanoi
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiDeluxeLakeRTId,
      'UrlAnh': 'assets/image/jw_hanoi_deluxe_lake_gallery1.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiDeluxeLakeRTId,
      'UrlAnh': 'assets/image/jw_hanoi_deluxe_lake_gallery3.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiDeluxeLakeRTId,
      'UrlAnh': 'assets/image/jw_hanoi_deluxe_lake_gallery4.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiDeluxeLakeRTId,
      'UrlAnh': 'assets/image/jw_hanoi_deluxe_lake_gallery2.webp',
      'ChuThich': 'Phòng',
    });
    //phong executive_hanoi
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiExecutiveRTId,
      'UrlAnh': 'assets/image/jw_hanoi_executive_gallery1.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiExecutiveRTId,
      'UrlAnh': 'assets/image/jw_hanoi_executive_gallery2.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiExecutiveRTId,
      'UrlAnh': 'assets/image/jw_hanoi_executive_gallery3.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiExecutiveRTId,
      'UrlAnh': 'assets/image/jw_hanoi_executive_gallery4.webp',
      'ChuThich': 'Phòng',
    });
    //phong deluxe suite_hanoi
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiDeluxeSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_deluxe_suite_gallery1.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiDeluxeSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_deluxe_suite_gallery2.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiDeluxeSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_deluxe_suite_gallery3.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiDeluxeSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_deluxe_suite_gallery4.webp',
      'ChuThich': 'Phòng',
    });
    //phong grand suite_hanoi
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiGrandSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_grand_suite_gallery1.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiGrandSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_grand_suite_gallery2.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiGrandSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_grand_suite_gallery3.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiGrandSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_grand_suite_gallery4.jpg',
      'ChuThich': 'Phòng',
    });
    //phong presidential suite_hanoi
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiPresidentialSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_presidential_suite_gallery1.jpg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiPresidentialSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_presidential_suite_gallery2.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiPresidentialSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_presidential_suite_gallery3.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiPresidentialSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_presidential_suite_gallery4.webp',
      'ChuThich': 'Phòng',
    });

    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiPresidentialSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_presidential_suite_gallery5.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwHanoiPresidentialSuiteRTId,
      'UrlAnh': 'assets/image/jw_hanoi_presidential_suite_gallery6.webp',
      'ChuThich': 'Phòng',
    });

    //phòng emerald bay view_phuquoc
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_emerald_bay_view_gallery1.webp',
      'ChuThich': 'Ban công view biển',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_emerald_bay_view_gallery2.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_emerald_bay_view_gallery3.jpeg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_emerald_bay_view_gallery4.jpeg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_emerald_bay_view_gallery5.webp',
      'ChuThich': 'Phòng',
    });
    //phòng emerald bay view2_phuquoc
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeral1dRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_emerald_bay_view1_gallery1.webp',
      'ChuThich': 'Ban công view biển',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeral1dRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_emerald_bay_view1_gallery2.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeral1dRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_emerald_bay_view1_gallery3.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeral1dRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_emerald_bay_view1_gallery4.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeral1dRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_emerald_bay_view1_gallery5.webp',
      'ChuThich': 'Phòng',
    });
    //phòng deluxe emerald bay view_phuquoc
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocDeluxedRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_deluxe_emerald_bay_view_gallery1.jpeg',
      'ChuThich': 'Ban công view biển',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocDeluxedRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_deluxe_emerald_bay_view_gallery2.webp',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocDeluxedRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_deluxe_emerald_bay_view_gallery3.jpeg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocDeluxedRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_deluxe_emerald_bay_view_gallery4.jpeg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocDeluxedRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_deluxe_emerald_bay_view_gallery5.jpeg',
      'ChuThich': 'Phòng',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocDeluxedRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_deluxe_emerald_bay_view_gallery6.jpg',
      'ChuThich': 'Phòng',
    });

    try {
      await batchAnhLP.commit(noResult: true);
      print("SQLite: Đã chèn AnhLoaiPhong.");
    } catch (e) {
      print("SQLite: Lỗi chèn AnhLoaiPhong: $e");
    }
    List<Map<String, dynamic>> anhLoaiPhong = await db.query(tableAnhLoaiPhong);
    print("SQLite: Dữ liệu AnhLoaiPhong: $anhLoaiPhong");

    // --- TienNghiLoaiPhong ---
    Batch batchTienNghiLP = db.batch();
    batchTienNghiLP.insert(tableTienNghiLoaiPhong, {
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'IDTienNghi': wifiId,
    });
    batchTienNghiLP.insert(tableTienNghiLoaiPhong, {
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'IDTienNghi': acId,
    });
    batchTienNghiLP.insert(tableTienNghiLoaiPhong, {
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'IDTienNghi': tvId,
    });
    batchTienNghiLP.insert(tableTienNghiLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'IDTienNghi': wifiId,
    });
    batchTienNghiLP.insert(tableTienNghiLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'IDTienNghi': kettleId,
    });
    try {
      await batchTienNghiLP.commit(noResult: true);
      print("SQLite: Đã chèn TienNghiLoaiPhong.");
    } catch (e) {
      print("SQLite: Lỗi chèn TienNghiLoaiPhong: $e");
    }
    List<Map<String, dynamic>> tienNghiLoaiPhong = await db.query(
      tableTienNghiLoaiPhong,
    );
    print("SQLite: Dữ liệu TienNghiLoaiPhong: $tienNghiLoaiPhong");

    // --- Phong ---
    Batch batchPhong = db.batch();

    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwSaigonId,
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'SoPhong': 'S_DK101',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwSaigonId,
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'SoPhong': 'S_DK102',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwSaigonId,
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'SoPhong': 'S_DK103',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwSaigonId,
      'IDLoaiPhong': jwSaigonExecSuiteRTId,
      'SoPhong': 'S_ES201',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwSaigonId,
      'IDLoaiPhong': jwSaigonExecSuiteRTId,
      'SoPhong': 'S_ES202',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwSaigonId,
      'IDLoaiPhong': jwSaigonExecSuiteRTId,
      'SoPhong': 'S_ES203',
      'DangTrong': 1,
    });
    //
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwSaigonId,
      'IDLoaiPhong': jwSaigonCanho1RTId,
      'SoPhong': 'S_C1A301',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwSaigonId,
      'IDLoaiPhong': jwSaigonCanho1RTId,
      'SoPhong': 'S_C1A302',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwSaigonId,
      'IDLoaiPhong': jwSaigonCanho1RTId,
      'SoPhong': 'S_C1A303',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwSaigonId,
      'IDLoaiPhong': jwSaigonCanho2RTId,
      'SoPhong': 'S_C2A401',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwSaigonId,
      'IDLoaiPhong': jwSaigonCanho2RTId,
      'SoPhong': 'S_C2A402',
      'DangTrong': 1,
    });
    //

    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwHanoiId,
      'IDLoaiPhong': jwHanoiDeluxeLakeRTId,
      'SoPhong': 'H_DL301',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwHanoiId,
      'IDLoaiPhong': jwHanoiDeluxeLakeRTId,
      'SoPhong': 'H_DL302',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwHanoiId,
      'IDLoaiPhong': jwHanoiDeluxeLakeRTId,
      'SoPhong': 'H_DL303',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwHanoiId,
      'IDLoaiPhong': jwHanoiExecutiveRTId,
      'SoPhong': 'H_EX401',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwHanoiId,
      'IDLoaiPhong': jwHanoiExecutiveRTId,
      'SoPhong': 'H_EX402',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwHanoiId,
      'IDLoaiPhong': jwHanoiExecutiveRTId,
      'SoPhong': 'H_EX403',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwHanoiId,
      'IDLoaiPhong': jwHanoiDeluxeSuiteRTId,
      'SoPhong': 'H_DS501',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwHanoiId,
      'IDLoaiPhong': jwHanoiDeluxeSuiteRTId,
      'SoPhong': 'H_DS502',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwHanoiId,
      'IDLoaiPhong': jwHanoiGrandSuiteRTId,
      'SoPhong': 'H_GS601',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwHanoiId,
      'IDLoaiPhong': jwHanoiGrandSuiteRTId,
      'SoPhong': 'H_GS602',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwHanoiId,
      'IDLoaiPhong': jwHanoiPresidentialSuiteRTId,
      'SoPhong': 'H_PS701',
      'DangTrong': 1,
    });
    //
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'SoPhong': 'P_EB401',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'SoPhong': 'P_EB402',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'SoPhong': 'P_EB403',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'SoPhong': 'P_EB404',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'SoPhong': 'P_EB405',
      'DangTrong': 1,
    });
    // Phòng Emerald Bay View 1
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocEmeral1dRTId,
      'SoPhong': 'P_EB1_501',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocEmeral1dRTId,
      'SoPhong': 'P_EB1_502',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocEmeral1dRTId,
      'SoPhong': 'P_EB1_503',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocEmeral1dRTId,
      'SoPhong': 'P_EB1_504',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocEmeral1dRTId,
      'SoPhong': 'P_EB1_505',
      'DangTrong': 1,
    });

    // Phòng Deluxe Emerald Bay View
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocDeluxedRTId,
      'SoPhong': 'P_DEB1_601',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocDeluxedRTId,
      'SoPhong': 'P_DEB1_602',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocDeluxedRTId,
      'SoPhong': 'P_DEB1_603',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocDeluxedRTId,
      'SoPhong': 'P_DEB1_604',
      'DangTrong': 1,
    });
    batchPhong.insert(tablePhong, {
      'IDKhachSan': jwPhuQuocId,
      'IDLoaiPhong': jwPhuQuocDeluxedRTId,
      'SoPhong': 'P_DEB1_605',
      'DangTrong': 1,
    });
    //
    try {
      await batchPhong.commit(noResult: true);
      print("SQLite: Đã chèn Phong.");
    } catch (e) {
      print("SQLite: Lỗi chèn Phong: $e");
    }
    List<Map<String, dynamic>> phong = await db.query(tablePhong);
    print("SQLite: Dữ liệu Phong: $phong");

    print("--- SQLite: Hoàn tất chèn dữ liệu mẫu ---");
  }

  Future<void> resetDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    await deleteDatabase(path);
    print("SQLite: Đã đặt lại cơ sở dữ liệu.");
    _database = null;
    await database; // Khởi tạo lại
  }

  Future<List<Map<String, dynamic>>> getAllHotels() async {
    final db = await database;
    List<Map<String, dynamic>> hotels = await db.query(tableKhachSan);
    print("SQLite: Dữ liệu lấy từ getAllHotels: $hotels");
    return hotels;
  }

  Future<List<Map<String, dynamic>>> getAllKhachSan() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableKhachSan);
    print("SQLite: Lấy tất cả khách sạn - ${maps.length} bản ghi tìm thấy.");
    return maps;
  }

  Future<Map<String, dynamic>?> getKhachSanById(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableKhachSan,
      where: 'IDKhachSan = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      print("SQLite: Lấy khách sạn theo ID $id - Tìm thấy.");
      return maps.first;
    }
    print("SQLite: Lấy khách sạn theo ID $id - KHÔNG tìm thấy.");
    return null;
  }

  Future<List<Map<String, dynamic>>> getAnhKhachSan(int idKhachSan) async {
    Database db = await database;
    final result = await db.query(
      tableAnhKhachSan,
      where: 'IDKhachSan = ?',
      whereArgs: [idKhachSan],
    );
    print("SQLite: Ảnh khách sạn cho IDKhachSan $idKhachSan: $result");
    return result;
  }

  Future<List<Map<String, dynamic>>> getTienNghiKhachSan(int idKhachSan) async {
    Database db = await database;
    final result = await db.rawQuery(
      '''
      SELECT T.IDTienNghi, T.TenTienNghi, T.TenIcon
      FROM $tableTienNghiKhachSan HT
      JOIN $tableTienNghi T ON HT.IDTienNghi = T.IDTienNghi
      WHERE HT.IDKhachSan = ?
      ''',
      [idKhachSan],
    );
    print("SQLite: Tiện nghi khách sạn cho IDKhachSan $idKhachSan: $result");
    return result;
  }

  Future<List<Map<String, dynamic>>> getLoaiPhongByKhachSan(
    int idKhachSan,
  ) async {
    Database db = await database;
    final result = await db.query(
      tableLoaiPhong,
      where: 'IDKhachSan = ?',
      whereArgs: [idKhachSan],
    );
    print("SQLite: Loại phòng cho IDKhachSan $idKhachSan: $result");
    return result;
  }

  Future<List<Map<String, dynamic>>> getAnhLoaiPhong(int idLoaiPhong) async {
    Database db = await database;
    final result = await db.query(
      tableAnhLoaiPhong,
      where: 'IDLoaiPhong = ?',
      whereArgs: [idLoaiPhong],
    );
    print("SQLite: Ảnh loại phòng cho IDLoaiPhong $idLoaiPhong: $result");
    return result;
  }

  Future<List<Map<String, dynamic>>> getTienNghiLoaiPhong(
    int idLoaiPhong,
  ) async {
    Database db = await database;
    final result = await db.rawQuery(
      '''
      SELECT T.IDTienNghi, T.TenTienNghi, T.TenIcon
      FROM $tableTienNghiLoaiPhong RT_A
      JOIN $tableTienNghi T ON RT_A.IDTienNghi = T.IDTienNghi
      WHERE RT_A.IDLoaiPhong = ?
      ''',
      [idLoaiPhong],
    );
    print("SQLite: Tiện nghi loại phòng cho IDLoaiPhong $idLoaiPhong: $result");
    return result;
  }

  Future<List<Map<String, dynamic>>> getPhongByLoaiPhong(
    int idLoaiPhong,
  ) async {
    Database db = await database;
    final result = await db.query(
      tablePhong,
      where: 'IDLoaiPhong = ?',
      whereArgs: [idLoaiPhong],
    );
    print("SQLite: Phòng cho IDLoaiPhong $idLoaiPhong: $result");
    return result;
  }

  Future<Map<String, dynamic>?> getFullHotelDetails(int hotelId) async {
    final db = await database;
    final hotel = await db.query(
      'KhachSan',
      where: 'IDKhachSan = ?',
      whereArgs: [hotelId],
      limit: 1,
    );

    if (hotel.isEmpty) {
      print(
        'DatabaseHelper: Không tìm thấy khách sạn với IDKhachSan = $hotelId',
      );
      return null;
    }

    final hotelData = Map<String, dynamic>.from(hotel.first);
    print('DatabaseHelper: Hotel data: $hotelData');

    // Lấy danh sách loại phòng
    final roomTypes = await db.query(
      'LoaiPhong',
      where: 'IDKhachSan = ?',
      whereArgs: [hotelId],
    );
    print('DatabaseHelper: Room types: $roomTypes');

    final List<Map<String, dynamic>> detailedRoomTypes = [];
    for (var roomType in roomTypes) {
      // Lấy phòng cụ thể
      final rooms = await db.query(
        'Phong',
        where: 'IDKhachSan = ? AND IDLoaiPhong = ?',
        whereArgs: [hotelId, roomType['IDLoaiPhong']],
      );
      print(
        'DatabaseHelper: Rooms for IDLoaiPhong ${roomType['IDLoaiPhong']}: $rooms',
      );

      // Lấy gallery của loại phòng
      final gallery = await db.query(
        'AnhLoaiPhong',
        where: 'IDLoaiPhong = ?',
        whereArgs: [roomType['IDLoaiPhong']],
      );
      final galleryList =
          gallery.map((img) => {'UrlAnh': img['UrlAnh']}).toList();
      print(
        'DatabaseHelper: Gallery for IDLoaiPhong ${roomType['IDLoaiPhong']}: $galleryList',
      );

      // Lấy tiện nghi của loại phòng
      final amenities = await db.rawQuery(
        '''
      SELECT t.IDTienNghi, t.TenTienNghi, t.TenIcon
      FROM TienNghiLoaiPhong tnlp
      JOIN TienNghi t ON tnlp.IDTienNghi = t.IDTienNghi
      WHERE tnlp.IDLoaiPhong = ?
    ''',
        [roomType['IDLoaiPhong']],
      );
      print(
        'DatabaseHelper: Amenities for IDLoaiPhong ${roomType['IDLoaiPhong']}: $amenities',
      );

      detailedRoomTypes.add({
        ...roomType,
        'rooms_specific': rooms,
        'gallery': galleryList,
        'amenities': amenities,
      });
    }

    // Lấy gallery của khách sạn
    final hotelGallery = await db.query(
      'AnhKhachSan',
      where: 'IDKhachSan = ?',
      whereArgs: [hotelId],
    );
    final hotelGalleryList =
        hotelGallery.map((img) => {'UrlAnh': img['UrlAnh']}).toList();
    print('DatabaseHelper: Hotel gallery: $hotelGalleryList');

    // Lấy tiện nghi của khách sạn
    final hotelAmenities = await db.rawQuery(
      '''
    SELECT t.IDTienNghi, t.TenTienNghi, t.TenIcon
    FROM TienNghiKhachSan tnk
    JOIN TienNghi t ON tnk.IDTienNghi = t.IDTienNghi
    WHERE tnk.IDKhachSan = ?
  ''',
      [hotelId],
    );
    print('DatabaseHelper: Hotel amenities: $hotelAmenities');

    return {
      ...hotelData,
      'room_types': detailedRoomTypes,
      'gallery': hotelGalleryList,
      'amenities': hotelAmenities,
    };
  }

  Future<int> countTableRecords(String tableName) async {
    final db = await database;
    final result = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );
    print("SQLite: Số bản ghi trong $tableName: $result");
    return result ?? 0;
  }

  Future<List<Map<String, dynamic>>> getHotelRoomCounts() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        ks.IDKhachSan,
        ks.TenKhachSan,
        COUNT(p.IDPhong) AS TongSoPhongKhachSan
      FROM $tableKhachSan ks
      LEFT JOIN $tablePhong p ON ks.IDKhachSan = p.IDKhachSan
      GROUP BY ks.IDKhachSan, ks.TenKhachSan
      ORDER BY ks.TenKhachSan
    ''');
    print("SQLite: Thống kê số phòng khách sạn: $result");
    return result;
  }

  Future<List<Map<String, dynamic>>> getRoomTypeCountsPerHotel(
    int hotelId,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT
        lp.IDLoaiPhong,
        lp.TenLoaiPhong,
        COUNT(p.IDPhong) AS TongSoPhongCuaLoaiNay,
        SUM(CASE WHEN p.DangTrong = 1 THEN 1 ELSE 0 END) AS SoPhongTrong,
        SUM(CASE WHEN p.DangTrong = 0 THEN 1 ELSE 0 END) AS SoPhongDaDat
      FROM $tableLoaiPhong lp
      LEFT JOIN $tablePhong p ON lp.IDLoaiPhong = p.IDLoaiPhong
      WHERE lp.IDKhachSan = ?
      GROUP BY lp.IDLoaiPhong, lp.TenLoaiPhong
      ORDER BY lp.TenLoaiPhong
    ''',
      [hotelId],
    );
    print("SQLite: Thống kê loại phòng cho IDKhachSan $hotelId: $result");
    return result;
  }

  Future<List<Map<String, dynamic>>> getActiveBookingsInfo() async {
    final db = await database;
    print(
      "SQLite: getActiveBookingsInfo được gọi, nhưng không có dữ liệu DatPhong mẫu.",
    );
    return [];
  }

  // // Lấy thông tin người dùng theo ID
  // Future<Map<String, dynamic>?> getUserById(int idNguoiDung) async {
  //   final db = await database;
  //   final result = await db.query(
  //     tableTaiKhoanNguoiDung,
  //     where: 'IDNguoiDung = ?',
  //     whereArgs: [idNguoiDung],
  //   );
  //   return result.isNotEmpty ? result.first : null;
  // }

  Future getUserByEmailAndPassword(String email, String password) async {
    final db = await database;
    final result = await db.query(
      tableTaiKhoanNguoiDung,
      where: 'Email = ? AND MatKhauHash = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Đặt phòng tạm thời
  Future<int> bookRoomTemp({
    required int idLoaiPhong,
    required int idNguoiDung,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    required double giaMoiDemKhiDat,
    required double totalCost,
    required Map<String, dynamic> userInfo,
    String? specialRequest,
  }) async {
    final db = await database;
    try {
      // Chọn một phòng trống thuộc loại phòng
      final rooms = await db.query(
        tablePhong,
        where: 'IDLoaiPhong = ? AND DangTrong = ?',
        whereArgs: [idLoaiPhong, 1],
        limit: 1,
      );
      if (rooms.isEmpty) {
        print('SQLite: Không còn phòng trống cho loại phòng $idLoaiPhong');
        throw Exception('Không còn phòng trống cho loại phòng này');
      }
      final idPhong = rooms.first['IDPhong'] as int;

      // Tính số đêm
      final soDem = checkOutDate.difference(checkInDate).inDays;

      // Chèn thông tin đặt phòng
      final booking = {
        'IDNguoiDung': idNguoiDung,
        'IDPhong': idPhong,
        'NgayNhanPhong': checkInDate.toIso8601String(),
        'NgayTraPhong': checkOutDate.toIso8601String(),
        'SoDem': soDem,
        'GiaMoiDemKhiDat': giaMoiDemKhiDat,
        'TongTien': totalCost,
        'YeuCauDacBiet': specialRequest,
        'TrangThai': 'pending',
      };
      final idDatPhong = await db.insert(tableDatPhong, booking);
      print('SQLite: Đã chèn đặt phòng tạm thời: IDDatPhong = $idDatPhong');

      // Cập nhật trạng thái phòng thành không trống
      final updateSuccess = await updateRoomStatus(idPhong, 0);
      if (!updateSuccess) {
        print('SQLite: Lỗi khi cập nhật trạng thái phòng $idPhong');
        throw Exception('Không thể cập nhật trạng thái phòng');
      }

      return idDatPhong;
    } catch (e) {
      print('SQLite: Lỗi khi chèn đặt phòng tạm thời: $e');
      rethrow;
    }
  }

  // Cập nhật trạng thái phòng
  Future<bool> updateRoomStatus(int idPhong, int dangTrong) async {
    final db = await database;
    try {
      print('--- Bắt đầu updateRoomStatus ---');
      print('IDPhong kiểm tra: $idPhong, DangTrong: $dangTrong');
      print('Database đã mở thành công');

      // Kiểm tra xem IDPhong có tồn tại không
      final roomCheck = await db.query(
        tablePhong,
        where: 'IDPhong = ?',
        whereArgs: [idPhong],
      );
      if (roomCheck.isEmpty) {
        print('SQLite: Lỗi - IDPhong $idPhong không tồn tại trong bảng Phong');
        return false;
      }

      final result = await db.update(
        tablePhong,
        {'DangTrong': dangTrong},
        where: 'IDPhong = ?',
        whereArgs: [idPhong],
      );
      print('SQLite: Số hàng bị ảnh hưởng trong updateRoomStatus: $result');
      return result > 0;
    } catch (e) {
      print('SQLite: Lỗi khi cập nhật trạng thái phòng: $e');
      return false;
    }
  }

  // // Đảm bảo getRoomTypeCountsPerHotel trả về số lượng phòng trống chính xác
  // Future<List<Map<String, dynamic>>> getRoomTypeCountsPerHotel(
  //   int hotelId,
  // ) async {
  //   final db = await database;
  //   try {
  //     final result = await db.rawQuery(
  //       '''
  //       SELECT
  //         lp.IDLoaiPhong,
  //         lp.TenLoaiPhong,
  //         COUNT(p.IDPhong) AS TongSoPhongCuaLoaiNay,
  //         SUM(CASE WHEN p.DangTrong = 1 THEN 1 ELSE 0 END) AS SoPhongTrong,
  //         SUM(CASE WHEN p.DangTrong = 0 THEN 1 ELSE 0 END) AS SoPhongDaDat
  //       FROM $tableLoaiPhong lp
  //       LEFT JOIN $tablePhong p ON lp.IDLoaiPhong = p.IDLoaiPhong
  //       WHERE lp.IDKhachSan = ?
  //       GROUP BY lp.IDLoaiPhong, lp.TenLoaiPhong
  //       ORDER BY lp.TenLoaiPhong
  //       ''',
  //       [hotelId],
  //     );
  //     print('SQLite: Thống kê loại phòng cho IDKhachSan $hotelId: $result');
  //     return result;
  //   } catch (e) {
  //     print('SQLite: Lỗi khi lấy thống kê loại phòng: $e');
  //     rethrow;
  //   }
  // }

  // Sửa hàm updateBookingStatus để sử dụng bảng DatPhong
  Future<void> updateBookingStatus(
    int idDatPhong,
    String status,
    String? paymentMethod,
  ) async {
    final db = await database;
    try {
      print(
        'SQLite: Cập nhật trạng thái đặt phòng IDDatPhong: $idDatPhong, trạng thái: $status',
      );
      final result = await db.update(
        tableDatPhong,
        {'TrangThai': status},
        where: 'IDDatPhong = ?',
        whereArgs: [idDatPhong],
      );
      print('SQLite: Số hàng bị ảnh hưởng trong updateBookingStatus: $result');
    } catch (e) {
      print('SQLite: Lỗi khi cập nhật trạng thái đặt phòng: $e');
      rethrow;
    }
  }

  // Sửa hàm getBookingById để sử dụng bảng DatPhong
  Future<Map<String, dynamic>?> getBookingById(int idDatPhong) async {
    final db = await database;
    try {
      final result = await db.query(
        tableDatPhong,
        where: 'IDDatPhong = ?',
        whereArgs: [idDatPhong],
      );
      if (result.isNotEmpty) {
        print('SQLite: Lấy đặt phòng IDDatPhong: $idDatPhong - Tìm thấy');
        return result.first;
      }
      print('SQLite: Lấy đặt phòng IDDatPhong: $idDatPhong - Không tìm thấy');
      return null;
    } catch (e) {
      print('SQLite: Lỗi khi lấy thông tin đặt phòng: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getRoomStatus(int idPhong) async {
    final db = await database;
    final result = await db.query(
      'rooms',
      where: 'IDPhong = ?',
      whereArgs: [idPhong],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // // Đảm bảo getRoomTypeCountsPerHotel trả về dữ liệu chính xác
  // Future<List<Map<String, dynamic>>> getRoomTypeCountsPerHotel(int hotelId) async {
  //   final db = await database;
  //   try {
  //     final result = await db.rawQuery(
  //       '''
  //       SELECT
  //         lp.IDLoaiPhong,
  //         lp.TenLoaiPhong,
  //         COUNT(p.IDPhong) AS TongSoPhongCuaLoaiNay,
  //         SUM(CASE WHEN p.DangTrong = 1 THEN 1 ELSE 0 END) AS SoPhongTrong,
  //         SUM(CASE WHEN p.DangTrong = 0 THEN 1 ELSE 0 END) AS SoPhongDaDat
  //       FROM $tableLoaiPhong lp
  //       LEFT JOIN $tablePhong p ON lp.IDLoaiPhong = p.IDLoaiPhong
  //       WHERE lp.IDKhachSan = ?
  //       GROUP BY lp.IDLoaiPhong, lp.TenLoaiPhong
  //       ORDER BY lp.TenLoaiPhong
  //       ''',
  //       [hotelId],
  //     );
  //     print('SQLite: Thống kê loại phòng cho IDKhachSan $hotelId: $result');
  //     return result;
  //   } catch (e) {
  //     print('SQLite: Lỗi khi lấy thống kê loại phòng: $e');
  //     rethrow;
  //   }
  // }
  Future loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      tableTaiKhoanNguoiDung,
      where: 'Email = ? AND MatKhauHash = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      print("SQLite: Đăng nhập thành công cho email $email");
      return result.first;
    } else {
      print("SQLite: Đăng nhập thất bại cho email $email");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllBookingsDetailed() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
    SELECT 
      dp.IDDatPhong,
      dp.NgayNhanPhong,
      dp.NgayTraPhong,
      dp.SoDem,
      dp.GiaMoiDemKhiDat,
      dp.TongTien,
      dp.NgayDatPhong,
      dp.TrangThai,
      dp.YeuCauDacBiet,
      dp.MaGiaoDich,
      
      nguoidung.HoTen AS TenNguoiDung,
      nguoidung.Email,
      nguoidung.SoDienThoai AS SoDienThoaiNguoiDung,
      
      phong.IDPhong,
      phong.SoPhong,
      
      loaiphong.IDLoaiPhong,
      loaiphong.TenLoaiPhong,
      loaiphong.MoTa AS MoTaLoaiPhong,
      
      khachsan.IDKhachSan,
      khachsan.TenKhachSan,
      khachsan.DiaChi,
      khachsan.ThanhPho,
      khachsan.SoDienThoaiKhachSan
      
    FROM DatPhong dp
    INNER JOIN TaiKhoanNguoiDung nguoidung ON dp.IDNguoiDung = nguoidung.IDNguoiDung
    INNER JOIN Phong phong ON dp.IDPhong = phong.IDPhong
    INNER JOIN LoaiPhong loaiphong ON phong.IDLoaiPhong = loaiphong.IDLoaiPhong
    INNER JOIN KhachSan khachsan ON phong.IDKhachSan = khachsan.IDKhachSan
    ORDER BY dp.NgayDatPhong DESC
  ''');

    return result;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    try {
      final result = await db.query(
        tableTaiKhoanNguoiDung, // Sử dụng đúng tên bảng người dùng
        where: 'IDNguoiDung = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        print('SQLite: Lấy người dùng IDNguoiDung: $id - Tìm thấy');
        return result.first;
      }
      print('SQLite: Lấy người dùng IDNguoiDung: $id - Không tìm thấy');
      return null;
    } catch (e) {
      print(
        'SQLite: Lỗi khi lấy thông tin người dùng IDNguoiDung: $id - Lỗi: $e',
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBookingsByUserId(int userId) async {
    print('Bắt đầu getBookingsByUserId với userId: $userId');
    final db = await instance.database;
    try {
      final result = await db.rawQuery(
        '''
      SELECT 
        dp.IDDatPhong,
        dp.NgayNhanPhong,
        dp.NgayTraPhong,
        dp.SoDem,
        dp.GiaMoiDemKhiDat,
        dp.TongTien,
        dp.NgayDatPhong,
        dp.TrangThai,
        dp.YeuCauDacBiet,
        dp.MaGiaoDich,
        
        nguoidung.HoTen AS TenNguoiDung,
        nguoidung.Email,
        nguoidung.SoDienThoai AS SoDienThoaiNguoiDung,
        
        phong.IDPhong,
        phong.SoPhong,
        
        loaiphong.IDLoaiPhong,
        loaiphong.TenLoaiPhong,
        loaiphong.MoTa AS MoTaLoaiPhong,
        
        khachsan.IDKhachSan,
        khachsan.TenKhachSan,
        khachsan.DiaChi,
        khachsan.ThanhPho,
        khachsan.SoDienThoaiKhachSan
        
      FROM DatPhong dp
      INNER JOIN TaiKhoanNguoiDung nguoidung ON dp.IDNguoiDung = nguoidung.IDNguoiDung
      INNER JOIN Phong phong ON dp.IDPhong = phong.IDPhong
      INNER JOIN LoaiPhong loaiphong ON phong.IDLoaiPhong = loaiphong.IDLoaiPhong
      INNER JOIN KhachSan khachsan ON phong.IDKhachSan = khachsan.IDKhachSan
      WHERE dp.IDNguoiDung = ?
      ORDER BY dp.NgayDatPhong DESC
    ''',
        [userId],
      );
      print('Kết quả truy vấn getBookingsByUserId: $result');
      print('Số lượng booking tìm thấy: ${result.length}');
      return result;
    } catch (e) {
      print('Lỗi trong getBookingsByUserId: $e');
      return [];
    }
  }

  //
  // Hàm nâng cấp database
  Future upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE TaiKhoanNguoiDung ADD COLUMN Role TEXT');
    }
  }

  // Thêm hoặc cập nhật người dùng
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(tableTaiKhoanNguoiDung, user);
  }

  // Lấy thông tin người dùng
  Future<List<Map<String, dynamic>>> queryUser(
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.query(
      tableTaiKhoanNguoiDung,
      where: where,
      whereArgs: whereArgs,
    );
  }

  //Xử lý cho Admin

  Future<int> insert(String table, Map<String, dynamic> values) async {
    print('Calling insert on table: $table with values: $values');
    final db = await database;
    final result = await db.insert(table, values);
    print('Insert completed with result (new ID): $result');
    return result;
  }
  //xet duyet phong

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    List<String>? columns,
  }) async {
    print(
      'Calling query on table: $table, where: $where, whereArgs: $whereArgs, columns: $columns',
    );
    final db = await database;
    final result = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      columns: columns,
    );
    print(
      'Query completed with result length: ${result.length}, data: $result',
    );
    return result;
  }

  // Lấy thông tin phòng dựa trên IDPhong
  Future<Map<String, dynamic>?> getRoomById(int idPhong) async {
    final db = await database;
    try {
      final result = await db.query(
        'Phong',
        where: 'IDPhong = ?',
        whereArgs: [idPhong],
      );
      print(
        'SQLite: Lấy phòng IDPhong: $idPhong - Tìm thấy ${result.length} bản ghi',
      );
      print('SQLite: Dữ liệu trả về: $result');
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('SQLite: Lỗi khi lấy phòng IDPhong: $idPhong - Lỗi: $e');
      return null;
    }
  }

  // Lấy thông tin loại phòng dựa trên IDLoaiPhong
  Future<Map<String, dynamic>?> getRoomTypeById(int idLoaiPhong) async {
    final db = await database;
    try {
      final result = await db.query(
        'LoaiPhong',
        where: 'IDLoaiPhong = ?',
        whereArgs: [idLoaiPhong],
      );
      print(
        'SQLite: Lấy loại phòng IDLoaiPhong: $idLoaiPhong - Tìm thấy ${result.length} bản ghi',
      );
      print('SQLite: Dữ liệu trả về: $result');
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print(
        'SQLite: Lỗi khi lấy loại phòng IDLoaiPhong: $idLoaiPhong - Lỗi: $e',
      );
      return null;
    }
  }

  // Lấy thông tin khách sạn dựa trên IDKhachSan
  Future<Map<String, dynamic>?> getHotelById(int idKhachSan) async {
    final db = await database;
    try {
      final result = await db.query(
        'KhachSan',
        where: 'IDKhachSan = ?',
        whereArgs: [idKhachSan],
      );
      print(
        'SQLite: Lấy khách sạn IDKhachSan: $idKhachSan - Tìm thấy ${result.length} bản ghi',
      );
      print('SQLite: Dữ liệu trả về: $result');
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('SQLite: Lỗi khi lấy khách sạn IDKhachSan: $idKhachSan - Lỗi: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getPaidBookings() async {
    final db = await database;
    try {
      final results = await db.rawQuery('''
      SELECT 
        dp.IDDatPhong,
        dp.IDNguoiDung,
        dp.IDPhong,
        dp.NgayNhanPhong,
        dp.NgayTraPhong,
        dp.SoDem,
        dp.GiaMoiDemKhiDat,
        dp.TongTien,
        dp.NgayDatPhong,
        dp.TrangThai,
        dp.YeuCauDacBiet,
        dp.MaGiaoDich,
        u.HoTen,
        u.Email,
        u.SoDienThoai,           -- Thêm trường số điện thoại người dùng
        p.SoPhong,               -- Thêm trường số phòng
        lp.TenLoaiPhong
      FROM DatPhong dp
      LEFT JOIN TaiKhoanNguoiDung u ON dp.IDNguoiDung = u.IDNguoiDung
      LEFT JOIN Phong p ON dp.IDPhong = p.IDPhong
      LEFT JOIN LoaiPhong lp ON p.IDLoaiPhong = lp.IDLoaiPhong
      WHERE dp.TrangThai = 'paid'
    ''');
      print(
        'SQLite: Lấy danh sách đặt phòng đã thanh toán - Tìm thấy ${results.length} bản ghi',
      );
      print('SQLite: Dữ liệu trả về: $results');
      return results;
    } catch (e) {
      print('SQLite: Lỗi khi lấy danh sách đặt phòng đã thanh toán - Lỗi: $e');
      return [];
    }
  }

  // Future<List<Map<String, dynamic>>> rawQuery(
  //   String sql, [
  //   List<dynamic>? arguments,
  // ]) async {
  //   print('Calling rawQuery with SQL: $sql, arguments: $arguments');
  //   final db = await database;
  //   final result = await db.rawQuery(sql, arguments);
  //   print(
  //     'RawQuery completed with result length: ${result.length}, data: $result',
  //   );
  //   return result;
  // }

  // Future<int> update(
  //   String table,
  //   Map<String, dynamic> values, {
  //   String? where,
  //   List<dynamic>? whereArgs,
  // }) async {
  //   print(
  //     'Calling update on table: $table with values: $values, where: $where, whereArgs: $whereArgs',
  //   );
  //   final db = await database;
  //   final result = await db.update(
  //     table,
  //     values,
  //     where: where,
  //     whereArgs: whereArgs,
  //   );
  //   print('Update completed with result: $result');
  //   return result;
  // }
  // Lấy danh sách đặt phòng hết hạn trong ngày hôm nay
  Future<List<Map<String, dynamic>>> getExpiredBookingsToday() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    try {
      // Sử dụng rawQuery với JOIN để lấy thông tin từ DatPhong, Phong, KhachSan, và NguoiDung
      final results = await db.rawQuery(
        """
      SELECT 
        dp.IDDatPhong,
        dp.NgayNhanPhong,
        dp.NgayTraPhong,
        dp.SoDem,
        dp.GiaMoiDemKhiDat,
        dp.TongTien,
        dp.TrangThai,
        p.IDPhong,
        p.SoPhong,
        p.DangTrong,
        ks.IDKhachSan,
        ks.TenKhachSan,
        ks.DiaChi,
        nd.IDNguoiDung,
        nd.HoTen AS TenNguoiDat,
        nd.SoDienThoai AS SoDienThoaiNguoiDat,
        nd.Email AS EmailNguoiDat
      FROM DatPhong dp
      INNER JOIN Phong p ON dp.IDPhong = p.IDPhong
      INNER JOIN KhachSan ks ON p.IDKhachSan = ks.IDKhachSan
      INNER JOIN TaiKhoanNguoiDung nd ON dp.IDNguoiDung = nd.IDNguoiDung
      WHERE dp.NgayTraPhong BETWEEN ? AND ? AND dp.TrangThai = ?
    """,
        [startOfDay.toIso8601String(), endOfDay.toIso8601String(), 'confirmed'],
      );

      // Log chi tiết kết quả
      print(
        'SQLite: Lấy danh sách đặt phòng hết hạn hôm nay - Tìm thấy ${results.length} bản ghi',
      );
      for (var result in results) {
        print(
          'SQLite: Dữ liệu đặt phòng hết hạn - IDDatPhong: ${result['IDDatPhong']}, '
          'Phòng: ${result['SoPhong']}, Khách sạn: ${result['TenKhachSan']}, '
          'Trạng thái phòng: ${result['DangTrong'] == 1 ? 'Trống' : 'Đang thuê'}, '
          'Người đặt: ${result['TenNguoiDat']} (${result['EmailNguoiDat']}), '
          'NgayTraPhong: ${result['NgayTraPhong']}',
        );
      }

      return results;
    } catch (e) {
      print('SQLite: Lỗi khi lấy danh sách đặt phòng hết hạn - Lỗi: $e');
      return [];
    }
  }

  // // Cập nhật trạng thái phòng thành trống
  // Future<void> updateRoomStatus(int idPhong, int dangTrong) async {
  //   final db = await database;
  //   try {
  //     await db.update(
  //       'Phong',
  //       {'DangTrong': dangTrong},
  //       where: 'IDPhong = ?',
  //       whereArgs: [idPhong],
  //     );
  //     print(
  //       'SQLite: Cập nhật trạng thái phòng IDPhong: $idPhong thành DangTrong: $dangTrong',
  //     );
  //   } catch (e) {
  //     print(
  //       'SQLite: Lỗi khi cập nhật trạng thái phòng IDPhong: $idPhong - Lỗi: $e',
  //     );
  //     throw e;
  //   }
  // }

  Future<List<Map<String, dynamic>>> queryDatPhongForGiaHan() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT DatPhong.*, TaiKhoanNguoiDung.HoTen
      FROM DatPhong
      LEFT JOIN TaiKhoanNguoiDung ON DatPhong.IDNguoiDung = TaiKhoanNguoiDung.IDNguoiDung
      WHERE DatPhong.TrangThai = 'confirmed'
    ''');
  }

  Future<int> updateGiaHanDatPhong(
    int id,
    String newNgayTraPhong,
    double newTongTien,
    int newSoDem,
  ) async {
    final db = await database;
    return await db.update(
      tableDatPhong,
      {
        'NgayTraPhong': newNgayTraPhong,
        'TongTien': newTongTien,
        'SoDem': newSoDem,
      },
      where: 'IDDatPhong = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDatPhong(int id) async {
    final db = await database;
    return await db.delete(
      tableDatPhong,
      where: 'IDDatPhong = ?',
      whereArgs: [id],
    );
  }
}

Future<List<Map<String, dynamic>>> getBookingsForReminder() async {
  print('Bắt đầu kiểm tra booking để gửi nhắc nhở');
  final db = await instance.database;
  try {
    // Lấy ngày mai dưới định dạng phù hợp với NgayNhanPhong (giả sử định dạng là 'YYYY-MM-DD')
    final tomorrow = DateTime.now().add(Duration(days: 1));
    final tomorrowFormatted = tomorrow.toIso8601String().split('T')[0];
    print('Ngày mai: $tomorrowFormatted');

    final result = await db.rawQuery(
      '''
      SELECT 
        dp.IDDatPhong,
        dp.NgayNhanPhong,
        dp.NgayTraPhong,
        dp.SoDem,
        dp.TongTien,
        dp.TrangThai,
        nguoidung.HoTen AS TenNguoiDung,
        nguoidung.Email,
        khachsan.TenKhachSan,
        khachsan.DiaChi,
        khachsan.ThanhPho,
        phong.SoPhong,
        loaiphong.TenLoaiPhong
      FROM DatPhong dp
      INNER JOIN TaiKhoanNguoiDung nguoidung ON dp.IDNguoiDung = nguoidung.IDNguoiDung
      INNER JOIN Phong phong ON dp.IDPhong = phong.IDPhong
      INNER JOIN LoaiPhong loaiphong ON phong.IDLoaiPhong = loaiphong.IDLoaiPhong
      INNER JOIN KhachSan khachsan ON phong.IDKhachSan = khachsan.IDKhachSan
      WHERE dp.NgayNhanPhong = ? AND dp.TrangThai = 'Đã xác nhận'
    ''',
      [tomorrowFormatted],
    );
    print('Booking cần nhắc nhở: $result');
    print('Số lượng booking: ${result.length}');
    return result;
  } catch (e) {
    print('Lỗi khi lấy booking nhắc nhở: $e');
    return [];
  }
}
