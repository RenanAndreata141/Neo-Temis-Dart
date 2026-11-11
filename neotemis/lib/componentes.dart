import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';

void avisar(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(mensagem)));
}

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
  final VoidCallback onTap;
  final double largura;
  final double altura;
  final double tamanhoFonte;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      height: altura,
      child: Material(
        color: NeoCores.botao,
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

class TextoErro extends StatelessWidget {
  const TextoErro(this.mensagem, {super.key});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        mensagem,
        textAlign: TextAlign.center,
        style: NeoTextos.rajdhani(
          size: 16,
          peso: FontWeight.w600,
          cor: Colors.red.shade800,
        ),
      ),
    );
  }
}


class TelaAutenticacao extends StatelessWidget {
  const TelaAutenticacao({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoCores.fundo,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 9.8, sigmaY: 9.8),
              child: Transform.scale(
                scale: 1.12,
                child: Image.asset(
                  'assets/images/NEOloginFUNDO.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 462),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 41),
                decoration: BoxDecoration(
                  color: NeoCores.card,
                  borderRadius: BorderRadius.circular(29),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: children),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _ufs = {
  'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA',
  'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
};

/// Máscara do registro da OAB: sigla do estado + 6 dígitos (ex.: "SP 123456").
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

/// Devolve a mensagem de erro, ou null se a OAB estiver no formato certo.
String? validarOab(String oab) {
  final m = RegExp(r'^([A-Z]{2}) (\d{6})$').firstMatch(oab.trim());
  if (m == null) return 'A OAB deve ter a sigla do estado e 6 números (ex.: SP 123456).';
  if (!_ufs.contains(m.group(1))) return 'Sigla de estado inválida na OAB.';
  return null;
}
