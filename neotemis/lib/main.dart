import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'app/dependencias.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencias = Dependencias.criar();
  await dependencias.sessao.restaurar();

  runApp(NeotemisApp(dependencias: dependencias));
}
