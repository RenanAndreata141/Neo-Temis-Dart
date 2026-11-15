import 'package:material_ui/material_ui.dart';

import '../../../../data/models/processo.dart';
import '../../../theme/tema.dart';
import '../../../widgets/caixa_marcacao.dart';
import '../../../widgets/neo_botao.dart';

class CardFiltro extends StatelessWidget {
  const CardFiltro({
    super.key,
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
          for (final status in StatusProcesso.opcoes)
            InkWell(
              onTap: () => onMarcar(status),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CaixaMarcacao(marcada: marcados.contains(status), tamanho: 25),
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
