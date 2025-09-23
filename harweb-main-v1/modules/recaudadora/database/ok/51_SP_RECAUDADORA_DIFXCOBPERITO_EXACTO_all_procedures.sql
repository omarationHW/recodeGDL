-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DIFXCOBPERITO (EXACTO del archivo original)
-- Archivo: 51_SP_RECAUDADORA_DIFXCOBPERITO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_difxcobperito_peritos
-- Tipo: Report
-- Descripción: Obtiene la lista de peritos con diferencias en el periodo y vigencia indicada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_difxcobperito_peritos(p_fecha1 DATE, p_fecha2 DATE, p_vigencia VARCHAR)
RETURNS TABLE(noperito INTEGER, nom TEXT, difer NUMERIC) AS $$
BEGIN
  RETURN QUERY
    SELECT d.noperito, TRIM(p.paterno)||' '||TRIM(p.materno)||' '||TRIM(p.nombres) AS nom, COUNT(*) AS difer
    FROM diferencias_glosa d
    JOIN peritos p ON d.noperito = p.noperito
    WHERE d.fecha_alta BETWEEN p_fecha1 AND p_fecha2
      AND d.vigencia = p_vigencia
    GROUP BY d.noperito, p.paterno, p.materno, p.nombres;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DIFXCOBPERITO (EXACTO del archivo original)
-- Archivo: 51_SP_RECAUDADORA_DIFXCOBPERITO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

