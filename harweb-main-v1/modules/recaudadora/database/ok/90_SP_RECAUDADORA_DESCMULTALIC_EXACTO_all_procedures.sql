-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DESCMULTALIC (EXACTO del archivo original)
-- Archivo: 90_SP_RECAUDADORA_DESCMULTALIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_descmultalic_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo descuento de multa para una licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultalic_create(
    p_id_licencia INTEGER,
    p_porcentaje SMALLINT,
    p_autoriza SMALLINT,
    p_useralta VARCHAR
) RETURNS TABLE(id_descto INTEGER, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM descmultalic WHERE id_licencia = p_id_licencia AND vigencia = 'V';
    IF v_exists > 0 THEN
        RETURN QUERY SELECT NULL, 'Ya existe un descuento vigente para esta licencia';
        RETURN;
    END IF;
    INSERT INTO descmultalic (id_licencia, porcentaje, fecalta, useralta, vigencia, autoriza)
    VALUES (p_id_licencia, p_porcentaje, CURRENT_DATE, p_useralta, 'V', p_autoriza)
    RETURNING id_descto, 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DESCMULTALIC (EXACTO del archivo original)
-- Archivo: 90_SP_RECAUDADORA_DESCMULTALIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_descmultalic_delete
-- Tipo: CRUD
-- Descripción: Elimina un descuento de multa de licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultalic_delete(
    p_id_descto INTEGER
) RETURNS TABLE(id_descto INTEGER, message TEXT) AS $$
BEGIN
    DELETE FROM descmultalic WHERE id_descto = p_id_descto RETURNING id_descto, 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DESCMULTALIC (EXACTO del archivo original)
-- Archivo: 90_SP_RECAUDADORA_DESCMULTALIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_descmultalic_folio
-- Tipo: Report
-- Descripción: Obtiene los folios de requerimientos vigentes para una licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultalic_folio(
    p_id_licencia INTEGER
) RETURNS TABLE(folio INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT folioreq FROM reqlicencias WHERE id_licencia = p_id_licencia AND vigencia = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================

