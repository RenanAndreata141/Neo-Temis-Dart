class Processo {
  const Processo({
    this.id = '',
    required this.nome,
    this.numero = '',
    this.cliente = '',
    this.status = 'Em andamento',
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

  static Processo fromJson(Map<String, dynamic> j) {
    return Processo(
      id: j['id'],
      nome: j['nome'] ?? '',
      numero: j['numero'] ?? '',
      cliente: j['cliente'] ?? '',
      status: j['status'] ?? 'Em andamento',
      descricao: j['descricao'] ?? '',
      prazo: lerData(j['prazo']),
      temImagem: j['temImagem'] == true,
      atualizadoEm: j['atualizadoEm'] ?? 0,
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

  int? get diasParaPrazo {
    if (prazo == null) return null;
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    return prazo!.difference(hoje).inDays;
  }

  static const statusOpcoes = [
    'Em andamento',
    'Aguardando',
    'Concluído',
    'Arquivado',
  ];
}

String _dois(int n) => n.toString().padLeft(2, '0');

DateTime? lerData(String? texto) {
  if (texto == null || texto.isEmpty) return null;
  final d = DateTime.tryParse(texto);
  return d == null ? null : DateTime(d.year, d.month, d.day);
}

String dataIso(DateTime d) => '${d.year}-${_dois(d.month)}-${_dois(d.day)}';

String dataBr(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}/${d.year}';
