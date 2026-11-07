import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeoCores {
  static const fundo = Color(0xFFF9FAFB);
  static const card = Color(0xFFD9D9D9);
  static const botao = Color(0xFF212121);
}

class NeoTextos {
  static TextStyle rajdhani({
    double size = 16,
    FontWeight peso = FontWeight.w500,
    Color cor = Colors.black,
  }) =>
      GoogleFonts.rajdhani(fontSize: size, fontWeight: peso, color: cor);

  static TextStyle platypi({
    double size = 18,
    FontWeight peso = FontWeight.w300,
    Color cor = Colors.black,
  }) =>
      GoogleFonts.platypi(
        fontSize: size,
        fontWeight: peso,
        fontStyle: FontStyle.italic,
        color: cor,
      );
}
