# NeoTêmis

Aplicativo de gestão de processos jurídicos para advogados. O advogado entra com o registro da OAB, cadastra seus processos (com status, prazo de vencimento e imagem) e pode pedir ajuda à **Têmis**, uma assistente com IA que filtra os processos na tela e avisa quais prazos estão mais próximos.

O projeto tem duas partes:

| Pasta | O que é | Tecnologias |
|---|---|---|
| [`neotemis/`](neotemis/) | App (interface) | Flutter / Dart |
| [`neotemis_api/`](neotemis_api/) | API (servidor) | Node.js, Express, MongoDB, JWT, Google Gemini |

O app não acessa o banco diretamente: tudo passa pela API, que precisa estar rodando para o app funcionar.

---

## Dependências necessárias

Instale antes de começar:

| Programa | Versão | Para quê |
|---|---|---|
| **Git** | qualquer recente | baixar o projeto 
| **Node.js** | 18 ou mais nova (testado na 26) | rodar a API |
| **MongoDB Community Server** | 6 ou mais nova (testado na 8.3) | banco de dados |
| **Flutter SDK** | versão que traga o Dart 3.13 ou mais novo (testado no Flutter 3.47) | rodar o app |
| **Chave do Google Gemini** | gratuita, sem cartão | assistente Têmis (opcional) |


### Dependências extras para rodar o app no computador

O app está configurado para **Linux** e **Windows** (desktop).

- **Windows:** Visual Studio 2022 com a carga de trabalho **"Desenvolvimento para desktop com C++"**.
- **Linux:** compilador e bibliotecas do GTK:
  ```bash
  # Ubuntu / Debian / Mint
  sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev

  # Arch / CachyOS / Manjaro
  sudo pacman -S clang cmake ninja pkgconf gtk3
  ```

Depois de instalar, rode `flutter doctor`. Os itens de **Flutter** e do desktop (Linux toolchain ou Visual Studio) precisam aparecer com.

### Bibliotecas usadas (instaladas automaticamente)

Você não precisa instalar estas bibliotecas à mão; os comandos `npm install` e `flutter pub get` dos passos abaixo baixam tudo.

- **API** (`neotemis_api/package.json`): `express`, `mongoose`, `jsonwebtoken`, `bcryptjs`, `cors`, `dotenv`.
- **App** (`neotemis/pubspec.yaml`): `http`, `shared_preferences`, `image_picker`, `google_fonts`, `flutter_localizations`.

---

## Instalação passo a passo

### 1. Baixar o projeto

```bash
git clone https://github.com/RenanAndreata141/NeoTemis.git
cd NeoTemis
```

### 2. Ligar o MongoDB

Se instalou o MongoDB no computador, confira se o serviço está rodando:

- **Windows:** normalmente ele já inicia sozinho como serviço. Se não, abra "Serviços" e inicie o **MongoDB Server**.
- **Linux:** `sudo systemctl start mongodb`

### 3. Configurar e rodar a API

```bash
cd neotemis_api
npm install
```

Crie o arquivo `.env` a partir do modelo:

```bash
# Linux / macOS
cp .env.example .env

# Windows (PowerShell)
copy .env.example .env
```

Abra o `.env` e preencha:

```env
# Endereço do banco (local). Se usar o Atlas, cole a URL de conexão dele aqui.
MONGODB_URI=mongodb://127.0.0.1:27017/neotemis

# Qualquer texto alatorio e de preferencia longo.
JWT_SECRET=troque-por-um-texto-longo-e-aleatorio

PORT=3000

# Assistente Têmis, Chave gratuita em https://aistudio.google.com/apikey
GEMINI_API_KEY=
GEMINI_MODEL=gemini-3.5-flash,gemini-3.1-flash-lite,gemini-flash-latest
```

Inicie a API:

```bash
npm start        # ou: npm run dev  (reinicia sozinho ao salvar arquivos)
```

Deve aparecer `Neotemis API rodando na porta 3000`. **Deixe esse terminal aberto** enquanto usa o app.

> Rode `npm start` **dentro da pasta `neotemis_api`**. Rodar na pasta `NeoTemis` dá o erro `ENOENT: no such file or directory, open '.../package.json'`.

### 4. Rodar o app

Em **outro terminal**, a partir da pasta `NeoTemis`:

```bash
cd neotemis
flutter pub get
flutter run -d linux      # no Windows: flutter run -d windows
```

Na primeira tela, clique em **Criar conta**, cadastre-se com um registro da OAB e senha, e pronto.

---

## Assistente Têmis (IA)

O botão redondo com a logo, no canto inferior direito, abre o chat. Exemplos do que dá para pedir:

- "Quais processos vencem primeiro?"
- "Mostre os processos vencidos"
- "Filtre os processos aguardando do cliente João"

Quando a assistente filtra, a tela de Processos mostra só os processos escolhidos, com uma faixa **"Assistente: …"** e o botão **LIMPAR**.

Para funcionar, a API precisa da `GEMINI_API_KEY` no `.env`. Sem ela, o resto do app funciona normalmente e o chat avisa que o assistente não está configurado. Para o assistente responder sobre vencimentos, preencha o campo **Prazo** dos processos.

---



## Outras plataformas (opcional)

O app já sabe falar com a API pelo emulador Android (usa `http://10.0.2.2:3000` automaticamente), mas as pastas dessas plataformas não estão no projeto. Para criá-las:

```bash
cd neotemis
flutter create --platforms=android,web .
flutter run -d chrome          # web
flutter run -d emulator-5554   # emulador Android (veja o nome em: flutter devices)
```

Se a API estiver em outro endereço (outro computador na rede, por exemplo), informe na hora de rodar:

```bash
flutter run --dart-define=API_URL=http://192.168.0.10:3000
```

---

## Documentação da API

As rotas estão listadas em [`neotemis_api/README.md`](neotemis_api/README.md).
