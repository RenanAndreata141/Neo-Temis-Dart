import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../theme/tema.dart';

class NeoCampo extends StatelessWidget {
  const NeoCampo({
    super.key,
    required this.controller,
    required this.dica,
    this.senha = false,
    this.teclado,
    this.aoEnviar,
    this.mascaras,
  });

  final TextEditingController controller;
  final String dica;
  final bool senha;
  final TextInputType? teclado;
  final ValueChanged<String>? aoEnviar;
  final List<TextInputFormatter>? mascaras;

  @override
  Widget build(BuildContext context) {
    final estilo = NeoTextos.platypi(size: 20);

    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        obscureText: senha,
        keyboardType: teclado,
        onSubmitted: aoEnviar,
        inputFormatters: mascaras,
        style: estilo,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: dica,
          hintStyle: estilo.copyWith(color: Colors.black54),
          contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class MascaraOab extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue antigo, TextEditingValue novo) {
    var letras = '';
    var numeros = '';
    for (final c in novo.text.toUpperCase().split('')) {
      if (letras.length < 2) {
        if (RegExp('[A-Z]').hasMatch(c)) letras += c;
      } else if (numeros.length < 6 && RegExp('[0-9]').hasMatch(c)) {
        numeros += c;
      }
    }
    final texto = numeros.isEmpty ? letras : '$letras $numeros';
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
