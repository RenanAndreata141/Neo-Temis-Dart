import 'package:flutter/material.dart';

import 'api_service.dart';
import 'componentes.dart';
import 'theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _oab = TextEditingController();
  final _senha = TextEditingController();

  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _oab.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final oab = _oab.text.trim();
    final senha = _senha.text;
    if (oab.isEmpty || senha.isEmpty) {
      setState(() => _erro = 'informe a OAB e a senha');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await Api.login(oab, senha);
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
    final estiloLink = NeoTextos.rajdhani();

    return TelaAutenticacao(
      children: [
        Image.asset('assets/images/NeoTemis OFICIAL png 1.png', width: 233, height: 120),
        const SizedBox(height: 39),
        NeoCampo(
          controller: _oab,
          dica: 'OAB (ex: SP 123456)',
          mascaras: [MascaraOab()],
        ),
        const SizedBox(height: 19),
        NeoCampo(
          controller: _senha,
          dica: 'Digite a senha',
          senha: true,
          aoEnviar: (_) => _entrar(),
        ),
        const SizedBox(height: 11),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => avisar(
                context,
                'Recuperação de senha em breve',
              ),
              child: Text('Esqueci a senha', style: estiloLink),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('|', style: estiloLink),
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/cadastro'),
              child: Text('Cadastre-se', style: estiloLink),
            ),
          ],
        ),
        if (_erro != null) TextoErro(_erro!),
        const SizedBox(height: 39),
        NeoBotao(texto: 'ENTRAR', onTap: _entrar, carregando: _carregando),
      ],
    );
  }
}
