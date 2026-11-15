import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/datas.dart';
import '../../../../data/models/processo.dart';
import '../../../theme/tema.dart';
import '../../../widgets/caixa_marcacao.dart';
import '../../../widgets/neo_botao.dart';
import '../../../widgets/texto_erro.dart';

class TabelaProcessos extends StatelessWidget {
  const TabelaProcessos({
    super.key,
    required this.processos,
    required this.carregando,
    required this.erro,
    required this.mensagemVazia,
    required this.selecionados,
    required this.onAlternarSelecao,
    required this.onAbrir,
    required this.onTentarNovamente,
  });

  static const larguraPrazo = 150.0;
  static const _linhasMinimas = 13;

  final List<Processo> processos;
  final bool carregando;
  final String? erro;
  final String? mensagemVazia;
  final Set<String> selecionados;
  final ValueChanged<String> onAlternarSelecao;
  final ValueChanged<Processo> onAbrir;
  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final erro = this.erro;
    if (erro != null) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextoErro(erro),
            const SizedBox(height: 16),
            NeoBotao(
              texto: 'tenta denovo ai, deu errado',
              largura: 260,
              onTap: onTentarNovamente,
            ),
          ],
        ),
      );
    }

    final mensagemVazia = this.mensagemVazia;
    if (mensagemVazia != null) return _estadoVazio(mensagemVazia);

    final totalLinhas = max(processos.length, _linhasMinimas);
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        children: [
          for (var i = 0; i < totalLinhas; i++)
            _linha(i < processos.length ? processos[i] : null, ultima: i == totalLinhas - 1),
        ],
      ),
    );
  }

  Widget _estadoVazio(String mensagem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        children: [
          const Icon(Icons.folder_open_outlined, size: 64, color: Colors.black45),
          const SizedBox(height: 16),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: NeoTextos.rajdhani(size: 20, peso: FontWeight.w600, cor: Colors.black54),
          ),
        ],
      ),
    );
  }

  Color _corPrazo(int dias) {
    if (dias < 0) return Colors.red.shade700;
    if (dias <= 7) return Colors.orange.shade800;
    return Colors.black;
  }

  Widget _linha(Processo? p, {required bool ultima}) {
    final prazo = p?.prazo;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: ultima ? null : const Border(bottom: BorderSide()),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 50,
            alignment: Alignment.center,
            decoration: const BoxDecoration(border: Border(right: BorderSide())),
            child: CaixaMarcacao(
              marcada: p != null && selecionados.contains(p.id),
              onTap: p == null ? null : () => onAlternarSelecao(p.id),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: p == null ? null : () => onAbrir(p),
              child: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    p?.titulo ?? '',
                    style: NeoTextos.rajdhani(size: 20, peso: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: larguraPrazo,
            padding: const EdgeInsets.only(left: 14),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(border: Border(left: BorderSide())),
            child: prazo == null
                ? null
                : Text(
                    dataBr(prazo),
                    style: NeoTextos.rajdhani(
                      size: 20,
                      peso: FontWeight.w700,
                      cor: _corPrazo(diasAte(prazo)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
