-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CatastroDM
-- Generado: 2025-08-27 21:03:36
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_get_cuenta_by_clave
-- Tipo: Catalog
-- Descripción: Obtiene la cuenta catastral por clave catastral
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cuenta_by_clave(p_clave TEXT)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecatnva TEXT,
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT cvecuenta, cvecatnva, recaud, urbrus, cuenta
    FROM convcta WHERE cvecatnva = p_clave;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_get_adeudos_by_cuenta
-- Tipo: Report
-- Descripción: Obtiene los adeudos de una cuenta catastral
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_by_cuenta(p_cvecuenta INTEGER)
RETURNS TABLE(
    axosal INTEGER,
    bimsal INTEGER,
    impfac NUMERIC,
    recfac NUMERIC,
    saldo NUMERIC
) AS $$
BEGIN
    RETURN QUERY SELECT axosal, bimsal, impfac, recfac, saldo
    FROM detsaldos WHERE cvecuenta = p_cvecuenta ORDER BY axosal, bimsal;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_insert_descuento_predial
-- Tipo: CRUD
-- Descripción: Inserta un nuevo descuento predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_descuento_predial(
    p_cvecuenta INTEGER,
    p_cvedescuento INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_fecalta DATE,
    p_captalta TEXT,
    p_solicitante TEXT,
    p_observaciones TEXT,
    p_recaud INTEGER,
    p_foliodesc INTEGER,
    p_status TEXT,
    p_identificacion TEXT DEFAULT NULL,
    p_fecnac DATE DEFAULT NULL,
    p_institucion INTEGER DEFAULT NULL
) RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO descpred (cvecuenta, cvedescuento, bimini, bimfin, fecalta, captalta, solicitante, observaciones, recaud, foliodesc, status, identificacion, fecnac, institucion)
    VALUES (p_cvecuenta, p_cvedescuento, p_bimini, p_bimfin, p_fecalta, p_captalta, p_solicitante, p_observaciones, p_recaud, p_foliodesc, p_status, p_identificacion, p_fecnac, p_institucion)
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_get_descuentos_predial
-- Tipo: Report
-- Descripción: Obtiene los descuentos predial de una cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_descuentos_predial(p_cvecuenta INTEGER)
RETURNS TABLE(
    id INTEGER,
    cvedescuento INTEGER,
    bimini INTEGER,
    bimfin INTEGER,
    solicitante TEXT,
    observaciones TEXT,
    fecalta DATE,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT id, cvedescuento, bimini, bimfin, solicitante, observaciones, fecalta, status
    FROM descpred WHERE cvecuenta = p_cvecuenta ORDER BY fecalta DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_cancelar_descuento_predial
-- Tipo: CRUD
-- Descripción: Cancela un descuento predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelar_descuento_predial(p_id INTEGER, p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE descpred SET status = 'C', fecbaja = NOW(), captbaja = p_usuario WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_get_usuarios
-- Tipo: Catalog
-- Descripción: Obtiene los usuarios activos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_usuarios()
RETURNS TABLE(usuario TEXT, nombres TEXT, cvedepto INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT usuario, nombres, cvedepto FROM usuarios WHERE fecbaj IS NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_get_catalogo_descuentos
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de tipos de descuentos predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_catalogo_descuentos()
RETURNS TABLE(cvedescuento INTEGER, descripcion TEXT) AS $$
BEGIN
    RETURN QUERY SELECT cvedescuento, descripcion FROM c_descpred ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

