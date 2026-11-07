import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';
import 'processo.dart';
import 'processo_imagem.dart';
import 'theme.dart';

class ResultadoProcesso {
  const ResultadoProcesso.salvo(this.processo) : excluir = false;
  const ResultadoProcesso.excluido(this.processo) : excluir = true;

  final Processo processo;
  final bool excluir;
}

Future<ResultadoProcesso?> mostrarProcessoDialog(
  BuildContext context, {
  Processo? processo,
}) {
  return showDialog<ResultadoProcesso>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ProcessoDialog(processo: processo),
  );
}

class _ProcessoDialog extends StatefulWidget {
  const _ProcessoDialog({this.processo});

  final Processo? processo;

  @override
  State<_ProcessoDialog> createState() => _ProcessoDialogState();
}

class _ProcessoDialogState extends State<_ProcessoDialog> {
  static const _limiteImagem = 5 * 1024 * 1024;

  final _form = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _numero;
  late final TextEditingController _cliente;
  late final TextEditingController _descricao;
  late String _status;
  late bool _editando;

  Uint8List? _novaImagem;
  String? _novoTipo;
  bool _removerImagem = false;

  bool _salvando = false;
  String? _erro;

  bool get _novo => widget.processo == null;

  bool get _temImagemAtual =>
      _novaImagem != null ||
      (!_removerImagem && (widget.processo?.temImagem ?? false));

  @override
  void initState() {
    super.initState();
    final p = widget.processo;
    _nome = TextEditingController(text: p?.nome ?? '');
    _numero = TextEditingController(text: p?.numero ?? '');
    _cliente = TextEditingController(text: p?.cliente ?? '');
    _descricao = TextEditingController(text: p?.descricao ?? '');
    _status = p?.status ?? Processo.statusOpcoes.first;
    _editando = _novo;
  }

  @override
  void dispose() {
    _nome.dispose();
    _numero.dispose();
    _cliente.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _escolherImagem() async {
    try {
      final arquivo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (arquivo == null) return;
      final bytes = await arquivo.readAsBytes();
      if (!mounted) return;

      final tipo = detectarTipoImagem(bytes);
      if (tipo == null) {
        setState(() => _erro = 'Use uma imagem JPG, PNG ou WebP.');
        return;
      }
      if (bytes.length > _limiteImagem) {
        setState(() => _erro = 'A imagem passa de 5 MB.');
        return;
      }
      setState(() {
        _novaImagem = bytes;
        _novoTipo = tipo;
        _removerImagem = false;
        _erro = null;
      });
    } catch (_) {
      if (mounted) setState(() => _erro = 'Não foi possível abrir a imagem.');
    }
  }

  void _removerImagemAtual() {
    setState(() {
      _novaImagem = null;
      _novoTipo = null;
      _removerImagem = widget.processo?.temImagem ?? false;
    });
  }

  void _cancelarEdicao() {
    if (_novo) {
      Navigator.pop(context);
      return;
    }
    final p = widget.processo!;
    setState(() {
      _nome.text = p.nome;
      _numero.text = p.numero;
      _cliente.text = p.cliente;
      _descricao.text = p.descricao;
      _status = p.status;
      _novaImagem = null;
      _novoTipo = null;
      _removerImagem = false;
      _erro = null;
      _editando = false;
    });
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      final rascunho = Processo(
        id: widget.processo?.id ?? '',
        nome: _nome.text.trim(),
        numero: _numero.text.trim(),
        cliente: _cliente.text.trim(),
        status: _status,
        descricao: _descricao.text.trim(),
      );
      final salvo = await Api.salvar(
        rascunho,
        imagem: _novaImagem,
        imagemTipo: _novoTipo,
        removerImagem: _removerImagem,
      );
      if (!mounted) return;
      Navigator.pop(context, ResultadoProcesso.salvo(salvo));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _salvando = false;
      });
    }
  }

  Future<void> _excluir() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir processo?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await Api.excluir(widget.processo!.id);
      if (!mounted) return;
      Navigator.pop(context, ResultadoProcesso.excluido(widget.processo!));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _salvando = false;
      });
    }
  }

  InputDecoration _decoracao(String label) => InputDecoration(
        labelText: label,
        labelStyle: NeoTextos.rajdhani(size: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      );

  Widget _campo(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: !_editando,
        maxLines: maxLines,
        validator: validator,
        style: NeoTextos.platypi(size: 18),
        decoration: _decoracao(label),
      ),
    );
  }

  Widget _previaImagem() {
    final p = widget.processo;
    final Widget imagem;
    if (_novaImagem != null) {
      imagem = Image.memory(
        _novaImagem!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (!_removerImagem && p != null && p.temImagem) {
      imagem = ProcessoImagem(processo: p);
    } else {
      imagem = const ImagemPadrao();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: ClipRRect(borderRadius: BorderRadius.circular(12), child: imagem),
      ),
    );
  }

  Widget _botaoPrincipal(String texto, VoidCallback? onPressed, {bool carregando = false}) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: NeoCores.botao,
        shape: const RoundedRectangleBorder(),
      ),
      onPressed: onPressed,
      child: carregando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: NeoCores.fundo),
            )
          : Text(
              texto,
              style: NeoTextos.rajdhani(
                size: 18,
                peso: FontWeight.w700,
                cor: NeoCores.fundo,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: NeoCores.fundo,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720, maxHeight: altura * 0.85),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _novo
                          ? 'Novo processo'
                          : (_editando ? 'Editar processo' : 'Detalhes do processo'),
                      style: NeoTextos.rajdhani(size: 28, peso: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: _salvando ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _form,
                    child: Column(
                      children: [
                        _previaImagem(),
                        if (_editando)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _salvando ? null : _escolherImagem,
                                  icon: const Icon(Icons.image_outlined),
                                  label: Text(_temImagemAtual
                                      ? 'Trocar imagem'
                                      : 'Escolher imagem'),
                                ),
                                const SizedBox(width: 8),
                                if (_temImagemAtual)
                                  TextButton(
                                    onPressed: _salvando ? null : _removerImagemAtual,
                                    child: const Text('Remover imagem'),
                                  ),
                              ],
                            ),
                          ),
                        _campo(
                          'Nome do processo',
                          _nome,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Informe o nome'
                              : null,
                        ),
                        _campo('Número do processo', _numero),
                        _campo('Cliente', _cliente),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DropdownButtonFormField<String>(
                            initialValue: _status,
                            decoration: _decoracao('Status'),
                            style: NeoTextos.rajdhani(size: 18),
                            items: [
                              for (final s in Processo.statusOpcoes)
                                DropdownMenuItem(value: s, child: Text(s)),
                            ],
                            onChanged: _editando
                                ? (v) => setState(() => _status = v!)
                                : null,
                          ),
                        ),
                        _campo('Descrição / andamento', _descricao, maxLines: 5),
                      ],
                    ),
                  ),
                ),
              ),
              if (_erro != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _erro!,
                      style: NeoTextos.rajdhani(
                        size: 16,
                        peso: FontWeight.w600,
                        cor: Colors.red.shade800,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _editando
                    ? [
                        TextButton(
                          onPressed: _salvando ? null : _cancelarEdicao,
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 8),
                        _botaoPrincipal(
                          'SALVAR',
                          _salvando ? null : _salvar,
                          carregando: _salvando,
                        ),
                      ]
                    : [
                        TextButton(
                          onPressed: _salvando ? null : _excluir,
                          child: const Text('Excluir'),
                        ),
                        const SizedBox(width: 8),
                        _botaoPrincipal(
                          'EDITAR',
                          _salvando ? null : () => setState(() => _editando = true),
                        ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
