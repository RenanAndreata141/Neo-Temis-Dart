import 'package:material_ui/material_ui.dart';
import '../../../theme/tema.dart';

class AvisoFiltroAssistente extends StatelessWidget {
  const AvisoFiltroAssistente({
    super.key,
    required this.descricao,
    required this.quantidade,
    required this.onLimpar,
  });

  final String descricao;
  final int quantidade;
  final VoidCallback onLimpar;

  @override
  Widget build(BuildContext context) {
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
              'Assistente: $descricao ($quantidade)',
              style: NeoTextos.rajdhani(size: 18, peso: FontWeight.w700, cor: Colors.white),
            ),
          ),
          TextButton(
            onPressed: onLimpar,
            child: Text(
              'LIMPAR',
              style: NeoTextos.rajdhani(size: 16, peso: FontWeight.w700, cor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
