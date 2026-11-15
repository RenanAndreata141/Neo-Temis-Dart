import 'dart:collection';

import '../core/erros/app_exception.dart';
import '../data/models/assistente.dart';
import '../data/models/processo.dart';
import '../data/repositories/processo_repository.dart';
import 'assistente_controller.dart';
import 'controller_base.dart';

class ProcessosController extends ControllerBase {
  ProcessosController(this._repo, this._assistente) {
    _assistente.addListener(_aoMudarAssistente);
    _filtroAssistente = _assistente.filtro;
  }

  final ProcessoRepository _repo;
  final AssistenteController _assistente;

  List<Processo> _processos = [];
  bool _carregando = true;
  String? _erro;

  String _busca = '';
  final Set<String> _selecionados = {};

  final Set<String> _statusMarcados = {};

  /// Status aplicados ao clicar em FILTRAR.
  Set<String> _statusFiltro = {};

  FiltroAssistente? _filtroAssistente;

  bool get carregando => _carregando;
  String? get erro => _erro;
  Set<String> get selecionados => UnmodifiableSetView(_selecionados);
  Set<String> get statusMarcados => UnmodifiableSetView(_statusMarcados);
  FiltroAssistente? get filtroAssistente => _filtroAssistente;

  List<Processo> get visiveis {
    var base = _processos;
    final filtroIa = _filtroAssistente;
    if (filtroIa != null) {
      final porId = {for (final p in _processos) p.id: p};
      base = [
        for (final id in filtroIa.ids)
          if (porId[id] != null) porId[id]!,
      ];
    }

    final busca = _busca.toLowerCase();
    return base.where((p) {
      final passaStatus = _statusFiltro.isEmpty || _statusFiltro.contains(p.status);
      final texto = '${p.numero} ${p.nome} ${p.cliente}'.toLowerCase();
      return passaStatus && texto.contains(busca);
    }).toList();
  }

  String? mensagemListaVazia(List<Processo> visiveis) {
    if (visiveis.isNotEmpty) return null;
    if (_processos.isEmpty) {
      return 'Nenhum processo cadastrado ainda';
    }
    return 'Nenhum processo encontrado com a busca e os filtros atuais';
  }

  Future<void> carregar() async {
    try {
      _processos = await _repo.listar();
      _erro = null;
    } on AppException catch (e) {
      _erro = e.mensagem;
    }
    _carregando = false;
    notifyListeners();
  }

  void tentarNovamente() {
    _carregando = true;
    notifyListeners();
    carregar();
  }

  void pesquisar(String texto) {
    _busca = texto;
    notifyListeners();
  }

  void alternarSelecao(String id) {
    if (!_selecionados.remove(id)) _selecionados.add(id);
    notifyListeners();
  }

  bool todosSelecionados(List<Processo> lista) =>
      lista.isNotEmpty && lista.every((p) => _selecionados.contains(p.id));

  void alternarTodos(List<Processo> lista) {
    final ids = lista.map((p) => p.id);
    if (todosSelecionados(lista)) {
      _selecionados.removeAll(ids);
    } else {
      _selecionados.addAll(ids);
    }
    notifyListeners();
  }

  void alternarStatus(String status) {
    if (!_statusMarcados.remove(status)) _statusMarcados.add(status);
    notifyListeners();
  }

  void aplicarFiltroStatus() {
    _statusFiltro = Set.of(_statusMarcados);
    notifyListeners();
  }

  void limparFiltroAssistente() => _assistente.limparFiltro();

  void registrarSalvo(Processo salvo) {
    final i = _processos.indexWhere((p) => p.id == salvo.id);
    if (i >= 0) {
      _processos[i] = salvo;
    } else {
      _processos.insert(0, salvo);
    }
    notifyListeners();
  }

  void registrarExcluido(Processo excluido) {
    _processos.removeWhere((p) => p.id == excluido.id);
    _selecionados.remove(excluido.id);
    notifyListeners();
  }

  void _aoMudarAssistente() {
    if (_assistente.filtro == _filtroAssistente) return;
    _filtroAssistente = _assistente.filtro;
    notifyListeners();
  }

  @override
  void dispose() {
    _assistente.removeListener(_aoMudarAssistente);
    super.dispose();
  }
}
