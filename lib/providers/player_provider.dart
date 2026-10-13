import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer audio = AudioPlayer();

  List<Song> queue = [];
  int index = -1;
  bool isLoading = false;
  String? error;

  PlayerProvider() {
    // rebuild the UI whenever the player starts, pauses or finishes
    audio.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (hasNext) {
          next();
        } else {
          audio.pause();
          audio.seek(Duration.zero);
        }
      }
      notifyListeners();
    });
  }

  Song? get currentSong => index >= 0 ? queue[index] : null;
  bool get isPlaying => audio.playing;
  bool get hasNext => index < queue.length - 1;

  Future<void> playSong(List<Song> songs, int songIndex) async {
    queue = songs;
    index = songIndex;
    await _load();
  }

  Future<void> _load() async {
    error = null;
    isLoading = true;
    notifyListeners();

    try {
      await audio.setUrl(currentSong!.audioUrl);
      audio.play();
    } catch (e) {
      // PlayerInterruptedException just means another song was selected
      if (e is! PlayerInterruptedException) {
        error = 'Could not play this song.';
      }
    }

    isLoading = false;
    notifyListeners();
  }

  void togglePlay() {
    if (error != null) {
      _load();
    } else if (audio.playing) {
      audio.pause();
    } else {
      audio.play();
    }
  }

  Future<void> next() async {
    if (!hasNext) return;
    index++;
    await _load();
  }

  Future<void> previous() async {
    // like most players: restart the song if it already played a few seconds
    if (audio.position.inSeconds > 3 || index == 0) {
      await audio.seek(Duration.zero);
    } else {
      index--;
      await _load();
    }
  }

  void seek(Duration position) {
    audio.seek(position);
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }
}
