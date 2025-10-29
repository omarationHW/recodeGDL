-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: TIPOBLOQUEOFRM (EXACTO del archivo original)
-- Archivo: 89_SP_LICENCIAS_TIPOBLOQUEOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: get_tipo_bloqueo_catalog
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de tipos de bloqueo activos para selección.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_tipo_bloqueo_catalog()
RETURNS TABLE(id integer, descripcion varchar, sel_cons char(1))
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT id, descripcion, sel_cons
    FROM c_tipobloqueo
    WHERE sel_cons = 'S';
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: TIPOBLOQUEOFRM (EXACTO del archivo original)
-- Archivo: 89_SP_LICENCIAS_TIPOBLOQUEOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

