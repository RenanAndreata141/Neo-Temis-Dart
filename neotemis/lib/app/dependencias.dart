import 'package:flutter/widgets.dart';

import '../core/config/ambiente.dart';
import '../data/repositories/assistente_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/processo_repository.dart';
import '../data/services/api_client.dart';
import '../data/services/gemini_client.dart';
import '../data/services/sessao_storage.dart';
import '../logic/assistente_controller.dart';
import '../logic/sessao_controller.dart';


class Dependencias {
  Dependencias._({
    required this.processoRepository,
    required this.sessao,
    required this.assistente,
  });

  factory Dependencias.criar() {
    final api = ApiClient(baseUrl: Ambiente.apiUrl);
    final gemini = GeminiClient(chave: Ambiente.geminiChave, modelos: Ambiente.geminiModelos);

    final authRepository = AuthRepository(api, SessaoStorage());
    final processoRepository = ProcessoRepository(api);
    final assistenteRepository = AssistenteRepository(gemini, processoRepository);

    final assistente = AssistenteController(assistenteRepository);
    final sessao = SessaoController(
      authRepository,
      aoEncerrar: () {
        assistente.limpar();
        processoRepository.limparCache();
      },
    );
    api.aoNaoAutorizado = sessao.sessaoExpirou;

    return Dependencias._(
      processoRepository: processoRepository,
      sessao: sessao,
      assistente: assistente,
    );
  }

  final ProcessoRepository processoRepository;

  /// Estado global (vive o app inteiro).
  final SessaoController sessao;
  final AssistenteController assistente;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.dependencias, required super.child});

  final Dependencias dependencias;

  static Dependencias of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não foi encontrado na árvore de widgets :(');
    return scope!.dependencias;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}

extension DependenciasContext on BuildContext {
  Dependencias get deps => AppScope.of(this);
}
