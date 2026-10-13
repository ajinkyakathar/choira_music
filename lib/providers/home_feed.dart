import '../models/song.dart';
import '../services/api_service.dart';
import 'paged_song_list.dart';

/// Home tab: a row of featured squares plus a paginated recommended list.
/// Jamendo has no personal recommendation endpoint, so "recommended" here
/// means the most popular tracks this week.
class HomeFeed extends PagedSongList {
  final _api = ApiService();

  /// Short row shown above the list. Optional: if it fails it is just hidden.
  List<Song> featured = [];

  HomeFeed() {
    reset();
    _loadFeatured();
  }

  @override
  String get cacheKey => 'home';

  @override
  Future<List<Song>> fetchPage(int offset, int limit) {
    return _api.getSongs(
      offset: offset,
      limit: limit,
      order: 'popularity_week',
    );
  }

  Future<void> refresh() {
    _loadFeatured();
    return reset();
  }

  Future<void> _loadFeatured() async {
    try {
      featured = await _api.getSongs(limit: 10, order: 'popularity_total');
      notifyListeners();
    } catch (_) {
      // the featured row is optional
    }
  }
}
