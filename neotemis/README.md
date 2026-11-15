# NeoTemis — app (Flutter)

Interface do NeoTemis. Precisa da API (`../neotemis_api`) rodando.

Instruções completas de instalação e dependências: veja o [README principal](../README.md).

Resumo:

```bash
flutter pub get
flutter run -d linux      # ou: flutter run -d windows
```

## Arquitetura

O código em `lib/` é separado em camadas. Cada camada só conhece a de baixo:

```
ui  ──►  logic  ──►  data  ──►  (API / Gemini / disco)
            \          |
             └──► core ◄┘   (usado por todas)
```

```
lib/
├── main.dart                 # inicia o app: cria as dependências e restaura a sessão
├── app/
│   ├── app.dart              # MaterialApp, rotas e navegação login ⇄ home
│   └── dependencias.dart     # composition root + AppScope (injeção de dependências)
├── core/                     # código puro, sem Flutter de UI
│   ├── config/ambiente.dart  # --dart-define (API_URL, GEMINI_API_KEY, GEMINI_MODEL)
│   ├── erros/                # AppException, NaoAutorizadoException
│   ├── utils/                # datas, detecção de tipo de imagem
│   └── validacao/            # validarOab, emailValido
├── data/                     # DADOS: de onde vêm e para onde vão
│   ├── models/               # Processo, Usuario, MensagemChat, FiltroAssistente
│   ├── services/             # ApiClient (HTTP), GeminiClient, SessaoStorage (token)
│   └── repositories/         # AuthRepository, ProcessoRepository, AssistenteRepository
├── logic/                    # LÓGICA e ESTADO (ChangeNotifier)
│   ├── sessao_controller.dart        # global: usuário logado
│   ├── assistente_controller.dart    # global: conversa e filtro da Têmis
│   ├── login_controller.dart         # por tela
│   ├── cadastro_controller.dart      # por tela
│   ├── processos_controller.dart     # por tela: lista, busca, seleção, filtros
│   └── processo_form_controller.dart # por diálogo: edição de um processo
└── ui/                       # INTERFACE: só desenha e repassa ações
    ├── rotas.dart
    ├── theme/tema.dart       # cores, fontes, imagens, ThemeData
    ├── widgets/              # componentes reutilizáveis (NeoBotao, NeoCampo...)
    ├── layout/               # estruturas de página (NeoPaginaBase, TelaAutenticacao)
    └── pages/                # uma pasta por tela
        ├── login/  cadastro/  home/  assistente/
        └── processos/ (+ widgets/ da tela)
```

### Regras

- **UI** não faz requisições nem tem regra de negócio: lê o estado de um controller e chama métodos dele.
- **Logic** guarda o estado e as regras (validação, filtros, o que acontece ao salvar). Não importa nada de `ui/` nem widgets do Material.
- **Data** fala com o mundo externo e converte JSON ⇄ modelos. Não guarda estado de tela.
- Objetos só são criados em `app/dependencias.dart`; o resto os recebe pelo construtor ou por `context.deps`.

### Gerenciamento de estado

Usa o que já vem no Flutter, sem pacotes extras: `ChangeNotifier` + `ListenableBuilder`.

| Tipo de estado | Onde fica | Tempo de vida |
|---|---|---|
| Global (sessão, chat da Têmis) | `SessaoController`, `AssistenteController` | app inteiro (criados em `Dependencias`) |
| De tela (lista, formulário, loading, erro) | `LoginController`, `ProcessosController`... | criado no `initState` da tela, descartado no `dispose` |
| Efêmero de UI (texto digitado, relógio, rolagem) | `TextEditingController`, `StatefulWidget` | o widget |

Fluxos importantes:

- **Login/logout:** os controllers só mudam a sessão; `app.dart` escuta o `SessaoController` e navega para home/login. Um 401 da API chama `SessaoController.sessaoExpirou()`, que limpa o chat e o cache de imagens e mostra "Sua sessão expirou".
- **Filtro da Têmis:** o `AssistenteController` guarda o filtro; o `ProcessosController` escuta essa mudança e recalcula a lista visível.
