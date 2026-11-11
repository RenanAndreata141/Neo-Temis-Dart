import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'api_service.dart';
import 'assistente.dart';
import 'cadastro_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'processos_page.dart';
import 'theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Quando o usuário sai (ou a sessão expira), volta para o login.
  Api.aoDeslogar = ({bool sessaoExpirada = false}) {
    Assistente.limpar();
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
    if (sessaoExpirada) {
      messengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Sua sessão expirou. Entre novamente.')),
      );
    }
  };

  final logado = await Api.restaurarSessao();
  runApp(NeotemisApp(logado: logado));
}

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
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: NeoCores.botao),
        scaffoldBackgroundColor: NeoCores.fundo,
      ),
      home: logado ? const HomePage() : const LoginPage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/cadastro': (_) => const CadastroPage(),
        '/home': (_) => const HomePage(),
        '/processos': (_) => const ProcessosPage(),
      },
    );
  }
}
