import 'package:flutter/material.dart';

import '../providers/paged_song_list.dart';

/// Last row of a song list. When it is built, the list is near the bottom
/// (or too short to scroll), so it asks for the next page. The list's own
/// guards stop duplicate requests while a page is loading.
class PagedFooter extends StatefulWidget {
  final PagedSongList list;
  const PagedFooter({super.key, required this.list});

  @override
  State<PagedFooter> createState() => _PagedFooterState();
}

class _PagedFooterState extends State<PagedFooter> {
  @override
  void initState() {
    super.initState();
    // wait until the frame is done, then ask for more
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.list.loadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.list;

    if (list.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (list.error != null) {
      return TextButton(
        onPressed: () => list.loadMore(retry: true),
        child: Text('${list.error} Tap to retry'),
      );
    }
    if (!list.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No more songs')),
      );
    }
    return const SizedBox(height: 24);
  }
}
