import 'package:flutter/widgets.dart';

abstract final class Rotas {
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const home = '/home';
  static const processos = '/processos';
}

void irPara(BuildContext context, String rota) {
  Navigator.pushNamedAndRemoveUntil(context, rota, (_) => false);
}
