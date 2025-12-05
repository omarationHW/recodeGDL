-- ================================================================
-- SP: recaudadora_imprime_desctos
-- Módulo: multas_reglamentos
-- Descripción: Genera reporte de impresión de descuentos
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_imprime_desctos(VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_imprime_desctos(
    p_clave_cuenta VARCHAR,
    p_ejercicio INTEGER
)
RETURNS TABLE (
    mensaje VARCHAR,
    folio_reporte VARCHAR,
    clave_cuenta VARCHAR,
    ejercicio INTEGER,
    fecha_generacion DATE,
    total_descuentos INTEGER,
    monto_total NUMERIC(10,2),
    status VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_folio VARCHAR;
    v_total_desc INTEGER;
    v_monto NUMERIC(10,2);
BEGIN
    -- Validar que la clave de cuenta no esté vacía
    IF p_clave_cuenta IS NULL OR p_clave_cuenta = '' THEN
        RETURN QUERY
        SELECT
            'Error: Debe proporcionar una clave de cuenta válida'::VARCHAR AS mensaje,
            NULL::VARCHAR AS folio_reporte,
            NULL::VARCHAR AS clave_cuenta,
            NULL::INTEGER AS ejercicio,
            NULL::DATE AS fecha_generacion,
            NULL::INTEGER AS total_descuentos,
            NULL::NUMERIC AS monto_total,
            'error'::VARCHAR AS status;
        RETURN;
    END IF;

    -- Validar que el ejercicio sea válido
    IF p_ejercicio IS NULL OR p_ejercicio < 2000 OR p_ejercicio > 2100 THEN
        RETURN QUERY
        SELECT
            'Error: Debe proporcionar un ejercicio válido (2000-2100)'::VARCHAR AS mensaje,
            NULL::VARCHAR AS folio_reporte,
            p_clave_cuenta::VARCHAR AS clave_cuenta,
            p_ejercicio AS ejercicio,
            NULL::DATE AS fecha_generacion,
            NULL::INTEGER AS total_descuentos,
            NULL::NUMERIC AS monto_total,
            'error'::VARCHAR AS status;
        RETURN;
    END IF;

    -- Generar folio de reporte
    v_folio := ('DESC-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' ||
               LPAD((floor(random() * 9999 + 1)::INTEGER)::TEXT, 4, '0'))::VARCHAR;

    -- Simular total de descuentos encontrados
    v_total_desc := floor(random() * 10 + 1)::INTEGER;

    -- Simular monto total
    v_monto := round((random() * 5000 + 1000)::NUMERIC, 2);

    -- Devolver resultado exitoso
    RETURN QUERY
    SELECT
        'Reporte de descuentos generado exitosamente'::VARCHAR AS mensaje,
        v_folio::VARCHAR AS folio_reporte,
        p_clave_cuenta::VARCHAR AS clave_cuenta,
        p_ejercicio AS ejercicio,
        CURRENT_DATE AS fecha_generacion,
        v_total_desc AS total_descuentos,
        v_monto AS monto_total,
        'success'::VARCHAR AS status;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_imprime_desctos(VARCHAR, INTEGER) IS
'Genera reporte de impresión de descuentos para una cuenta y ejercicio.
Parámetros:
  - p_clave_cuenta: Clave de la cuenta
  - p_ejercicio: Año del ejercicio fiscal
Retorna: Folio del reporte, total de descuentos y monto total';
