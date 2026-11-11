import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeoCores {
  static const fundo = Color(0xFFF9FAFB);
  static const card = Color(0xFFD9D9D9);
  static const botao = Color(0xFF212121);
  static const preto = Color(0xFF080808);
  static const cardEscuro = Color(0xFF211F1F);
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
    bool italico = true,
  }) =>
      GoogleFonts.platypi(
        fontSize: size,
        fontWeight: peso,
        color: cor,
        fontStyle: italico ? FontStyle.italic : FontStyle.normal,
      );
}

const neoCardBranco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(15)),
  boxShadow: [
    BoxShadow(color: Color(0x26000000), blurRadius: 25.7, spreadRadius: -7),
  ],
);

const neoGradiente = LinearGradient(colors: [NeoCores.preto, NeoCores.botao]);
