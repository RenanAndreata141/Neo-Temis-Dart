# Neotemis API

API em Node.js + MongoDB do app Neotemis.

## Rodar

1. Instale o Node 18+ e tenha um MongoDB (local ou Atlas).
2. `npm install`
3. Copie `.env.example` para `.env` e preencha `MONGODB_URI` e `JWT_SECRET`.
4. `npm run dev` (ou `npm start`)

A API sobe em `http://localhost:3000`.

## Rotas

| Método | Rota | O que faz | Login? |
|---|---|---|---|
| POST | `/auth/registro` | Cria conta (nome, oab, email, senha) | não |
| POST | `/auth/login` | Entra com OAB + senha | não |
| GET | `/auth/eu` | Dados do usuário logado | sim |
| GET | `/processos` | Lista os processos do usuário | sim |
| POST | `/processos` | Cria processo (com imagem opcional) | sim |
| PUT | `/processos/:id` | Edita processo / troca ou remove imagem | sim |
| DELETE | `/processos/:id` | Exclui processo | sim |
| GET | `/processos/:id/imagem` | Baixa a imagem salva no MongoDB | sim |

A imagem é enviada em base64 (`imagem` + `imagemTipo`), validada (JPG/PNG/WebP, até 5 MB)
e gravada como binário dentro do documento do processo.
