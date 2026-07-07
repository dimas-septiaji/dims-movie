const express = require('express');
const cors = require('cors');
const db = require('./db');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// GET: Ambil daftar watchlist
app.get('/api/watchlist', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM watchlist ORDER BY added_at DESC');
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching watchlist:', error);
        res.status(500).json({ success: false, message: 'Gagal mengambil data watchlist' });
    }
});

// POST: Tambah ke watchlist
app.post('/api/watchlist', async (req, res) => {
    const { movie_id, title, poster_path, rating, notes } = req.body;

    if (!movie_id || !title) {
        return res.status(400).json({ success: false, message: 'movie_id dan title wajib diisi' });
    }

    try {
        const query = 'INSERT INTO watchlist (movie_id, title, poster_path, rating, notes) VALUES (?, ?, ?, ?, ?)';
        const [result] = await db.query(query, [movie_id, title, poster_path, rating, notes]);
        res.status(201).json({ success: true, message: 'Film ditambahkan ke watchlist', id: result.insertId });
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ success: false, message: 'Film sudah ada di watchlist' });
        }
        console.error('Error inserting into watchlist:', error);
        res.status(500).json({ success: false, message: 'Gagal menambahkan film ke watchlist' });
    }
});

// PUT: Update item watchlist berdasarkan movie_id
app.put('/api/watchlist/:movie_id', async (req, res) => {
    const movieId = Number(req.params.movie_id);
    const { title, poster_path, rating, notes } = req.body;

    if (!movieId || !title) {
        return res.status(400).json({ success: false, message: 'movie_id dan title wajib diisi' });
    }

    try {
        const query = 'UPDATE watchlist SET title = ?, poster_path = ?, rating = ?, notes = ? WHERE movie_id = ?';
        const [result] = await db.query(query, [title, poster_path, rating, notes, movieId]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Film tidak ditemukan di watchlist' });
        }

        res.json({ success: true, message: 'Watchlist berhasil diupdate' });
    } catch (error) {
        console.error('Error updating watchlist:', error);
        res.status(500).json({ success: false, message: 'Gagal mengupdate watchlist' });
    }
});

// DELETE: Hapus item watchlist berdasarkan movie_id
app.delete('/api/watchlist/:movie_id', async (req, res) => {
    const movieId = Number(req.params.movie_id);

    if (!movieId) {
        return res.status(400).json({ success: false, message: 'movie_id wajib diisi' });
    }

    try {
        const [result] = await db.query('DELETE FROM watchlist WHERE movie_id = ?', [movieId]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Film tidak ditemukan di watchlist' });
        }

        res.json({ success: true, message: 'Film dihapus dari watchlist' });
    } catch (error) {
        console.error('Error deleting watchlist:', error);
        res.status(500).json({ success: false, message: 'Gagal menghapus film dari watchlist' });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server backend berjalan di http://0.0.0.0:${PORT}`);
});
