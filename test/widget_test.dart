import 'package:choira_music/models/song.dart';
import 'package:choira_music/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatTime shows minutes and seconds', () {
    expect(formatTime(const Duration(seconds: 5)), '0:05');
    expect(formatTime(const Duration(seconds: 185)), '3:05');
  });

  test('Song.fromJson reads the Jamendo fields', () {
    final song = Song.fromJson({
      'id': '10',
      'name': 'Sunrise',
      'artist_name': 'The Band',
      'album_name': 'Dawn',
      'image': 'https://example.com/a.jpg',
      'audio': 'https://example.com/a.mp3',
      'duration': 200,
    });

    expect(song.title, 'Sunrise');
    expect(song.artist, 'The Band');
    expect(song.duration, 200);
  });
}
