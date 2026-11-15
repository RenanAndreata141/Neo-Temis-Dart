//TEORICAMENTE FUNCIONANDO NÃO MECHE GALERA

String _dois(int n) => n.toString().padLeft(2, '0');

DateTime? lerData(String? texto) {
  if (texto == null || texto.isEmpty) return null;
  final d = DateTime.tryParse(texto);
  return d == null ? null : DateTime(d.year, d.month, d.day);
}

String dataIso(DateTime d) => '${d.year}-${_dois(d.month)}-${_dois(d.day)}';

String dataBr(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}/${d.year}';

String horaCompleta(DateTime d) => '${_dois(d.hour)}:${_dois(d.minute)}:${_dois(d.second)}';

const _diasDaSemana = [
  'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
  'Sexta-feira', 'Sábado', 'Domingo',
];

const _meses = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

String dataPorExtenso(DateTime d) =>
    '${_diasDaSemana[d.weekday - 1]}, ${d.day} de ${_meses[d.month - 1]}';

int diasAte(DateTime data) {
  final agora = DateTime.now();
  final hoje = DateTime(agora.year, agora.month, agora.day);
  return data.difference(hoje).inDays;
}
