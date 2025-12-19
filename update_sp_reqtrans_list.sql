-- =====================================================
-- Stored Procedure: recaudadora_reqtrans_list
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Consulta de requerimientos de diferencias de transmisión
--              Busca requerimientos por cuenta o ejercicio fiscal
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_reqtrans_list(VARCHAR, INTEGER);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_reqtrans_list(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    cvereq INTEGER,
    clave_cuenta TEXT,
    folio INTEGER,
    ejercicio INTEGER,
    estatus TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar requerimientos de diferencias de transmisión
    RETURN QUERY
    SELECT
        r.cvereq::INTEGER,
        COALESCE(r.cvecuenta::TEXT, '')::TEXT as clave_cuenta,
        COALESCE(r.foliotransm, 0)::INTEGER as folio,
        COALESCE(r.axoreq, 0)::INTEGER as ejercicio,
        CASE
            WHEN r.vigencia = 'V' THEN 'Vigente'::TEXT
            WHEN r.vigencia = 'C' THEN 'Cancelado'::TEXT
            WHEN r.vigencia = 'P' THEN 'Pendiente'::TEXT
            WHEN r.vigencia = '1' OR r.vigencia = 'A' THEN 'Activo'::TEXT
            WHEN r.vigencia = '0' OR r.vigencia = 'I' THEN 'Inactivo'::TEXT
            ELSE 'Sin estatus'::TEXT
        END as estatus
    FROM public.reqdiftransmision r
    WHERE 1=1
       AND (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
       AND (p_ejercicio IS NULL OR p_ejercicio = 0 OR r.axoreq = p_ejercicio)
    ORDER BY r.axoreq DESC, r.foliotransm DESC
    LIMIT 100;

    RETURN;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_reqtrans_list(VARCHAR, INTEGER) IS
'Consulta de requerimientos de diferencias de transmisión.
Busca en la tabla public.reqdiftransmision.
Parámetros:
  - p_clave_cuenta: Clave de cuenta (puede ser NULL)
  - p_ejercicio: Año del ejercicio fiscal (puede ser NULL o 0)
Retorna:
  - cvereq: Clave de requerimiento
  - clave_cuenta: Clave de cuenta
  - folio: Folio de transmisión
  - ejercicio: Año del requerimiento
  - estatus: Estatus (Vigente/Cancelado/Pendiente/Activo/Inactivo)
Limitado a 100 registros por consulta.';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqtrans_list(VARCHAR, INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqtrans_list(VARCHAR, INTEGER) TO PUBLIC;
