import 'package:flutter/material.dart';

import 'api_service.dart';
import 'theme.dart';

class Assistente {
  Assistente._();

  static final mensagens = ValueNotifier<List<MensagemChat>>([]);
  static final enviando = ValueNotifier<bool>(false);

  static final filtro = ValueNotifier<FiltroAssistente?>(null);

  static void limpar() {
    mensagens.value = [];
    enviando.value = false;
    filtro.value = null;
  }

  static void _adicionar(MensagemChat m) {
    mensagens.value = [...mensagens.value, m];
  }

  static Future<FiltroAssistente?> enviar(String texto) async {
    final historico = mensagens.value;
    _adicionar(MensagemChat(doUsuario: true, texto: texto));
    enviando.value = true;
    try {
      final r = await Api.assistente(texto, historico);
      _adicionar(MensagemChat(doUsuario: false, texto: r.texto));
      if (r.filtro != null) filtro.value = r.filtro;
      return r.filtro;
    } on ApiException catch (e) {
      _adicionar(MensagemChat(doUsuario: false, texto: e.mensagem, erro: true));
      return null;
    } finally {
      enviando.value = false;
    }
  }
}

void abrirAssistente(BuildContext context, {String? rotaAtual}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar assistente',
    barrierColor: Colors.black12,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (ctx, _, _) => Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 24, bottom: 140, left: 24, top: 24),
        child: _PainelChat(naTelaProcessos: rotaAtual == '/processos'),
      ),
    ),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        alignment: Alignment.bottomRight,
        scale: Tween(begin: 0.92, end: 1.0).animate(anim),
        child: child,
      ),
    ),
  );
}

class _PainelChat extends StatefulWidget {
  const _PainelChat({required this.naTelaProcessos});

  final bool naTelaProcessos;

  @override
  State<_PainelChat> createState() => _PainelChatState();
}

class _PainelChatState extends State<_PainelChat> {
  static const _sugestoes = [
    'Quais processos vencem primeiro?',
    'Mostre os processos vencidos',
    'Filtre os processos aguardando',
  ];

  final _texto = TextEditingController();
  final _rolagem = ScrollController();

  @override
  void initState() {
    super.initState();
    Assistente.mensagens.addListener(_rolarParaFim);
    WidgetsBinding.instance.addPostFrameCallback((_) => _rolarParaFim());
  }

  @override
  void dispose() {
    Assistente.mensagens.removeListener(_rolarParaFim);
    _texto.dispose();
    _rolagem.dispose();
    super.dispose();
  }

  void _rolarParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_rolagem.hasClients) {
        _rolagem.animateTo(
          _rolagem.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviar([String? sugestao]) async {
    final texto = (sugestao ?? _texto.text).trim();
    if (texto.isEmpty || Assistente.enviando.value) return;
    _texto.clear();

    final filtro = await Assistente.enviar(texto);

    // Se a IA filtrou e o usuário não está na tela de processos, leva até lá.
    if (filtro != null && !widget.naTelaProcessos && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/processos', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.sizeOf(context).height;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 400,
        height: (altura - 180).clamp(320.0, 560.0),
        decoration: neoCardBranco,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _cabecalho(),
            Expanded(
              child: ValueListenableBuilder<List<MensagemChat>>(
                valueListenable: Assistente.mensagens,
                builder: (_, mensagens, _) =>
                    mensagens.isEmpty ? _boasVindas() : _lista(mensagens),
              ),
            ),
            _campoTexto(),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
      decoration: const BoxDecoration(gradient: neoGradiente),
      child: Row(
        children: [
          Image.asset('assets/images/Temis Home Page barra superior.png', height: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'ASSISTENTE TÊMIS',
              style: NeoTextos.rajdhani(size: 20, peso: FontWeight.w700, cor: Colors.white),
            ),
          ),
          IconButton(
            tooltip: 'Nova conversa',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => Assistente.mensagens.value = [],
          ),
          IconButton(
            tooltip: 'Fechar',
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _boasVindas() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Olá! Posso filtrar seus processos na tela e avisar quais prazos estão mais próximos.',
          style: NeoTextos.rajdhani(size: 18, peso: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        for (final s in _sugestoes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ActionChip(
                label: Text(s, style: NeoTextos.rajdhani(size: 15, peso: FontWeight.w600)),
                onPressed: () => _enviar(s),
              ),
            ),
          ),
      ],
    );
  }

  Widget _lista(List<MensagemChat> mensagens) {
    return ValueListenableBuilder<bool>(
      valueListenable: Assistente.enviando,
      builder: (_, enviando, _) => ListView.builder(
        controller: _rolagem,
        padding: const EdgeInsets.all(14),
        itemCount: mensagens.length + (enviando ? 1 : 0),
        itemBuilder: (_, i) =>
            i < mensagens.length ? _Balao(mensagens[i]) : const _Digitando(),
      ),
    );
  }

  Widget _campoTexto() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: NeoCores.card)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _texto,
              autofocus: true,
              maxLength: 1000,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _enviar(),
              style: NeoTextos.rajdhani(size: 17, peso: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Pergunte sobre seus processos...',
                hintStyle: NeoTextos.rajdhani(size: 17, cor: Colors.black45),
                border: InputBorder.none,
                counterText: '',
                isDense: true,
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: Assistente.enviando,
            builder: (_, enviando, _) => IconButton(
              tooltip: 'Enviar',
              onPressed: enviando ? null : _enviar,
              icon: const Icon(Icons.send),
              color: NeoCores.botao,
            ),
          ),
        ],
      ),
    );
  }
}

class _Balao extends StatelessWidget {
  const _Balao(this.m);

  final MensagemChat m;

  @override
  Widget build(BuildContext context) {
    final Color fundo;
    final Color cor;
    if (m.doUsuario) {
      fundo = NeoCores.botao;
      cor = Colors.white;
    } else if (m.erro) {
      fundo = Colors.red.shade50;
      cor = Colors.red.shade900;
    } else {
      fundo = const Color(0xFFEFEFEF);
      cor = Colors.black;
    }

    return Align(
      alignment: m.doUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(m.doUsuario ? 14 : 2),
            bottomRight: Radius.circular(m.doUsuario ? 2 : 14),
          ),
        ),
        child: SelectableText(
          m.texto,
          style: NeoTextos.rajdhani(size: 16, peso: FontWeight.w600, cor: cor),
        ),
      ),
    );
  }
}

class _Digitando extends StatelessWidget {
  const _Digitando();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
