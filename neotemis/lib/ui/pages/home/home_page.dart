import 'package:material_ui/material_ui.dart';

import '../../layout/neo_pagina_base.dart';
import '../../rotas.dart';
import '../../theme/tema.dart';
import '../../widgets/avisos.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return NeoPaginaBase(
      child: Wrap(
        spacing: 28,
        runSpacing: 28,
        children: [
          _CardMenu(
            titulo: 'PROCESSOS',
            tamanhoTitulo: 40,
            icone: Icons.balance,
            onTap: () => irPara(context, Rotas.processos),
          ),
          _CardMenu(
            titulo: 'CONFIGURAÇÕES',
            tamanhoTitulo: 30,
            icone: Icons.settings_outlined,
            onTap: () => avisar(context, 'configurações em breve'),
          ),
        ],
      ),
    );
  }
}

class _CardMenu extends StatelessWidget {
  const _CardMenu({
    required this.titulo,
    required this.tamanhoTitulo,
    required this.icone,
    required this.onTap,
  });

  final String titulo;
  final double tamanhoTitulo;
  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 180,
      decoration: neoCardBranco.copyWith(color: NeoCores.cardEscuro),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 64, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                titulo,
                style: NeoTextos.rajdhani(
                  size: tamanhoTitulo,
                  peso: FontWeight.w700,
                  cor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
