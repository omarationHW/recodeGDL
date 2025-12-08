-- ============================================
-- DEPLOY CONSOLIDADO: h_bloqueoDomiciliosfrm
-- Componente 79/95 - BATCH 16
-- Generado: 2025-11-20
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_h_bloqueo_dom_listar
CREATE OR REPLACE FUNCTION public.sp_h_bloqueo_dom_listar(p_order TEXT DEFAULT 'calle,num_ext')
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

-- SP 2/3: sp_h_bloqueo_dom_filtrar
CREATE OR REPLACE FUNCTION public.sp_h_bloqueo_dom_filtrar(
    p_campo TEXT,
    p_valor TEXT,
    p_order TEXT DEFAULT 'calle,num_ext'
)
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
    RETURN QUERY EXECUTE format(
        'SELECT * FROM h_bloqueo_dom WHERE %I ILIKE %L ORDER BY %s',
        p_campo,
        '%' || p_valor || '%',
        p_order
    );
END;
$$ LANGUAGE plpgsql;

-- SP 3/3: sp_h_bloqueo_dom_detalle
CREATE OR REPLACE FUNCTION public.sp_h_bloqueo_dom_detalle(p_id INTEGER)
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
