//A API FOI!!!!!! TA TODA TORTA MAS TA FUNCIONANDO DEIXA ELA QUIETA

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../core/erros/app_exception.dart';

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? cliente})
      : _http = cliente ?? http.Client();

  final String baseUrl;
  final http.Client _http;

  String? token;

  void Function()? aoNaoAutorizado;

  static const _timeoutPadrao = Duration(seconds: 20);

  Future<dynamic> get(String caminho, {bool autenticado = true}) =>
      _enviar('GET', caminho, autenticado: autenticado);

  Future<dynamic> post(
    String caminho, {
    Object? corpo,
    bool autenticado = true,
    Duration timeout = _timeoutPadrao,
  }) =>
      _enviar('POST', caminho, corpo: corpo, autenticado: autenticado, timeout: timeout);

  Future<dynamic> put(
    String caminho, {
    Object? corpo,
    Duration timeout = _timeoutPadrao,
  }) =>
      _enviar('PUT', caminho, corpo: corpo, timeout: timeout);

  Future<dynamic> delete(String caminho) => _enviar('DELETE', caminho);

  Future<Uint8List?> baixarBytes(
    String caminho, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final r = await _http
          .get(Uri.parse('$baseUrl$caminho'), headers: _cabecalhos(autenticado: true))
          .timeout(timeout);
      return r.statusCode == 200 ? r.bodyBytes : null;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _cabecalhos({required bool autenticado}) => {
        'Content-Type': 'application/json',
        if (autenticado && token != null) 'Authorization': 'Bearer $token',
      };

  Future<http.Response> _executar(http.Request requisicao) async =>
      http.Response.fromStream(await _http.send(requisicao));

  Future<dynamic> _enviar(
    String metodo,
    String caminho, {
    Object? corpo,
    bool autenticado = true,
    Duration timeout = _timeoutPadrao,
  }) async {
    final requisicao = http.Request(metodo, Uri.parse('$baseUrl$caminho'))
      ..headers.addAll(_cabecalhos(autenticado: autenticado));
    if (corpo != null) requisicao.body = jsonEncode(corpo);

    late http.Response r;
    try {
      r = await _executar(requisicao).timeout(timeout);
    } on TimeoutException {
      throw const AppException('O servidor demorou demais para responder');
    } catch (_) {
      throw const AppException(
        'Não foi possível conectar ao servidor',
      );
    }

    dynamic dados;
    try {
      dados = r.bodyBytes.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      dados = null;
    }

    if (r.statusCode >= 400) {
      final msg = (dados is Map && dados['erro'] is String)
          ? dados['erro'] as String
          : 'Erro inesperado (${r.statusCode}).';
      if (r.statusCode == 401 && autenticado) {
        aoNaoAutorizado?.call();
        throw NaoAutorizadoException(msg);
      }
      throw AppException(msg);
    }
    return dados;
  }
}
