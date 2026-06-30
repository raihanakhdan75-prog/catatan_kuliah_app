import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../database/db_helper.dart';
import '../models/note.dart';
import 'login_screen.dart';
import 'main_screen2.dart';

class MainScreen extends StatefulWidget {
  final int userId;
  final String username;

  const MainScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DbHelper _db = DbHelper();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;
  bool _showForm = false;
  int? _editingId;
  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  bool _isDarkMode = true;
  String _sortOrder = 'Terbaru';

  final List<String> _kategoriList = ['Semua', 'Teori', 'Praktikum', 'Tugas', 'UTS', 'UAS'];
  final List<String> _sortOptions = ['Terbaru', 'Terlama'];
  final List<String> _matkulList = [
    'Kecerdasan Bisnis',
    'Bahasa Inggris 2',
    'Komputer dan Masyarakat',
    'Rekayasa Perangkat Lunak',
    'Mobile Programming',
    'Analisa Proses Bisnis',
    'Matrik dan Transformasi Linier',
    'Keamanan Komputer',
  ];
  final List<String> _kategoriDropdownList = [
    'Teori', 'Praktikum', 'Tugas', 'UTS', 'UAS', 'Lainnya'
  ];

  final TextEditingController _matkulController = TextEditingController();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _materiController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final notes = await _db.getNotes(widget.userId);
      if (mounted) {
        setState(() {
          _notes = notes;
          _filteredNotes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    var notes = _notes;
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
    setState(() => _filteredNotes = notes);
  }

  Color get bgColor => _isDarkMode ? const Color(0xFF0A1628) : const Color(0xFFF0F4FF);
  Color get cardColor => _isDarkMode ? const Color(0xFF1A2744) : const Color(0xFFFFFFFF);
  Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF0A1628);
  Color get subTextColor => _isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  Color get accentColor => const Color(0xFF3B82F6);

  void _shareNote(Note note) {
    final text = '''
📚 *Catatan Kuliah*
━━━━━━━━━━━━━━━━━━━━━
📌 Judul: ${note.judul}
📖 Mata Kuliah: ${note.mataKuliah}
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

  void _showDetail(Note note) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.description, color: accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note.judul, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
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
              ]),
              const Divider(color: Colors.grey, height: 32),
              _buildDetailRow(Icons.book, 'Mata Kuliah', note.mataKuliah),
              _buildDetailRow(Icons.calendar_today, 'Tanggal', note.tanggal),
              const SizedBox(height: 12),
              const Text('📝 Materi:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withOpacity(0.1)),
                ),
                child: Text(note.materi, style: TextStyle(color: subTextColor, height: 1.6)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareNote(note),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
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
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: subTextColor, fontSize: 14)),
          Expanded(child: Text(value, style: TextStyle(color: textColor, fontSize: 14))),
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

  IconData _getCategoryIcon(String kategori) {
    switch (kategori) {
      case 'Teori': return Icons.lightbulb;
      case 'Praktikum': return Icons.computer;
      case 'Tugas': return Icons.assignment;
      case 'UTS': return Icons.school;
      case 'UAS': return Icons.emoji_events;
      default: return Icons.note;
    }
  }

  void _showAddForm() {
    if (!mounted) return;
    _editingId = null;
    _matkulController.clear();
    _judulController.clear();
    _materiController.clear();
    _tanggalController.clear();
    _kategoriController.clear();
    setState(() => _showForm = true);
  }

  void _showEditForm(Note note) {
    if (!mounted) return;
    _editingId = note.id;
    _matkulController.text = note.mataKuliah;
    _judulController.text = note.judul;
    _materiController.text = note.materi;
    _tanggalController.text = note.tanggal;
    _kategoriController.text = note.kategori;
    setState(() => _showForm = true);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Color(0xFF1A2744),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1A2744),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = picked.toString().split(' ')[0];
      });
    }
  }

  Future<void> _saveNote() async {
    final matkul = _matkulController.text.trim();
    final judul = _judulController.text.trim();
    final materi = _materiController.text.trim();
    final tanggal = _tanggalController.text.trim();

    if (matkul.isEmpty || judul.isEmpty || materi.isEmpty || tanggal.isEmpty) {
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
        mataKuliah: matkul,
        judul: judul,
        materi: materi,
        tanggal: tanggal,
        kategori: _kategoriController.text.trim().isEmpty ? 'Lainnya' : _kategoriController.text.trim(),
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
            _clearControllers();
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearControllers() {
    _matkulController.clear();
    _judulController.clear();
    _materiController.clear();
    _tanggalController.clear();
    _kategoriController.clear();
  }

  Future<void> _deleteNote(int id, String judul) async {
  final scaffoldContext = context;
  
  showDialog(
    context: scaffoldContext,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: cardColor,
      title: Text('Hapus Catatan?', style: TextStyle(color: textColor)),
      content: Text('Yakin ingin menghapus "$judul"?', style: TextStyle(color: subTextColor)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            
            if (mounted) {
              setState(() => _isLoading = true);
            }
            
            try {
              final result = await _db.deleteNote(id);
              if (result['success'] == true) {
                await _loadNotes();
                if (mounted) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Catatan berhasil dihapus!'), backgroundColor: Colors.green),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
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

  Widget _buildStats() {
    int total = _notes.length;
    int totalMatkul = _notes.map((n) => n.mataKuliah).toSet().length;
    int totalKategori = _notes.map((n) => n.kategori).toSet().length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.note, 'Total', total.toString(), Colors.blue),
          _buildStatItem(Icons.book, 'Matkul', totalMatkul.toString(), Colors.green),
          _buildStatItem(Icons.category, 'Kategori', totalKategori.toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        Text(label, style: TextStyle(fontSize: 12, color: subTextColor)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.school, color: accentColor),
            const SizedBox(width: 8),
            Text('Catatan Kuliah', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open, color: accentColor),
            tooltip: 'Lihat Folder',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen2(
                    userId: widget.userId,
                    username: widget.username,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, color: textColor),
            onPressed: () {
              if (mounted) setState(() => _isDarkMode = !_isDarkMode);
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
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterRow(),
          const SizedBox(height: 8),
          if (_notes.isNotEmpty) _buildStats(),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6))))
                : _filteredNotes.isEmpty ? _buildEmptyState() : _buildNoteList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddForm,
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomSheet: _showForm ? _buildForm() : null,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
    );
  }

  Widget _buildFilterRow() {
    return Padding(
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: subTextColor),
          const SizedBox(height: 16),
          Text('Belum ada catatan kuliah', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: subTextColor)),
          const SizedBox(height: 8),
          Text('Tap + untuk menambahkan catatan', style: TextStyle(color: subTextColor)),
        ],
      ),
    );
  }

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
            _editingId == null ? '📚 Tambah Catatan' : '✏️ Edit Catatan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _matkulController.text.isNotEmpty ? _matkulController.text : null,
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
            items: _matkulList.map((matkul) {
              return DropdownMenuItem(value: matkul, child: Text(matkul));
            }).toList(),
            onChanged: (value) {
              if (mounted) setState(() => _matkulController.text = value ?? '');
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
            maxLines: 3,
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
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: TextField(
                controller: _tanggalController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Tanggal (YYYY-MM-DD)',
                  labelStyle: TextStyle(color: subTextColor),
                  prefixIcon: Icon(Icons.calendar_today, color: accentColor),
                  suffixIcon: Icon(Icons.arrow_drop_down, color: accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _kategoriController.text.isNotEmpty ? _kategoriController.text : null,
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
            items: _kategoriDropdownList.map((kategori) {
              return DropdownMenuItem(value: kategori, child: Text(kategori));
            }).toList(),
            onChanged: (value) {
              if (mounted) setState(() => _kategoriController.text = value ?? '');
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
                  child: Text(
                    _editingId == null ? 'Tambah' : 'Update',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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
                        _clearControllers();
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[600]!),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNoteList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        return GestureDetector(
          onTap: () => _showDetail(note),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.1)),
            ),
            child: ListTile(
              leading: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getCategoryIcon(note.kategori), color: accentColor),
              ),
              title: Text(
                note.judul,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📚 ${note.mataKuliah}', style: TextStyle(color: subTextColor, fontSize: 13)),
                  Text(note.materi, style: TextStyle(color: subTextColor, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: subTextColor),
                      const SizedBox(width: 4),
                      Text(note.tanggal, style: TextStyle(color: subTextColor, fontSize: 11)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(note.kategori),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(note.kategori, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: PopupMenuButton(
                color: cardColor,
                icon: Icon(Icons.more_vert, color: subTextColor),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Color(0xFF3B82F6)), SizedBox(width: 8), Text('Edit')])),
                  const PopupMenuItem(value: 'share', child: Row(children: [Icon(Icons.share, color: Colors.green), SizedBox(width: 8), Text('Share')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditForm(note);
                  } else if (value == 'share') {
                    _shareNote(note);
                  } else if (value == 'delete') {
                    _deleteNote(note.id!, note.judul);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}