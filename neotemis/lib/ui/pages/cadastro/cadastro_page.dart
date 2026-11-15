import 'package:material_ui/material_ui.dart';

import '../../../app/dependencias.dart';
import '../../../logic/cadastro_controller.dart';
import '../../layout/tela_autenticacao.dart';
import '../../theme/tema.dart';
import '../../widgets/neo_botao.dart';
import '../../widgets/neo_campo.dart';
import '../../widgets/texto_erro.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  late final CadastroController _controller = CadastroController(context.deps.sessao);
  final _nome = TextEditingController();
  final _oab = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirma = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _nome.dispose();
    _oab.dispose();
    _email.dispose();
    _senha.dispose();
    _confirma.dispose();
    super.dispose();
  }

  void _cadastrar() => _controller.cadastrar(
        nome: _nome.text,
        oab: _oab.text,
        email: _email.text,
        senha: _senha.text,
        confirmacao: _confirma.text,
      );

  @override
  Widget build(BuildContext context) {
    return TelaAutenticacao(
      children: [
        Image.asset(NeoImagens.logo, width: 200, height: 90),
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
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Column(
            children: [
              if (_controller.erro case final erro?) TextoErro(erro),
              const SizedBox(height: 24),
              NeoBotao(
                texto: 'CADASTRAR',
                onTap: _cadastrar,
                carregando: _controller.carregando,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _controller.carregando ? null : () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text('Já tenho conta', style: NeoTextos.rajdhani()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
