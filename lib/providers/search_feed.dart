import '../models/song.dart';
import '../services/api_service.dart';
import 'paged_song_list.dart';

/// Search tab: results for the text the user typed, paginated the same way.
class SearchFeed extends PagedSongList {
  final _api = ApiService();
  String query = '';

  @override
  String get cacheKey => 'search:${query.toLowerCase()}';

  @override
  Future<List<Song>> fetchPage(int offset, int limit) {
    return _api.getSongs(query: query, offset: offset, limit: limit);
  }

  /// Starts a new search. Empty text just clears the results.
  Future<void> search(String text) {
    query = text.trim();
    if (query.isEmpty) {
      clear();
      return Future.value();
    }
    return reset();
  }
}
