-- ================================================================
-- STORED PROCEDURES PARA REQMULTAS400FRM
-- Módulo: multas_reglamentos
-- Fecha: 2025-12-04
-- ================================================================

-- NOTA: Este script asume que la tabla existe en el schema 'comun'
-- Si está en otro schema, ajusta las referencias según corresponda

-- ================================================================
-- SP 1: Búsqueda por Acta
-- ================================================================
CREATE OR REPLACE FUNCTION req_mul_400_by_acta(
    p_dep VARCHAR,
    p_axo INTEGER,
    p_numacta INTEGER,
    p_tipo INTEGER
)
RETURNS TABLE (
    cvelet VARCHAR,
    cvenum INTEGER,
    ctarfc INTEGER,
    cveapl INTEGER,
    axoreq INTEGER,
    folreq INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    importe NUMERIC,
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.cvelet,
        r.cvenum,
        r.ctarfc,
        r.cveapl,
        r.axoreq,
        r.folreq,
        r.nombre,
        r.domicilio,
        r.importe,
        r.fecha
    FROM comun.req_mul_400 r
    WHERE SUBSTRING(r.cvelet FROM 4 FOR 3) = p_dep
      AND r.cvenum = p_axo
      AND r.ctarfc = p_numacta
      AND r.cveapl = p_tipo
    ORDER BY r.axoreq DESC, r.folreq DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION req_mul_400_by_acta(VARCHAR, INTEGER, INTEGER, INTEGER) IS
'Busca requerimientos de multas 400 por dependencia, año de acta, número de acta y tipo';

-- ================================================================
-- SP 2: Búsqueda por Folio
-- ================================================================
CREATE OR REPLACE FUNCTION req_mul_400_by_folio(
    p_axo INTEGER,
    p_folio INTEGER,
    p_tipo INTEGER
)
RETURNS TABLE (
    cvelet VARCHAR,
    cvenum INTEGER,
    ctarfc INTEGER,
    cveapl INTEGER,
    axoreq INTEGER,
    folreq INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    importe NUMERIC,
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.cvelet,
        r.cvenum,
        r.ctarfc,
        r.cveapl,
        r.axoreq,
        r.folreq,
        r.nombre,
        r.domicilio,
        r.importe,
        r.fecha
    FROM comun.req_mul_400 r
    WHERE r.axoreq = p_axo
      AND r.folreq = p_folio
      AND r.cveapl = p_tipo
    ORDER BY r.axoreq DESC, r.folreq DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION req_mul_400_by_folio(INTEGER, INTEGER, INTEGER) IS
'Busca requerimientos de multas 400 por año de requerimiento, folio y tipo';

-- ================================================================
-- SP 3: Búsqueda General (Principal)
-- ================================================================
CREATE OR REPLACE FUNCTION recaudadora_reqmultas400frm(
    p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvelet VARCHAR,
    cvenum INTEGER,
    ctarfc INTEGER,
    cveapl INTEGER,
    axoreq INTEGER,
    folreq INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    importe NUMERIC,
    fecha DATE,
    tipo_multa VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.cvelet,
        r.cvenum,
        r.ctarfc,
        r.cveapl,
        r.axoreq,
        r.folreq,
        r.nombre,
        r.domicilio,
        r.importe,
        r.fecha,
        CASE
            WHEN r.cveapl = 6 THEN 'Federal'
            WHEN r.cveapl = 5 THEN 'Municipal'
            ELSE 'Otro'
        END::VARCHAR as tipo_multa
    FROM comun.req_mul_400 r
    WHERE p_clave_cuenta IS NULL
       OR r.cvelet ILIKE '%' || p_clave_cuenta || '%'
       OR CAST(r.folreq AS VARCHAR) = p_clave_cuenta
       OR CAST(r.axoreq AS VARCHAR) = p_clave_cuenta
    ORDER BY r.axoreq DESC, r.folreq DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION recaudadora_reqmultas400frm(VARCHAR) IS
'Búsqueda general de requerimientos de multas 400. Si no se proporciona parámetro, devuelve los últimos 100 registros';

-- ================================================================
-- VERIFICACIONES
-- ================================================================

-- Verificar que la función existe
SELECT
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_name IN (
    'req_mul_400_by_acta',
    'req_mul_400_by_folio',
    'recaudadora_reqmultas400frm'
)
ORDER BY routine_name;

-- ================================================================
-- SCRIPT PARA OBTENER EJEMPLOS DE DATOS
-- ================================================================

-- Ejecuta esto después de desplegar los SPs para obtener ejemplos:

/*
-- Ejemplo 1: Obtener últimos registros
SELECT * FROM recaudadora_reqmultas400frm(NULL) LIMIT 10;

-- Ejemplo 2: Buscar por folio específico
SELECT * FROM comun.req_mul_400 WHERE folreq IS NOT NULL ORDER BY axoreq DESC LIMIT 3;

-- Ejemplo 3: Buscar por tipo de multa
SELECT
    cveapl,
    COUNT(*) as total,
    MIN(axoreq) as axo_min,
    MAX(axoreq) as axo_max
FROM comun.req_mul_400
GROUP BY cveapl;

-- Ejemplo 4: Ver estructura completa de un registro
SELECT * FROM comun.req_mul_400 LIMIT 1;
*/

