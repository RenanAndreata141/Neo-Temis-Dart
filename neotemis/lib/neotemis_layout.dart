import 'dart:async';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'assistente.dart';
import 'theme.dart';

void irPara(BuildContext context, String rota) {
  Navigator.pushNamedAndRemoveUntil(context, rota, (_) => false);
}

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
              'assets/images/NEOhomeFUNDO.png',
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
          Image.asset('assets/images/Temis Home Page barra superior.png', height: 42),
          const SizedBox(width: 35),
          _LinkMenu('INÍCIO', () => irPara(context, '/home')),
          const SizedBox(width: 40),
          _LinkMenu('PROCESSOS', () => irPara(context, '/processos')),
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
    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (sair == true) Api.sair();
  }

  @override
  Widget build(BuildContext context) {
    final nome = Api.usuario?['nome'] as String? ?? '';
    final inicial = nome.isEmpty ? '?' : nome[0].toUpperCase();

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
  static const _dias = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
    'Sexta-feira', 'Sábado', 'Domingo',
  ];
  static const _meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

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

  String _doisDigitos(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final nome = (Api.usuario?['nome'] as String? ?? '').split(' ').first;
    final data = '${_dias[_agora.weekday - 1]}, ${_agora.day} de ${_meses[_agora.month - 1]}';
    final hora = '${_doisDigitos(_agora.hour)}:${_doisDigitos(_agora.minute)}:${_doisDigitos(_agora.second)}';

    return Text(
      'Olá $nome | $data | $hora',
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
            child: Image.asset('assets/images/Temis Home Page barra superior.png', width: 49, height: 66),
          ),
        ),
      ),
    );
  }
}
