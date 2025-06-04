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
      'TenKhachSan': 'JW Marriott Hotel Hanoi',
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
      'UrlAnh': 'assets/image/jw_phuquoc_gallery_1.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_gallery_1.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_gallery_1.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_gallery_1.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_gallery_1.jpg',
      'ChuThich': 'Bãi biển riêng',
    });
    batchAnhKS.insert(tableAnhKhachSan, {
      'IDKhachSan': jwPhuQuocId,
      'UrlAnh': 'assets/image/jw_phuquoc_gallery_1.jpg',
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
          'Diện tích 80m², phòng khách riêng, truy cập Executive Lounge, view sông.',
      'SoKhachToiDa': 2,
      'GiaCoBanMoiDem': 9000000,
      'UrlAnhChinh': 'assets/image/jw_saigon_executive_suite_main.jpg',
    });
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwHanoiId,
      'TenLoaiPhong': 'Phòng Deluxe Lake View',
      'MoTa':
          'Diện tích 48m², giường King hoặc 2 giường đơn, tầm nhìn ra hồ Mễ Trì.',
      'SoKhachToiDa': 2,
      'GiaCoBanMoiDem': 4800000,
      'UrlAnhChinh': 'assets/image/jw_hanoi_deluxe_lake_main.jpg',
    });
    batchLoaiPhong.insert(tableLoaiPhong, {
      'IDKhachSan': jwPhuQuocId,
      'TenLoaiPhong': 'Emerald Bay View',
      'MoTa':
          'Diện tích 53m², ban công riêng nhìn ra Vịnh Ngọc Bích tuyệt đẹp.',
      'SoKhachToiDa': 2,
      'GiaCoBanMoiDem': 7500000,
      'UrlAnhChinh': 'assets/image/jw_phuquoc_emerald_bay_view_main.jpg',
    });
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
    int jwHanoiDeluxeLakeRTId =
        roomTypes.firstWhere(
              (rt) =>
                  rt['TenLoaiPhong'] == 'Phòng Deluxe Lake View' &&
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

    // --- AnhLoaiPhong ---
    Batch batchAnhLP = db.batch();
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'UrlAnh': 'assets/image/jw_saigon_deluxe_king_gallery1.jpg',
      'ChuThich': 'Giường King thoải mái',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwSaigonDeluxeKingRTId,
      'UrlAnh': 'assets/image/jw_saigon_deluxe_king_gallery2.jpg',
      'ChuThich': 'Phòng tắm',
    });
    batchAnhLP.insert(tableAnhLoaiPhong, {
      'IDLoaiPhong': jwPhuQuocEmeraldRTId,
      'UrlAnh': 'assets/image/jw_phuquoc_emerald_bay_view_gallery1.jpg',
      'ChuThich': 'Ban công view biển',
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
    final List<Map<String, dynamic>> hotelInfoList = await db.query(
      tableKhachSan,
      where: 'IDKhachSan = ?',
      whereArgs: [hotelId],
    );
    if (hotelInfoList.isEmpty) {
      print(
        "SQLite: Không tìm thấy khách sạn với ID: $hotelId trong getFullHotelDetails",
      );
      return null;
    }
    Map<String, dynamic> hotelData = Map<String, dynamic>.from(
      hotelInfoList.first,
    );
    print("SQLite: Thông tin khách sạn ID $hotelId: $hotelData");

    hotelData['gallery'] = await getAnhKhachSan(hotelId);
    hotelData['amenities'] = await getTienNghiKhachSan(hotelId);

    List<Map<String, dynamic>> roomTypesRaw = await getLoaiPhongByKhachSan(
      hotelId,
    );
    List<Map<String, dynamic>> roomTypesDetailed = [];
    for (var rtRaw in roomTypesRaw) {
      Map<String, dynamic> roomTypeData = Map<String, dynamic>.from(rtRaw);
      int roomTypeId = roomTypeData['IDLoaiPhong'] as int;

      roomTypeData['gallery'] = await getAnhLoaiPhong(roomTypeId);
      roomTypeData['amenities'] = await getTienNghiLoaiPhong(roomTypeId);
      roomTypeData['rooms_specific'] = await getPhongByLoaiPhong(roomTypeId);

      roomTypesDetailed.add(roomTypeData);
    }
    hotelData['room_types'] = roomTypesDetailed;
    print(
      "SQLite: Loại phòng chi tiết cho ID $hotelId: ${hotelData['room_types']}",
    );

    hotelData['reviews'] = [];
    print(
      "SQLite: Lấy chi tiết khách sạn ID $hotelId - Thành công. Dữ liệu đầy đủ: $hotelData",
    );
    return hotelData;
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
}
