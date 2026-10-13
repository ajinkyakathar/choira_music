class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String image;
  final String audioUrl;
  final int duration; // in seconds

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.image,
    required this.audioUrl,
    required this.duration,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'].toString(),
      title: json['name'] ?? 'Unknown title',
      artist: json['artist_name'] ?? 'Unknown artist',
      album: json['album_name'] ?? '',
      image: json['image'] ?? '',
      audioUrl: json['audio'] ?? '',
      duration: int.tryParse(json['duration'].toString()) ?? 0,
    );
  }

  // same keys as the API, so saved songs can be read back with fromJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'artist_name': artist,
      'album_name': album,
      'image': image,
      'audio': audioUrl,
      'duration': duration,
    };
  }
}
