import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../theme/tema.dart';

class TelaAutenticacao extends StatelessWidget {
  const TelaAutenticacao({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoCores.fundo,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 9.8, sigmaY: 9.8),
              child: Transform.scale(
                scale: 1.12,
                child: Image.asset(NeoImagens.fundoLogin, fit: BoxFit.cover),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 462),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 41),
                decoration: BoxDecoration(
                  color: NeoCores.card,
                  borderRadius: BorderRadius.circular(29),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: children),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
