# Choira Music

A music player app made with Flutter using the [Jamendo API](https://developer.jamendo.com/v3.0).

## What it does

- Home screen with a list of songs (artwork, title, artist, duration)
- Search songs by name
- Pagination: loads the next 20 songs when you scroll near the bottom
  (no duplicate requests while loading, and it stops at the end of the list)
- Loading, error (with retry) and empty states, pull to refresh
- Play / pause, previous / next, seek bar, current time and duration
- Mini player at the bottom and a full Now Playing screen
- Works on different screen sizes (content is limited to a readable width on tablets,
  Now Playing scrolls in landscape)
- Offline caching: the first page of each search is saved on the phone and shown
  when there is no internet
- App icon


## Project structure

```
lib/
  main.dart                  app start, theme, providers
  models/song.dart           Song class (fromJson / toJson)
  services/api_service.dart  calls the Jamendo API
  providers/
    song_provider.dart       song list, search, pagination, offline cache
    player_provider.dart     audio player (queue, play, pause, next, previous, seek)
  screens/
    home_screen.dart         list + search
    player_screen.dart       Now Playing screen
  widgets/                   song_tile, song_image, mini_player
  utils.dart                 formatTime helper
```

## Architecture and state management

I used **Provider** with `ChangeNotifier` because it is simple and enough for this app.

- `ApiService` only talks to the API and returns a list of `Song`.
- `SongProvider` holds everything about the list: the songs, current search, loading / error
  flags and the offset for pagination. Screens just read its values and call
  `fetch()`, `loadMore()` and `search()`.
  - `fetch()` ignores calls while a page is loading, so scrolling cannot send the same
    request twice.
  - Every request gets an id, and old responses are ignored if a newer search started.
  - If the first page fails, the saved copy in `shared_preferences` is used (offline mode).
- `PlayerProvider` wraps the `just_audio` player and keeps the queue and current song.
  The UI rebuilds when the player state changes, and the progress bar listens
  directly to the player's position stream.
- Screens and widgets only show data and handle taps. No API or audio logic is inside them.

## Notes

- Audio stops if the app goes to the background (no background service added).
- Song artwork needs internet, a placeholder icon is shown when it can't load.

Music and data from [Jamendo](https://www.jamendo.com).
