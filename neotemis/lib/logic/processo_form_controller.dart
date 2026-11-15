//info pro prof: esse arquivo basicamente edita as funções de criar, ver e editar um processo

import 'dart:typed_data';

import '../core/erros/app_exception.dart';
import '../core/utils/imagem.dart';
import '../data/models/processo.dart';
import '../data/repositories/processo_repository.dart';
import 'controller_base.dart';

class ProcessoFormController extends ControllerBase {
  ProcessoFormController(this._repo, {this.original})
      : _editando = original == null,
        _status = original?.status ?? StatusProcesso.opcoes.first,
        _prazo = original?.prazo;

  static const limiteImagem = 5 * 1024 * 1024;

  final ProcessoRepository _repo;

  final Processo? original;

  bool _editando;
  String _status;
  DateTime? _prazo;
  Uint8List? _novaImagem;
  String? _novoTipo;
  bool _removerImagem = false;
  bool _salvando = false;
  String? _erro;

  bool get novo => original == null;
  bool get editando => _editando;
  String get status => _status;
  DateTime? get prazo => _prazo;
  Uint8List? get novaImagem => _novaImagem;
  bool get removerImagem => _removerImagem;
  bool get salvando => _salvando;
  String? get erro => _erro;

  bool get temImagemAtual =>
      _novaImagem != null || (!_removerImagem && (original?.temImagem ?? false));

  String get titulo {
    if (novo) return 'Novo processo';
    return _editando ? 'Editar processo' : 'Detalhes do processo';
  }

  void iniciarEdicao() {
    _editando = true;
    notifyListeners();
  }

  bool cancelarEdicao() {
    final p = original;
    if (p == null) return false;
    _status = p.status;
    _prazo = p.prazo;
    _novaImagem = null;
    _novoTipo = null;
    _removerImagem = false;
    _erro = null;
    _editando = false;
    notifyListeners();
    return true;
  }

  void definirStatus(String status) {
    _status = status;
    notifyListeners();
  }

  void definirPrazo(DateTime? prazo) {
    _prazo = prazo;
    notifyListeners();
  }

  void receberImagem(Uint8List bytes) {
    final tipo = detectarTipoImagem(bytes);
    if (tipo == null) {
      _erro = 'use uma imagem JPG, PNG ou WebP';
    } else if (bytes.length > limiteImagem) {
      _erro = 'a imagem passa de 5 MB, nossa API é muita fraca pra lidar com isso então....tenta outra';
    } else {
      _novaImagem = bytes;
      _novoTipo = tipo;
      _removerImagem = false;
      _erro = null;
    }
    notifyListeners();
  }

  void falhaAoAbrirImagem() {
    _erro = 'não foi possível abrir a imagem....é...deu alguma coisa errada :(';
    notifyListeners();
  }

  void removerImagemAtual() {
    _novaImagem = null;
    _novoTipo = null;
    _removerImagem = original?.temImagem ?? false;
    notifyListeners();
  }

  Future<Processo?> salvar({
    required String nome,
    required String numero,
    required String cliente,
    required String descricao,
  }) {
    final rascunho = Processo(
      id: original?.id ?? '',
      nome: nome.trim(),
      numero: numero.trim(),
      cliente: cliente.trim(),
      status: _status,
      descricao: descricao.trim(),
      prazo: _prazo,
    );
    return _executar(
      () => _repo.salvar(
        rascunho,
        imagem: _novaImagem,
        imagemTipo: _novoTipo,
        removerImagem: _removerImagem,
      ),
    );
  }

  Future<bool> excluir() async {
    final p = original;
    if (p == null) return false;
    final ok = await _executar(() async {
      await _repo.excluir(p.id);
      return true;
    });
    return ok ?? false;
  }

  Future<T?> _executar<T>(Future<T> Function() acao) async {
    _salvando = true;
    _erro = null;
    notifyListeners();
    try {
      return await acao();
    } on AppException catch (e) {
      _erro = e.mensagem;
      _salvando = false;
      notifyListeners();
      return null;
    }
  }
}
