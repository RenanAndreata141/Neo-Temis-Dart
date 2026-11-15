import 'package:flutter/foundation.dart';

abstract class ControllerBase extends ChangeNotifier {
  bool _descartado = false;

  bool get descartado => _descartado;

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
