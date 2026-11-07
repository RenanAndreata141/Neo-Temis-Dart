class Processo {
  const Processo({
    this.id = '',
    required this.nome,
    this.numero = '',
    this.cliente = '',
    this.status = 'Em andamento',
    this.descricao = '',
    this.temImagem = false,
    this.atualizadoEm = 0,
  });

  final String id;
  final String nome;
  final String numero;
  final String cliente;
  final String status;
  final String descricao;
  final bool temImagem;

  final int atualizadoEm;

  factory Processo.fromJson(Map<String, dynamic> j) => Processo(
        id: j['id'] as String,
        nome: (j['nome'] ?? '') as String,
        numero: (j['numero'] ?? '') as String,
        cliente: (j['cliente'] ?? '') as String,
        status: (j['status'] ?? statusOpcoes.first) as String,
        descricao: (j['descricao'] ?? '') as String,
        temImagem: j['temImagem'] == true,
        atualizadoEm: (j['atualizadoEm'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'numero': numero,
        'cliente': cliente,
        'status': status,
        'descricao': descricao,
      };

  static const statusOpcoes = [
    'Em andamento',
    'Aguardando',
    'Concluído',
    'Arquivado',
  ];
}
