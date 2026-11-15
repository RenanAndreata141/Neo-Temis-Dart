import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class NeoCores {
  static const fundo = Color(0xFFF9FAFB);
  static const card = Color(0xFFD9D9D9);
  static const botao = Color(0xFF212121);
  static const preto = Color(0xFF080808);
  static const cardEscuro = Color(0xFF211F1F);
  static const balaoAssistente = Color(0xFFEFEFEF);
}

abstract final class NeoTextos {
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

/// Caminhos dos arquivos em `assets/images/`.
abstract final class NeoImagens {
  static const logo = 'assets/images/NeoTemis OFICIAL png 1.png';
  static const logoBarra = 'assets/images/Temis Home Page barra superior.png';
  static const fundoLogin = 'assets/images/NEOloginFUNDO.png';
  static const fundoHome = 'assets/images/NEOhomeFUNDO.png';
}

const neoCardBranco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(15)),
  boxShadow: [
    BoxShadow(color: Color(0x26000000), blurRadius: 25.7, spreadRadius: -7),
  ],
);

const neoGradiente = LinearGradient(colors: [NeoCores.preto, NeoCores.botao]);

ThemeData neoTema() => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: NeoCores.botao),
      scaffoldBackgroundColor: NeoCores.fundo,
    );
