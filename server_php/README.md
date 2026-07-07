# dplayer PHP API

Upload `watchlist.php` ke server API kamu, misalnya:

```text
https://api-dmovie.dimas-server.my.id/watchlist.php
```

Import `database.sql` ke MySQL server untuk membuat database `dplayer_db` dan tabel `watchlist`.

Setelah upload, edit bagian kredensial di `watchlist.php`:

```php
$dbHost = 'localhost';
$dbName = 'dplayer_db';
$dbUser = 'ISI_USER_DATABASE_KAMU';
$dbPass = 'ISI_PASSWORD_DATABASE_KAMU';
```

Endpoint:

```text
GET    /watchlist.php
POST   /watchlist.php
PUT    /watchlist.php
DELETE /watchlist.php?movie_id=123
```

## Nginx Terpisah

Kalau API Google Books sudah memakai Nginx port `8080`, pakai config terpisah ini untuk dplayer:

```text
/etc/nginx/sites-available/api-dmovie
```

Isi config tersedia di `nginx-api-dmovie.conf`. Config ini memakai port `8880` dan root:

```text
/var/www/api-dmovie
```

Aktifkan:

```bash
sudo cp nginx-api-dmovie.conf /etc/nginx/sites-available/api-dmovie
sudo ln -s /etc/nginx/sites-available/api-dmovie /etc/nginx/sites-enabled/api-dmovie
sudo nginx -t
sudo systemctl reload nginx
```

Test dari server:

```bash
curl http://localhost:8880/watchlist.php
```

Kalau pakai Cloudflare Tunnel, arahkan public hostname ke:

```text
http://localhost:8880
```

Kalau pakai DNS proxied biasa, pastikan firewall membuka port `8880`:

```bash
sudo ufw allow 8880/tcp
```

Contoh body POST:

```json
{
  "movie_id": 123,
  "title": "Interstellar",
  "poster_path": "/abc.jpg",
  "rating": 8.4,
  "notes": "Terakhir nonton menit 45"
}
```

Contoh body PUT:

```json
{
  "movie_id": 123,
  "title": "Interstellar",
  "poster_path": "/abc.jpg",
  "rating": 8.7,
  "notes": "Lanjut dari menit 70"
}
```

Kalau database lama belum punya kolom catatan:

```sql
ALTER TABLE watchlist
ADD COLUMN notes TEXT NULL DEFAULT NULL;
```
