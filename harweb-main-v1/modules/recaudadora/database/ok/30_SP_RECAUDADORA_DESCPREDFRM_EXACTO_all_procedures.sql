-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: descpredfrm (Descuentos Predial)
-- Generado: 2025-08-27 21:10:43
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_descpred_list
-- Tipo: Report
-- Descripción: Lista todos los descuentos de predial para una cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descpred_list(p_cvecuenta INTEGER)
RETURNS TABLE(
    id INTEGER,
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    bimini INTEGER,
    bimfin INTEGER,
    fecalta DATE,
    captalta TEXT,
    fecbaja DATE,
    captbaja TEXT,
    propie TEXT,
    solicitante TEXT,
    observaciones TEXT,
    recaud INTEGER,
    foliodesc INTEGER,
    status TEXT,
    identificacion TEXT,
    fecnac DATE,
    institucion INTEGER,
    porcentaje INTEGER,
    descripcion TEXT,
    institucion_nombre TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id, d.cvecuenta, d.cvedescuento, d.bimini, d.bimfin, d.fecalta, 
        d.captalta, d.fecbaja, d.captbaja, d.propie, d.solicitante, 
        d.observaciones, d.recaud, d.foliodesc, d.status, d.identificacion, 
        d.fecnac, d.institucion, d.porcentaje, c.descripcion, i.institucion
    FROM public.descpred d
    JOIN public.c_descpred c ON d.cvedescuento = c.cvedescuento
    LEFT JOIN public.c_instituciones i ON d.institucion = i.cveinst
    WHERE d.cvecuenta = p_cvecuenta
    ORDER BY d.fecalta DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_descpred_get
-- Tipo: CRUD
-- Descripción: Obtiene un descuento de predial por ID
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descpred_get(p_id INTEGER)
RETURNS TABLE(
    id INTEGER,
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    bimini INTEGER,
    bimfin INTEGER,
    fecalta DATE,
    captalta TEXT,
    fecbaja DATE,
    captbaja TEXT,
    propie TEXT,
    solicitante TEXT,
    observaciones TEXT,
    recaud INTEGER,
    foliodesc INTEGER,
    status TEXT,
    identificacion TEXT,
    fecnac DATE,
    institucion INTEGER,
    porcentaje INTEGER,
    descripcion TEXT,
    institucion_nombre TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id, d.cvecuenta, d.cvedescuento, d.bimini, d.bimfin, d.fecalta, 
        d.captalta, d.fecbaja, d.captbaja, d.propie, d.solicitante, 
        d.observaciones, d.recaud, d.foliodesc, d.status, d.identificacion, 
        d.fecnac, d.institucion, d.porcentaje, c.descripcion, i.institucion
    FROM public.descpred d
    JOIN public.c_descpred c ON d.cvedescuento = c.cvedescuento
    LEFT JOIN public.c_instituciones i ON d.institucion = i.cveinst
    WHERE d.id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_descpred_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo descuento de predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descpred_create(
    p_cvecuenta INTEGER,
    p_cvedescuento INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_solicitante TEXT,
    p_identificacion TEXT,
    p_fecnac DATE,
    p_institucion INTEGER,
    p_observaciones TEXT,
    p_porcentaje INTEGER,
    p_user TEXT
) RETURNS TABLE(id INTEGER) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    -- Verificar que no exista un descuento vigente para el mismo período
    IF EXISTS (
        SELECT 1 FROM public.descpred 
        WHERE cvecuenta = p_cvecuenta 
          AND cvedescuento = p_cvedescuento
          AND status = 'V'
          AND (
            (p_bimini BETWEEN bimini AND bimfin) OR
            (p_bimfin BETWEEN bimini AND bimfin) OR
            (bimini BETWEEN p_bimini AND p_bimfin)
          )
    ) THEN
        RAISE EXCEPTION 'Ya existe un descuento vigente para este período';
    END IF;
    
    INSERT INTO public.descpred (
        cvecuenta, cvedescuento, bimini, bimfin, solicitante, identificacion, 
        fecnac, institucion, observaciones, porcentaje, fecalta, captalta, status
    ) VALUES (
        p_cvecuenta, p_cvedescuento, p_bimini, p_bimfin, p_solicitante, 
        p_identificacion, p_fecnac, p_institucion, p_observaciones, 
        p_porcentaje, NOW(), p_user, 'V'
    ) RETURNING id INTO v_id;
    
    RETURN QUERY SELECT v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_descpred_update
-- Tipo: CRUD
-- Descripción: Actualiza un descuento de predial existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descpred_update(
    p_id INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_solicitante TEXT,
    p_identificacion TEXT,
    p_fecnac DATE,
    p_institucion INTEGER,
    p_observaciones TEXT,
    p_porcentaje INTEGER,
    p_user TEXT
) RETURNS TABLE(id INTEGER) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE public.descpred SET
        bimini = p_bimini,
        bimfin = p_bimfin,
        solicitante = p_solicitante,
        identificacion = p_identificacion,
        fecnac = p_fecnac,
        institucion = p_institucion,
        observaciones = p_observaciones,
        porcentaje = p_porcentaje,
        captbaja = NULL,
        fecbaja = NULL
    WHERE id = p_id AND status = 'V'; -- Solo permitir actualizar descuentos vigentes
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    IF v_count = 0 THEN
        RAISE EXCEPTION 'No se encontró descuento vigente con ID: %', p_id;
    END IF;
    
    RETURN QUERY SELECT p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_descpred_delete
-- Tipo: CRUD
-- Descripción: Da de baja (cancela) un descuento de predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descpred_delete(
    p_id INTEGER,
    p_motivo TEXT,
    p_user TEXT
) RETURNS TABLE(id INTEGER) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE public.descpred SET
        status = 'C',
        fecbaja = NOW(),
        captbaja = p_user,
        observaciones = COALESCE(observaciones, '') || E'\nBAJA: ' || p_motivo
    WHERE id = p_id AND status = 'V'; -- Solo permitir cancelar descuentos vigentes
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    IF v_count = 0 THEN
        RAISE EXCEPTION 'No se encontró descuento vigente con ID: %', p_id;
    END IF;
    
    RETURN QUERY SELECT p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_descpred_reactivate
-- Tipo: CRUD
-- Descripción: Reactiva un descuento de predial dado de baja
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descpred_reactivate(
    p_id INTEGER,
    p_user TEXT
) RETURNS TABLE(id INTEGER) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE public.descpred SET
        status = 'V',
        fecbaja = NULL,
        captbaja = NULL,
        observaciones = COALESCE(observaciones, '') || E'\nREACTIVADO por: ' || p_user
    WHERE id = p_id AND status = 'C'; -- Solo permitir reactivar descuentos cancelados
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    IF v_count = 0 THEN
        RAISE EXCEPTION 'No se encontró descuento cancelado con ID: %', p_id;
    END IF;
    
    RETURN QUERY SELECT p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================