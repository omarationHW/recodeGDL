-- ============================================
-- STORED PROCEDURES PARA conscentrosfrm.vue
-- Modulo: multas_reglamentos
-- Fecha: 2025-11-25
-- Descripcion: SPs para consulta de centros
-- ============================================

-- ============================================
-- SP 1/2: conscentrosfrm_sp_get_dependencias
-- Lista de dependencias para combo (desde datos locales)
-- ============================================
DROP FUNCTION IF EXISTS conscentrosfrm_sp_get_dependencias();

CREATE OR REPLACE FUNCTION conscentrosfrm_sp_get_dependencias()
RETURNS TABLE (
    id INTEGER,
    abrevia VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    -- Usar dependencias que existen en recauda_centros
    RETURN QUERY
    SELECT DISTINCT
        rc.id_dependencia::INTEGER AS id,
        ('DEP-' || rc.id_dependencia::TEXT)::VARCHAR AS abrevia,
        ('Dependencia ' || rc.id_dependencia::TEXT)::VARCHAR AS descripcion
    FROM recauda_centros rc
    WHERE rc.id_dependencia IS NOT NULL
    ORDER BY 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION conscentrosfrm_sp_get_dependencias() IS 'Lista dependencias para filtro de consulta de centros';

-- ============================================
-- SP 2/2: conscentrosfrm_sp_list
-- Lista multas cobradas en centros
-- ============================================
DROP FUNCTION IF EXISTS conscentrosfrm_sp_list(VARCHAR, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION conscentrosfrm_sp_list(
    p_fecha VARCHAR DEFAULT '',
    p_id_dependencia INTEGER DEFAULT 0,
    p_axo_acta INTEGER DEFAULT 0,
    p_num_acta INTEGER DEFAULT 0
)
RETURNS TABLE (
    fecha DATE,
    id_dependencia INTEGER,
    abrevia VARCHAR,
    axo_acta SMALLINT,
    num_acta INTEGER,
    num_recibo INTEGER,
    importe_pago NUMERIC,
    contribuyente VARCHAR,
    domicilio VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        rc.fecha,
        rc.id_dependencia::INTEGER,
        ('DEP-' || COALESCE(rc.id_dependencia::TEXT, ''))::VARCHAR AS abrevia,
        rc.axo_acta,
        rc.num_acta,
        rc.num_recibo,
        COALESCE(rc.importe_pago, 0)::NUMERIC,
        COALESCE(rc.contribuyente, '')::VARCHAR,
        COALESCE(rc.domicilio, '')::VARCHAR
    FROM recauda_centros rc
    WHERE
        (p_fecha = '' OR rc.fecha = p_fecha::DATE)
        AND (p_id_dependencia = 0 OR rc.id_dependencia = p_id_dependencia)
        AND (p_axo_acta = 0 OR rc.axo_acta = p_axo_acta)
        AND (p_num_acta = 0 OR rc.num_acta = p_num_acta)
    ORDER BY rc.fecha DESC, rc.num_acta
    LIMIT 500;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION conscentrosfrm_sp_list(VARCHAR, INTEGER, INTEGER, INTEGER) IS 'Lista multas cobradas en centros de recaudacion';

-- ============================================
-- Verificacion
-- ============================================
SELECT 'SPs conscentrosfrm creados correctamente' AS status;
