import 'package:flutter/foundation.dart';

abstract final class Ambiente {
  static const _apiUrlDefinida = String.fromEnvironment('API_URL');

  static String get apiUrl {
    if (_apiUrlDefinida.isNotEmpty) return _apiUrlDefinida;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static const geminiChave = String.fromEnvironment('GEMINI_API_KEY');

  static const _geminiModelosDefinidos = String.fromEnvironment('GEMINI_MODEL');
  static const _geminiModelosPadrao = 'gemini-3.5-flash,gemini-3.1-flash-lite';

  static List<String> get geminiModelos {
    final texto = _geminiModelosDefinidos.isNotEmpty
        ? _geminiModelosDefinidos
        : _geminiModelosPadrao;
    return texto.split(',').map((m) => m.trim()).where((m) => m.isNotEmpty).toList();
  }
}
