-- Versión con parámetros
CREATE OR REPLACE FUNCTION publico.recaudadora_pruebacalcas(
    p_importe_base NUMERIC,
    p_meses_mora INTEGER,
    p_porc_descuento NUMERIC
)
RETURNS TABLE (
    concepto VARCHAR,
    descripcion VARCHAR,
    valor NUMERIC,
    porcentaje NUMERIC
)
LANGUAGE plpgsql AS $$
DECLARE
    v_importe_base NUMERIC := COALESCE(p_importe_base, 1000);
    v_meses_mora INTEGER := COALESCE(p_meses_mora, 0);
    v_porc_descuento NUMERIC := COALESCE(p_porc_descuento, 0);
    v_tasa_recargo NUMERIC := 2.0; -- 2% mensual de recargo
    v_recargos NUMERIC;
    v_subtotal NUMERIC;
    v_descuento NUMERIC;
    v_total NUMERIC;
BEGIN
    -- Calcular recargos (2% mensual)
    v_recargos := ROUND(v_importe_base * (v_tasa_recargo / 100) * v_meses_mora, 2);

    -- Calcular subtotal
    v_subtotal := v_importe_base + v_recargos;

    -- Calcular descuento
    v_descuento := ROUND(v_subtotal * (v_porc_descuento / 100), 2);

    -- Calcular total
    v_total := v_subtotal - v_descuento;

    -- Retornar resultados como tabla
    RETURN QUERY
    SELECT 'IMPORTE BASE'::VARCHAR, 'Monto original de la multa o cargo'::VARCHAR, v_importe_base, 0::NUMERIC
    UNION ALL
    SELECT 'RECARGOS'::VARCHAR,
           CASE
               WHEN v_meses_mora > 0 THEN v_meses_mora || ' meses de mora al ' || v_tasa_recargo || '% mensual'
               ELSE 'Sin recargos por mora'
           END::VARCHAR,
           v_recargos,
           CASE WHEN v_meses_mora > 0 THEN v_tasa_recargo * v_meses_mora ELSE 0 END
    UNION ALL
    SELECT 'SUBTOTAL'::VARCHAR, 'Importe base + recargos'::VARCHAR, v_subtotal, 0::NUMERIC
    UNION ALL
    SELECT 'DESCUENTO'::VARCHAR,
           CASE
               WHEN v_porc_descuento > 0 THEN 'Descuento aplicado del ' || v_porc_descuento || '%'
               ELSE 'Sin descuento'
           END::VARCHAR,
           v_descuento * -1, -- Negativo para mostrar como descuento
           v_porc_descuento
    UNION ALL
    SELECT 'TOTAL A PAGAR'::VARCHAR, 'Monto final después de recargos y descuentos'::VARCHAR, v_total, 0::NUMERIC;
END; $$;

-- Versión sin parámetros (valores por defecto)
CREATE OR REPLACE FUNCTION publico.recaudadora_pruebacalcas()
RETURNS TABLE (
    concepto VARCHAR,
    descripcion VARCHAR,
    valor NUMERIC,
    porcentaje NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM publico.recaudadora_pruebacalcas(1000, 0, 0);
END; $$;
