import 'package:material_ui/material_ui.dart';

import '../theme/tema.dart';

class NeoBotao extends StatelessWidget {
  const NeoBotao({
    super.key,
    required this.texto,
    required this.onTap,
    this.largura = 231,
    this.altura = 52,
    this.tamanhoFonte = 24,
    this.carregando = false,
  });

  final String texto;
  final VoidCallback? onTap;
  final double largura;
  final double altura;
  final double tamanhoFonte;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    final desabilitado = onTap == null && !carregando;
    return SizedBox(
      width: largura,
      height: altura,
      child: Material(
        color: desabilitado ? NeoCores.botao.withValues(alpha: 0.5) : NeoCores.botao,
        child: InkWell(
          onTap: carregando ? null : onTap,
          child: Center(
            child: carregando
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: NeoCores.fundo,
                    ),
                  )
                : Text(
                    texto,
                    style: NeoTextos.rajdhani(
                      size: tamanhoFonte,
                      peso: FontWeight.w700,
                      cor: NeoCores.fundo,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
