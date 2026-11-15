import 'package:flutter/foundation.dart';

import '../data/models/usuario.dart';
import '../data/repositories/auth_repository.dart';

class SessaoController extends ChangeNotifier {
  SessaoController(this._auth, {this._aoEncerrar});

  final AuthRepository _auth;
  final VoidCallback? _aoEncerrar;

  Usuario? _usuario;
  bool _expirou = false;

  Usuario? get usuario => _usuario;
  bool get logado => _usuario != null;
  bool get expirou => _expirou;

  Future<void> restaurar() async {
    _usuario = await _auth.restaurar();
    notifyListeners();
  }

  Future<void> entrar(String oab, String senha) async {
    _definirUsuario(await _auth.login(oab, senha));
  }

  Future<void> registrar({
    required String nome,
    required String oab,
    required String email,
    required String senha,
  }) async {
    _definirUsuario(
      await _auth.registrar(nome: nome, oab: oab, email: email, senha: senha),
    );
  }

  Future<void> sair() => _encerrar(expirou: false);

  void sessaoExpirou() => _encerrar(expirou: true);

  void _definirUsuario(Usuario usuario) {
    _usuario = usuario;
    _expirou = false;
    notifyListeners();
  }

  Future<void> _encerrar({required bool expirou}) async {
    if (!logado) return;
    _usuario = null;
    _expirou = expirou;
    _aoEncerrar?.call();
    notifyListeners();
    await _auth.sair();
  }
}
