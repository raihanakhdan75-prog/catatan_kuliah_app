<?php
// ============================================================
// 🔥 API CATATAN KULIAH - 1 FILE UNTUK SEMUA!
// ============================================================

$host = 'localhost';
$dbname = 'catatan_kuliah_db';
$username = 'root';
$password = '';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);
$action = $data['action'] ?? $_GET['action'] ?? '';

// ============================================================
// 📝 REGISTER
// ============================================================
if ($action == 'register') {
    $username = $data['username'] ?? '';
    $password = $data['password'] ?? '';

    if (empty($username) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'Username dan password harus diisi']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("INSERT INTO users (username, password) VALUES (?, ?)");
        $stmt->execute([$username, $password]);
        echo json_encode(['success' => true, 'message' => 'Registrasi berhasil']);
    } catch(PDOException $e) {
        echo json_encode(['success' => false, 'message' => 'Username sudah terdaftar']);
    }
    exit;
}

// ============================================================
// 🔐 LOGIN
// ============================================================
if ($action == 'login') {
    $username = $data['username'] ?? '';
    $password = $data['password'] ?? '';

    if (empty($username) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'Username dan password harus diisi']);
        exit;
    }

    $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
    $stmt->execute([$username, $password]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        echo json_encode([
            'success' => true,
            'user' => [
                'id' => $user['id'],
                'username' => $user['username']
            ]
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Username atau password salah']);
    }
    exit;
}

// ============================================================
// 📋 GET USER ID
// ============================================================
if ($action == 'get_user_id') {
    $username = $data['username'] ?? $_GET['username'] ?? '';

    if (empty($username)) {
        echo json_encode(['success' => false, 'message' => 'Username harus diisi']);
        exit;
    }

    $stmt = $pdo->prepare("SELECT id FROM users WHERE username = ?");
    $stmt->execute([$username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        echo json_encode(['success' => true, 'user_id' => $user['id']]);
    } else {
        echo json_encode(['success' => false, 'message' => 'User tidak ditemukan']);
    }
    exit;
}

// ============================================================
// 📋 GET NOTES
// ============================================================
if ($action == 'get_notes') {
    $user_id = $data['user_id'] ?? $_GET['user_id'] ?? 0;

    if ($user_id <= 0) {
        echo json_encode(['success' => false, 'message' => 'User ID tidak valid']);
        exit;
    }

    $stmt = $pdo->prepare("SELECT * FROM notes WHERE user_id = ? ORDER BY id DESC");
    $stmt->execute([$user_id]);
    $notes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(['success' => true, 'notes' => $notes]);
    exit;
}

// ============================================================
// ➕ ADD NOTE
// ============================================================
if ($action == 'add_note') {
    $user_id = $data['user_id'] ?? 0;
    $mata_kuliah = $data['mata_kuliah'] ?? '';
    $judul = $data['judul'] ?? '';
    $materi = $data['materi'] ?? '';
    $tanggal = $data['tanggal'] ?? '';
    $kategori = $data['kategori'] ?? '';

    if (empty($mata_kuliah) || empty($judul) || empty($materi) || empty($tanggal)) {
        echo json_encode(['success' => false, 'message' => 'Semua field harus diisi']);
        exit;
    }

    $stmt = $pdo->prepare("INSERT INTO notes (user_id, mata_kuliah, judul, materi, tanggal, kategori) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$user_id, $mata_kuliah, $judul, $materi, $tanggal, $kategori]);

    echo json_encode(['success' => true, 'message' => 'Catatan berhasil ditambahkan']);
    exit;
}

// ============================================================
// ✏️ UPDATE NOTE
// ============================================================
if ($action == 'update_note') {
    $id = $data['id'] ?? 0;
    $mata_kuliah = $data['mata_kuliah'] ?? '';
    $judul = $data['judul'] ?? '';
    $materi = $data['materi'] ?? '';
    $tanggal = $data['tanggal'] ?? '';
    $kategori = $data['kategori'] ?? '';

    if (empty($mata_kuliah) || empty($judul) || empty($materi) || empty($tanggal) || $id <= 0) {
        echo json_encode(['success' => false, 'message' => 'Data tidak valid']);
        exit;
    }

    $stmt = $pdo->prepare("UPDATE notes SET mata_kuliah = ?, judul = ?, materi = ?, tanggal = ?, kategori = ? WHERE id = ?");
    $stmt->execute([$mata_kuliah, $judul, $materi, $tanggal, $kategori, $id]);

    echo json_encode(['success' => true, 'message' => 'Catatan berhasil diupdate']);
    exit;
}

// ============================================================
// 🗑️ DELETE NOTE
// ============================================================
if ($action == 'delete_note') {
    $id = $data['id'] ?? 0;

    if ($id <= 0) {
        echo json_encode(['success' => false, 'message' => 'ID tidak valid']);
        exit;
    }

    $stmt = $pdo->prepare("DELETE FROM notes WHERE id = ?");
    $stmt->execute([$id]);

    echo json_encode(['success' => true, 'message' => 'Catatan berhasil dihapus']);
    exit;
}

// ============================================================
// 🔍 SEARCH NOTES
// ============================================================
if ($action == 'search_notes') {
    $user_id = $data['user_id'] ?? 0;
    $keyword = $data['keyword'] ?? '';

    if ($user_id <= 0) {
        echo json_encode(['success' => false, 'message' => 'User ID tidak valid']);
        exit;
    }

    if (empty($keyword)) {
        $stmt = $pdo->prepare("SELECT * FROM notes WHERE user_id = ? ORDER BY id DESC");
        $stmt->execute([$user_id]);
    } else {
        $stmt = $pdo->prepare("SELECT * FROM notes WHERE user_id = ? AND (judul LIKE ? OR mata_kuliah LIKE ? OR materi LIKE ?) ORDER BY id DESC");
        $likeKeyword = "%$keyword%";
        $stmt->execute([$user_id, $likeKeyword, $likeKeyword, $likeKeyword]);
    }
    
    $notes = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode(['success' => true, 'notes' => $notes]);
    exit;
}

// DEFAULT
echo json_encode(['success' => false, 'message' => 'Action "' . $action . '" tidak dikenal']);
?>