-- ============================================================
-- LicitaRadar V3 — Schema do banco de dados (Supabase/Postgres)
-- Execute no SQL Editor do Supabase: Database → SQL Editor → New Query
-- ============================================================

-- Tabela: buscas monitoradas por e-mail
CREATE TABLE IF NOT EXISTS monitored_searches (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email        TEXT NOT NULL,
  label        TEXT NOT NULL DEFAULT 'Busca sem nome',
  filters      JSONB NOT NULL,
  last_checked TIMESTAMPTZ,
  last_count   INTEGER DEFAULT 0,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para buscar por e-mail rapidamente
CREATE INDEX IF NOT EXISTS idx_monitored_email ON monitored_searches(email);

-- Tabela: snapshots das licitações (para detectar novidades e mudanças de status)
CREATE TABLE IF NOT EXISTS licitacao_snapshots (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_id       UUID NOT NULL REFERENCES monitored_searches(id) ON DELETE CASCADE,
  pncp_id         TEXT NOT NULL,
  situacao_id     INTEGER,
  objeto          TEXT,
  valor_estimado  NUMERIC,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(search_id, pncp_id)
);

-- Índice para busca por search_id
CREATE INDEX IF NOT EXISTS idx_snapshots_search ON licitacao_snapshots(search_id);

-- ============================================================
-- Permissões (Row Level Security)
-- IMPORTANTE: Habilite RLS e configure as policies abaixo
-- para que apenas requisições autenticadas possam ler/escrever.
-- Para uso inicial/testes, pode manter desabilitado.
-- ============================================================

-- ALTER TABLE monitored_searches ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE licitacao_snapshots ENABLE ROW LEVEL SECURITY;

-- Policy: permite tudo via service_role (usado pelo backend)
-- CREATE POLICY "service_role full access" ON monitored_searches
--   USING (true) WITH CHECK (true);
-- CREATE POLICY "service_role full access" ON licitacao_snapshots
--   USING (true) WITH CHECK (true);
