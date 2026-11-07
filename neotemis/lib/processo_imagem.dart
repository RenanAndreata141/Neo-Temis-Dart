import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'processo.dart';
import 'theme.dart';

String? detectarTipoImagem(Uint8List b) {
  if (b.length > 3 && b[0] == 0xFF && b[1] == 0xD8) return 'image/jpeg';
  if (b.length > 8 &&
      b[0] == 0x89 &&
      b[1] == 0x50 &&
      b[2] == 0x4E &&
      b[3] == 0x47 &&
      b[4] == 0x0D &&
      b[5] == 0x0A &&
      b[6] == 0x1A &&
      b[7] == 0x0A) {
    return 'image/png';
  }
  if (b.length > 12 &&
      String.fromCharCodes(b.sublist(0, 4)) == 'RIFF' &&
      String.fromCharCodes(b.sublist(8, 12)) == 'WEBP') {
    return 'image/webp';
  }
  return null;
}

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
    _futuro = widget.processo.temImagem ? Api.imagemDe(widget.processo) : null;
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
            errorBuilder: (_, __, ___) => const ImagemPadrao(),
          );
        }
        return ImagemPadrao(carregando: snap.connectionState != ConnectionState.done);
      },
    );
  }
}
