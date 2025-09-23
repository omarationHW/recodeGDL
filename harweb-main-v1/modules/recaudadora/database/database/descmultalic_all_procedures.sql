-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: descmultalic
-- Generado: 2025-08-27 00:04:06
-- Total SPs: 5
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

-- SP 2/5: sp_descmultalic_update
-- Tipo: CRUD
-- Descripción: Actualiza un descuento de multa de licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultalic_update(
    p_id_descto INTEGER,
    p_porcentaje SMALLINT,
    p_autoriza SMALLINT,
    p_useract VARCHAR,
    p_vigencia VARCHAR
) RETURNS TABLE(id_descto INTEGER, message TEXT) AS $$
BEGIN
    UPDATE descmultalic
    SET porcentaje = p_porcentaje,
        autoriza = p_autoriza,
        fecact = CURRENT_DATE,
        useract = p_useract,
        vigencia = p_vigencia
    WHERE id_descto = p_id_descto
    RETURNING id_descto, 'OK';
END;
$$ LANGUAGE plpgsql;

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

-- SP 4/5: sp_descmultalic_cancel
-- Tipo: CRUD
-- Descripción: Cancela (marca como no vigente) un descuento de multa de licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultalic_cancel(
    p_id_descto INTEGER,
    p_userbaja VARCHAR
) RETURNS TABLE(id_descto INTEGER, message TEXT) AS $$
BEGIN
    UPDATE descmultalic
    SET vigencia = 'C', fecbaja = CURRENT_DATE, userbaja = p_userbaja
    WHERE id_descto = p_id_descto
    RETURNING id_descto, 'CANCELADO';
END;
$$ LANGUAGE plpgsql;

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

