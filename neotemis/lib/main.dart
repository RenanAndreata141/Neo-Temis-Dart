import 'package:flutter/material.dart';

import 'api_service.dart';
import 'cadastro_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Api.aoDeslogar = ({bool sessaoExpirada = false}) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => construirLogin()),
      (_) => false,
    );
    if (sessaoExpirada) _aviso('Sua sessão expirou. Entre novamente.');
  };

  final logado = await Api.restaurarSessao();
  runApp(NeotemisApp(logado: logado));
}

void _aviso(String mensagem) {
  messengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(mensagem)));
}

Future<void> _entrar(String oab, String senha) async {
  if (oab.isEmpty || senha.isEmpty) {
    _aviso('Informe a OAB e a senha.');
    return;
  }

  final nav = navigatorKey.currentState!;
  showDialog(
    context: navigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    await Api.login(oab, senha);
    nav.pop();
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (_) => false,
    );
  } on ApiException catch (e) {
    nav.pop();
    _aviso(e.mensagem);
  }
}

Widget construirLogin() => LoginPage(
      onLogin: _entrar,
      onRegister: () => navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => const CadastroPage()),
      ),
      onForgotPassword: () =>
          _aviso('Recuperação de senha em breve. Por enquanto, fale com o suporte.'),
    );

class NeotemisApp extends StatelessWidget {
  const NeotemisApp({super.key, required this.logado});

  final bool logado;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neotemis',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: NeoCores.botao),
        scaffoldBackgroundColor: NeoCores.fundo,
      ),
      home: logado ? const HomePage() : construirLogin(),
    );
  }
}
