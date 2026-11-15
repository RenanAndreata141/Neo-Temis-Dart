import 'package:material_ui/material_ui.dart';

import '../../../app/dependencias.dart';
import '../../../logic/login_controller.dart';
import '../../layout/tela_autenticacao.dart';
import '../../rotas.dart';
import '../../theme/tema.dart';
import '../../widgets/avisos.dart';
import '../../widgets/neo_botao.dart';
import '../../widgets/neo_campo.dart';
import '../../widgets/texto_erro.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller = LoginController(context.deps.sessao);
  final _oab = TextEditingController();
  final _senha = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _oab.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _entrar() => _controller.entrar(_oab.text, _senha.text);

  @override
  Widget build(BuildContext context) {
    final estiloLink = NeoTextos.rajdhani();

    return TelaAutenticacao(
      children: [
        Image.asset(NeoImagens.logo, width: 233, height: 120),
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
              onTap: () => avisar(context, 'Recuperação de senha em breve'),
              child: Text('Esqueci a senha', style: estiloLink),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('|', style: estiloLink),
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(context, Rotas.cadastro),
              child: Text('Cadastre-se', style: estiloLink),
            ),
          ],
        ),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Column(
            children: [
              if (_controller.erro case final erro?) TextoErro(erro),
              const SizedBox(height: 39),
              NeoBotao(texto: 'ENTRAR', onTap: _entrar, carregando: _controller.carregando),
            ],
          ),
        ),
      ],
    );
  }
}
