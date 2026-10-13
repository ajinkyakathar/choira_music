import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../screens/player_screen.dart';
import 'song_image.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;

    // nothing is playing yet, so no mini player
    if (song == null) return const SizedBox.shrink();

    return SafeArea(
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlayerScreen()),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // thin progress line on top
              StreamBuilder<Duration>(
                stream: player.audio.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  double progress = 0;
                  if (song.duration > 0) {
                    progress = position.inSeconds / song.duration;
                  }
                  return LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0).toDouble(),
                    minHeight: 2,
                  );
                },
              ),
              ListTile(
                leading: SongImage(url: song.image, size: 44),
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  player.error ?? song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (player.isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        onPressed: player.togglePlay,
                        icon: Icon(
                          player.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    IconButton(
                      onPressed: player.next,
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
