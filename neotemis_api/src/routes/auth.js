const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();

const tentativas = new Map();
const JANELA_MS = 15 * 60 * 1000;
const MAX_TENTATIVAS = 20;

function limitar(req, res, next) {
  const agora = Date.now();
  const chave = req.ip;
  const reg = tentativas.get(chave);
  if (!reg || agora - reg.inicio > JANELA_MS) {
    tentativas.set(chave, { inicio: agora, n: 1 });
    return next();
  }
  reg.n += 1;
  if (reg.n > MAX_TENTATIVAS) {
    return res
      .status(429)
      .json({ erro: 'Muitas tentativas. Aguarde alguns minutos e tente de novo' });
  }
  next();
}

const OAB_VALIDA =
  /^(AC|AL|AP|AM|BA|CE|DF|ES|GO|MA|MT|MS|MG|PA|PB|PR|PE|PI|RJ|RN|RS|RO|RR|SC|SP|SE|TO)\d{6}$/;

function normalizarOab(valor) {
  return String(valor || '').replace(/\s+/g, '').toUpperCase();
}

function gerarToken(user) {
  return jwt.sign({ sub: user._id.toString() }, process.env.JWT_SECRET, {
    expiresIn: '7d',
  });
}

function respostaUsuario(user) {
  return { id: user._id.toString(), nome: user.nome, oab: user.oab, email: user.email };
}

router.post('/registro', limitar, async (req, res, next) => {
  try {
    const nome = String(req.body.nome || '').trim();
    const oab = normalizarOab(req.body.oab);
    const email = String(req.body.email || '').trim().toLowerCase();
    const senha = String(req.body.senha || '');

    if (nome.length < 3) return res.status(400).json({ erro: 'Informe seu nome completo' });
    if (!OAB_VALIDA.test(oab)) {
      return res.status(400).json({ erro: 'A OAB deve ter a sigla do estado e 6 números (ex.: SP 123456)' });
    }
    if (email && !/^\S+@\S+\.\S+$/.test(email)) {
      return res.status(400).json({ erro: 'E-mail inválido' });
    }
    if (senha.length < 6) {
      return res.status(400).json({ erro: 'A senha precisa ter pelo menos 6 caracteres' });
    }

    if (await User.exists({ oab })) {
      return res.status(409).json({ erro: 'Já existe um cadastro com esse registro da OAB' });
    }

    const senhaHash = await bcrypt.hash(senha, 10);
    const user = await User.create({ nome, oab, email, senhaHash });

    res.status(201).json({ token: gerarToken(user), usuario: respostaUsuario(user) });
  } catch (e) {
    if (e && e.code === 11000) {
      return res.status(409).json({ erro: 'Já existe um cadastro com esse registro da OAB' });
    }
    next(e);
  }
});

router.post('/login', limitar, async (req, res, next) => {
  try {
    const oab = normalizarOab(req.body.oab);
    const senha = String(req.body.senha || '');

    if (!oab || !senha) {
      return res.status(400).json({ erro: 'Informe a OAB e a senha' });
    }

    const user = await User.findOne({ oab });
    const ok = user && (await bcrypt.compare(senha, user.senhaHash));
    if (!ok) return res.status(401).json({ erro: 'OAB ou senha incorretos' });

    res.json({ token: gerarToken(user), usuario: respostaUsuario(user) });
  } catch (e) {
    next(e);
  }
});

router.get('/eu', auth, async (req, res, next) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) return res.status(401).json({ erro: 'Sessão inválida' });
    res.json(respostaUsuario(user));
  } catch (e) {
    next(e);
  }
});

module.exports = router;
