-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: OBSERVACIONFRM (EXACTO del archivo original)
-- Archivo: 77_SP_LICENCIAS_OBSERVACIONFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_save_observacion
-- Tipo: CRUD
-- Descripción: Guarda una nueva observación en la tabla observaciones y retorna el registro insertado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_save_observacion(p_observacion TEXT)
RETURNS TABLE(id BIGINT, observacion TEXT, created_at TIMESTAMP) AS $$
BEGIN
    INSERT INTO observaciones (observacion, created_at)
    VALUES (UPPER(p_observacion), NOW());
    RETURN QUERY
        SELECT id, observacion, created_at
        FROM observaciones
        WHERE id = currval('observaciones_id_seq');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: OBSERVACIONFRM (EXACTO del archivo original)
-- Archivo: 77_SP_LICENCIAS_OBSERVACIONFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

