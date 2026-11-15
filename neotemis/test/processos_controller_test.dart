import 'package:flutter_test/flutter_test.dart';
import 'package:neotemis/core/erros/app_exception.dart';
import 'package:neotemis/data/models/processo.dart';
import 'package:neotemis/data/repositories/assistente_repository.dart';
import 'package:neotemis/data/repositories/processo_repository.dart';
import 'package:neotemis/data/services/api_client.dart';
import 'package:neotemis/data/services/gemini_client.dart';
import 'package:neotemis/logic/assistente_controller.dart';
import 'package:neotemis/logic/processos_controller.dart';

/// Repositório falso: devolve uma lista fixa (ou um erro) sem tocar na rede.
class _RepoFalso extends ProcessoRepository {
  _RepoFalso(this.processos, {this.erro}) : super(ApiClient(baseUrl: ''));

  final List<Processo> processos;
  final String? erro;

  @override
  Future<List<Processo>> listar() async {
    final erro = this.erro;
    if (erro != null) throw AppException(erro);
    return List.of(processos);
  }
}

ProcessosController _criar(List<Processo> processos, {String? erro}) {
  final repo = _RepoFalso(processos, erro: erro);
  final assistente = AssistenteController(
    AssistenteRepository(GeminiClient(chave: '', modelos: const []), repo),
  );
  return ProcessosController(repo, assistente);
}

void main() {
  const a = Processo(id: '1', nome: 'Divórcio', cliente: 'Ana', status: StatusProcesso.aguardando);
  const b = Processo(id: '2', nome: 'Inventário', cliente: 'Bruno');

  test('carrega a lista e sai do estado de carregamento', () async {
    final c = _criar([a, b]);
    expect(c.carregando, isTrue);
    await c.carregar();
    expect(c.carregando, isFalse);
    expect(c.erro, isNull);
    expect(c.visiveis, [a, b]);
  });

  test('guarda a mensagem quando a API falha', () async {
    final c = _criar([], erro: 'sem conexão');
    await c.carregar();
    expect(c.erro, 'sem conexão');
  });

  test('busca filtra por nome, número ou cliente', () async {
    final c = _criar([a, b]);
    await c.carregar();
    c.pesquisar('bruno');
    expect(c.visiveis, [b]);
  });

  test('filtro de status só vale depois de aplicar', () async {
    final c = _criar([a, b]);
    await c.carregar();
    c.alternarStatus(StatusProcesso.aguardando);
    expect(c.visiveis, [a, b]);
    c.aplicarFiltroStatus();
    expect(c.visiveis, [a]);
  });

  test('mensagem de lista vazia diferencia "sem processos" de "sem resultado"', () async {
    final vazio = _criar([]);
    await vazio.carregar();
    expect(vazio.mensagemListaVazia(vazio.visiveis), contains('Nenhum processo cadastrado'));

    final cheio = _criar([a]);
    await cheio.carregar();
    cheio.pesquisar('xyz');
    expect(cheio.mensagemListaVazia(cheio.visiveis), contains('busca'));
  });

  test('registrarSalvo insere novos e substitui existentes; registrarExcluido remove', () async {
    final c = _criar([a]);
    await c.carregar();

    c.registrarSalvo(b);
    expect(c.visiveis.first, b);

    const aEditado = Processo(id: '1', nome: 'Divórcio consensual');
    c.registrarSalvo(aEditado);
    expect(c.visiveis.map((p) => p.nome), contains('Divórcio consensual'));

    c.alternarSelecao('1');
    c.registrarExcluido(aEditado);
    expect(c.visiveis, [b]);
    expect(c.selecionados, isEmpty);
  });
}
