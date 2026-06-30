class Note {
  int? id;
  int userId;
  String mataKuliah;
  String dosen;
  String judul;
  String materi;
  String tanggal;
  String kategori;
  String hari;
  String jam;
  bool isFavorite;

  Note({
    this.id,
    required this.userId,
    required this.mataKuliah,
    this.dosen = '',
    required this.judul,
    required this.materi,
    required this.tanggal,
    required this.kategori,
    this.hari = '',
    this.jam = '',
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'mata_kuliah': mataKuliah,
    'dosen': dosen,
    'judul': judul,
    'materi': materi,
    'tanggal': tanggal,
    'kategori': kategori,
    'hari': hari,
    'jam': jam,
    'is_favorite': isFavorite ? 1 : 0,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    userId: json['user_id'] ?? 0,
    mataKuliah: json['mata_kuliah'] ?? '',
    dosen: json['dosen'] ?? '',
    judul: json['judul'] ?? '',
    materi: json['materi'] ?? '',
    tanggal: json['tanggal'] ?? '',
    kategori: json['kategori'] ?? '',
    hari: json['hari'] ?? '',
    jam: json['jam'] ?? '',
    isFavorite: json['is_favorite'] == 1,
  );
}