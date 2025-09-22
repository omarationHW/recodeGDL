-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: EMPRESAS (EXACTO del archivo original)
-- Archivo: 56_SP_RECAUDADORA_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 1/7: sp_get_ejecutores
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de ejecutores vigentes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_ejecutores()
RETURNS TABLE(cveejecutor SMALLINT, ejecutor TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT cveejecutor, TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres) AS ejecutor
    FROM ejecutor
    WHERE vigencia = 'V' AND fecinic >= DATE '2022-01-01';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: EMPRESAS (EXACTO del archivo original)
-- Archivo: 56_SP_RECAUDADORA_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 3/7: sp_check_empresa_diferente
-- Tipo: CRUD
-- Descripción: Verifica si la cuenta existe para otra empresa (ejecutor) distinta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_check_empresa_diferente(
  ecta INTEGER,
  eeje INTEGER
) RETURNS TABLE(existe INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT COUNT(*) FROM ctaempexterna WHERE cvecuenta = ecta AND fecha_trabajo >= DATE '2022-01-01' AND cveejecutor <> eeje;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: EMPRESAS (EXACTO del archivo original)
-- Archivo: 56_SP_RECAUDADORA_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 5/7: sp_empresas_folios
-- Tipo: CRUD
-- Descripción: Obtiene o actualiza folios para empresas externas según parámetros.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_folios(
  prec INTEGER,
  paxo INTEGER,
  pfdsd INTEGER,
  pfhst INTEGER,
  pfecha DATE,
  pejecutor INTEGER,
  pmod INTEGER,
  popc TEXT
) RETURNS SETOF empresas_folios AS $$
-- empresas_folios debe ser un tipo compuesto o tabla con los campos requeridos
DECLARE
BEGIN
  IF popc = 'C' THEN
    RETURN QUERY SELECT * FROM empresas_folios WHERE rec = prec AND axo = paxo AND folio BETWEEN pfdsd AND pfhst AND fecha = pfecha AND ejecutor = pejecutor AND mod = pmod;
  ELSIF popc = 'M' THEN
    -- Aquí se debe realizar la actualización de los folios (practicar)
    UPDATE empresas_folios SET practicado = NOW() WHERE rec = prec AND axo = paxo AND folio BETWEEN pfdsd AND pfhst AND fecha = pfecha AND ejecutor = pejecutor AND mod = pmod;
    RETURN QUERY SELECT * FROM empresas_folios WHERE rec = prec AND axo = paxo AND folio BETWEEN pfdsd AND pfhst AND fecha = pfecha AND ejecutor = pejecutor AND mod = pmod;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: EMPRESAS (EXACTO del archivo original)
-- Archivo: 56_SP_RECAUDADORA_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 7/7: sp_predial_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de predial para un ejecutor y fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_predial_detalle(
  pejec INTEGER,
  pfecha DATE
) RETURNS SETOF predial_detalle AS $$
-- predial_detalle debe ser un tipo compuesto o tabla con los campos requeridos
BEGIN
  RETURN QUERY
    SELECT * FROM predial_detalle WHERE cveejecutor = pejec AND fecha = pfecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

