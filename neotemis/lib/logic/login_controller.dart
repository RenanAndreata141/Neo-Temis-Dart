import '../core/erros/app_exception.dart';
import 'controller_base.dart';
import 'sessao_controller.dart';

class LoginController extends ControllerBase {
  LoginController(this._sessao);

  final SessaoController _sessao;

  bool _carregando = false;
  String? _erro;

  bool get carregando => _carregando;
  String? get erro => _erro;

  Future<void> entrar(String oab, String senha) async {
    oab = oab.trim();
    if (oab.isEmpty || senha.isEmpty) {
      _erro = 'informe a OAB e a senha';
      notifyListeners();
      return;
    }

    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      await _sessao.entrar(oab, senha);
    } on AppException catch (e) {
      _erro = e.mensagem;
      _carregando = false;
      notifyListeners();
    }
  }
}
