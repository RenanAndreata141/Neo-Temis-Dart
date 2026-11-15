const _ufs = {
  'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA',
  'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
};

String? validarOab(String oab) {
  final m = RegExp(r'^([A-Z]{2}) (\d{6})$').firstMatch(oab.trim());
  if (m == null) return 'A OAB deve ter a sigla do estado e 6 números (ex.: SP 123456)';
  if (!_ufs.contains(m.group(1))) return 'Sigla de estado inválida na OAB';
  return null;
}

bool emailValido(String email) => RegExp(r'^\S+@\S+\.\S+$').hasMatch(email);

//Funcionou n meche!