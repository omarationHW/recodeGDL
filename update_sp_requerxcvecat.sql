-- =====================================================
-- Stored Procedure: recaudadora_requerxcvecat
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Consulta de requerimientos prediales por clave catastral
--              Busca requerimientos en cartas de invitación predial
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_requerxcvecat(VARCHAR);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_requerxcvecat(
    p_cvecat VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvereq INTEGER,
    folio INTEGER,
    cuenta INTEGER,
    clave_catastral TEXT,
    ejercicio INTEGER,
    fecha_emision DATE,
    fecha_entrega DATE,
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
    -- Retornar requerimientos de cartas de invitación predial
    RETURN QUERY
    SELECT
        r.cvereq::INTEGER,
        r.foliocarta::INTEGER as folio,
        r.cvecuenta::INTEGER as cuenta,
        COALESCE(TRIM(r.cvecatnva)::TEXT, '') as clave_catastral,
        r.axoini::INTEGER as ejercicio,
        r.fecemi::DATE as fecha_emision,
        r.fecprac::DATE as fecha_entrega,
        COALESCE(r.impuesto::NUMERIC, 0) as impuesto,
        COALESCE(r.recargos::NUMERIC, 0) as recargos,
        COALESCE(r.gastos::NUMERIC, 0) as gastos,
        COALESCE(r.multas::NUMERIC, 0) as multas,
        COALESCE(r.total::NUMERIC, 0) as total,
        CASE
            WHEN r.vigencia = 'P' THEN 'Pendiente'::TEXT
            WHEN r.vigencia = 'C' THEN 'Cancelado'::TEXT
            WHEN r.vigencia = 'E' THEN 'Entregado'::TEXT
            WHEN r.vigencia = 'V' THEN 'Vigente'::TEXT
            ELSE COALESCE(r.vigencia::TEXT, 'Sin estatus')
        END as vigencia
    FROM public.cartainvpredial r
    WHERE 1=1
       AND (p_cvecat IS NULL OR p_cvecat = '' OR TRIM(r.cvecatnva) ILIKE '%' || p_cvecat || '%')
    ORDER BY r.axoini DESC, r.foliocarta DESC
    LIMIT 100;

    RETURN;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_requerxcvecat(VARCHAR) IS
'Consulta de requerimientos prediales por clave catastral.
Busca en cartas de invitación predial (tabla public.cartainvpredial).
Parámetros:
  - p_cvecat: Clave catastral (puede ser NULL para traer primeros 100)
Retorna:
  - cvereq: Clave de requerimiento
  - folio: Folio de carta
  - cuenta: Clave de cuenta
  - clave_catastral: Clave catastral
  - ejercicio: Año inicial del ejercicio
  - fecha_emision: Fecha de emisión
  - fecha_entrega: Fecha de practicación
  - impuesto: Importe del impuesto
  - recargos: Importe de recargos
  - gastos: Importe de gastos
  - multas: Importe de multas
  - total: Total a pagar
  - vigencia: Estatus (Pendiente/Cancelado/Entregado/Vigente)
Limitado a 100 registros por consulta.';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_requerxcvecat(VARCHAR) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_requerxcvecat(VARCHAR) TO PUBLIC;
