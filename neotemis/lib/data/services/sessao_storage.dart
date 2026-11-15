import 'package:shared_preferences/shared_preferences.dart';

class SessaoStorage {
  static const _chaveToken = 'neotemis_token';

  Future<String?> lerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveToken);
  }

  Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveToken, token);
  }

  Future<void> apagarToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveToken);
  }
}

 //n sei se era uma boa separar isso em um arquivo diferente mas foi ta feito