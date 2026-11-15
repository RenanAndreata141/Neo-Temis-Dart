import 'package:material_ui/material_ui.dart';

class CaixaMarcacao extends StatelessWidget {
  const CaixaMarcacao({super.key, required this.marcada, this.onTap, this.tamanho = 15});

  final bool marcada;
  final VoidCallback? onTap;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(color: Colors.white, border: Border.all()),
        child: marcada ? Icon(Icons.check, size: tamanho - 4, color: Colors.black) : null,
      ),
    );
  }
}
