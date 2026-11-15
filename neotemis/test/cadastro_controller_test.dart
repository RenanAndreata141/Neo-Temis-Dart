import 'package:flutter_test/flutter_test.dart';
import 'package:neotemis/data/repositories/auth_repository.dart';
import 'package:neotemis/data/services/api_client.dart';
import 'package:neotemis/data/services/sessao_storage.dart';
import 'package:neotemis/logic/cadastro_controller.dart';
import 'package:neotemis/logic/sessao_controller.dart';

// Só testa a validação local: nenhum caso abaixo chega a chamar a API.
void main() {
  late CadastroController c;

  setUp(() {
    final sessao = SessaoController(AuthRepository(ApiClient(baseUrl: ''), SessaoStorage()));
    c = CadastroController(sessao);
  });

  Future<String?> cadastrar({
    String nome = 'Maria Silva',
    String oab = 'SP 123456',
    String email = '',
    String senha = '123456',
    String? confirmacao,
  }) async {
    await c.cadastrar(
      nome: nome,
      oab: oab,
      email: email,
      senha: senha,
      confirmacao: confirmacao ?? senha,
    );
    return c.erro;
  }

  test('nome curto', () async {
    expect(await cadastrar(nome: 'Al'), 'informe seu nome completo');
  });

  test('OAB inválida', () async {
    expect(await cadastrar(oab: 'ZZ 123456'), isNotNull);
  });

  test('e-mail inválido', () async {
    expect(await cadastrar(email: 'nao-e-email'), 'E-mail inválido.');
  });

  test('senha curta', () async {
    expect(await cadastrar(senha: '123'), contains('6 caracteres'));
  });

  test('senhas diferentes', () async {
    expect(await cadastrar(confirmacao: '654321'), 'as senhas não conferem');
    expect(c.carregando, isFalse);
  });
}
