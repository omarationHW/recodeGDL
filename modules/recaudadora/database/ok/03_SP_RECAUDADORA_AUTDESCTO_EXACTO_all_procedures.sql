-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: autdescto
-- Generado: 2025-08-26 20:45:21
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_autdescto_list
-- Tipo: Catalog
-- Descripción: Lista todos los descuentos de predial para una cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autdescto_list(p_cvecuenta INTEGER)
RETURNS TABLE(
    id INTEGER,
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    bimini INTEGER,
    bimfin INTEGER,
    fecalta DATE,
    captalta VARCHAR,
    fecbaja DATE,
    captbaja VARCHAR,
    solicitante VARCHAR,
    observaciones VARCHAR,
    recaud INTEGER,
    foliodesc INTEGER,
    status VARCHAR,
    identificacion VARCHAR,
    fecnac DATE,
    institucion INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id, d.cvecuenta, d.cvedescuento, d.bimini, d.bimfin, d.fecalta, d.captalta, d.fecbaja, d.captbaja, d.solicitante, d.observaciones, d.recaud, d.foliodesc, d.status, d.identificacion, d.fecnac, d.institucion, c.descripcion
    FROM public.descpred d
    JOIN public.c_descpred c ON c.cvedescuento = d.cvedescuento
    WHERE d.cvecuenta = p_cvecuenta
    ORDER BY d.fecalta DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_autdescto_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo descuento de predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autdescto_create(
    p_cvecuenta INTEGER,
    p_cvedescuento INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_solicitante VARCHAR,
    p_observaciones VARCHAR,
    p_institucion INTEGER,
    p_identificacion VARCHAR,
    p_fecnac DATE,
    p_usuario VARCHAR
) RETURNS TABLE(id INTEGER, message TEXT) AS $$
DECLARE
    v_folio INTEGER;
BEGIN
    -- Validación de rango de bimestres
    IF p_bimini > p_bimfin THEN
        RAISE EXCEPTION 'Error en el rango de bimestres';
    END IF;
    -- Validación de duplicidad
    IF EXISTS (SELECT 1 FROM public.descpred WHERE cvecuenta=p_cvecuenta AND fecbaja IS NULL AND ((bimini BETWEEN p_bimini AND p_bimfin) OR (bimfin BETWEEN p_bimini AND p_bimfin))) THEN
        RAISE EXCEPTION 'Ya existe un descuento vigente sobre este periodo';
    END IF;
    -- Folio automático (ejemplo simple)
    SELECT COALESCE(MAX(foliodesc),0)+1 INTO v_folio FROM public.descpred WHERE recaud=(SELECT recaud FROM public.convcta WHERE cvecuenta=p_cvecuenta LIMIT 1);
    INSERT INTO public.descpred (cvecuenta, cvedescuento, bimini, bimfin, fecalta, captalta, solicitante, observaciones, recaud, foliodesc, status, identificacion, fecnac, institucion)
    VALUES (p_cvecuenta, p_cvedescuento, p_bimini, p_bimfin, CURRENT_DATE, p_usuario, p_solicitante, p_observaciones, (SELECT recaud FROM public.convcta WHERE cvecuenta=p_cvecuenta LIMIT 1), v_folio, 'V', p_identificacion, p_fecnac, p_institucion)
    RETURNING id, 'Descuento creado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_autdescto_update
-- Tipo: CRUD
-- Descripción: Actualiza un descuento de predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autdescto_update(
    p_id INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_solicitante VARCHAR,
    p_observaciones VARCHAR,
    p_institucion INTEGER,
    p_identificacion VARCHAR,
    p_fecnac DATE,
    p_usuario VARCHAR
) RETURNS TABLE(id INTEGER, message TEXT) AS $$
BEGIN
    UPDATE public.descpred
    SET bimini = p_bimini,
        bimfin = p_bimfin,
        solicitante = p_solicitante,
        observaciones = p_observaciones,
        institucion = p_institucion,
        identificacion = p_identificacion,
        fecnac = p_fecnac,
        captalta = p_usuario
    WHERE id = p_id;
    RETURN QUERY SELECT p_id, 'Descuento actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_autdescto_cancel
-- Tipo: CRUD
-- Descripción: Cancela un descuento de predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autdescto_cancel(
    p_id INTEGER,
    p_usuario VARCHAR,
    p_motivo VARCHAR
) RETURNS TABLE(id INTEGER, message TEXT) AS $$
BEGIN
    UPDATE public.descpred
    SET fecbaja = CURRENT_DATE,
        captbaja = p_usuario,
        status = 'C',
        observaciones = COALESCE(observaciones,'') || '\nCancelado: ' || p_motivo
    WHERE id = p_id AND fecbaja IS NULL;
    RETURN QUERY SELECT p_id, 'Descuento cancelado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_autdescto_reactivate
-- Tipo: CRUD
-- Descripción: Reactiva un descuento de predial cancelado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autdescto_reactivate(
    p_id INTEGER,
    p_usuario VARCHAR
) RETURNS TABLE(id INTEGER, message TEXT) AS $$
BEGIN
    UPDATE public.descpred
    SET fecbaja = NULL,
        captbaja = NULL,
        status = 'V',
        observaciones = COALESCE(observaciones,'') || '\nReactivado por ' || p_usuario
    WHERE id = p_id AND status = 'C';
    RETURN QUERY SELECT p_id, 'Descuento reactivado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================