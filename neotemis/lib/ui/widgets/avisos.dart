import 'package:material_ui/material_ui.dart';

void avisar(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(mensagem)));
}

Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  String? mensagem,
  required String textoConfirmar,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: mensagem == null ? null : Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(textoConfirmar),
        ),
      ],
    ),
  );
  return r == true;
}
