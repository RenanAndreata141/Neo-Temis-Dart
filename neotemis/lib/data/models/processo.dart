import '../../core/utils/datas.dart';

class Processo {
  const Processo({
    this.id = '',
    required this.nome,
    this.numero = '',
    this.cliente = '',
    this.status = StatusProcesso.emAndamento,
    this.descricao = '',
    this.prazo,
    this.temImagem = false,
    this.atualizadoEm = 0,
  });

  final String id;
  final String nome;
  final String numero;
  final String cliente;
  final String status;
  final String descricao;
  final DateTime? prazo;
  final bool temImagem;
  final int atualizadoEm;

  bool get novo => id.isEmpty;

  String get titulo => numero.isNotEmpty ? numero : nome;

  int? get diasParaPrazo => prazo == null ? null : diasAte(prazo!);

  factory Processo.fromJson(Map<String, dynamic> j) {
    return Processo(
      id: j['id'] as String,
      nome: j['nome'] as String? ?? '',
      numero: j['numero'] as String? ?? '',
      cliente: j['cliente'] as String? ?? '',
      status: j['status'] as String? ?? StatusProcesso.emAndamento,
      descricao: j['descricao'] as String? ?? '',
      prazo: lerData(j['prazo'] as String?),
      temImagem: j['temImagem'] == true,
      atualizadoEm: j['atualizadoEm'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'numero': numero,
        'cliente': cliente,
        'status': status,
        'descricao': descricao,
        'prazo': prazo == null ? null : dataIso(prazo!),
      };
}

abstract final class StatusProcesso {
  static const emAndamento = 'Em andamento';
  static const aguardando = 'Aguardando';
  static const concluido = 'Concluído';
  static const arquivado = 'Arquivado';

  static const opcoes = [emAndamento, aguardando, concluido, arquivado];
}
