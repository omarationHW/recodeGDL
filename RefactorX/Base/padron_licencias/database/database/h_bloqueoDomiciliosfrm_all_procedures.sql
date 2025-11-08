-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: h_bloqueoDomiciliosfrm
-- Generado: 2025-08-27 18:27:22
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_h_bloqueo_dom_listar
-- Tipo: Report
-- Descripción: Lista todos los domicilios históricos bloqueados, ordenados por el campo especificado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_h_bloqueo_dom_listar(p_order TEXT DEFAULT 'calle,num_ext')
RETURNS TABLE (
    cvecuenta INTEGER,
    cvecalle INTEGER,
    calle VARCHAR,
    num_ext INTEGER,
    let_ext VARCHAR,
    num_int INTEGER,
    let_int VARCHAR,
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    vig VARCHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    fecha_mov TIMESTAMP,
    motivo_mov VARCHAR,
    tipo_mov VARCHAR,
    modifico VARCHAR
) AS $$
BEGIN
    RETURN QUERY EXECUTE format('SELECT * FROM h_bloqueo_dom ORDER BY %s', p_order);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_h_bloqueo_dom_filtrar
-- Tipo: Report
-- Descripción: Filtra los domicilios históricos bloqueados por campo y valor, ordenados por el campo especificado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_h_bloqueo_dom_filtrar(p_campo TEXT, p_valor TEXT, p_order TEXT DEFAULT 'calle,num_ext')
RETURNS TABLE (
    cvecuenta INTEGER,
    cvecalle INTEGER,
    calle VARCHAR,
    num_ext INTEGER,
    let_ext VARCHAR,
    num_int INTEGER,
    let_int VARCHAR,
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    vig VARCHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    fecha_mov TIMESTAMP,
    motivo_mov VARCHAR,
    tipo_mov VARCHAR,
    modifico VARCHAR
) AS $$
BEGIN
    RETURN QUERY EXECUTE format('SELECT * FROM h_bloqueo_dom WHERE %I ILIKE %L ORDER BY %s', p_campo, '%' || p_valor || '%', p_order);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_h_bloqueo_dom_detalle
-- Tipo: Catalog
-- Descripción: Obtiene el detalle de un domicilio histórico bloqueado por ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_h_bloqueo_dom_detalle(p_id INTEGER)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvecalle INTEGER,
    calle VARCHAR,
    num_ext INTEGER,
    let_ext VARCHAR,
    num_int INTEGER,
    let_int VARCHAR,
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    vig VARCHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    fecha_mov TIMESTAMP,
    motivo_mov VARCHAR,
    tipo_mov VARCHAR,
    modifico VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM h_bloqueo_dom WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

