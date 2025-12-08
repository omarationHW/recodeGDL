-- ============================================
-- STORED PROCEDURE PARA consescrit400.vue
-- Modulo: multas_reglamentos
-- Fecha: 2025-11-26
-- Descripcion: SP para consulta de escrituras AS-400
-- ============================================

DROP FUNCTION IF EXISTS consescrit400_sp_search(INTEGER, INTEGER, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION consescrit400_sp_search(
    p_mpio INTEGER DEFAULT 0,
    p_notario INTEGER DEFAULT 0,
    p_escritura INTEGER DEFAULT 0,
    p_folio INTEGER DEFAULT 0,
    p_fecha INTEGER DEFAULT 0
)
RETURNS TABLE (
    escritura INTEGER,
    notario INTEGER,
    mpio INTEGER,
    folio INTEGER,
    axofolio INTEGER,
    cuenta VARCHAR,
    recaud VARCHAR,
    nocomp INTEGER,
    axocomp INTEGER,
    ccta NUMERIC,
    crec NUMERIC,
    clave VARCHAR,
    capturista VARCHAR,
    enviado BOOLEAN,
    regresado BOOLEAN,
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(e.escritura, 0)::INTEGER,
        COALESCE(e.notario, 0)::INTEGER,
        COALESCE(e.mpio, 0)::INTEGER,
        COALESCE(e.folio, 0)::INTEGER,
        COALESCE(e.axofolio, 0)::INTEGER,
        COALESCE(e.cuenta, '')::VARCHAR,
        COALESCE(e.recaud, '')::VARCHAR,
        COALESCE(e.nocomp, 0)::INTEGER,
        COALESCE(e.axocomp, 0)::INTEGER,
        COALESCE(e.ccta, 0)::NUMERIC,
        COALESCE(e.crec, 0)::NUMERIC,
        COALESCE(e.clave, '')::VARCHAR,
        COALESCE(e.capturista, '')::VARCHAR,
        COALESCE(e.enviado, FALSE)::BOOLEAN,
        COALESCE(e.regresado, FALSE)::BOOLEAN,
        e.fecha::DATE
    FROM comun.escrituras_400 e
    WHERE
        -- Busqueda por Escritura (mpio/notario/escritura)
        (
            (p_mpio = 0 OR e.mpio = p_mpio)
            AND (p_notario = 0 OR e.notario = p_notario)
            AND (p_escritura = 0 OR e.escritura = p_escritura)
        )
        -- Busqueda por Folio
        AND (p_folio = 0 OR e.folio = p_folio)
        AND (p_fecha = 0 OR e.axofolio = p_fecha)
    ORDER BY e.fecha DESC NULLS LAST, e.escritura
    LIMIT 500;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION consescrit400_sp_search(INTEGER, INTEGER, INTEGER, INTEGER, INTEGER) IS 'Busca escrituras AS-400 por mpio/notario/escritura o folio/fecha';

SELECT 'SP consescrit400_sp_search creado correctamente' AS status;
