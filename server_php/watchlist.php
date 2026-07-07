<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$dbHost = 'localhost';
$dbName = 'dplayer_db';
$dbUser = 'ISI_USER_DATABASE_KAMU';
$dbPass = 'ISI_PASSWORD_DATABASE_KAMU';

function sendJson(int $statusCode, array $payload): void
{
    http_response_code($statusCode);
    echo json_encode($payload);
    exit;
}

function getPayload(): array
{
    $rawBody = file_get_contents('php://input');
    $payload = json_decode($rawBody, true);

    if (!is_array($payload)) {
        $payload = $_POST;
    }

    return $payload;
}

try {
    $pdo = new PDO(
        "mysql:host={$dbHost};dbname={$dbName};charset=utf8mb4",
        $dbUser,
        $dbPass,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
} catch (PDOException $error) {
    sendJson(500, [
        'success' => false,
        'message' => 'Gagal terhubung ke database',
    ]);
}

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $statement = $pdo->query(
            'SELECT id, movie_id, title, poster_path, rating, notes, added_at
             FROM watchlist
             ORDER BY added_at DESC'
        );

        sendJson(200, [
            'success' => true,
            'data' => $statement->fetchAll(),
        ]);
    } catch (PDOException $error) {
        sendJson(500, [
            'success' => false,
            'message' => 'Gagal mengambil watchlist',
        ]);
    }
}

if ($method === 'POST') {
    $payload = getPayload();

    $movieId = isset($payload['movie_id']) ? (int) $payload['movie_id'] : 0;
    $title = trim($payload['title'] ?? '');
    $posterPath = $payload['poster_path'] ?? null;
    $rating = isset($payload['rating']) ? (float) $payload['rating'] : null;
    $notes = isset($payload['notes']) ? trim($payload['notes']) : null;

    if ($movieId <= 0 || $title === '') {
        sendJson(400, [
            'success' => false,
            'message' => 'movie_id dan title wajib diisi',
        ]);
    }

    try {
        $statement = $pdo->prepare(
            'INSERT INTO watchlist (movie_id, title, poster_path, rating, notes)
             VALUES (:movie_id, :title, :poster_path, :rating, :notes)'
        );

        $statement->execute([
            ':movie_id' => $movieId,
            ':title' => $title,
            ':poster_path' => $posterPath,
            ':rating' => $rating,
            ':notes' => $notes,
        ]);

        sendJson(201, [
            'success' => true,
            'message' => 'Film ditambahkan ke watchlist',
            'id' => (int) $pdo->lastInsertId(),
        ]);
    } catch (PDOException $error) {
        if ($error->getCode() === '23000') {
            sendJson(409, [
                'success' => false,
                'message' => 'Film sudah ada di watchlist',
            ]);
        }

        sendJson(500, [
            'success' => false,
            'message' => 'Gagal menambahkan film ke watchlist',
        ]);
    }
}

if ($method === 'PUT') {
    $payload = getPayload();

    $movieId = isset($payload['movie_id']) ? (int) $payload['movie_id'] : 0;
    $title = trim($payload['title'] ?? '');
    $posterPath = $payload['poster_path'] ?? null;
    $rating = isset($payload['rating']) ? (float) $payload['rating'] : null;
    $notes = isset($payload['notes']) ? trim($payload['notes']) : null;

    if ($movieId <= 0 || $title === '') {
        sendJson(400, [
            'success' => false,
            'message' => 'movie_id dan title wajib diisi',
        ]);
    }

    try {
        $statement = $pdo->prepare(
            'UPDATE watchlist
             SET title = :title, poster_path = :poster_path, rating = :rating, notes = :notes
             WHERE movie_id = :movie_id'
        );

        $statement->execute([
            ':movie_id' => $movieId,
            ':title' => $title,
            ':poster_path' => $posterPath,
            ':rating' => $rating,
            ':notes' => $notes,
        ]);

        if ($statement->rowCount() === 0) {
            $existsStatement = $pdo->prepare(
                'SELECT COUNT(*) FROM watchlist WHERE movie_id = :movie_id'
            );
            $existsStatement->execute([':movie_id' => $movieId]);

            if ((int) $existsStatement->fetchColumn() === 0) {
                sendJson(404, [
                    'success' => false,
                    'message' => 'Film tidak ditemukan di watchlist',
                ]);
            }
        }

        sendJson(200, [
            'success' => true,
            'message' => 'Watchlist berhasil diupdate',
        ]);
    } catch (PDOException $error) {
        sendJson(500, [
            'success' => false,
            'message' => 'Gagal mengupdate watchlist',
        ]);
    }
}

if ($method === 'DELETE') {
    $payload = getPayload();
    $movieId = isset($_GET['movie_id'])
        ? (int) $_GET['movie_id']
        : (isset($payload['movie_id']) ? (int) $payload['movie_id'] : 0);

    if ($movieId <= 0) {
        sendJson(400, [
            'success' => false,
            'message' => 'movie_id wajib diisi',
        ]);
    }

    try {
        $statement = $pdo->prepare('DELETE FROM watchlist WHERE movie_id = :movie_id');
        $statement->execute([':movie_id' => $movieId]);

        if ($statement->rowCount() === 0) {
            sendJson(404, [
                'success' => false,
                'message' => 'Film tidak ditemukan di watchlist',
            ]);
        }

        sendJson(200, [
            'success' => true,
            'message' => 'Film dihapus dari watchlist',
        ]);
    } catch (PDOException $error) {
        sendJson(500, [
            'success' => false,
            'message' => 'Gagal menghapus film dari watchlist',
        ]);
    }
}

sendJson(405, [
    'success' => false,
    'message' => 'Method tidak diizinkan',
]);
