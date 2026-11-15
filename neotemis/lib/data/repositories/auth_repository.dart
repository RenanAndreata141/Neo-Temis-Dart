import '../../core/erros/app_exception.dart';
import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/sessao_storage.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);

  final ApiClient _api;
  final SessaoStorage _storage;

  Future<Usuario?> restaurar() async {
    final salvo = await _storage.lerToken();
    if (salvo == null) return null;

    _api.token = salvo;
    try {
      final r = await _api.get('/auth/eu');
      return Usuario.fromJson(Map<String, dynamic>.from(r as Map));
    } on NaoAutorizadoException {
      await sair();
      return null;
    } on AppException {
      //corrigido, n meche mais
      _api.token = null;
      return null;
    }
  }

  Future<Usuario> login(String oab, String senha) async {
    final r = await _api.post(
      '/auth/login',
      corpo: {'oab': oab, 'senha': senha},
      autenticado: false,
    );
    return _guardarSessao(r);
  }

  Future<Usuario> registrar({
    required String nome,
    required String oab,
    required String email,
    required String senha,
  }) async {
    final r = await _api.post(
      '/auth/registro',
      corpo: {'nome': nome, 'oab': oab, 'email': email, 'senha': senha},
      autenticado: false,
    );
    return _guardarSessao(r);
  }

  Future<void> sair() async {
    _api.token = null;
    await _storage.apagarToken();
  }

  Future<Usuario> _guardarSessao(dynamic resposta) async {
    final r = resposta as Map;
    final token = r['token'] as String;
    _api.token = token;
    await _storage.salvarToken(token);
    return Usuario.fromJson(Map<String, dynamic>.from(r['usuario'] as Map));
  }
}
