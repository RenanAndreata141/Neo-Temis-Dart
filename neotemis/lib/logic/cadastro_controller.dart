import '../core/erros/app_exception.dart';
import '../core/validacao/validadores.dart';
import 'controller_base.dart';
import 'sessao_controller.dart';

class CadastroController extends ControllerBase {
  CadastroController(this._sessao);

  final SessaoController _sessao;

  bool _carregando = false;
  String? _erro;

  bool get carregando => _carregando;
  String? get erro => _erro;

  Future<void> cadastrar({
    required String nome,
    required String oab,
    required String email,
    required String senha,
    required String confirmacao,
  }) async {
    nome = nome.trim();
    oab = oab.trim();
    email = email.trim();

    final problema = _validar(nome, oab, email, senha, confirmacao);
    _erro = problema;
    _carregando = problema == null;
    notifyListeners();
    if (problema != null) return;

    try {
      await _sessao.registrar(nome: nome, oab: oab, email: email, senha: senha);
    } on AppException catch (e) {
      _erro = e.mensagem;
      _carregando = false;
      notifyListeners();
    }
  }

  String? _validar(String nome, String oab, String email, String senha, String confirmacao) {
    if (nome.length < 3) return 'informe seu nome completo';
    final erroOab = validarOab(oab);
    if (erroOab != null) return erroOab;
    if (email.isNotEmpty && !emailValido(email)) return 'E-mail inválido';
    if (senha.length < 6) return 'a senha precisa ter pelo menos 6 caracteres';
    if (senha != confirmacao) return 'as senhas não conferem';
    return null;
  }
}
