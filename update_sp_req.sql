-- =====================================================
-- Stored Procedure: recaudadora_req
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Consultar requerimientos generales
--              Lista registros de la tabla reqtransm
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_req(VARCHAR, INTEGER);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_req(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    id INTEGER,
    folio_requerimiento INTEGER,
    tipo TEXT,
    cuenta INTEGER,
    ejecutoria INTEGER,
    fecha_emision TEXT,
    fecha_ejecucion TEXT,
    fecha_practica TEXT,
    vigencia TEXT,
    importe NUMERIC,
    recargos NUMERIC,
    multas_extemporaneas NUMERIC,
    multas_otras NUMERIC,
    gastos NUMERIC,
    gastos_requerimiento NUMERIC,
    total NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id::INTEGER,
        COALESCE(r.folioreq, 0)::INTEGER as folio_requerimiento,
        CASE
            WHEN r.tipo = 'P' THEN 'Predial'::TEXT
            WHEN r.tipo = 'L' THEN 'Licencia'::TEXT
            WHEN r.tipo = 'M' THEN 'Multa'::TEXT
            WHEN r.tipo = 'A' THEN 'Anuncio'::TEXT
            WHEN r.tipo = 'T' THEN 'Transmisión'::TEXT
            ELSE COALESCE(r.tipo, 'Sin tipo')::TEXT
        END as tipo,
        COALESCE(r.cvecta, 0)::INTEGER as cuenta,
        COALESCE(r.cveejec, 0)::INTEGER as ejecutoria,
        COALESCE(TO_CHAR(r.fecemi, 'DD/MM/YYYY'), '')::TEXT as fecha_emision,
        COALESCE(TO_CHAR(r.feceje, 'DD/MM/YYYY'), '')::TEXT as fecha_ejecucion,
        COALESCE(TO_CHAR(r.fecprac, 'DD/MM/YYYY'), '')::TEXT as fecha_practica,
        CASE
            WHEN r.vigencia = 'V' THEN 'Vigente'::TEXT
            WHEN r.vigencia = 'C' THEN 'Cancelado'::TEXT
            WHEN r.vigencia = 'P' THEN 'Pagado'::TEXT
            WHEN r.vigencia = 'B' THEN 'Baja'::TEXT
            ELSE COALESCE(r.vigencia, 'Sin estatus')::TEXT
        END as vigencia,
        COALESCE(r.importe, 0)::NUMERIC as importe,
        COALESCE(r.recargos, 0)::NUMERIC as recargos,
        COALESCE(r.multas_ex, 0)::NUMERIC as multas_extemporaneas,
        COALESCE(r.multas_otr, 0)::NUMERIC as multas_otras,
        COALESCE(r.gastos, 0)::NUMERIC as gastos,
        COALESCE(r.gastos_req, 0)::NUMERIC as gastos_requerimiento,
        COALESCE(r.total, 0)::NUMERIC as total
    FROM public.reqtransm r
    WHERE 1=1
       AND (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR r.cvecta::TEXT ILIKE '%' || p_clave_cuenta || '%')
       AND (p_ejercicio IS NULL OR p_ejercicio = 0 OR EXTRACT(YEAR FROM r.fecemi) = p_ejercicio)
    ORDER BY r.fecemi DESC, r.folioreq DESC
    LIMIT 100;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_req(VARCHAR, INTEGER) IS
'Consultar requerimientos generales de la tabla public.reqtransm.
Lista requerimientos con filtros opcionales por cuenta y ejercicio.
Parámetros:
  - p_clave_cuenta: VARCHAR (opcional) - Cuenta a buscar
  - p_ejercicio: INTEGER (opcional) - Año de emisión (0 o NULL = todos)
Retorna tabla con información completa del requerimiento incluyendo:
  - Identificación (id, folio, tipo)
  - Datos de cuenta y ejecutoria
  - Fechas (emisión, ejecución, práctica)
  - Vigencia
  - Importes desglosados (importe, recargos, multas, gastos, total)
Límite: 100 registros';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_req(VARCHAR, INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_req(VARCHAR, INTEGER) TO PUBLIC;
