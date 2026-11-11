import 'package:flutter/material.dart';

import 'api_service.dart';
import 'componentes.dart';
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

  String? _validar() {
    final email = _email.text.trim();
    if (_nome.text.trim().length < 3) return 'informe seu nome completo';
    final erroOab = validarOab(_oab.text);
    if (erroOab != null) return erroOab;
    if (email.isNotEmpty && !RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
      return 'E-mail inválido.';
    }
    if (_senha.text.length < 6) return 'a senha precisa ter pelo menos 6 caracteres';
    if (_senha.text != _confirma.text) return 'as senhas não conferem';
    return null;
  }

  Future<void> _cadastrar() async {
    final problema = _validar();
    setState(() {
      _erro = problema;
      _carregando = problema == null;
    });
    if (problema != null) return;

    try {
      await Api.registro(
        nome: _nome.text.trim(),
        oab: _oab.text.trim(),
        email: _email.text.trim(),
        senha: _senha.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
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
    return TelaAutenticacao(
      children: [
        Image.asset('assets/images/NeoTemis OFICIAL png 1.png', width: 200, height: 90),
        const SizedBox(height: 12),
        Text('CRIAR CONTA', style: NeoTextos.rajdhani(size: 26, peso: FontWeight.w700)),
        const SizedBox(height: 20),
        NeoCampo(controller: _nome, dica: 'Nome completo'),
        const SizedBox(height: 14),
        NeoCampo(
          controller: _oab,
          dica: 'OAB (ex: SP 123456)',
          mascaras: [MascaraOab()],
        ),
        const SizedBox(height: 14),
        NeoCampo(
          controller: _email,
          dica: 'E-mail (opcional)',
          teclado: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        NeoCampo(controller: _senha, dica: 'Senha', senha: true),
        const SizedBox(height: 14),
        NeoCampo(
          controller: _confirma,
          dica: 'Confirme a senha',
          senha: true,
          aoEnviar: (_) => _cadastrar(),
        ),
        if (_erro != null) TextoErro(_erro!),
        const SizedBox(height: 24),
        NeoBotao(texto: 'CADASTRAR', onTap: _cadastrar, carregando: _carregando),
        const SizedBox(height: 12),
        InkWell(
          onTap: _carregando ? null : () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text('Já tenho conta', style: NeoTextos.rajdhani()),
          ),
        ),
      ],
    );
  }
}
