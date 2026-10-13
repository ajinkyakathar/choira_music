import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';
import '../services/api_service.dart';

/// A song list that loads one page at a time using limit and offset.
/// The Home and Search tabs each use a subclass of this.
abstract class PagedSongList extends ChangeNotifier {
  /// Loads one page from the API. Subclasses implement this.
  Future<List<Song>> fetchPage(int offset, int limit);

  /// Name used to save the first page for offline use. Empty = no saving.
  String get cacheKey => '';

  final List<Song> songs = [];
  bool isLoading = false;
  bool hasMore = true; // false once the end of the list is reached
  bool isOffline = false; // true when the list shows saved songs
  String? error;

  int _offset = 0;
  int _requestId = 0; // lets an old response be ignored after a new request
  final Set<String> _ids = {};

  /// Empties the list and ignores any request that is still running.
  void clear() {
    _requestId++;
    songs.clear();
    _ids.clear();
    _offset = 0;
    isLoading = false;
    hasMore = true;
    isOffline = false;
    error = null;
    notifyListeners();
  }

  /// Starts again from the first page (first load, search, pull to refresh).
  Future<void> reset() {
    clear();
    return loadMore();
  }

  /// Loads the next page.
  /// Calls are ignored while a request is running, after the end of the list,
  /// and after an error unless [retry] is true (the user tapped Retry).
  Future<void> loadMore({bool retry = false}) async {
    if (isLoading || !hasMore) return;
    if (error != null && !retry) return;

    final requestId = _requestId;
    final isFirstPage = _offset == 0;
    final cacheName = cacheKey;

    // set before the first await, so a second call right after is ignored
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final page = await fetchPage(_offset, ApiService.pageSize);
      if (requestId != _requestId) return;

      // move the offset by what the server sent, not by what is new on screen
      _offset += page.length;
      hasMore = page.length == ApiService.pageSize;

      for (final song in page) {
        if (_ids.add(song.id)) songs.add(song); // skip repeats
      }
      if (isFirstPage && cacheName.isNotEmpty) _saveCache(cacheName, page);
    } catch (_) {
      if (requestId != _requestId) return;

      if (isFirstPage) {
        final restored = cacheName.isNotEmpty && await _loadCache(cacheName);
        if (requestId != _requestId) return;
        if (!restored) {
          error = 'Could not load songs. Please check your internet connection.';
        }
      } else {
        error = 'Could not load more songs.';
      }
    }

    isLoading = false;
    notifyListeners();
  }

  // Offline support: the first page is saved on the phone
  Future<void> _saveCache(String name, List<Song> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(list.map((song) => song.toJson()).toList());
      await prefs.setString('cache_$name', json);
    } catch (_) {
      // saving the cache is optional
    }
  }

  Future<bool> _loadCache(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('cache_$name');
      if (saved == null) return false;

      final list = (jsonDecode(saved) as List)
          .map((item) => Song.fromJson(item))
          .toList();
      songs
        ..clear()
        ..addAll(list);
      _ids
        ..clear()
        ..addAll(list.map((song) => song.id));
      isOffline = true;
      hasMore = false; // saved copy only holds the first page
      return true;
    } catch (_) {
      return false;
    }
  }
}
