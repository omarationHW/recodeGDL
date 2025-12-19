-- =====================================================
-- Stored Procedure: recaudadora_reqctascanfrm
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Consulta de cuentas canceladas (requerimiento)
--              Busca multas canceladas por cuenta
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_reqctascanfrm(VARCHAR);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_reqctascanfrm(
    p_clave_cuenta VARCHAR
)
RETURNS TABLE (
    id_multa INTEGER,
    num_acta INTEGER,
    expediente VARCHAR,
    fecha_acta DATE,
    fecha_cancelacion DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    dependencia INTEGER,
    nombre_dependencia VARCHAR,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    observacion TEXT,
    user_baja VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar que se proporcione la cuenta
    IF p_clave_cuenta IS NULL OR p_clave_cuenta = '' THEN
        RAISE EXCEPTION 'Debe proporcionar la clave de cuenta';
    END IF;

    -- Retornar multas canceladas por cuenta
    RETURN QUERY
    SELECT
        h.id_multa::INTEGER,
        h.num_acta::INTEGER,
        TRIM(h.expediente)::VARCHAR as expediente,
        h.fecha_acta::DATE,
        h.fecha_cancelacion::DATE,
        h.contribuyente::VARCHAR,
        h.domicilio::VARCHAR,
        h.id_dependencia::INTEGER as dependencia,
        CASE h.id_dependencia
            WHEN 1 THEN 'Dependencia 1 - Predial'
            WHEN 3 THEN 'Dependencia 3 - Tránsito'
            WHEN 5 THEN 'Dependencia 5 - Obras'
            WHEN 7 THEN 'Dependencia 7 - Reglamentos'
            WHEN 12 THEN 'Dependencia 12 - Licencias'
            WHEN 35 THEN 'Dependencia 35 - Vía Pública'
            ELSE 'Dependencia ' || h.id_dependencia::VARCHAR
        END::VARCHAR as nombre_dependencia,
        h.multa::NUMERIC,
        h.gastos::NUMERIC,
        h.total::NUMERIC,
        h.observacion::TEXT,
        h.user_baja::VARCHAR
    FROM public.h_multasnvo h
    WHERE h.fecha_cancelacion IS NOT NULL  -- Solo multas canceladas
    AND (
        -- Buscar por expediente
        TRIM(h.expediente) = TRIM(p_clave_cuenta)
        -- O por número de acta
        OR CAST(h.num_acta AS VARCHAR) = p_clave_cuenta
        -- O por ID de multa
        OR CAST(h.id_multa AS VARCHAR) = p_clave_cuenta
    )
    ORDER BY h.fecha_cancelacion DESC, h.id_multa DESC;

    RETURN;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_reqctascanfrm(VARCHAR) IS
'Consulta de cuentas canceladas (requerimiento).
Busca multas canceladas asociadas a una cuenta específica.
Parámetros:
  - p_clave_cuenta: Clave de cuenta (expediente, número de acta o ID de multa)
Retorna:
  - id_multa: ID de la multa
  - num_acta: Número de acta
  - expediente: Número de expediente
  - fecha_acta: Fecha del acta
  - fecha_cancelacion: Fecha de cancelación
  - contribuyente: Nombre del contribuyente
  - domicilio: Domicilio
  - dependencia: ID de la dependencia
  - nombre_dependencia: Nombre descriptivo de la dependencia
  - multa: Monto de la multa
  - gastos: Gastos de ejecución
  - total: Total (multa + gastos)
  - observacion: Observaciones
  - user_baja: Usuario que dio de baja';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqctascanfrm(VARCHAR) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqctascanfrm(VARCHAR) TO PUBLIC;
