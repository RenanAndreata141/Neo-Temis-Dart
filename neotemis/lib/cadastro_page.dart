import 'dart:ui';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'home_page.dart';
import 'theme.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nome = TextEditingController();
  final _oab = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirma = TextEditingController();

  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _oab.dispose();
    _email.dispose();
    _senha.dispose();
    _confirma.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final nome = _nome.text.trim();
    final oab = _oab.text.trim();
    final email = _email.text.trim();
    final senha = _senha.text;

    String? problema;
    if (nome.length < 3) {
      problema = 'Informe seu nome completo.';
    } else if (oab.length < 4) {
      problema = 'Informe seu registro da OAB.';
    } else if (email.isNotEmpty && !RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
      problema = 'E-mail inválido.';
    } else if (senha.length < 6) {
      problema = 'A senha precisa ter pelo menos 6 caracteres.';
    } else if (senha != _confirma.text) {
      problema = 'As senhas não conferem.';
    }
    if (problema != null) {
      setState(() => _erro = problema);
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await Api.registro(nome: nome, oab: oab, email: email, senha: senha);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    }
  }

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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 462),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 40),
                  decoration: BoxDecoration(
                    color: NeoCores.card,
                    borderRadius: BorderRadius.circular(29),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/NeoTemis OFICIAL png 1.png',
                        width: 200,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'CRIAR CONTA',
                        style: NeoTextos.rajdhani(size: 26, peso: FontWeight.w700),
                      ),
                      const SizedBox(height: 20),
                      _Campo(controller: _nome, hint: 'Nome completo'),
                      const SizedBox(height: 14),
                      _Campo(
                        controller: _oab,
                        hint: 'Registro oficial da OAB',
                      ),
                      const SizedBox(height: 14),
                      _Campo(
                        controller: _email,
                        hint: 'E-mail (opcional)',
                        teclado: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _Campo(controller: _senha, hint: 'Senha', obscure: true),
                      const SizedBox(height: 14),
                      _Campo(
                        controller: _confirma,
                        hint: 'Confirme a senha',
                        obscure: true,
                        onSubmitted: (_) => _cadastrar(),
                      ),
                      if (_erro != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _erro!,
                          textAlign: TextAlign.center,
                          style: NeoTextos.rajdhani(
                            size: 16,
                            peso: FontWeight.w600,
                            cor: Colors.red.shade800,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 231,
                        height: 52,
                        child: Material(
                          color: NeoCores.botao,
                          child: InkWell(
                            onTap: _carregando ? null : _cadastrar,
                            child: Center(
                              child: _carregando
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: NeoCores.fundo,
                                      ),
                                    )
                                  : Text(
                                      'CADASTRAR',
                                      style: NeoTextos.rajdhani(
                                        size: 24,
                                        peso: FontWeight.w700,
                                        cor: NeoCores.fundo,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _carregando ? null : () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text('Já tenho conta', style: NeoTextos.rajdhani()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.teclado,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? teclado;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final base = NeoTextos.platypi(size: 20);
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: teclado,
        onSubmitted: onSubmitted,
        style: base,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: base.copyWith(color: const Color(0x80000000)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
