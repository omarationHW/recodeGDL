-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SOLSDOSFAVOR (EXACTO del archivo original)
-- Archivo: 73_SP_RECAUDADORA_SOLSDOSFAVOR_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SOLSDOSFAVOR (EXACTO del archivo original)
-- Archivo: 73_SP_RECAUDADORA_SOLSDOSFAVOR_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SOLSDOSFAVOR (EXACTO del archivo original)
-- Archivo: 73_SP_RECAUDADORA_SOLSDOSFAVOR_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SOLSDOSFAVOR (EXACTO del archivo original)
-- Archivo: 73_SP_RECAUDADORA_SOLSDOSFAVOR_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
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

