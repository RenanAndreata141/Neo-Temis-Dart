import 'package:flutter_test/flutter_test.dart';
import 'package:neotemis/core/utils/datas.dart';
import 'package:neotemis/core/validacao/validadores.dart';
import 'package:neotemis/data/models/processo.dart';

void main() {
  group('validarOab', () {
    test('aceita sigla válida + 6 dígitos', () {
      expect(validarOab('SP 123456'), isNull);
    });

    test('recusa formato errado', () {
      expect(validarOab('SP123456'), isNotNull);
      expect(validarOab('SP 12345'), isNotNull);
      expect(validarOab(''), isNotNull);
    });

    test('recusa estado inexistente', () {
      expect(validarOab('XX 123456'), 'Sigla de estado inválida na OAB.');
    });
  });

  group('datas', () {
    test('formata e lê datas', () {
      final d = DateTime(2026, 3, 7);
      expect(dataIso(d), '2026-03-07');
      expect(dataBr(d), '07/03/2026');
      expect(lerData('2026-03-07'), d);
      expect(lerData(null), isNull);
      expect(lerData(''), isNull);
    });
  });

  group('Processo', () {
    test('fromJson preenche padrões e toJson ida e volta', () {
      final p = Processo.fromJson({'id': 'abc', 'nome': 'Ação', 'prazo': '2026-01-02'});
      expect(p.status, StatusProcesso.emAndamento);
      expect(p.numero, '');
      expect(p.prazo, DateTime(2026, 1, 2));
      expect(p.toJson()['prazo'], '2026-01-02');
    });

    test('titulo usa o número, ou o nome se não houver', () {
      expect(const Processo(nome: 'Ação', numero: '123').titulo, '123');
      expect(const Processo(nome: 'Ação').titulo, 'Ação');
    });
  });
}
