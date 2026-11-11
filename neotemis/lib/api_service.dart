import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'processo.dart';

class ApiException implements Exception {
  ApiException(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

class Api {
  Api._();

  static const _urlDefinida = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_urlDefinida.isNotEmpty) return _urlDefinida;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static const _chaveToken = 'neotemis_token';
  static String? _token;
  static Map<String, dynamic>? usuario;
  static final Map<String, Uint8List> _cacheImagens = {};


  static void Function({bool sessaoExpirada})? aoDeslogar;


  static Future<bool> restaurarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString(_chaveToken);
    if (salvo == null) return false;
    _token = salvo;
    try {
      final r = await _req('GET', '/auth/eu', notificar: false);
      usuario = Map<String, dynamic>.from(r as Map);
      return true;
    } on ApiException {
      return false;
    }
  }

  static Future<void> _guardarSessao(dynamic resposta) async {
    final r = resposta as Map;
    _token = r['token'] as String;
    usuario = Map<String, dynamic>.from(r['usuario'] as Map);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveToken, _token!);
  }

  static Future<void> _limparSessao() async {
    _token = null;
    usuario = null;
    _cacheImagens.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveToken);
  }

  static Future<void> login(String oab, String senha) async {
    final r = await _req(
      'POST',
      '/auth/login',
      corpo: {'oab': oab, 'senha': senha},
      autenticado: false,
    );
    await _guardarSessao(r);
  }

  static Future<void> registro({
    required String nome,
    required String oab,
    required String email,
    required String senha,
  }) async {
    final r = await _req(
      'POST',
      '/auth/registro',
      corpo: {'nome': nome, 'oab': oab, 'email': email, 'senha': senha},
      autenticado: false,
    );
    await _guardarSessao(r);
  }

  static Future<void> sair({bool sessaoExpirada = false}) async {
    await _limparSessao();
    aoDeslogar?.call(sessaoExpirada: sessaoExpirada);
  }

  static Future<List<Processo>> listar() async {
    final r = await _req('GET', '/processos');
    return (r as List)
        .map((e) => Processo.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<Processo> salvar(
    Processo p, {
    Uint8List? imagem,
    String? imagemTipo,
    bool removerImagem = false,
  }) async {
    final corpo = <String, dynamic>{
      ...p.toJson(),
      if (imagem != null) 'imagem': base64Encode(imagem),
      if (imagem != null) 'imagemTipo': imagemTipo,
      if (imagem == null && removerImagem) 'removerImagem': true,
    };
    final novo = p.id.isEmpty;
    final r = await _req(
      novo ? 'POST' : 'PUT',
      novo ? '/processos' : '/processos/${p.id}',
      corpo: corpo,
      timeout: const Duration(seconds: 60),
    );
    return Processo.fromJson(Map<String, dynamic>.from(r as Map));
  }

  static Future<void> excluir(String id) async {
    await _req('DELETE', '/processos/$id');
  }

  static Future<Uint8List?> imagemDe(Processo p) async {
    if (!p.temImagem || p.id.isEmpty) return null;
    final chave = '${p.id}_${p.atualizadoEm}';
    final emCache = _cacheImagens[chave];
    if (emCache != null) return emCache;

    try {
      final r = await http
          .get(
            Uri.parse('$baseUrl/processos/${p.id}/imagem'),
            headers: {if (_token != null) 'Authorization': 'Bearer $_token'},
          )
          .timeout(const Duration(seconds: 30));
      if (r.statusCode != 200) return null;
      if (_cacheImagens.length > 100) _cacheImagens.clear();
      _cacheImagens[chave] = r.bodyBytes;
      return r.bodyBytes;
    } catch (_) {
      return null;
    }
  }


  static Future<dynamic> _req(
    String metodo,
    String caminho, {
    Object? corpo,
    bool autenticado = true,
    bool notificar = true,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final uri = Uri.parse('$baseUrl$caminho');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (autenticado && _token != null) 'Authorization': 'Bearer $_token',
    };
    final texto = corpo == null ? null : jsonEncode(corpo);

    late http.Response r;
    try {
      switch (metodo) {
        case 'GET':
          r = await http.get(uri, headers: headers).timeout(timeout);
        case 'POST':
          r = await http.post(uri, headers: headers, body: texto).timeout(timeout);
        case 'PUT':
          r = await http.put(uri, headers: headers, body: texto).timeout(timeout);
        case 'DELETE':
          r = await http.delete(uri, headers: headers).timeout(timeout);
        default:
          throw ArgumentError('Método HTTP não suportado: $metodo');
      }
    } on TimeoutException {
      throw ApiException('O servidor demorou demais para responder.');
    } catch (_) {
      throw ApiException(
        'Não foi possível conectar ao servidor. Verifique se a API está rodando.',
      );
    }

    dynamic dados;
    try {
      dados = r.bodyBytes.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      dados = null;
    }

    if (r.statusCode >= 400) {
      if (r.statusCode == 401 && autenticado) {
        await _limparSessao();
        if (notificar) aoDeslogar?.call(sessaoExpirada: true);
      }
      final msg = (dados is Map && dados['erro'] is String)
          ? dados['erro'] as String
          : 'Erro inesperado (${r.statusCode}).';
      throw ApiException(msg);
    }
    return dados;
  }
}
