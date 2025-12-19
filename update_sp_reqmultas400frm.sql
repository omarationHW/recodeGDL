-- =====================================================
-- Stored Procedure: recaudadora_reqmultas400frm
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Consulta de requerimientos multas 400
--              Busca requerimientos por cuenta o folio
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_reqmultas400frm(VARCHAR);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_reqmultas400frm(
    p_clave_cuenta VARCHAR
)
RETURNS TABLE (
    cvelet TEXT,
    cvenum INTEGER,
    ctarfc INTEGER,
    cveapl INTEGER,
    axoreq INTEGER,
    folreq INTEGER,
    fecreq TEXT,
    impcuo NUMERIC,
    observr TEXT,
    vigreq TEXT,
    actreq TEXT,
    tipo_multa TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar requerimientos de multas 400
    RETURN QUERY
    SELECT
        TRIM(r.cvelet)::TEXT,
        r.cvenum::INTEGER,
        r.ctarfc::INTEGER,
        r.cveapl::INTEGER,
        r.axoreq::INTEGER,
        r.folreq::INTEGER,
        r.fecreq::TEXT,
        r.impcuo::NUMERIC,
        TRIM(r.observr)::TEXT,
        TRIM(r.vigreq)::TEXT,
        r.actreq::TEXT,
        CASE
            WHEN r.cveapl = 6 THEN 'Federal'
            WHEN r.cveapl = 5 THEN 'Municipal'
            ELSE 'Otro'
        END::TEXT as tipo_multa
    FROM public.req_mul_400 r
    WHERE p_clave_cuenta IS NULL
       OR TRIM(r.cvelet) ILIKE '%' || p_clave_cuenta || '%'
       OR CAST(r.folreq AS TEXT) = p_clave_cuenta
       OR CAST(r.axoreq AS TEXT) = p_clave_cuenta
    ORDER BY r.axoreq DESC, r.folreq DESC
    LIMIT 100;

    RETURN;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_reqmultas400frm(VARCHAR) IS
'Consulta de requerimientos multas 400.
Busca requerimientos por cuenta o folio en la tabla public.req_mul_400.
Parámetros:
  - p_clave_cuenta: Clave de cuenta, folio o año (puede ser NULL para traer primeros 100)
Retorna:
  - cvelet: Clave letra
  - cvenum: Año acta
  - ctarfc: Número de acta
  - cveapl: Tipo de aplicación (5=Municipal, 6=Federal)
  - axoreq: Año de requerimiento
  - folreq: Folio de requerimiento
  - fecreq: Fecha de requerimiento
  - impcuo: Importe
  - observr: Observaciones
  - vigreq: Vigencia de requerimiento
  - actreq: Activación de requerimiento
  - tipo_multa: Tipo de multa (Federal/Municipal/Otro)
Limitado a 100 registros por consulta.';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqmultas400frm(VARCHAR) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqmultas400frm(VARCHAR) TO PUBLIC;
