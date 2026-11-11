import 'dart:math';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'assistente.dart';
import 'componentes.dart';
import 'neotemis_layout.dart';
import 'processo.dart';
import 'processo_dialog.dart';
import 'theme.dart';

/// Tela de processos: tabela à esquerda e card de filtro à direita.
class ProcessosPage extends StatefulWidget {
  const ProcessosPage({super.key});

  @override
  State<ProcessosPage> createState() => _ProcessosPageState();
}

class _ProcessosPageState extends State<ProcessosPage> {
  static const _linhasMinimas = 13;
  static const _larguraPrazo = 150.0;

  List<Processo> _processos = [];
  bool _carregando = true;
  String? _erro;

  String _busca = ''; // texto da barra de pesquisa
  final Set<String> _selecionados = {}; // ids marcados na tabela
  final Set<String> _statusMarcados = {}; // caixas marcadas no filtro
  Set<String> _statusFiltro = {}; // filtro aplicado ao clicar em FILTRAR

  @override
  void initState() {
    super.initState();
    Assistente.filtro.addListener(_aoMudarFiltro);
    _carregar();
  }

  @override
  void dispose() {
    Assistente.filtro.removeListener(_aoMudarFiltro);
    super.dispose();
  }

  void _aoMudarFiltro() => setState(() {});

