import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/player_provider.dart';
import '../utils.dart';
import 'song_image.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongTile({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currentSong = context.watch<PlayerProvider>().currentSong;
    final isPlaying = currentSong?.id == song.id;

    return ListTile(
      onTap: onTap,
      leading: SongImage(url: song.image, size: 52),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPlaying ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(formatTime(Duration(seconds: song.duration))),
    );
  }
}
