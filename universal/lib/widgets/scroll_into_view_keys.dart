import 'package:flutter/material.dart';

/// Per-item [GlobalKey] registry that lets a newly added list item be
/// scrolled into view via [Scrollable.ensureVisible] once it has been laid
/// out, rather than assuming it landed at a particular position.
class ScrollIntoViewKeys<K extends Object> {
  final Map<K, GlobalKey> _keys = {};

  GlobalKey keyFor(K id) => _keys.putIfAbsent(id, GlobalKey.new);

  void pruneExcept(Iterable<K> liveIds) {
    final live = liveIds.toSet();
    _keys.removeWhere((id, _) => !live.contains(id));
  }

  void scrollIntoView(K id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _keys[id]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }
}
