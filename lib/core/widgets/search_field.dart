import 'package:flutter/material.dart';

import '../utils/debouncer.dart';

/// A search input for filtering a list in place, styled through the app's
/// shared InputDecorationTheme like every other text field.
///
/// [onChanged] fires [duration] after the user stops typing, not on every
/// keystroke — cheap for an in-memory filter, and load-bearing for a search
/// that hits the network (see the maintenance list screens' server-side
/// search).
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.duration = const Duration(milliseconds: 350),
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final Duration duration;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  late final _debouncer = Debouncer(duration: widget.duration);

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {}); // toggles the clear button
    _debouncer.run(() => widget.onChanged(value));
  }

  void _clear() {
    _controller.clear();
    setState(() {});
    _debouncer.dispose();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Clear search',
                onPressed: _clear,
              ),
      ),
    );
  }
}
