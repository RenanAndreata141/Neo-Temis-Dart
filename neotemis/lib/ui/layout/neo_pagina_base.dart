import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../app/dependencias.dart';
import '../../core/utils/datas.dart';
import '../pages/assistente/painel_assistente.dart';
import '../rotas.dart';
import '../theme/tema.dart';
import '../widgets/avisos.dart';

class NeoPaginaBase extends StatelessWidget {
  const NeoPaginaBase({super.key, required this.child, this.onPesquisar});

  final Widget child;

  final ValueChanged<String>? onPesquisar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoCores.fundo,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              NeoImagens.fundoHome,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          Column(
            children: [
              _Cabecalho(onPesquisar: onPesquisar),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(51, 45, 51, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Saudacao(),
                      const SizedBox(height: 47),
                      child,
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(right: 55, bottom: 52, child: _BotaoAssistente()),
        ],
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({this.onPesquisar});

  final ValueChanged<String>? onPesquisar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(gradient: neoGradiente),
      child: Row(
        children: [
          Image.asset(NeoImagens.logoBarra, height: 42),
          const SizedBox(width: 35),
          _LinkMenu('INÍCIO', () => irPara(context, Rotas.home)),
          const SizedBox(width: 40),
          _LinkMenu('PROCESSOS', () => irPara(context, Rotas.processos)),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 456,
                child: _BarraPesquisa(onPesquisar: onPesquisar),
              ),
            ),
          ),
          const _Avatar(),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _LinkMenu extends StatelessWidget {
  const _LinkMenu(this.texto, this.onTap);

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        texto,
        style: NeoTextos.rajdhani(size: 32, peso: FontWeight.w700, cor: Colors.white),
      ),
    );
  }
}

class _BarraPesquisa extends StatelessWidget {
  const _BarraPesquisa({this.onPesquisar});

  final ValueChanged<String>? onPesquisar;

  @override
  Widget build(BuildContext context) {
    final estilo = NeoTextos.rajdhani(size: 14, peso: FontWeight.w700, cor: Colors.white);

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xCC404040),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              enabled: onPesquisar != null,
              onChanged: onPesquisar,
              style: estilo,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Pesquisar...',
                hintStyle: estilo.copyWith(color: Colors.white60),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  Future<void> _confirmarSaida(BuildContext context) async {
    final sessao = context.deps.sessao;
    final sair = await confirmar(context, titulo: 'Sair da conta?', textoConfirmar: 'Sair');
    // A navegação para o login acontece no app, ao ouvir a sessão.
    if (sair) await sessao.sair();
  }

  @override
  Widget build(BuildContext context) {
    final inicial = context.deps.sessao.usuario?.inicial ?? '?';

    return Tooltip(
      message: 'Sair',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _confirmarSaida(context),
        child: CircleAvatar(
          radius: 24.5,
          backgroundColor: Colors.white,
          child: Text(inicial, style: NeoTextos.rajdhani(size: 24, peso: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _Saudacao extends StatefulWidget {
  const _Saudacao();

  @override
  State<_Saudacao> createState() => _SaudacaoState();
}

class _SaudacaoState extends State<_Saudacao> {
  DateTime _agora = DateTime.now();
  late final Timer _relogio;

  @override
  void initState() {
    super.initState();
    _relogio = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _agora = DateTime.now());
    });
  }

  @override
  void dispose() {
    _relogio.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nome = context.deps.sessao.usuario?.primeiroNome ?? '';

    return Text(
      'Olá $nome | ${dataPorExtenso(_agora)} | ${horaCompleta(_agora)}',
      style: NeoTextos.platypi(
        size: 24,
        peso: FontWeight.w400,
        italico: false,
        cor: const Color(0xCC212121),
      ),
    );
  }
}

class _BotaoAssistente extends StatelessWidget {
  const _BotaoAssistente();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: neoGradiente),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => abrirAssistente(
            context,
            rotaAtual: ModalRoute.of(context)?.settings.name,
          ),
          child: Center(
            child: Image.asset(NeoImagens.logoBarra, width: 49, height: 66),
          ),
        ),
      ),
    );
  }
}
