class AppException implements Exception {
  const AppException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class NaoAutorizadoException extends AppException {
  const NaoAutorizadoException(super.mensagem);
}
