import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../database/db_helper.dart';
import '../models/note.dart';
import 'login_screen.dart';

class MainScreen2 extends StatefulWidget {
  final int userId;
  final String username;

  const MainScreen2({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<MainScreen2> createState() => _MainScreen2State();
}

class _MainScreen2State extends State<MainScreen2> {
  final DbHelper _db = DbHelper();
  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;
  bool _showForm = false;
  bool _showFolderForm = false;
  int? _editingId;
  int? _editingFolderIndex;
  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  bool _isDarkMode = true;
  String _sortOrder = 'Terbaru';

  // 📚 DATA MATA KULIAH (FOLDER) - BISA DI-CRUD!
  List<Map<String, String>> _mataKuliahList = [
    {'nama': 'Kecerdasan Bisnis', 'dosen': 'Feby Charlos', 'hari': 'Senin', 'jam': '08.50 - 10.30'},
    {'nama': 'Bahasa Inggris 2', 'dosen': 'Meida Fitriana', 'hari': 'Senin', 'jam': '10.30 - 12.10'},
    {'nama': 'Komputer dan Masyarakat', 'dosen': 'Kanim', 'hari': 'Senin', 'jam': '13.00 - 14.40'},
    {'nama': 'Rekayasa Perangkat Lunak', 'dosen': 'Fauzan Dika', 'hari': 'Selasa', 'jam': '07.10 - 08.50'},
    {'nama': 'Analisa Proses Bisnis', 'dosen': 'Melati Rahma Suri', 'hari': 'Selasa', 'jam': '08.50 - 10.30'},
    {'nama': 'Mobile Programming', 'dosen': 'Leo Sandi', 'hari': 'Rabu', 'jam': '07.10 - 08.50'},
    {'nama': 'Matrik dan Transformasi Linier', 'dosen': 'Kanim', 'hari': 'Rabu', 'jam': '08.50 - 10.30'},
    {'nama': 'Keamanan Komputer', 'dosen': 'Yuda Pratama Wibawa', 'hari': 'Rabu', 'jam': '10.30 - 12.10'},
  ];

  final List<String> _kategoriList = ['Semua', 'Teori', 'Praktikum', 'Tugas', 'UTS', 'UAS'];
  final List<String> _sortOptions = ['Terbaru', 'Terlama'];
  final List<String> _hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  // Controllers untuk Folder
  final TextEditingController _folderNamaController = TextEditingController();
  final TextEditingController _folderDosenController = TextEditingController();
  final TextEditingController _folderHariController = TextEditingController();
  final TextEditingController _folderJamController = TextEditingController();

  // Controllers untuk Catatan
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _materiController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedMatkul = '';
  String _selectedDosen = '';
  String _selectedHari = '';
  String _selectedJam = '';
  String _selectedKategori = 'Teori';
  String? _expandedFolder;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // ============================================================
  // 📥 LOAD & FILTER NOTES
  // ============================================================
  Future<void> _loadNotes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final notes = await _db.getNotes(widget.userId);
      if (mounted) {
        setState(() {
          _allNotes = notes;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    var notes = _allNotes;

    if (_searchQuery.isNotEmpty) {
      notes = notes.where((note) =>
        note.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        note.mataKuliah.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        note.materi.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_selectedFilter != 'Semua') {
      notes = notes.where((note) => note.kategori == _selectedFilter).toList();
    }

    if (_sortOrder == 'Terbaru') {
      notes.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    } else {
      notes.sort((a, b) => a.tanggal.compareTo(b.tanggal));
    }

    setState(() {
      _filteredNotes = notes;
    });
  }

  List<Note> _getNotesByMatkul(String matkul) {
    return _filteredNotes.where((note) => note.mataKuliah == matkul).toList();
  }

  // ============================================================
  // 📁 CRUD FOLDER (MATA KULIAH)
  // ============================================================
  void _showAddFolderForm() {
    if (!mounted) return;
    _editingFolderIndex = null;
    _folderNamaController.clear();
    _folderDosenController.clear();
    _folderHariController.clear();
    _folderJamController.clear();
    setState(() => _showFolderForm = true);
  }

  void _showEditFolderForm(int index) {
    if (!mounted) return;
    final folder = _mataKuliahList[index];
    _editingFolderIndex = index;
    _folderNamaController.text = folder['nama'] ?? '';
    _folderDosenController.text = folder['dosen'] ?? '';
    _folderHariController.text = folder['hari'] ?? '';
    _folderJamController.text = folder['jam'] ?? '';
    setState(() => _showFolderForm = true);
  }

  void _saveFolder() async {
    final nama = _folderNamaController.text.trim();
    final dosen = _folderDosenController.text.trim();
    final hari = _folderHariController.text.trim();
    final jam = _folderJamController.text.trim();

    if (nama.isEmpty || dosen.isEmpty || hari.isEmpty || jam.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua field folder harus diisi!'), backgroundColor: Colors.amber),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        if (_editingFolderIndex == null) {
          _mataKuliahList.add({
            'nama': nama,
            'dosen': dosen,
            'hari': hari,
            'jam': jam,
          });
        } else {
          _mataKuliahList[_editingFolderIndex!] = {
            'nama': nama,
            'dosen': dosen,
            'hari': hari,
            'jam': jam,
          };
        }
        _showFolderForm = false;
        _folderNamaController.clear();
        _folderDosenController.clear();
        _folderHariController.clear();
        _folderJamController.clear();
        _editingFolderIndex = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingFolderIndex == null ? 'Folder berhasil ditambahkan!' : 'Folder berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _deleteFolder(int index) {
    if (!mounted) return;
    final nama = _mataKuliahList[index]['nama'] ?? '';
    final notesInFolder = _allNotes.where((note) => note.mataKuliah == nama).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF1A2744) : Colors.white,
        title: Text('Hapus Folder?', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yakin ingin menghapus folder "$nama"?',
                style: TextStyle(color: _isDarkMode ? Colors.grey[300] : Colors.grey[700])),
            if (notesInFolder.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Ada ${notesInFolder.length} catatan di folder ini yang akan terhapus!',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              for (var note in notesInFolder) {
                await _db.deleteNote(note.id!);
              }

              if (mounted) {
                setState(() {
                  _mataKuliahList.removeAt(index);
                });
                await _loadNotes();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Folder berhasil dihapus!'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📝 CRUD CATATAN
  // ============================================================
  void _showAddForm({String? matkul, String? dosen, String? hari, String? jam}) {
    if (!mounted) return;
    _editingId = null;
    _selectedMatkul = matkul ?? '';
    _selectedDosen = dosen ?? '';
    _selectedHari = hari ?? '';
    _selectedJam = jam ?? '';
    _judulController.clear();
    _materiController.clear();
    _tanggalController.text = DateTime.now().toString().split(' ')[0];
    _selectedKategori = 'Teori';
    setState(() => _showForm = true);
  }

  void _showEditForm(Note note) {
    if (!mounted) return;
    _editingId = note.id;
    _selectedMatkul = note.mataKuliah;
    _selectedDosen = note.dosen;
    _selectedHari = note.hari;
    _selectedJam = note.jam;
    _judulController.text = note.judul;
    _materiController.text = note.materi;
    _tanggalController.text = note.tanggal;
    _selectedKategori = note.kategori;
    setState(() => _showForm = true);
  }

  Future<void> _saveNote() async {
    final judul = _judulController.text.trim();
    final materi = _materiController.text.trim();
    final tanggal = _tanggalController.text.trim();

    if (_selectedMatkul.isEmpty || judul.isEmpty || materi.isEmpty || tanggal.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua field harus diisi!'), backgroundColor: Colors.amber),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final note = Note(
        id: _editingId,
        userId: widget.userId,
        mataKuliah: _selectedMatkul,
        dosen: _selectedDosen,
        judul: judul,
        materi: materi,
        tanggal: tanggal,
        kategori: _selectedKategori,
        hari: _selectedHari,
        jam: _selectedJam,
      );

      Map<String, dynamic> result;
      if (_editingId == null) {
        result = await _db.addNote(note);
      } else {
        result = await _db.updateNote(note);
      }

      if (result['success'] == true) {
        if (mounted) {
          setState(() {
            _showForm = false;
            _judulController.clear();
            _materiController.clear();
            _tanggalController.clear();
            _editingId = null;
          });
          await _loadNotes();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_editingId == null ? 'Catatan berhasil ditambahkan!' : 'Catatan berhasil diupdate!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal menyimpan'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteNote(int id, String judul) async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF1A2744) : Colors.white,
        title: Text('Hapus Catatan?', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        content: Text('Yakin ingin menghapus "$judul"?',
            style: TextStyle(color: _isDarkMode ? Colors.grey[300] : Colors.grey[700])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                final result = await _db.deleteNote(id);
                if (result['success'] == true) {
                  await _loadNotes();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Catatan berhasil dihapus!'), backgroundColor: Colors.green),
                    );
                  }
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📤 SHARE CATATAN
  // ============================================================
  void _shareNote(Note note) {
    final text = '''
📚 *Catatan Kuliah*
━━━━━━━━━━━━━━━━━━━━━
📌 Judul: ${note.judul}
📖 Mata Kuliah: ${note.mataKuliah}
👨‍🏫 Dosen: ${note.dosen}
📅 Tanggal: ${note.tanggal}
🏷️ Kategori: ${note.kategori}
━━━━━━━━━━━━━━━━━━━━━
📝 Materi:
${note.materi}
━━━━━━━━━━━━━━━━━━━━━
📱 Dibagikan dari Aplikasi Catatan Kuliah
    ''';
    Share.share(text);
  }

  // ============================================================
  // 🔍 SHOW DETAIL
  // ============================================================
  void _showDetail(Note note) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _isDarkMode ? const Color(0xFF1A2744) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.description, color: const Color(0xFF3B82F6)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note.judul,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                            color: _isDarkMode ? Colors.white : Colors.black)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(note.kategori),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(note.kategori, style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.grey, height: 32),
              _buildDetailRow(Icons.book, 'Mata Kuliah', note.mataKuliah),
              _buildDetailRow(Icons.person, 'Dosen', note.dosen),
              _buildDetailRow(Icons.calendar_today, 'Tanggal', note.tanggal),
              _buildDetailRow(Icons.access_time, 'Jam', '${note.hari} ${note.jam}'),
              const SizedBox(height: 12),
              Text('📝 Materi:',
                style: TextStyle(fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isDarkMode ? const Color(0xFF0A1628) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
                ),
                child: Text(note.materi,
                  style: TextStyle(color: _isDarkMode ? Colors.grey[300] : Colors.grey[700], height: 1.6)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { _shareNote(note); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[600]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 18),
          const SizedBox(width: 8),
          Text('$label: ',
            style: TextStyle(color: _isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
          Expanded(child: Text(value,
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black, fontSize: 14))),
        ],
      ),
    );
  }

  Color _getCategoryColor(String kategori) {
    switch (kategori) {
      case 'Teori': return Colors.purple;
      case 'Praktikum': return Colors.orange;
      case 'Tugas': return Colors.green;
      case 'UTS': return Colors.red;
      case 'UAS': return Colors.amber;
      default: return Colors.grey;
    }
  }

  // ============================================================
  // 🎨 TEMA
  // ============================================================
  Color get bgColor => _isDarkMode ? const Color(0xFF0A1628) : const Color(0xFFF0F4FF);
  Color get cardColor => _isDarkMode ? const Color(0xFF1A2744) : const Color(0xFFFFFFFF);
  Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF0A1628);
  Color get subTextColor => _isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  Color get accentColor => const Color(0xFF3B82F6);

  // ============================================================
  // 🏠 BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.folder, color: accentColor),
            const SizedBox(width: 8),
            Text('Folder Kuliah', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder, color: accentColor),
            tooltip: 'Tambah Folder',
            onPressed: _showAddFolderForm,
          ),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, color: textColor),
            onPressed: () {
              if (mounted) {
                setState(() => _isDarkMode = !_isDarkMode);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: textColor),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6))))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accentColor.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: textColor),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilters();
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari catatan...',
                        hintStyle: TextStyle(color: subTextColor),
                        prefixIcon: Icon(Icons.search, color: accentColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: subTextColor),
                                onPressed: () {
                                  _searchController.clear();
                                  if (mounted) {
                                    setState(() {
                                      _searchQuery = '';
                                      _applyFilters();
                                    });
                                  }
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _kategoriList.length,
                            itemBuilder: (context, index) {
                              final filter = _kategoriList[index];
                              final isSelected = _selectedFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(filter),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    if (mounted) {
                                      setState(() {
                                        _selectedFilter = filter;
                                        _applyFilters();
                                      });
                                    }
                                  },
                                  backgroundColor: cardColor,
                                  selectedColor: accentColor,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : subTextColor,
                                    fontSize: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: isSelected ? accentColor : Colors.grey[700]!),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _sortOrder,
                        dropdownColor: cardColor,
                        style: TextStyle(color: textColor),
                        icon: Icon(Icons.sort, color: subTextColor),
                        underline: Container(),
                        items: _sortOptions.map((option) {
                          return DropdownMenuItem(value: option, child: Text(option));
                        }).toList(),
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              _sortOrder = value!;
                              _applyFilters();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _mataKuliahList.isEmpty
                      ? _buildEmptyFolderState()
                      : _buildFolderList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddForm(),
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomSheet: _showForm ? _buildForm() : _showFolderForm ? _buildFolderForm() : null,
    );
  }

  Widget _buildEmptyFolderState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: subTextColor),
          const SizedBox(height: 16),
          Text('Belum ada folder', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: subTextColor)),
          const SizedBox(height: 8),
          Text('Tap + di pojok kanan atas untuk buat folder', style: TextStyle(color: subTextColor)),
        ],
      ),
    );
  }

  Widget _buildFolderList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _mataKuliahList.length,
      itemBuilder: (context, index) {
        final matkul = _mataKuliahList[index];
        final nama = matkul['nama']!;
        final dosen = matkul['dosen']!;
        final hari = matkul['hari']!;
        final jam = matkul['jam']!;
        final notes = _getNotesByMatkul(nama);
        final isExpanded = _expandedFolder == nama;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      _expandedFolder = isExpanded ? null : nama;
                    });
                  }
                },
                leading: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.folder, color: accentColor),
                ),
                title: Text(
                  nama,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '👨‍🏫 $dosen • ${notes.length} catatan • $hari $jam',
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange, size: 20),
                      onPressed: () => _showEditFolderForm(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _deleteFolder(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: accentColor, size: 20),
                      onPressed: () => _showAddForm(matkul: nama, dosen: dosen, hari: hari, jam: jam),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: subTextColor,
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                if (notes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Belum ada catatan untuk mata kuliah ini',
                      style: TextStyle(color: subTextColor, fontSize: 13),
                    ),
                  )
                else
                  ...notes.map((note) => _buildNoteItem(note)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoteItem(Note note) {
    return GestureDetector(
      onTap: () => _showDetail(note),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getCategoryColor(note.kategori),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.judul,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(note.kategori).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          note.kategori,
                          style: TextStyle(
                            color: _getCategoryColor(note.kategori),
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        note.tanggal,
                        style: TextStyle(color: subTextColor, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: subTextColor, size: 18),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: cardColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: Icon(Icons.edit, color: accentColor),
                            title: Text('Edit', style: TextStyle(color: textColor)),
                            onTap: () {
                              Navigator.pop(context);
                              _showEditForm(note);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.share, color: Colors.green),
                            title: Text('Share', style: TextStyle(color: textColor)),
                            onTap: () {
                              Navigator.pop(context);
                              _shareNote(note);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Hapus', style: TextStyle(color: Colors.red)),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteNote(note.id!, note.judul);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📁 FOLDER FORM
  // ============================================================
  Widget _buildFolderForm() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(
            _editingFolderIndex == null ? '📁 Tambah Folder' : '✏️ Edit Folder',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _folderNamaController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Nama Mata Kuliah',
              labelStyle: TextStyle(color: subTextColor),
              prefixIcon: Icon(Icons.book, color: accentColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _folderDosenController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Nama Dosen',
              labelStyle: TextStyle(color: subTextColor),
              prefixIcon: Icon(Icons.person, color: accentColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _folderHariController.text.isNotEmpty ? _folderHariController.text : null,
            style: TextStyle(color: textColor),
            dropdownColor: cardColor,
            decoration: InputDecoration(
              labelText: 'Hari',
              labelStyle: TextStyle(color: subTextColor),
              prefixIcon: Icon(Icons.calendar_today, color: accentColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
            ),
            items: _hariList.map((hari) {
              return DropdownMenuItem(value: hari, child: Text(hari));
            }).toList(),
            onChanged: (value) {
              if (mounted) {
                setState(() => _folderHariController.text = value ?? '');
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _folderJamController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Jam (contoh: 08.50 - 10.30)',
              labelStyle: TextStyle(color: subTextColor),
              prefixIcon: Icon(Icons.access_time, color: accentColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveFolder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_editingFolderIndex == null ? 'Tambah' : 'Update',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _showFolderForm = false;
                        _editingFolderIndex = null;
                        _folderNamaController.clear();
                        _folderDosenController.clear();
                        _folderHariController.clear();
                        _folderJamController.clear();
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[600]!),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================================================
  // 📝 CATATAN FORM
  // ============================================================
  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(
            _editingId == null ? '📝 Tambah Catatan' : '✏️ Edit Catatan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedMatkul.isNotEmpty ? _selectedMatkul : null,
            style: TextStyle(color: textColor),
            dropdownColor: cardColor,
            decoration: InputDecoration(
              labelText: 'Mata Kuliah',
              labelStyle: TextStyle(color: subTextColor),
              prefixIcon: Icon(Icons.book, color: accentColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
            ),
            items: _mataKuliahList.map((matkul) {
              return DropdownMenuItem(
                value: matkul['nama'],
                child: Text('${matkul['nama']} - ${matkul['dosen']}'),
              );
            }).toList(),
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  _selectedMatkul = value!;
                  final matkul = _mataKuliahList.firstWhere((m) => m['nama'] == value);
                  _selectedDosen = matkul['dosen']!;
                  _selectedHari = matkul['hari']!;
                  _selectedJam = matkul['jam']!;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _judulController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Judul Catatan',
              labelStyle: TextStyle(color: subTextColor),
              prefixIcon: Icon(Icons.title, color: accentColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _materiController,
            style: TextStyle(color: textColor),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Materi',
              labelStyle: TextStyle(color: subTextColor),
              prefixIcon: Icon(Icons.description, color: accentColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tanggalController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Tanggal (YYYY-MM-DD)',
              labelStyle: TextStyle(color: subTextColor),
              prefixIcon: Icon(Icons.calendar_today, color: accentColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedKategori,
            style: TextStyle(color: textColor),
            dropdownColor: cardColor,
            decoration: InputDecoration(
              labelText: 'Kategori',
              labelStyle: TextStyle(color: subTextColor),
              prefixIcon: Icon(Icons.category, color: accentColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
            ),
            items: ['Teori', 'Praktikum', 'Tugas', 'UTS', 'UAS'].map((k) {
              return DropdownMenuItem(value: k, child: Text(k));
            }).toList(),
            onChanged: (value) {
              if (mounted) {
                setState(() => _selectedKategori = value!);
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_editingId == null ? 'Tambah' : 'Update',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _showForm = false;
                        _editingId = null;
                        _judulController.clear();
                        _materiController.clear();
                        _tanggalController.clear();
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[600]!),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}