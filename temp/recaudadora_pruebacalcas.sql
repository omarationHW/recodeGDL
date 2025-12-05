-- ================================================================
-- SP: recaudadora_pruebacalcas
-- Módulo: multas_reglamentos
-- Descripción: Prueba de cálculos de multas, recargos y descuentos
-- Parámetros:
--   p_importe_base: Importe base para calcular
--   p_meses_mora: Meses de mora (para recargos)
--   p_porc_descuento: Porcentaje de descuento a aplicar
-- ================================================================

DROP FUNCTION IF EXISTS public.recaudadora_pruebacalcas(NUMERIC, INTEGER, NUMERIC);

CREATE OR REPLACE FUNCTION public.recaudadora_pruebacalcas(
    p_importe_base NUMERIC DEFAULT 1000,
    p_meses_mora INTEGER DEFAULT 0,
    p_porc_descuento NUMERIC DEFAULT 0
)
RETURNS TABLE (
    concepto TEXT,
    descripcion TEXT,
    valor NUMERIC,
    porcentaje NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_recargo_mensual NUMERIC := 2.0;  -- 2% mensual
    v_recargo_total NUMERIC;
    v_descuento NUMERIC;
    v_subtotal NUMERIC;
    v_total NUMERIC;
BEGIN
    -- Validar parámetros
    IF p_importe_base IS NULL OR p_importe_base <= 0 THEN
        p_importe_base := 1000;
    END IF;

    IF p_meses_mora IS NULL OR p_meses_mora < 0 THEN
        p_meses_mora := 0;
    END IF;

    IF p_porc_descuento IS NULL OR p_porc_descuento < 0 THEN
        p_porc_descuento := 0;
    END IF;

    IF p_porc_descuento > 100 THEN
        p_porc_descuento := 100;
    END IF;

    -- Calcular recargos por mora
    v_recargo_total := p_importe_base * (v_recargo_mensual / 100) * p_meses_mora;

    -- Calcular subtotal
    v_subtotal := p_importe_base + v_recargo_total;

    -- Calcular descuento
    v_descuento := v_subtotal * (p_porc_descuento / 100);

    -- Calcular total
    v_total := v_subtotal - v_descuento;

    -- Retornar resultados
    RETURN QUERY
    SELECT
        '1. IMPORTE BASE'::TEXT,
        'Importe original de la multa o pago'::TEXT,
        p_importe_base,
        CAST(0 AS NUMERIC);

    RETURN QUERY
    SELECT
        '2. RECARGOS POR MORA'::TEXT,
        'Recargo del ' || v_recargo_mensual::TEXT || '% mensual x ' || p_meses_mora::TEXT || ' meses'::TEXT,
        v_recargo_total,
        v_recargo_mensual * p_meses_mora;

    RETURN QUERY
    SELECT
        '3. SUBTOTAL'::TEXT,
        'Importe base + Recargos'::TEXT,
        v_subtotal,
        CAST(0 AS NUMERIC);

    RETURN QUERY
    SELECT
        '4. DESCUENTO'::TEXT,
        'Descuento del ' || p_porc_descuento::TEXT || '%'::TEXT,
        v_descuento,
        p_porc_descuento;

    RETURN QUERY
    SELECT
        '5. TOTAL A PAGAR'::TEXT,
        'Importe final después de recargos y descuentos'::TEXT,
        v_total,
        CAST(0 AS NUMERIC);

END;
$$;

COMMENT ON FUNCTION public.recaudadora_pruebacalcas(NUMERIC, INTEGER, NUMERIC) IS 'Prueba de cálculos de multas, recargos y descuentos';
