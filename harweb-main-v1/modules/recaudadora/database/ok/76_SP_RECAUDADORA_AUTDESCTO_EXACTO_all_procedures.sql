-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: AUTDESCTO (EXACTO del archivo original)
-- Archivo: 76_SP_RECAUDADORA_AUTDESCTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
    FROM descpred d
    JOIN c_descpred c ON c.cvedescuento = d.cvedescuento
    WHERE d.cvecuenta = p_cvecuenta
    ORDER BY d.fecalta DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: AUTDESCTO (EXACTO del archivo original)
-- Archivo: 76_SP_RECAUDADORA_AUTDESCTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
    UPDATE descpred
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: AUTDESCTO (EXACTO del archivo original)
-- Archivo: 76_SP_RECAUDADORA_AUTDESCTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
    UPDATE descpred
    SET fecbaja = NULL,
        captbaja = NULL,
        status = 'V',
        observaciones = COALESCE(observaciones,'') || '\nReactivado por ' || p_usuario
    WHERE id = p_id AND status = 'C';
    RETURN QUERY SELECT p_id, 'Descuento reactivado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

