-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSESCRIT400 (EXACTO del archivo original)
-- Archivo: 83_SP_RECAUDADORA_CONSESCRIT400_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_consescrit400_search_by_folio_fecha
-- Tipo: Report
-- Descripción: Busca registros en escrituras_400 por folio y fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consescrit400_search_by_folio_fecha(p_folio integer, p_fecha integer)
RETURNS TABLE (
    escritura integer,
    notario smallint,
    mpio smallint,
    folio integer,
    axofolio smallint,
    cuenta integer,
    recaud smallint,
    nocomp integer,
    axocomp smallint,
    ccta integer,
    crec smallint,
    clave varchar(13),
    capturista varchar(8),
    enviado varchar(12),
    regresado varchar(12),
    fecha integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM escrituras_400
    WHERE folio = p_folio AND fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSESCRIT400 (EXACTO del archivo original)
-- Archivo: 83_SP_RECAUDADORA_CONSESCRIT400_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

