import 'package:material_ui/material_ui.dart';

import '../ui/pages/cadastro/cadastro_page.dart';
import '../ui/pages/home/home_page.dart';
import '../ui/pages/login/login_page.dart';
import '../ui/pages/processos/processos_page.dart';
import '../ui/rotas.dart';
import '../ui/theme/tema.dart';
import 'dependencias.dart';

class NeotemisApp extends StatefulWidget {
  const NeotemisApp({super.key, required this.dependencias});

  final Dependencias dependencias;

  @override
  State<NeotemisApp> createState() => _NeotemisAppState();
}

class _NeotemisAppState extends State<NeotemisApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  late bool _estavaLogado;

  @override
  void initState() {
    super.initState();
    final sessao = widget.dependencias.sessao;
    _estavaLogado = sessao.logado;
    sessao.addListener(_aoMudarSessao);
  }

  @override
  void dispose() {
    widget.dependencias.sessao.removeListener(_aoMudarSessao);
    super.dispose();
  }

  void _aoMudarSessao() {
    final sessao = widget.dependencias.sessao;
    if (sessao.logado == _estavaLogado) return;
    _estavaLogado = sessao.logado;

    final rota = sessao.logado ? Rotas.home : Rotas.login;
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(rota, (_) => false);

    if (!sessao.logado && sessao.expirou) {
      _messengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Sua sessão expirou')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencias: widget.dependencias,
      child: MaterialApp(
        title: 'Neotemis',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        scaffoldMessengerKey: _messengerKey,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: neoTema(),
        initialRoute: widget.dependencias.sessao.logado ? Rotas.home : Rotas.login,
        routes: {
          Rotas.login: (_) => const LoginPage(),
          Rotas.cadastro: (_) => const CadastroPage(),
          Rotas.home: (_) => const HomePage(),
          Rotas.processos: (_) => const ProcessosPage(),
        },
      ),
    );
  }
}
