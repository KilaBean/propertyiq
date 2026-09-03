import 'dart:async';

import 'package:flutter/foundation.dart';

/// Delays running [action] until [duration] has passed with no further call
/// to [run] — e.g. a search box that shouldn't fire a query on every
/// keystroke, especially one that hits the network (see SearchField and its
/// use in the maintenance list screens).
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 350)});

  final Duration duration;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() => _timer?.cancel();
}
