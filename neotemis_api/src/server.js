require('dotenv').config();

const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

if (!process.env.MONGODB_URI || !process.env.JWT_SECRET) {
  console.error('Defina MONGODB_URI e JWT_SECRET no arquivo .env (veja .env.example).');
  process.exit(1);
}

const app = express();

app.use(cors());
app.use(express.json({ limit: '12mb' }));

app.get('/', (req, res) => res.json({ ok: true, servico: 'neotemis-api' }));
app.use('/auth', require('./routes/auth'));
app.use('/processos', require('./routes/processos'));

app.use((err, req, res, next) => {
  if (err.type === 'entity.too.large') {
    return res.status(413).json({ erro: 'A imagem é grande demais.' });
  }
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ erro: 'Requisição inválida.' });
  }
  console.error(err);
  res.status(500).json({ erro: 'Erro interno do servidor.' });
});

const PORT = process.env.PORT || 3000;

mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => {
    app.listen(PORT, () => console.log(`Neotemis API rodando na porta ${PORT}`));
  })
  .catch((e) => {
    console.error('Falha ao conectar no MongoDB:', e.message);
    process.exit(1);
  });
