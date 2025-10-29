-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: descmultalic (Descuentos Multas Licencias)
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
    v_new_id INTEGER;
BEGIN
    -- Verificar si ya existe un descuento vigente para esta licencia
    SELECT COUNT(*) INTO v_exists 
    FROM public.descmultalic 
    WHERE id_licencia = p_id_licencia AND vigencia = 'V';
    
    IF v_exists > 0 THEN
        RETURN QUERY SELECT NULL::INTEGER, 'Ya existe un descuento vigente para esta licencia'::TEXT;
        RETURN;
    END IF;
    
    -- Insertar nuevo descuento
    INSERT INTO public.descmultalic (
        id_licencia, porcentaje, fecalta, useralta, vigencia, autoriza
    )
    VALUES (
        p_id_licencia, p_porcentaje, CURRENT_DATE, p_useralta, 'V', p_autoriza
    )
    RETURNING id_descto INTO v_new_id;
    
    RETURN QUERY SELECT v_new_id, 'OK'::TEXT;
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
DECLARE
    v_updated_id INTEGER;
BEGIN
    UPDATE public.descmultalic
    SET porcentaje = p_porcentaje,
        autoriza = p_autoriza,
        fecact = CURRENT_DATE,
        useract = p_useract,
        vigencia = p_vigencia
    WHERE id_descto = p_id_descto
    RETURNING id_descto INTO v_updated_id;
    
    IF v_updated_id IS NULL THEN
        RETURN QUERY SELECT NULL::INTEGER, 'No se encontró el descuento especificado'::TEXT;
    ELSE
        RETURN QUERY SELECT v_updated_id, 'OK'::TEXT;
    END IF;
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
DECLARE
    v_deleted_id INTEGER;
BEGIN
    DELETE FROM public.descmultalic 
    WHERE id_descto = p_id_descto 
    RETURNING id_descto INTO v_deleted_id;
    
    IF v_deleted_id IS NULL THEN
        RETURN QUERY SELECT NULL::INTEGER, 'No se encontró el descuento especificado'::TEXT;
    ELSE
        RETURN QUERY SELECT v_deleted_id, 'OK'::TEXT;
    END IF;
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
DECLARE
    v_cancelled_id INTEGER;
BEGIN
    UPDATE public.descmultalic
    SET vigencia = 'C', 
        fecbaja = CURRENT_DATE, 
        userbaja = p_userbaja
    WHERE id_descto = p_id_descto
    RETURNING id_descto INTO v_cancelled_id;
    
    IF v_cancelled_id IS NULL THEN
        RETURN QUERY SELECT NULL::INTEGER, 'No se encontró el descuento especificado'::TEXT;
    ELSE
        RETURN QUERY SELECT v_cancelled_id, 'CANCELADO'::TEXT;
    END IF;
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
    RETURN QUERY 
    SELECT r.folioreq 
    FROM public.reqlicencias r
    WHERE r.id_licencia = p_id_licencia 
      AND r.vigencia = 'V'
    ORDER BY r.folioreq;
END;
$$ LANGUAGE plpgsql;

-- ============================================