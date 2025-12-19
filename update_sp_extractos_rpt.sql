-- =====================================================
-- Stored Procedure: recaudadora_extractos_rpt
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Genera extracto de cuenta para multas
--              basándose en expediente o número de acta
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_extractos_rpt(VARCHAR);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_extractos_rpt(
    p_clave_cuenta VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR,
    cuenta VARCHAR,
    clave_catastral VARCHAR,
    total_adeudo NUMERIC,
    fecha_extracto VARCHAR,
    cantidad_multas BIGINT,
    contribuyente VARCHAR,
    domicilio VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
    v_total NUMERIC;
    v_contribuyente VARCHAR;
    v_domicilio VARCHAR;
BEGIN
    -- Validar que se proporcione la cuenta
    IF p_clave_cuenta IS NULL OR p_clave_cuenta = '' THEN
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN,
            'Debe proporcionar un número de cuenta/expediente'::VARCHAR,
            ''::VARCHAR,
            ''::VARCHAR,
            0::NUMERIC,
            TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD')::VARCHAR,
            0::BIGINT,
            ''::VARCHAR,
            ''::VARCHAR;
        RETURN;
    END IF;

    -- Buscar multas por expediente, num_acta o id_multa
    SELECT
        COUNT(*),
        COALESCE(SUM(h.total), 0),
        MAX(h.contribuyente),
        MAX(h.domicilio)
    INTO
        v_count,
        v_total,
        v_contribuyente,
        v_domicilio
    FROM public.h_multasnvo h
    WHERE
        -- Buscar por expediente (quitando espacios)
        TRIM(h.expediente) = TRIM(p_clave_cuenta)
        -- O por número de acta convertido a string
        OR CAST(h.num_acta AS VARCHAR) = p_clave_cuenta
        -- O por ID de multa
        OR CAST(h.id_multa AS VARCHAR) = p_clave_cuenta
    AND h.fecha_cancelacion IS NULL; -- Solo multas no canceladas

    -- Si no se encontraron registros
    IF v_count = 0 THEN
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN,
            ('No se encontraron multas para la cuenta: ' || p_clave_cuenta)::VARCHAR,
            p_clave_cuenta::VARCHAR,
            ''::VARCHAR,
            0::NUMERIC,
            TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD')::VARCHAR,
            0::BIGINT,
            ''::VARCHAR,
            ''::VARCHAR;
        RETURN;
    END IF;

    -- Retornar el extracto encontrado
    RETURN QUERY
    SELECT
        TRUE::BOOLEAN,
        ('Se encontraron ' || v_count || ' multa(s) pendiente(s) de pago')::VARCHAR,
        p_clave_cuenta::VARCHAR,
        COALESCE(TRIM(p_clave_cuenta), 'N/A')::VARCHAR, -- Usar la cuenta como clave catastral
        v_total::NUMERIC,
        TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD')::VARCHAR,
        v_count::BIGINT,
        COALESCE(v_contribuyente, 'N/A')::VARCHAR,
        COALESCE(v_domicilio, 'N/A')::VARCHAR;

    RETURN;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_extractos_rpt(VARCHAR) IS
'Genera extracto de cuenta para multas municipales.
Busca por expediente, número de acta o ID de multa.
Parámetros:
  - p_clave_cuenta: Número de expediente, acta o ID de multa
Retorna:
  - success: Indica si se encontraron resultados
  - message: Mensaje descriptivo
  - cuenta: Cuenta consultada
  - clave_catastral: Clave catastral (mismo que cuenta)
  - total_adeudo: Total adeudado de multas pendientes
  - fecha_extracto: Fecha del extracto
  - cantidad_multas: Número de multas encontradas
  - contribuyente: Nombre del contribuyente
  - domicilio: Domicilio del contribuyente';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_extractos_rpt(VARCHAR) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_extractos_rpt(VARCHAR) TO PUBLIC;
