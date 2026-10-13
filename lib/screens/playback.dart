import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/player_provider.dart';
import 'player_screen.dart';

/// Plays [songs] from [index], or opens Now Playing if that song is already playing.
void playFromList(BuildContext context, List<Song> songs, int index) {
  final player = context.read<PlayerProvider>();
  final song = songs[index];

  if (player.currentSong?.id == song.id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlayerScreen()),
    );
  } else {
    // copy the list: the feed clears and refills its own list, and the
    // queue must not change with it
    player.playSong(List<Song>.of(songs), index);
  }
}
