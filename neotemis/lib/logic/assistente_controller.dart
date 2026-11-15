import 'package:flutter/foundation.dart';

import '../core/erros/app_exception.dart';
import '../data/models/assistente.dart';
import '../data/repositories/assistente_repository.dart';

class AssistenteController extends ChangeNotifier {
  AssistenteController(this._repo);

  final AssistenteRepository _repo;

  List<MensagemChat> _mensagens = const [];
  bool _enviando = false;
  FiltroAssistente? _filtro;

  List<MensagemChat> get mensagens => _mensagens;
  bool get enviando => _enviando;

  FiltroAssistente? get filtro => _filtro;

  Future<FiltroAssistente?> enviar(String texto) async {
    texto = texto.trim();
    if (texto.isEmpty || _enviando) return null;

    final historico = _mensagens;
    _adicionar(MensagemChat(doUsuario: true, texto: texto));
    _enviando = true;
    notifyListeners();

    try {
      final r = await _repo.perguntar(texto, historico);
      _adicionar(MensagemChat(doUsuario: false, texto: r.texto));
      if (r.filtro != null) _filtro = r.filtro;
      return r.filtro;
    } on AppException catch (e) {
      _adicionar(MensagemChat(doUsuario: false, texto: e.mensagem, erro: true));
      return null;
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }

  void novaConversa() {
    _mensagens = const [];
    notifyListeners();
  }

  void limparFiltro() {
    _filtro = null;
    notifyListeners();
  }

  void limpar() {
    _mensagens = const [];
    _enviando = false;
    _filtro = null;
    notifyListeners();
  }

  void _adicionar(MensagemChat m) => _mensagens = [..._mensagens, m];
}
