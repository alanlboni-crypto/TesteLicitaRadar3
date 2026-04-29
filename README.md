# ⚡ LicitaRadar V3

Busca de licitações PNCP com **export Excel**, **busca server-side** e **alertas por e-mail**.

---

## Novidades da V3

| Funcionalidade | Como funciona |
|---|---|
| **Busca server-side** | Quando você digita uma palavra-chave, o backend percorre até 5 páginas do PNCP e filtra nos ~500 resultados — não apenas nos 20 da página atual |
| **Export Excel** | Botão "Exportar Excel" aparece após a busca — baixa `.xlsx` com todos os campos relevantes |
| **Monitoramento** | Salva uma busca com seu e-mail → todo dia às 08h o sistema verifica o PNCP e envia e-mail se houver novas licitações ou mudanças de status |

---

## Estrutura do projeto

```
licita-radar/
├── api/
│   ├── pncp.js              ← Proxy CORS (V2)
│   ├── search.js            ← Busca server-side multi-página (NOVO)
│   └── monitor/
│       ├── save.js          ← Salvar busca monitorada (NOVO)
│       ├── list.js          ← Listar buscas por e-mail (NOVO)
│       ├── delete.js        ← Remover busca (NOVO)
│       └── cron.js          ← Job diário de alertas (NOVO)
├── src/
│   ├── App.jsx              ← App principal
│   ├── MonitorPanel.jsx     ← Painel de monitoramentos
│   └── main.jsx
├── index.html
├── package.json
├── vite.config.js
├── vercel.json              ← Inclui configuração do Cron
├── .env.example             ← Variáveis de ambiente necessárias
└── supabase-schema.sql      ← Execute no Supabase para criar as tabelas
```

---

## Deploy — Passo a passo

### 1. Supabase (banco de dados gratuito)

1. Acesse [supabase.com](https://supabase.com) → **New project**
2. Aguarde a criação (2–3 minutos)
3. Vá em **Database → SQL Editor → New Query**
4. Cole o conteúdo do arquivo `supabase-schema.sql` e clique em **Run**
5. Vá em **Settings → API** e copie:
   - **Project URL** → `SUPABASE_URL`
   - **anon / public key** → `SUPABASE_ANON_KEY`

### 2. Resend (e-mail gratuito — 100/dia)

1. Acesse [resend.com](https://resend.com) → crie uma conta
2. Vá em **API Keys → Create API Key** → copie → `RESEND_API_KEY`
3. Para testes: use `FROM_EMAIL=LicitaRadar <onboarding@resend.dev>` (só envia para seu próprio e-mail do Resend)
4. Para produção: adicione e verifique seu domínio em **Domains**

### 3. GitHub + Vercel

1. Suba os arquivos para um repositório no GitHub (igual ao processo da V2)
2. No Vercel, importe o repositório
3. Antes de clicar em **Deploy**, vá em **Environment Variables** e adicione:

| Variável | Valor |
|---|---|
| `SUPABASE_URL` | URL do seu projeto Supabase |
| `SUPABASE_ANON_KEY` | Chave anon do Supabase |
| `RESEND_API_KEY` | Chave da API do Resend |
| `FROM_EMAIL` | `LicitaRadar <onboarding@resend.dev>` |
| `APP_URL` | URL do seu app no Vercel (ex: `https://licita-radar.vercel.app`) |
| `CRON_SECRET` | Qualquer string longa e aleatória (ex: `minha-chave-secreta-123`) |

4. Clique em **Deploy**

---

## Como funciona o Cron

O Vercel executa `GET /api/monitor/cron` todo dia às **08h (UTC)**.
O header `Authorization: Bearer {CRON_SECRET}` é adicionado automaticamente pelo Vercel.

Para testar manualmente, chame a URL com o header:
```bash
curl -H "Authorization: Bearer sua-chave-secreta" https://seu-app.vercel.app/api/monitor/cron
```

---

## Endpoints da API

| Endpoint | Método | Descrição |
|---|---|---|
| `/api/pncp` | GET | Proxy CORS → PNCP |
| `/api/search` | GET | Busca multi-página com keyword |
| `/api/monitor/save` | POST | Salvar busca monitorada |
| `/api/monitor/list` | GET | Listar buscas por e-mail |
| `/api/monitor/delete` | DELETE | Remover busca |
| `/api/monitor/cron` | GET | Job diário (chamado pelo Vercel Cron) |
