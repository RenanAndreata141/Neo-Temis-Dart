import 'dart:convert';
import 'dart:typed_data';

import '../models/processo.dart';
import '../services/api_client.dart';

class ProcessoRepository {
  ProcessoRepository(this._api);

  final ApiClient _api;
  final Map<String, Uint8List> _cacheImagens = {};

  static const _maxImagensEmCache = 100;

  Future<List<Processo>> listar() async {
    final r = await _api.get('/processos');
    return (r as List)
        .map((e) => Processo.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
  // o metodo de salvar o processo ta funfando tenta n quebrar pela mor de deus :(
  Future<Processo> salvar(
    Processo processo, {
    Uint8List? imagem,
    String? imagemTipo,
    bool removerImagem = false,
  }) async {
    final corpo = <String, dynamic>{
      ...processo.toJson(),
      if (imagem != null) 'imagem': base64Encode(imagem),
      if (imagem != null) 'imagemTipo': imagemTipo,
      if (imagem == null && removerImagem) 'removerImagem': true,
    };
    const timeout = Duration(seconds: 60);
    final r = processo.novo
        ? await _api.post('/processos', corpo: corpo, timeout: timeout)
        : await _api.put('/processos/${processo.id}', corpo: corpo, timeout: timeout);
    return Processo.fromJson(Map<String, dynamic>.from(r as Map));
  }

  Future<void> excluir(String id) => _api.delete('/processos/$id');

  /// Bytes da imagem do processo, ou null se não houver / falhar.
  Future<Uint8List?> imagemDe(Processo p) async {
    if (!p.temImagem || p.novo) return null;
    final chave = '${p.id}_${p.atualizadoEm}';
    final emCache = _cacheImagens[chave];
    if (emCache != null) return emCache;

    final bytes = await _api.baixarBytes('/processos/${p.id}/imagem');
    if (bytes == null) return null;
    if (_cacheImagens.length > _maxImagensEmCache) _cacheImagens.clear();
    _cacheImagens[chave] = bytes;
    return bytes;
  }

  void limparCache() => _cacheImagens.clear();
}
