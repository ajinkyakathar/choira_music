import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';
import '../services/api_service.dart';

class SongProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Song> songs = [];
  String query = '';
  bool isLoading = false;
  bool hasMore = true;
  bool isOffline = false;
  String? error;

  int _offset = 0;
  int _requestId = 0;

  // Loads a page of songs. reset = true starts again from the first page
  // (used for the first load, search and pull to refresh).
  Future<void> fetch({bool reset = false}) async {
    if (ApiService.clientId.isEmpty) {
      error = 'Jamendo client ID is missing. See the README.';
      notifyListeners();
      return;
    }

    // don't send another request while one is already running
    if (!reset && (isLoading || !hasMore)) return;

    if (reset) {
      songs = [];
      _offset = 0;
      hasMore = true;
      isOffline = false;
    }

    // if a newer request starts, the older response is ignored
    final requestId = ++_requestId;
    final isFirstPage = _offset == 0;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _api.getSongs(query: query, offset: _offset);
      if (requestId != _requestId) return;

      songs.addAll(result);
      _offset += result.length;
      hasMore = result.length == ApiService.pageSize;

      if (isFirstPage) _saveCache(result);
    } catch (e) {
      if (requestId != _requestId) return;

      if (isFirstPage) {
        await _loadCache();
      } else {
        error = 'Could not load more songs.';
      }
    }

    isLoading = false;
    notifyListeners();
  }

  void loadMore() {
    // after an error the user has to tap Retry, otherwise scrolling
    // would keep calling the API again and again
    if (error != null) return;
    fetch();
  }

  void search(String text) {
    query = text.trim();
    fetch(reset: true);
  }

  // Offline support: the first page of every search is saved on the phone
  Future<void> _saveCache(List<Song> list) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(list.map((song) => song.toJson()).toList());
    await prefs.setString('cache_${query.toLowerCase()}', json);
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('cache_${query.toLowerCase()}');

    if (saved == null) {
      error = 'Could not load songs. Please check your internet connection.';
      return;
    }

    final list = jsonDecode(saved) as List;
    songs = list.map((item) => Song.fromJson(item)).toList();
    isOffline = true;
    hasMore = false;
  }
}
