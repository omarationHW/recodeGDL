-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FECHASEGFRM (EXACTO del archivo original)
-- Archivo: 62_SP_LICENCIAS_FECHASEGFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: fechasegfrm_save
-- Tipo: CRUD
-- Descripción: Guarda un registro de fecha y oficio en la tabla fechasegfrm.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION fechasegfrm_save(p_fecha DATE, p_oficio VARCHAR)
RETURNS TABLE(id INTEGER, fecha DATE, oficio VARCHAR, created_at TIMESTAMP) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO fechasegfrm (fecha, oficio, created_at)
    VALUES (p_fecha, p_oficio, NOW())
    RETURNING id, fecha, oficio, created_at INTO new_id, fechasegfrm_save.fecha, fechasegfrm_save.oficio, fechasegfrm_save.created_at;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FECHASEGFRM (EXACTO del archivo original)
-- Archivo: 62_SP_LICENCIAS_FECHASEGFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

