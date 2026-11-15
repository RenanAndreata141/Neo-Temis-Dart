import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/dependencias.dart';
import '../../../../core/utils/datas.dart';
import '../../../../data/models/processo.dart';
import '../../../../logic/processo_form_controller.dart';
import '../../../theme/tema.dart';
import '../../../widgets/avisos.dart';
import '../../../widgets/neo_botao.dart';
import '../../../widgets/texto_erro.dart';
import 'processo_imagem.dart';

class ResultadoProcesso {
  const ResultadoProcesso.salvo(this.processo) : excluido = false;
  const ResultadoProcesso.excluido(this.processo) : excluido = true;

  final Processo processo;
  final bool excluido;
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
  late final ProcessoFormController _controller;

  final _form = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _numero;
  late final TextEditingController _cliente;
  late final TextEditingController _descricao;

  @override
  void initState() {
    super.initState();
    final p = widget.processo;
    _controller = ProcessoFormController(context.deps.processoRepository, original: p);
    _nome = TextEditingController(text: p?.nome ?? '');
    _numero = TextEditingController(text: p?.numero ?? '');
    _cliente = TextEditingController(text: p?.cliente ?? '');
    _descricao = TextEditingController(text: p?.descricao ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
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
      _controller.receberImagem(bytes);
    } catch (_) {
      if (mounted) _controller.falhaAoAbrirImagem();
    }
  }

  void _cancelarEdicao() {
    final p = widget.processo;
    if (p == null || !_controller.cancelarEdicao()) {
      Navigator.pop(context);
      return;
    }
    _nome.text = p.nome;
    _numero.text = p.numero;
    _cliente.text = p.cliente;
    _descricao.text = p.descricao;
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    final salvo = await _controller.salvar(
      nome: _nome.text,
      numero: _numero.text,
      cliente: _cliente.text,
      descricao: _descricao.text,
    );
    if (salvo != null && mounted) Navigator.pop(context, ResultadoProcesso.salvo(salvo));
  }

  Future<void> _excluir() async {
    final confirmou = await confirmar(
      context,
      titulo: 'Excluir processo?',
      mensagem: 'essa ação não pode ser desfeita e tera consequencias.....brincadeira :)',
      textoConfirmar: 'Excluir',
    );
    if (!confirmou || !mounted) return;

    final p = widget.processo;
    if (p != null && await _controller.excluir() && mounted) {
      Navigator.pop(context, ResultadoProcesso.excluido(p));
    }
  }

  Future<void> _escolherPrazo() async {
    final hoje = DateTime.now();
    final escolhido = await showDatePicker(
      context: context,
      initialDate: _controller.prazo ?? hoje,
      firstDate: DateTime(2000),
      lastDate: DateTime(hoje.year + 20),
      helpText: 'Prazo (vencimento)',
    );
    if (escolhido != null) _controller.definirPrazo(escolhido);
  }

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.sizeOf(context).height;

    return Dialog(
      backgroundColor: NeoCores.fundo,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720, maxHeight: altura * 0.85),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final erro = _controller.erro;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _cabecalho(),
                  const SizedBox(height: 12),
                  Flexible(child: SingleChildScrollView(child: _formulario())),
                  if (erro != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextoErro(
                          erro,
                          alinhamento: TextAlign.left,
                          espacoAcima: 4,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _acoes(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _controller.titulo,
            style: NeoTextos.rajdhani(size: 28, peso: FontWeight.w700),
          ),
        ),
        IconButton(
          onPressed: _controller.salvando ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _formulario() {
    final c = _controller;
    return Form(
      key: _form,
      child: Column(
        children: [
          _previaImagem(),
          if (c.editando)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: c.salvando ? null : _escolherImagem,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(c.temImagemAtual ? 'Trocar imagem' : 'Escolher imagem'),
                  ),
                  const SizedBox(width: 8),
                  if (c.temImagemAtual)
                    TextButton(
                      onPressed: c.salvando ? null : c.removerImagemAtual,
                      child: const Text('Remover imagem'),
                    ),
                ],
              ),
            ),
          _campo(
            'Nome do processo',
            _nome,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
          ),
          _campo('Número do processo', _numero),
          _campo('Cliente', _cliente),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<String>(
              key: ValueKey(c.status),
              initialValue: c.status,
              decoration: _decoracao('Status'),
              style: NeoTextos.rajdhani(size: 18),
              items: [
                for (final s in StatusProcesso.opcoes)
                  DropdownMenuItem(value: s, child: Text(s)),
              ],
              onChanged: c.editando ? (v) => c.definirStatus(v!) : null,
            ),
          ),
          _campoPrazo(),
          _campo('Descrição / andamento', _descricao, maxLines: 5),
        ],
      ),
    );
  }

  Widget _acoes() {
    final c = _controller;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: c.editando
          ? [
              TextButton(
                onPressed: c.salvando ? null : _cancelarEdicao,
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              _botaoPrincipal('SALVAR', _salvar, carregando: c.salvando),
            ]
          : [
              TextButton(
                onPressed: c.salvando ? null : _excluir,
                child: const Text('Excluir'),
              ),
              const SizedBox(width: 8),
              _botaoPrincipal('EDITAR', c.salvando ? null : c.iniciarEdicao),
            ],
    );
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
        readOnly: !_controller.editando,
        maxLines: maxLines,
        validator: validator,
        style: NeoTextos.platypi(size: 18),
        decoration: _decoracao(label),
      ),
    );
  }

  Widget _campoPrazo() {
    final c = _controller;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: c.editando ? _escolherPrazo : null,
        child: InputDecorator(
          decoration: _decoracao('Prazo (vencimento)').copyWith(
            suffixIcon: c.editando && c.prazo != null
                ? IconButton(
                    tooltip: 'Remover prazo',
                    icon: const Icon(Icons.clear),
                    onPressed: () => c.definirPrazo(null),
                  )
                : const Icon(Icons.event_outlined),
          ),
          child: Text(
            c.prazo == null ? 'Sem prazo' : dataBr(c.prazo!),
            style: NeoTextos.platypi(size: 18),
          ),
        ),
      ),
    );
  }

  Widget _previaImagem() {
    final c = _controller;
    final p = widget.processo;
    final Widget imagem;
    if (c.novaImagem != null) {
      imagem = Image.memory(
        c.novaImagem!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (!c.removerImagem && p != null && p.temImagem) {
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

  Widget _botaoPrincipal(String texto, VoidCallback? onTap, {bool carregando = false}) {
    return NeoBotao(
      texto: texto,
      onTap: onTap,
      carregando: carregando,
      largura: 120,
      altura: 40,
      tamanhoFonte: 18,
    );
  }
}
