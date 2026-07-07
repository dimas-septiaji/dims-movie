# dplayer

Flutter movie catalog app with TMDB search, watchlist, and notes.

## Local Setup

Do not commit API keys or database credentials. Provide the TMDB token at build
or run time:

```bash
flutter run --dart-define=TMDB_ACCESS_TOKEN=your_tmdb_v4_access_token
```

For release builds:

```bash
flutter build apk --dart-define=TMDB_ACCESS_TOKEN=your_tmdb_v4_access_token
```

For the optional Node backend, copy `backend/.env.example` to `backend/.env`
and fill it locally. The real `.env` file is ignored by git.
