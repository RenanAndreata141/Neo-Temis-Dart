class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.oab,
    this.email = '',
  });

  final String id;
  final String nome;
  final String oab;
  final String email;

  String get primeiroNome => nome.split(' ').first;

  String get inicial => nome.isEmpty ? '?' : nome[0].toUpperCase();

  factory Usuario.fromJson(Map<String, dynamic> j) {
    return Usuario(
      id: j['id'] as String? ?? '',
      nome: j['nome'] as String? ?? '',
      oab: j['oab'] as String? ?? '',
      email: j['email'] as String? ?? '',
    );
  }
}
