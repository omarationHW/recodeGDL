-- =====================================================
-- Stored Procedure: recaudadora_req_promocion
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Consulta de catálogo de descuentos/promociones prediales
--              Busca descuentos por código o ejercicio fiscal
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_req_promocion(VARCHAR, INTEGER);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_req_promocion(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    cvedescuento INTEGER,
    descripcion TEXT,
    importe NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar catálogo de descuentos prediales
    -- El campo 'importe' se mapea al porcentaje de descuento
    RETURN QUERY
    SELECT
        r.cvedescuento::INTEGER,
        TRIM(r.descripcion)::TEXT,
        r.porcentaje::NUMERIC as importe
    FROM public.c_descpred r
    WHERE 1=1
       AND (p_clave_cuenta IS NULL OR CAST(r.cvedescuento AS TEXT) ILIKE '%' || p_clave_cuenta || '%')
       AND (p_ejercicio IS NULL OR r.axodescto = p_ejercicio)
    ORDER BY r.cvedescuento DESC
    LIMIT 100;

    RETURN;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_req_promocion(VARCHAR, INTEGER) IS
'Consulta de catálogo de descuentos/promociones prediales.
Busca en el catálogo de descuentos prediales (tabla public.c_descpred).
Parámetros:
  - p_clave_cuenta: Código de descuento (puede ser NULL para traer todos)
  - p_ejercicio: Año del ejercicio fiscal (puede ser NULL)
Retorna:
  - cvedescuento: Código del descuento
  - descripcion: Descripción del descuento
  - importe: Porcentaje de descuento (50 = 50%)
Limitado a 100 registros por consulta.
Tabla base: c_descpred con 1,289 tipos de descuentos.';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_req_promocion(VARCHAR, INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_req_promocion(VARCHAR, INTEGER) TO PUBLIC;
