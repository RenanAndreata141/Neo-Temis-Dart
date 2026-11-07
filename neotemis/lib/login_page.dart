import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onLogin,
    this.onForgotPassword,
    this.onRegister,
  });

  final void Function(String oab, String senha)? onLogin;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onRegister;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _oabController = TextEditingController();
  final _senhaController = TextEditingController();

  static const _fundo = Color(0xFFF9FAFB);
  static const _cardCor = Color(0xFFD9D9D9);
  static const _botaoCor = Color(0xFF212121);

  @override
  void dispose() {
    _oabController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _entrar() {
    widget.onLogin?.call(_oabController.text.trim(), _senhaController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fundo,
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
              child: Container(
                width: 462,
                height: 542,
                decoration: BoxDecoration(
                  color: _cardCor,
                  borderRadius: BorderRadius.circular(29),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 57),

                    Image.asset(
                      'assets/images/NeoTemis OFICIAL png 1.png',
                      width: 233,
                      height: 120,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 39),

                    _CampoTexto(
                      controller: _oabController,
                      hint: 'Digite o registro oficial da OAB',
                    ),

                    const SizedBox(height: 19),

                    _CampoTexto(
                      controller: _senhaController,
                      hint: 'Digite a senha',
                      obscure: true,
                      onSubmitted: (_) => _entrar(),
                    ),

                    const SizedBox(height: 11),

                    SizedBox(
                      width: 379,
                      height: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LinkTexto(
                            texto: 'Esqueci a senha',
                            onTap: widget.onForgotPassword,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('|', style: _estiloLink),
                          ),
                          _LinkTexto(
                            texto: 'Cadastre-se',
                            onTap: widget.onRegister,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 39),

                    SizedBox(
                      width: 231,
                      height: 52,
                      child: Material(
                        color: _botaoCor,
                        child: InkWell(
                          onTap: _entrar,
                          child: Center(
                            child: Text(
                              'ENTRAR',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rajdhani(
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                height: 31 / 24,
                                color: _fundo,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final TextStyle _estiloLink = GoogleFonts.rajdhani(
  fontWeight: FontWeight.w500,
  fontSize: 16,
  height: 20 / 16,
  color: Colors.black,
);

class _LinkTexto extends StatelessWidget {
  const _LinkTexto({required this.texto, this.onTap});

  final String texto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(texto, style: _estiloLink),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  const _CampoTexto({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final ValueChanged<String>? onSubmitted;

  TextStyle get _base => GoogleFonts.platypi(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w300,
        fontSize: 20,
        height: 28 / 20,
        color: Colors.black,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 379,
      height: 52,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onSubmitted: onSubmitted,
        style: _base,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: _base.copyWith(color: const Color(0x80000000)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}