  Future<void> _carregar() async {
    try {
      final lista = await Api.listar();
      if (!mounted) return;
      setState(() {
        _processos = lista;
        _erro = null;
        _carregando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    }
  }

  void _tentarNovamente() {
    setState(() => _carregando = true);
    _carregar();
  }

  /// Abre o diálogo para ver/editar um processo (ou criar, se for nulo).
  Future<void> _abrir({Processo? processo}) async {
    final resultado = await mostrarProcessoDialog(context, processo: processo);
    if (resultado == null || !mounted) return;

    setState(() {
      final i = _processos.indexWhere((p) => p.id == resultado.processo.id);
      if (resultado.excluir) {
        if (i >= 0) _processos.removeAt(i);
      } else if (i >= 0) {
        _processos[i] = resultado.processo;
      } else {
        _processos.insert(0, resultado.processo);
      }
    });
  }

  /// Marca ou desmarca um valor em um conjunto.
  void _alternar(Set<String> conjunto, String valor) {
    setState(() {
      if (!conjunto.remove(valor)) conjunto.add(valor);
    });
  }

  void _marcarTodos(List<Processo> lista, bool todosMarcados) {
    final ids = lista.map((p) => p.id);
    setState(() {
      if (todosMarcados) {
        _selecionados.removeAll(ids);
      } else {
        _selecionados.addAll(ids);
      }
    });
  }

  /// Processos que passam pela pesquisa e pelo filtro de status.
  List<Processo> get _visiveis {
    final busca = _busca.toLowerCase();

    // Filtro do assistente: mostra só os ids escolhidos, na ordem da IA.
    var base = _processos;
    final filtroIa = Assistente.filtro.value;
    if (filtroIa != null) {
      final porId = {for (final p in _processos) p.id: p};
      base = [for (final id in filtroIa.ids) if (porId[id] != null) porId[id]!];
    }

    return base.where((p) {
      final passaStatus = _statusFiltro.isEmpty || _statusFiltro.contains(p.status);
      final texto = '${p.numero} ${p.nome} ${p.cliente}'.toLowerCase();
      return passaStatus && texto.contains(busca);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return NeoPaginaBase(
      onPesquisar: (texto) => setState(() => _busca = texto),
      child: Wrap(
        spacing: 32,
        runSpacing: 32,
        children: [
          _cardProcessos(),
          _CardFiltro(
            marcados: _statusMarcados,
            onMarcar: (status) => _alternar(_statusMarcados, status),
            onFiltrar: () => setState(() => _statusFiltro = Set.of(_statusMarcados)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Card da tabela
  // -------------------------------------------------------------------------
  Widget _cardProcessos() {
    final lista = _visiveis;
    final todosMarcados =
        lista.isNotEmpty && lista.every((p) => _selecionados.contains(p.id));

    return Container(
      width: 950,
      constraints: const BoxConstraints(minHeight: 854),
      padding: const EdgeInsets.fromLTRB(60, 26, 60, 29),
      decoration: neoCardBranco,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + botão de novo processo
          Row(
            children: [
              const Icon(Icons.balance, size: 78),
              const SizedBox(width: 16),
              Text('PROCESSOS', style: NeoTextos.rajdhani(size: 48, peso: FontWeight.w700)),
              const Spacer(),
              NeoBotao(texto: '+ NOVO', largura: 140, altura: 46, onTap: () => _abrir()),
            ],
          ),
          const SizedBox(height: 37),

          // Cabeçalho da tabela: [ ] NÚMERO CNJ
          Row(
            children: [
              const SizedBox(width: 17),
              _CaixaMarcacao(
                marcada: todosMarcados,
                onTap: () => _marcarTodos(lista, todosMarcados),
              ),
              const SizedBox(width: 33),
              Text('NÚMERO CNJ', style: NeoTextos.rajdhani(size: 20, peso: FontWeight.w700)),
              const Spacer(),
              SizedBox(
                width: _larguraPrazo,
                child: Text('PRAZO', style: NeoTextos.rajdhani(size: 20, peso: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (Assistente.filtro.value != null) _avisoFiltroIa(lista.length),

          _tabela(lista),
        ],
      ),
    );
  }

  Color _corPrazo(int dias) {
    if (dias < 0) return Colors.red.shade700;
    if (dias <= 7) return Colors.orange.shade800;
    return Colors.black;
  }

  /// Faixa que mostra o filtro aplicado pelo assistente, com botão para limpar.
  Widget _avisoFiltroIa(int quantidade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: NeoCores.cardEscuro,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Assistente: ${Assistente.filtro.value!.descricao} ($quantidade)',
              style: NeoTextos.rajdhani(size: 18, peso: FontWeight.w700, cor: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Assistente.filtro.value = null,
            child: Text(
              'LIMPAR',
              style: NeoTextos.rajdhani(size: 16, peso: FontWeight.w700, cor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabela(List<Processo> lista) {
    if (_carregando) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_erro != null) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextoErro(_erro!),
            const SizedBox(height: 16),
            NeoBotao(texto: 'TENTAR NOVAMENTE', largura: 260, onTap: _tentarNovamente),
          ],
        ),
      );
    }

    // Sempre desenha pelo menos 13 linhas, como no Figma
    final totalLinhas = max(lista.length, _linhasMinimas);
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        children: [
          for (var i = 0; i < totalLinhas; i++)
            _linha(i < lista.length ? lista[i] : null, ultima: i == totalLinhas - 1),
        ],
      ),
    );
  }

  /// Uma linha da tabela. Se [p] for nulo, desenha uma linha vazia.
  Widget _linha(Processo? p, {required bool ultima}) {
    final texto = p == null ? '' : (p.numero.isNotEmpty ? p.numero : p.nome);

    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: ultima ? null : const Border(bottom: BorderSide()),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Coluna da caixa de seleção
          Container(
            width: 50,
            alignment: Alignment.center,
            decoration: const BoxDecoration(border: Border(right: BorderSide())),
            child: _CaixaMarcacao(
              marcada: p != null && _selecionados.contains(p.id),
              onTap: p == null ? null : () => _alternar(_selecionados, p.id),
            ),
          ),
          // Número do processo (clique abre os detalhes)
          Expanded(
            child: InkWell(
              onTap: p == null ? null : () => _abrir(processo: p),
              child: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(texto, style: NeoTextos.rajdhani(size: 20, peso: FontWeight.w700)),
                ),
              ),
            ),
          ),
          // Prazo (vermelho = vencido, laranja = vence em até 7 dias)
          Container(
            width: _larguraPrazo,
            padding: const EdgeInsets.only(left: 14),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(border: Border(left: BorderSide())),
            child: p?.prazo == null
                ? null
                : Text(
                    dataBr(p!.prazo!),
                    style: NeoTextos.rajdhani(
                      size: 20,
                      peso: FontWeight.w700,
                      cor: _corPrazo(p.diasParaPrazo!),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de filtro por status
// ---------------------------------------------------------------------------
class _CardFiltro extends StatelessWidget {
  const _CardFiltro({
    required this.marcados,
    required this.onMarcar,
    required this.onFiltrar,
  });

  final Set<String> marcados;
  final ValueChanged<String> onMarcar;
  final VoidCallback onFiltrar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 314,
      height: 644,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: neoCardBranco,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined, size: 68),
              const SizedBox(width: 4),
              Text('FILTRAR', style: NeoTextos.rajdhani(size: 48, peso: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 50),
          Text('STATUS', style: NeoTextos.rajdhani(size: 32, peso: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final status in Processo.statusOpcoes)
            InkWell(
              onTap: () => onMarcar(status),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    _CaixaMarcacao(marcada: marcados.contains(status), tamanho: 25),
                    const SizedBox(width: 15),
                    Text(
                      status.toUpperCase(),
                      style: NeoTextos.rajdhani(size: 24, peso: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          const Spacer(),
          Center(child: NeoBotao(texto: 'FILTRAR', tamanhoFonte: 32, onTap: onFiltrar)),
        ],
      ),
    );
  }
}

/// Caixa de seleção quadrada (branca com borda preta).
class _CaixaMarcacao extends StatelessWidget {
  const _CaixaMarcacao({required this.marcada, this.onTap, this.tamanho = 15});

  final bool marcada;
  final VoidCallback? onTap;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(color: Colors.white, border: Border.all()),
        child: marcada ? Icon(Icons.check, size: tamanho - 4, color: Colors.black) : null,
      ),
    );
  }
}
