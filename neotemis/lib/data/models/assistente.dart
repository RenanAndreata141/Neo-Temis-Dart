class MensagemChat {
  const MensagemChat({required this.doUsuario, required this.texto, this.erro = false});

  final bool doUsuario;
  final String texto;
  final bool erro;
}

class FiltroAssistente {
  const FiltroAssistente({required this.ids, required this.descricao});

  final List<String> ids;
  final String descricao;
}

class RespostaAssistente {
  const RespostaAssistente({required this.texto, this.filtro});

  final String texto;
  final FiltroAssistente? filtro;
}
