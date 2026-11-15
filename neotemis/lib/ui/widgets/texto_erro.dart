import 'package:material_ui/material_ui.dart';

import '../theme/tema.dart';

class TextoErro extends StatelessWidget {
  const TextoErro(
    this.mensagem, {
    super.key,
    this.alinhamento = TextAlign.center,
    this.espacoAcima = 12,
  });

  final String mensagem;
  final TextAlign alinhamento;
  final double espacoAcima;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: espacoAcima),
      child: Text(
        mensagem,
        textAlign: alinhamento,
        style: NeoTextos.rajdhani(
          size: 16,
          peso: FontWeight.w600,
          cor: Colors.red.shade800,
        ),
      ),
    );
  }
}
