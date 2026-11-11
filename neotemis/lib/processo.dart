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

  /// Data de vencimento (só o dia, sem hora). Nulo = sem prazo.
  final DateTime? prazo;
  final bool temImagem;

  final int atualizadoEm;

  factory Processo.fromJson(Map<String, dynamic> j) => Processo(
        id: j['id'] as String,
        nome: (j['nome'] ?? '') as String,
        numero: (j['numero'] ?? '') as String,
        cliente: (j['cliente'] ?? '') as String,
        status: (j['status'] ?? statusOpcoes.first) as String,
        descricao: (j['descricao'] ?? '') as String,
        prazo: lerData(j['prazo'] as String?),
        temImagem: j['temImagem'] == true,
        atualizadoEm: (j['atualizadoEm'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'numero': numero,
        'cliente': cliente,
        'status': status,
        'descricao': descricao,
        'prazo': prazo == null ? null : dataIso(prazo!),
      };

  /// Dias até o prazo (negativo = vencido). Nulo se não houver prazo.
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

/// "2026-11-30" -> DateTime(2026, 11, 30). Retorna null se vazio/inválido.
DateTime? lerData(String? texto) {
  if (texto == null || texto.isEmpty) return null;
  final d = DateTime.tryParse(texto);
  return d == null ? null : DateTime(d.year, d.month, d.day);
}

/// DateTime -> "2026-11-30" (formato da API).
String dataIso(DateTime d) => '${d.year}-${_dois(d.month)}-${_dois(d.day)}';

/// DateTime -> "30/11/2026" (formato da tela).
String dataBr(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}/${d.year}';
