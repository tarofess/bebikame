import 'package:flutter/material.dart';

import 'package:bebikame/presentation/widget/loading_indicator.dart';

class LoadingOverlay {
  final BuildContext _context;
  OverlayEntry? _overlay;
  bool _isLoading = false;
  String? _message;

  LoadingOverlay._private(this._context, [this._message]);

  factory LoadingOverlay.of(BuildContext context, {String? message}) {
    return LoadingOverlay._private(context, message);
  }

  void show({String? message}) {
    if (!_isLoading) {
      _isLoading = true;
      _message = message ?? _message;
      _overlay = OverlayEntry(
        builder: (context) => LoadingIndicator(
          message: _message,
        ),
      );
      Overlay.of(_context).insert(_overlay!);
    }
  }

  void hide() {
    if (_isLoading) {
      _overlay?.remove();
      _overlay = null;
      _isLoading = false;
    }
  }

  Future<T> during<T>(Future<T> Function() asyncFunction) async {
    show();
    try {
      final result = await asyncFunction();
      return result;
    } finally {
      hide();
    }
  }

  bool get isLoading => _isLoading;
}

extension LoadingOverlayExtension on Widget {
  Widget withLoadingOverlay({Key? key}) {
    return _LoadingOverlayWidget(key: key, child: this);
  }
}

class _LoadingOverlayWidget extends StatefulWidget {
  final Widget child;

  const _LoadingOverlayWidget({required this.child, super.key});

  @override
  _LoadingOverlayWidgetState createState() => _LoadingOverlayWidgetState();
}

class _LoadingOverlayWidgetState extends State<_LoadingOverlayWidget> {
  late LoadingOverlay _loadingOverlay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadingOverlay = LoadingOverlay.of(context);
  }

  @override
  void dispose() {
    _loadingOverlay.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
