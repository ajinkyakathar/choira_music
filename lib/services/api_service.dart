import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/song.dart';

class ApiService {
  // The client id is passed when building the app (see README), so it is
  // never written in the code or pushed to GitHub.
  static const clientId = String.fromEnvironment('JAMENDO_CLIENT_ID');
  static bool get hasClientId => clientId.isNotEmpty;

  static const pageSize = 20;

  /// Returns one page of tracks. [limit] and [offset] select the part of the
  /// list to fetch. [order] is optional: leave it null for search results so
  /// the API uses its own ranking.
  Future<List<Song>> getSongs({
    String query = '',
    int offset = 0,
    int limit = pageSize,
    String? order,
  }) async {
    final params = <String, String>{
      'client_id': clientId,
      'format': 'json',
      'limit': '$limit',
      'offset': '$offset',
      'imagesize': '500',
    };
    if (query.isNotEmpty) params['namesearch'] = query;
    if (order != null) params['order'] = order;

    final url = Uri.https('api.jamendo.com', '/v3.0/tracks/', params);
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Server error ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data['headers']['status'] != 'success') {
      throw Exception(data['headers']['error_message']);
    }

    final results = data['results'] as List;
    return results.map((item) => Song.fromJson(item)).toList();
  }
}
