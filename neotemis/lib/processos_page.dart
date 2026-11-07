import 'package:flutter/material.dart';

import 'api_service.dart';
import 'processo.dart';
import 'processo_dialog.dart';
import 'processo_imagem.dart';
import 'theme.dart';

class ProcessosPage extends StatefulWidget {
  const ProcessosPage({super.key});

  @override
  State<ProcessosPage> createState() => _ProcessosPageState();
}

class _ProcessosPageState extends State<ProcessosPage> {
  List<Processo> _processos = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar({bool mostrarSpinner = true}) async {
    if (mostrarSpinner) setState(() => _carregando = true);
    try {
      final lista = await Api.listar();
      if (!mounted) return;
      setState(() {
        _processos = lista;
        _erro = null;
        _carregando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    }
  }

  Future<void> _abrir({Processo? processo}) async {
    final resultado = await mostrarProcessoDialog(context, processo: processo);
    if (resultado == null || !mounted) return;

    setState(() {
      final i = _processos.indexWhere((p) => p.id == resultado.processo.id);
      if (resultado.excluir) {
        if (i >= 0) _processos.removeAt(i);
      } else if (i >= 0) {
        _processos[i] = resultado.processo;
      } else {
        _processos.insert(0, resultado.processo);
      }
    });
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: NeoTextos.rajdhani(size: 20),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: NeoCores.botao,
                  shape: const RoundedRectangleBorder(),
                ),
                onPressed: _carregar,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (_processos.isEmpty) {
      return Center(
        child: Text(
          'Nenhum processo cadastrado.',
          style: NeoTextos.rajdhani(size: 20),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _carregar(mostrarSpinner: false),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          childAspectRatio: 0.8,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: _processos.length,
        itemBuilder: (context, i) {
          final p = _processos[i];
          return _ProcessoCard(processo: p, onTap: () => _abrir(processo: p));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoCores.fundo,
      appBar: AppBar(
        backgroundColor: NeoCores.botao,
        foregroundColor: NeoCores.fundo,
        title: Text(
          'Processos',
          style: NeoTextos.rajdhani(
            size: 24,
            peso: FontWeight.w700,
            cor: NeoCores.fundo,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregando ? null : _carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: NeoCores.botao,
        foregroundColor: NeoCores.fundo,
        onPressed: () => _abrir(),
        icon: const Icon(Icons.add),
        label: Text(
          'Novo processo',
          style: NeoTextos.rajdhani(
            size: 18,
            peso: FontWeight.w700,
            cor: NeoCores.fundo,
          ),
        ),
      ),
      body: _corpo(),
    );
  }
}

class _ProcessoCard extends StatelessWidget {
  const _ProcessoCard({required this.processo, required this.onTap});

  final Processo processo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ProcessoImagem(processo: processo)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    processo.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: NeoTextos.rajdhani(size: 17, peso: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    processo.status,
                    style: NeoTextos.rajdhani(size: 14, cor: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
