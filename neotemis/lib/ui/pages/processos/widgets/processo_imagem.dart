import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../../../app/dependencias.dart';
import '../../../../data/models/processo.dart';
import '../../../theme/tema.dart';

class ImagemPadrao extends StatelessWidget {
  const ImagemPadrao({super.key, this.carregando = false});

  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NeoCores.card,
      alignment: Alignment.center,
      child: carregando
          ? const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : const Icon(Icons.gavel, size: 56, color: NeoCores.botao),
    );
  }
}

class ProcessoImagem extends StatefulWidget {
  const ProcessoImagem({super.key, required this.processo});

  final Processo processo;

  @override
  State<ProcessoImagem> createState() => _ProcessoImagemState();
}

class _ProcessoImagemState extends State<ProcessoImagem> {
  Future<Uint8List?>? _futuro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void didUpdateWidget(ProcessoImagem antigo) {
    super.didUpdateWidget(antigo);
    final a = antigo.processo;
    final b = widget.processo;
    if (a.id != b.id || a.atualizadoEm != b.atualizadoEm || a.temImagem != b.temImagem) {
      _carregar();
    }
  }

  void _carregar() {
    _futuro = widget.processo.temImagem
        ? context.deps.processoRepository.imagemDe(widget.processo)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_futuro == null) return const ImagemPadrao();

    return FutureBuilder<Uint8List?>(
      future: _futuro,
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes != null) {
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            cacheWidth: 600,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const ImagemPadrao(),
          );
        }
        return ImagemPadrao(carregando: snap.connectionState != ConnectionState.done);
      },
    );
  }
}
