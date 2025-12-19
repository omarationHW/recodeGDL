-- =====================================================
-- Stored Procedure: recaudadora_requerimientos_dm
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Consultar requerimientos DM (Dirección Municipal)
--              Lista requerimientos prediales de beneficios fiscales
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_requerimientos_dm(VARCHAR, INTEGER);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_requerimientos_dm(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    cvereq INTEGER,
    folio INTEGER,
    cuenta TEXT,
    ejercicio INTEGER,
    fecha_emision TEXT,
    fecha_entrega TEXT,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    multas NUMERIC,
    total NUMERIC,
    vigencia TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.cvecuenta::INTEGER as cvereq,
        COALESCE(r.cveejecut, 0)::INTEGER as folio,
        COALESCE(r.cvecuenta::TEXT, '') as cuenta,
        COALESCE(r.axodesde, 0)::INTEGER as ejercicio,
        COALESCE(TO_CHAR(r.fecemi, 'DD/MM/YYYY'), '')::TEXT as fecha_emision,
        COALESCE(TO_CHAR(r.feccap, 'DD/MM/YYYY'), '')::TEXT as fecha_entrega,
        COALESCE(r.impuesto, 0)::NUMERIC as impuesto,
        COALESCE(r.recargos, 0)::NUMERIC as recargos,
        COALESCE(r.gastos, 0)::NUMERIC as gastos,
        COALESCE(r.multas, 0)::NUMERIC as multas,
        COALESCE(r.total, 0)::NUMERIC as total,
        CASE
            WHEN r.vigencia = 'V' THEN 'Vigente'::TEXT
            WHEN r.vigencia = 'C' THEN 'Cancelado'::TEXT
            WHEN r.vigencia = 'P' THEN 'Pendiente'::TEXT
            WHEN r.vigencia = 'E' THEN 'Entregado'::TEXT
            WHEN r.vigencia = 'A' OR r.vigencia = '1' THEN 'Activo'::TEXT
            WHEN r.vigencia = 'I' OR r.vigencia = '0' THEN 'Inactivo'::TEXT
            ELSE COALESCE(r.vigencia::TEXT, 'Sin estatus')
        END as vigencia
    FROM public.reqbfpredial r
    WHERE 1=1
       AND (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
       AND (p_ejercicio IS NULL OR p_ejercicio = 0 OR r.axodesde = p_ejercicio)
    ORDER BY r.axodesde DESC, r.cvecuenta DESC
    LIMIT 100;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_requerimientos_dm(VARCHAR, INTEGER) IS
'Consultar requerimientos DM (Dirección Municipal) de beneficios fiscales prediales.
Lista requerimientos de la tabla public.reqbfpredial.
Parámetros:
  - p_clave_cuenta: VARCHAR (opcional) - Cuenta a buscar
  - p_ejercicio: INTEGER (opcional) - Año del requerimiento (0 o NULL = todos)
Retorna tabla con información completa del requerimiento incluyendo:
  - Identificación (cvereq como cvecuenta, folio como ejecutoria)
  - Datos de cuenta y ejercicio
  - Fechas (emisión, entrega)
  - Vigencia
  - Importes desglosados (impuesto, recargos, gastos, multas, total)
Límite: 100 registros';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_requerimientos_dm(VARCHAR, INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_requerimientos_dm(VARCHAR, INTEGER) TO PUBLIC;
