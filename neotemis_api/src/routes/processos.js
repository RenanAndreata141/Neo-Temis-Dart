const express = require('express');
const mongoose = require('mongoose');
const auth = require('../middleware/auth');
const Processo = require('../models/Processo');

const router = express.Router();
router.use(auth);

const TIPOS_IMAGEM = ['image/jpeg', 'image/png', 'image/webp'];
const MAX_IMAGEM_BYTES = 5 * 1024 * 1024; // 5 MB

function bytesConferemComTipo(buf, tipo) {
  if (tipo === 'image/jpeg') return buf[0] === 0xff && buf[1] === 0xd8;
  if (tipo === 'image/png') {
    return buf.length > 8 && buf.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]));
  }
  if (tipo === 'image/webp') {
    return buf.length > 12 && buf.subarray(0, 4).toString() === 'RIFF' && buf.subarray(8, 12).toString() === 'WEBP';
  }
  return false;
}

function lerCorpo(body, { parcial }) {
  const campos = {};

  if (body.nome !== undefined || !parcial) {
    const nome = String(body.nome || '').trim();
    if (!nome) return { erro: 'Informe o nome do processo.' };
    campos.nome = nome;
  }
  for (const k of ['numero', 'cliente', 'descricao']) {
    if (body[k] !== undefined) campos[k] = String(body[k]).trim();
  }
  if (body.status !== undefined) {
    if (!Processo.STATUS.includes(body.status)) return { erro: 'Status inválido.' };
    campos.status = body.status;
  }
  if (body.prazo !== undefined) {
    // Aceita "AAAA-MM-DD"; vazio ou null apaga o prazo.
    if (body.prazo === null || body.prazo === '') {
      campos.prazo = null;
    } else {
      const texto = String(body.prazo);
      const data = new Date(`${texto}T00:00:00Z`);
      if (!/^\d{4}-\d{2}-\d{2}$/.test(texto) || Number.isNaN(data.getTime())) {
        return { erro: 'Prazo inválido. Use o formato AAAA-MM-DD.' };
      }
      campos.prazo = data;
    }
  }

  let imagem = null;
  if (body.imagem) {
    const tipo = String(body.imagemTipo || '');
    if (!TIPOS_IMAGEM.includes(tipo)) {
      return { erro: 'Formato de imagem não suportado. Use JPG, PNG ou WebP.' };
    }
    const buf = Buffer.from(String(body.imagem), 'base64');
    if (buf.length === 0) return { erro: 'Imagem inválida.' };
    if (buf.length > MAX_IMAGEM_BYTES) return { erro: 'A imagem passa de 5 MB.' };
    if (!bytesConferemComTipo(buf, tipo)) return { erro: 'O arquivo não é uma imagem válida.' };
    imagem = { dados: buf, tipo };
  }

  return { campos, imagem, removerImagem: body.removerImagem === true };
}

function idValido(req, res) {
  if (!mongoose.isValidObjectId(req.params.id)) {
    res.status(404).json({ erro: 'Processo não encontrado.' });
    return false;
  }
  return true;
}

router.get('/', async (req, res, next) => {
  try {
    const lista = await Processo.find({ usuario: req.userId }).sort({ updatedAt: -1 });
    res.json(lista.map((p) => p.paraJson()));
  } catch (e) {
    next(e);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const r = lerCorpo(req.body, { parcial: false });
    if (r.erro) return res.status(400).json({ erro: r.erro });

    const doc = new Processo({ ...r.campos, usuario: req.userId });
    if (r.imagem) doc.imagem = r.imagem;
    await doc.save();

    res.status(201).json(doc.paraJson());
  } catch (e) {
    next(e);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    if (!idValido(req, res)) return;

    const r = lerCorpo(req.body, { parcial: true });
    if (r.erro) return res.status(400).json({ erro: r.erro });

    // O filtro por "usuario" garante que um advogado nunca mexe no processo de outro.
    const doc = await Processo.findOne({ _id: req.params.id, usuario: req.userId });
    if (!doc) return res.status(404).json({ erro: 'Processo não encontrado.' });

    doc.set(r.campos);
    if (r.imagem) {
      doc.imagem = r.imagem;
    } else if (r.removerImagem) {
      doc.imagem = undefined;
    }
    await doc.save();

    res.json(doc.paraJson());
  } catch (e) {
    next(e);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    if (!idValido(req, res)) return;
    const apagado = await Processo.findOneAndDelete({ _id: req.params.id, usuario: req.userId });
    if (!apagado) return res.status(404).json({ erro: 'Processo não encontrado.' });
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

router.get('/:id/imagem', async (req, res, next) => {
  try {
    if (!idValido(req, res)) return;
    const doc = await Processo.findOne({ _id: req.params.id, usuario: req.userId }).select(
      '+imagem.dados imagem.tipo'
    );
    if (!doc || !doc.imagem || !doc.imagem.dados) {
      return res.status(404).json({ erro: 'Sem imagem.' });
    }
    res.set('Content-Type', doc.imagem.tipo);
    res.set('X-Content-Type-Options', 'nosniff');
    res.set('Cache-Control', 'private, max-age=86400');
    res.send(doc.imagem.dados);
  } catch (e) {
    next(e);
  }
});

module.exports = router;
