-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSMULPRESC (EXACTO del archivo original)
-- Archivo: 86_SP_RECAUDADORA_CONSMULPRESC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_list_presc_multas
-- Tipo: Catalog
-- Descripción: Lista todas las prescripciones de multas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_list_presc_multas()
RETURNS TABLE (
    id_prescri INTEGER,
    fecaut DATE,
    fecha_prescri DATE,
    oficio VARCHAR,
    capturista VARCHAR,
    dependencia VARCHAR,
    observaciones TEXT,
    id_multa INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT id_prescri, fecaut, fecha_prescri, oficio, capturista, dependencia, observaciones, id_multa
    FROM presc_multas
    ORDER BY id_prescri DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSMULPRESC (EXACTO del archivo original)
-- Archivo: 86_SP_RECAUDADORA_CONSMULPRESC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_create_presc_multa
-- Tipo: CRUD
-- Descripción: Crea una nueva prescripción de multa.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_create_presc_multa(
    p_fecaut DATE,
    p_fecha_prescri DATE,
    p_oficio VARCHAR,
    p_capturista VARCHAR,
    p_dependencia VARCHAR,
    p_observaciones TEXT,
    p_id_multa INTEGER
) RETURNS TABLE (
    id_prescri INTEGER,
    fecaut DATE,
    fecha_prescri DATE,
    oficio VARCHAR,
    capturista VARCHAR,
    dependencia VARCHAR,
    observaciones TEXT,
    id_multa INTEGER
) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO presc_multas (fecaut, fecha_prescri, oficio, capturista, dependencia, observaciones, id_multa)
    VALUES (p_fecaut, p_fecha_prescri, p_oficio, p_capturista, p_dependencia, p_observaciones, p_id_multa)
    RETURNING id_prescri INTO new_id;
    RETURN QUERY SELECT id_prescri, fecaut, fecha_prescri, oficio, capturista, dependencia, observaciones, id_multa
    FROM presc_multas WHERE id_prescri = new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSMULPRESC (EXACTO del archivo original)
-- Archivo: 86_SP_RECAUDADORA_CONSMULPRESC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_delete_presc_multa
-- Tipo: CRUD
-- Descripción: Elimina una prescripción de multa por id.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_presc_multa(p_id_prescri INTEGER)
RETURNS TABLE (
    id_prescri INTEGER
) AS $$
BEGIN
    DELETE FROM presc_multas WHERE id_prescri = p_id_prescri RETURNING id_prescri;
END;
$$ LANGUAGE plpgsql;

-- ============================================

