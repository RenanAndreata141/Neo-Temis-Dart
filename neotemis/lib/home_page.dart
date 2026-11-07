import 'package:flutter/material.dart';

import 'api_service.dart';
import 'processos_page.dart';
import 'theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nome = Api.usuario?['nome'] as String?;

    return Scaffold(
      backgroundColor: NeoCores.fundo,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 462,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 40),
            decoration: BoxDecoration(
              color: NeoCores.card,
              borderRadius: BorderRadius.circular(29),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/NeoTemis OFICIAL png 1.png',
                  width: 233,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                if (nome != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Olá, $nome',
                    textAlign: TextAlign.center,
                    style: NeoTextos.rajdhani(size: 20, peso: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 32),
                _BotaoMenu(
                  texto: 'PROCESSOS',
                  icone: Icons.folder_open,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProcessosPage()),
                  ),
                ),
                const SizedBox(height: 20),
                _BotaoMenu(
                  texto: 'CONFIGURAÇÕES',
                  icone: Icons.settings,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configurações em breve')),
                  ),
                ),
                const SizedBox(height: 20),
                _BotaoMenu(
                  texto: 'SAIR',
                  icone: Icons.logout,
                  onTap: () => Api.sair(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BotaoMenu extends StatelessWidget {
  const _BotaoMenu({
    required this.texto,
    required this.icone,
    required this.onTap,
  });

  final String texto;
  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 56,
      child: Material(
        color: NeoCores.botao,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, color: NeoCores.fundo),
              const SizedBox(width: 12),
              Text(
                texto,
                style: NeoTextos.rajdhani(
                  size: 22,
                  peso: FontWeight.w700,
                  cor: NeoCores.fundo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
