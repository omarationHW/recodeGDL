-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: SolSdosFavor
-- Generado: 2025-08-27 15:52:47
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_sol_sdosfavor_create
-- Tipo: CRUD
-- Descripción: Crea una nueva solicitud de saldo a favor
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sol_sdosfavor_create(
    p_cvecuenta INTEGER,
    p_domp TEXT,
    p_extp TEXT,
    p_intp TEXT,
    p_colp TEXT,
    p_telefono TEXT,
    p_codp TEXT,
    p_solicitante TEXT,
    p_observaciones TEXT,
    p_doctos TEXT,
    p_status TEXT,
    p_inconf INTEGER,
    p_peticionario INTEGER,
    p_user_id INTEGER,
    p_feccap TIMESTAMP
) RETURNS TABLE(id_solic INTEGER, folio INTEGER, axofol INTEGER, feccap TIMESTAMP) AS $$
DECLARE
    v_folio INTEGER;
    v_axofol INTEGER;
BEGIN
    -- Obtener folio y año actual
    SELECT nextval('sol_sdosfavor_folio_seq') INTO v_folio;
    v_axofol := EXTRACT(YEAR FROM CURRENT_DATE);
    INSERT INTO sol_sdosfavor (
        folio, axofol, cvecuenta, domp, extp, intp, colp, telefono, codp, solicitante, observaciones, doctos, status, inconf, peticionario, feccap, capturista
    ) VALUES (
        v_folio, v_axofol, p_cvecuenta, p_domp, p_extp, p_intp, p_colp, p_telefono, p_codp, p_solicitante, p_observaciones, p_doctos, p_status, p_inconf, p_peticionario, p_feccap, p_user_id
    ) RETURNING id_solic, folio, axofol, feccap INTO id_solic, folio, axofol, feccap;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_sol_sdosfavor_update
-- Tipo: CRUD
-- Descripción: Actualiza una solicitud de saldo a favor existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sol_sdosfavor_update(
    p_id_solic INTEGER,
    p_cvecuenta INTEGER,
    p_domp TEXT,
    p_extp TEXT,
    p_intp TEXT,
    p_colp TEXT,
    p_telefono TEXT,
    p_codp TEXT,
    p_solicitante TEXT,
    p_observaciones TEXT,
    p_doctos TEXT,
    p_status TEXT,
    p_inconf INTEGER,
    p_peticionario INTEGER,
    p_user_id INTEGER,
    p_feccap TIMESTAMP
) RETURNS TABLE(id_solic INTEGER, folio INTEGER, axofol INTEGER, feccap TIMESTAMP) AS $$
BEGIN
    UPDATE sol_sdosfavor SET
        cvecuenta = p_cvecuenta,
        domp = p_domp,
        extp = p_extp,
        intp = p_intp,
        colp = p_colp,
        telefono = p_telefono,
        codp = p_codp,
        solicitante = p_solicitante,
        observaciones = p_observaciones,
        doctos = p_doctos,
        status = p_status,
        inconf = p_inconf,
        peticionario = p_peticionario,
        feccap = p_feccap,
        capturista = p_user_id
    WHERE id_solic = p_id_solic
    RETURNING id_solic, folio, axofol, feccap;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_sol_sdosfavor_cancel
-- Tipo: CRUD
-- Descripción: Cancela una solicitud de saldo a favor
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sol_sdosfavor_cancel(
    p_id_solic INTEGER,
    p_user_id INTEGER
) RETURNS TABLE(id_solic INTEGER, status TEXT, feccap TIMESTAMP) AS $$
BEGIN
    UPDATE sol_sdosfavor SET
        status = 'C',
        feccap = now(),
        capturista = p_user_id
    WHERE id_solic = p_id_solic
    RETURNING id_solic, status, feccap;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_sol_sdosfavor_list
-- Tipo: Report
-- Descripción: Lista solicitudes de saldo a favor por status
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sol_sdosfavor_list(
    p_status TEXT DEFAULT NULL
) RETURNS TABLE(
    id_solic INTEGER, folio INTEGER, axofol INTEGER, cvecuenta INTEGER, ncompleto TEXT, domp TEXT, extp TEXT, intp TEXT, colp TEXT, telefono TEXT, codp TEXT, solicitante TEXT, observaciones TEXT, doctos TEXT, status TEXT, inconf INTEGER, peticionario INTEGER, feccap TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.id_solic, s.folio, s.axofol, s.cvecuenta, c.ncompleto, s.domp, s.extp, s.intp, s.colp, s.telefono, s.codp, s.solicitante, s.observaciones, s.doctos, s.status, s.inconf, s.peticionario, s.feccap
    FROM sol_sdosfavor s
    LEFT JOIN contribuyentes c ON c.cvecuenta = s.cvecuenta
    WHERE (p_status IS NULL OR s.status = p_status)
    ORDER BY s.folio ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_sol_sdosfavor_doctos_catalog
-- Tipo: Catalog
-- Descripción: Catálogo de documentos para solicitudes de saldo a favor
-- --------------------------------------------

CREATE TABLE IF NOT EXISTS doctos_catalog (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

INSERT INTO doctos_catalog (nombre) VALUES
('Comprobante de domicilio'),
('Acta de matrimonio'),
('Acta de nacimiento'),
('Poder simple'),
('Poder certificado'),
('Identificación'),
('Requerimiento'),
('Poder notarial'),
('Acta de Defunción')
ON CONFLICT DO NOTHING;

-- ============================================

-- SP 6/7: sp_sol_sdosfavor_peticionarios_catalog
-- Tipo: Catalog
-- Descripción: Catálogo de peticionarios
-- --------------------------------------------

CREATE TABLE IF NOT EXISTS peticionarios_catalog (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

INSERT INTO peticionarios_catalog (nombre) VALUES
('PROPIETARIO'),
('COPROPIETARIO'),
('ALBACEA'),
('APODERADO'),
('SUJETO DEL IMPTO. PREDIAL'),
('FAMILIAR EN 1er GRADO')
ON CONFLICT DO NOTHING;

-- ============================================

-- SP 7/7: sp_sol_sdosfavor_inconformidades_catalog
-- Tipo: Catalog
-- Descripción: Catálogo de inconformidades
-- --------------------------------------------

CREATE TABLE IF NOT EXISTS inconformidades_catalog (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

INSERT INTO inconformidades_catalog (nombre) VALUES
('PAGO ERRONEO'),
('PAGO DOBLE'),
('PAGO EN DEMASIA'),
('PAGO INDEBIDO'),
('PRESCRIPCIÓN'),
('SOLIC. DESCTOS.'),
('COND. MULTAS Y GASTOS'),
('OTROS')
ON CONFLICT DO NOTHING;

-- ============================================

