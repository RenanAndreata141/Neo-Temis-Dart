import 'package:material_ui/material_ui.dart';

import '../../../app/dependencias.dart';
import '../../../data/models/processo.dart';
import '../../../logic/processos_controller.dart';
import '../../layout/neo_pagina_base.dart';
import '../../theme/tema.dart';
import '../../widgets/caixa_marcacao.dart';
import '../../widgets/neo_botao.dart';
import 'widgets/aviso_filtro_assistente.dart';
import 'widgets/card_filtro.dart';
import 'widgets/processo_dialog.dart';
import 'widgets/tabela_processos.dart';

class ProcessosPage extends StatefulWidget {
  const ProcessosPage({super.key});

  @override
  State<ProcessosPage> createState() => _ProcessosPageState();
}

class _ProcessosPageState extends State<ProcessosPage> {
  late final ProcessosController _controller;

  @override
  void initState() {
    super.initState();
    final deps = context.deps;
    _controller = ProcessosController(deps.processoRepository, deps.assistente)..carregar();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _abrir({Processo? processo}) async {
    final resultado = await mostrarProcessoDialog(context, processo: processo);
    if (resultado == null) return;
    if (resultado.excluido) {
      _controller.registrarExcluido(resultado.processo);
    } else {
      _controller.registrarSalvo(resultado.processo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeoPaginaBase(
      onPesquisar: _controller.pesquisar,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => Wrap(
          spacing: 32,
          runSpacing: 32,
          children: [
            _cardProcessos(),
            CardFiltro(
              marcados: _controller.statusMarcados,
              onMarcar: _controller.alternarStatus,
              onFiltrar: _controller.aplicarFiltroStatus,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardProcessos() {
    final lista = _controller.visiveis;
    final filtroIa = _controller.filtroAssistente;

    return Container(
      width: 950,
      constraints: const BoxConstraints(minHeight: 854),
      padding: const EdgeInsets.fromLTRB(60, 26, 60, 29),
      decoration: neoCardBranco,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            children: [
              const SizedBox(width: 17),
              CaixaMarcacao(
                marcada: _controller.todosSelecionados(lista),
                onTap: () => _controller.alternarTodos(lista),
              ),
              const SizedBox(width: 33),
              Text('NÚMERO CNJ', style: NeoTextos.rajdhani(size: 20, peso: FontWeight.w700)),
              const Spacer(),
              SizedBox(
                width: TabelaProcessos.larguraPrazo,
                child: Text('PRAZO', style: NeoTextos.rajdhani(size: 20, peso: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (filtroIa != null)
            AvisoFiltroAssistente(
              descricao: filtroIa.descricao,
              quantidade: lista.length,
              onLimpar: _controller.limparFiltroAssistente,
            ),
          TabelaProcessos(
            processos: lista,
            carregando: _controller.carregando,
            erro: _controller.erro,
            mensagemVazia: _controller.mensagemListaVazia(lista),
            selecionados: _controller.selecionados,
            onAlternarSelecao: _controller.alternarSelecao,
            onAbrir: (p) => _abrir(processo: p),
            onTentarNovamente: _controller.tentarNovamente,
          ),
        ],
      ),
    );
  }
}
