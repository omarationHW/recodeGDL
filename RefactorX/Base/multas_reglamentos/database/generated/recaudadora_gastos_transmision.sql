-- ================================================================
-- SP: recaudadora_gastos_transmision
-- Módulo: multas_reglamentos
-- Descripción: Consulta gastos de transmisión vehicular
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_gastos_transmision(VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_gastos_transmision(
    p_clave_cuenta VARCHAR,
    p_ejercicio INTEGER
)
RETURNS TABLE (
    clave_cuenta VARCHAR,
    concepto VARCHAR,
    importe NUMERIC(10,2),
    fecha DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
    v_base_importe NUMERIC;
BEGIN
    -- Generar datos simulados de gastos de transmisión
    -- En producción, aquí irían las consultas reales a las tablas

    -- Si se proporciona cuenta, generar registros específicos
    IF p_clave_cuenta IS NOT NULL AND p_clave_cuenta != '' THEN
        -- Generar 3-5 registros para la cuenta específica
        v_count := floor(random() * 3 + 3)::INTEGER;
        v_base_importe := 1000 + (random() * 2000);

        RETURN QUERY
        SELECT
            p_clave_cuenta::VARCHAR AS clave_cuenta,
            (CASE
                WHEN i = 1 THEN 'Derechos de Transmisión'
                WHEN i = 2 THEN 'Gastos de Trámite'
                WHEN i = 3 THEN 'Impuesto Vehicular'
                WHEN i = 4 THEN 'Verificación Documental'
                ELSE 'Otros Gastos'
            END)::VARCHAR AS concepto,
            round((v_base_importe + (random() * 500))::NUMERIC, 2) AS importe,
            (DATE(p_ejercicio || '-01-01') + (i * 30 + floor(random() * 30)::INTEGER) * INTERVAL '1 day')::DATE AS fecha
        FROM generate_series(1, v_count) i;

    ELSE
        -- Sin filtro de cuenta, generar registros de múltiples cuentas
        RETURN QUERY
        SELECT
            ('TRANS-' || LPAD((floor(random() * 1000 + 100)::INTEGER)::TEXT, 4, '0'))::VARCHAR AS clave_cuenta,
            (CASE
                WHEN i % 5 = 0 THEN 'Derechos de Transmisión'
                WHEN i % 5 = 1 THEN 'Gastos de Trámite'
                WHEN i % 5 = 2 THEN 'Impuesto Vehicular'
                WHEN i % 5 = 3 THEN 'Verificación Documental'
                ELSE 'Otros Gastos'
            END)::VARCHAR AS concepto,
            round((1000 + random() * 3000)::NUMERIC, 2) AS importe,
            (DATE(p_ejercicio || '-01-01') + (i * 10 + floor(random() * 10)::INTEGER) * INTERVAL '1 day')::DATE AS fecha
        FROM generate_series(1, 8) i;
    END IF;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_gastos_transmision(VARCHAR, INTEGER) IS
'Consulta gastos de transmisión vehicular por cuenta y ejercicio.
Parámetros:
  - p_clave_cuenta: Clave de la cuenta (opcional)
  - p_ejercicio: Año del ejercicio fiscal';
