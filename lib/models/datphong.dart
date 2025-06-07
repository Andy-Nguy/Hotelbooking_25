class DatPhong {
  final int id;
  final int idNguoiDung;
  final int idPhong;
  final String ngayNhanPhong;
  final String ngayTraPhong;
  final int soDem;
  final double giaMoiDem;
  final double tongTien;
  final String ngayDatPhong;
  final String trangThai;
  final String? yeuCauDacBiet;
  final String? maGiaoDich;

  DatPhong({
    required this.id,
    required this.idNguoiDung,
    required this.idPhong,
    required this.ngayNhanPhong,
    required this.ngayTraPhong,
    required this.soDem,
    required this.giaMoiDem,
    required this.tongTien,
    required this.ngayDatPhong,
    required this.trangThai,
    this.yeuCauDacBiet,
    this.maGiaoDich,
  });

  factory DatPhong.fromMap(Map<String, dynamic> map) {
    return DatPhong(
      id: map['IDDatPhong'],
      idNguoiDung: map['IDNguoiDung'],
      idPhong: map['IDPhong'],
      ngayNhanPhong: map['NgayNhanPhong'],
      ngayTraPhong: map['NgayTraPhong'],
      soDem: map['SoDem'],
      giaMoiDem: map['GiaMoiDemKhiDat'],
      tongTien: map['TongTien'],
      ngayDatPhong: map['NgayDatPhong'],
      trangThai: map['TrangThai'],
      yeuCauDacBiet: map['YeuCauDacBiet'],
      maGiaoDich: map['MaGiaoDich'],
    );
  }
}
