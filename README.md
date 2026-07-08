# 🎬 Dplayer (Dims Movie)

A comprehensive Flutter-based movie catalog application that allows users to discover trending movies, search for specific titles via the TMDB API, and manage a personalized watchlist complete with custom notes.

## ✨ Features

- **Trending Movies**: Discover popular and top-rated movies directly from the home screen.
- **Search Capabilities**: Search the vast TMDB database for your favorite movies.
- **Detailed Information**: View comprehensive movie details, including posters, ratings, overviews, and more.
- **Personal Watchlist**: Save movies to your personal watchlist for later viewing.
- **Custom Notes**: Add personal notes or reviews to movies in your watchlist.
- **State Management**: Built with robust state management using `provider`.
- **Backend Integration**: Supports syncing data via a custom backend (Node.js/PHP).

## 🛠️ Tech Stack

- **Frontend**: Flutter & Dart
- **State Management**: Provider
- **API**: [The Movie Database (TMDB) API](https://developer.themoviedb.org/docs)
- **Backend**: Custom Node.js / PHP backend integration for watchlist management.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.12.0 or higher)
- A TMDB API v4 Access Token

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/dplayer.git
   cd dplayer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Backend Setup (Optional)**
   For the optional Node.js backend, copy the example environment file and configure it:
   ```bash
   cp backend/.env.example backend/.env
   ```
   *Note: Fill in the required variables locally. The `.env` file is ignored by Git.*

### Running the App

> **⚠️ Important**: Do not commit API keys or database credentials to version control.

Provide your TMDB Access Token when running the app. 

**For Development (Run locally):**
```bash
flutter run --dart-define=TMDB_ACCESS_TOKEN=your_tmdb_v4_access_token
```

**For Release Build (APK):**
```bash
flutter build apk --dart-define=TMDB_ACCESS_TOKEN=your_tmdb_v4_access_token
```

## 📂 Project Structure

- `lib/screens/`: Contains all UI screens (`home_screen`, `detail_screen`, `search_screen`, `watchlist_screen`).
- `lib/services/`: Handles API calls to TMDB (`tmdb_service`) and the custom backend (`backend_service`).
- `lib/providers/`: State management for the app.
- `lib/models/`: Dart data models for parsing JSON responses.
- `lib/widgets/`: Reusable UI components.

