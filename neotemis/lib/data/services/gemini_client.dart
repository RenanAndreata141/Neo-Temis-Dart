import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/erros/app_exception.dart';

class GeminiClient {
  GeminiClient({required this.chave, required this.modelos, http.Client? cliente})
      : _http = cliente ?? http.Client();

  final String chave;
  final List<String> modelos;
  final http.Client _http;

  bool get configurado => chave.isNotEmpty;

  static const _tentarProximo = {404, 429, 500, 503, 'timeout'};

  Future<Map<String, dynamic>> gerarJson({
    required String instrucoes,
    required List<Map<String, Object>> conversa,
    required Map<String, Object> esquema,
    double temperatura = 0.2,
  }) async {
    final corpo = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': instrucoes},
        ],
      },
      'contents': conversa,
      'generationConfig': {
        'temperature': temperatura,
        'responseMimeType': 'application/json',
        'responseSchema': esquema,
      },
    });

    http.Response? resposta;
    Object status = 'rede';

    for (final modelo in modelos) {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '${Uri.encodeComponent(modelo)}:generateContent',
      );
      try {
        final r = await _http
            .post(
              url,
              headers: {'Content-Type': 'application/json', 'x-goog-api-key': chave},
              body: corpo,
            )
            .timeout(const Duration(seconds: 30));
        if (r.statusCode == 200) {
          resposta = r;
          break;
        }
        status = r.statusCode;
      } on TimeoutException {
        status = 'timeout';
      } catch (_) {
        status = 'rede';
      }
      if (!_tentarProximo.contains(status)) break;
    }

    if (resposta == null) throw _erroPara(status);

    var texto = '';
    try {
      final dados = jsonDecode(utf8.decode(resposta.bodyBytes)) as Map;
      final partes = dados['candidates'][0]['content']['parts'] as List;
      texto = partes.map((p) => (p as Map)['text'] ?? '').join();
      return Map<String, dynamic>.from(jsonDecode(texto) as Map);
    } catch (_) {
      return {
        'resposta': texto.isNotEmpty ? texto : 'Não consegui entender',
        'aplicarFiltro': false,
      };
    }
  }

  AppException _erroPara(Object status) {
    const mensagens = <Object, String>{
      400: 'A IA recusou a requisição. Confira a GEMINI_API_KEY',
      403: 'Chave do Gemini inválida ou sem permissão. Confira a GEMINI_API_KEY',
      429: 'O limite gratuito da IA foi atingido. Espere um pouco e tente de novo',
      503: 'A IA do Google está sobrecarregada agora. Tente de novo em instantes',
      'timeout': 'A IA demorou demais para responder. Tente de novo',
      'rede': 'Não foi possível falar com a IA',
    };
    if (status == 404) {
      return AppException(
        'Modelo não encontrado (${modelos.join(', ')}). Ajuste o GEMINI_MODEL',
      );
    }
    return AppException(
      mensagens[status] ?? 'A IA está indisponível no momento. Tente de novo',
    );
  }
}
