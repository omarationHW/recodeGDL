-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DESCPREDFRM (EXACTO del archivo original)
-- Archivo: 92_SP_RECAUDADORA_DESCPREDFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
    SELECT d.id, d.cvecuenta, d.cvedescuento, d.bimini, d.bimfin, d.fecalta, d.captalta, d.fecbaja, d.captbaja, d.propie, d.solicitante, d.observaciones, d.recaud, d.foliodesc, d.status, d.identificacion, d.fecnac, d.institucion, d.porcentaje, c.descripcion, i.institucion
    FROM descpred d
    JOIN c_descpred c ON d.cvedescuento = c.cvedescuento
    LEFT JOIN c_instituciones i ON d.institucion = i.cveinst
    WHERE d.cvecuenta = p_cvecuenta
    ORDER BY d.fecalta DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DESCPREDFRM (EXACTO del archivo original)
-- Archivo: 92_SP_RECAUDADORA_DESCPREDFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
    INSERT INTO descpred (
        cvecuenta, cvedescuento, bimini, bimfin, solicitante, identificacion, fecnac, institucion, observaciones, porcentaje, fecalta, captalta, status
    ) VALUES (
        p_cvecuenta, p_cvedescuento, p_bimini, p_bimfin, p_solicitante, p_identificacion, p_fecnac, p_institucion, p_observaciones, p_porcentaje, NOW(), p_user, 'V'
    ) RETURNING id INTO v_id;
    RETURN QUERY SELECT v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DESCPREDFRM (EXACTO del archivo original)
-- Archivo: 92_SP_RECAUDADORA_DESCPREDFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
BEGIN
    UPDATE descpred SET
        status = 'C',
        fecbaja = NOW(),
        captbaja = p_user,
        observaciones = COALESCE(observaciones, '') || '\nBAJA: ' || p_motivo
    WHERE id = p_id;
    RETURN QUERY SELECT p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DESCPREDFRM (EXACTO del archivo original)
-- Archivo: 92_SP_RECAUDADORA_DESCPREDFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

