-- Actualización del Stored Procedure para pagosmultfrm.vue
-- Usa la tabla existente: public.pagos_400

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_pagosmultfrm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_pagosmultfrm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para pagosmultfrm
CREATE OR REPLACE FUNCTION publico.recaudadora_pagosmultfrm(
    p_cuenta VARCHAR DEFAULT '',
    p_anio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    id_pago INTEGER,
    cuenta INTEGER,
    anio SMALLINT,
    mes SMALLINT,
    dia SMALLINT,
    oficina SMALLINT,
    cajero VARCHAR,
    operacion INTEGER,
    tipo_operacion VARCHAR,
    secuencia SMALLINT,
    recaudacion SMALLINT,
    importe NUMERIC,
    fecha_pago DATE
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        ROW_NUMBER() OVER (ORDER BY p.axopag DESC, p.mespag DESC, p.diapag DESC)::INTEGER AS id_pago,
        p.cuenta,
        p.axopag AS anio,
        p.mespag AS mes,
        p.diapag AS dia,
        p.ofnpag AS oficina,
        TRIM(COALESCE(p.cajpag, ''))::VARCHAR AS cajero,
        p.opepag AS operacion,
        CASE
            WHEN TRIM(p.tpopag) = 'M' THEN 'Manual'
            WHEN TRIM(p.tpopag) = 'A' THEN 'Automático'
            ELSE 'Desconocido'
        END::VARCHAR AS tipo_operacion,
        p.secpag AS secuencia,
        p.recaud AS recaudacion,
        COALESCE(p.impto, 0)::NUMERIC AS importe,
        -- Construir fecha a partir de año, mes y día
        CASE
            WHEN p.axopag > 0 AND p.mespag BETWEEN 1 AND 12 AND p.diapag BETWEEN 1 AND 31 THEN
                MAKE_DATE(
                    CASE
                        WHEN p.axopag < 100 THEN 1900 + p.axopag
                        ELSE p.axopag
                    END,
                    p.mespag,
                    LEAST(p.diapag, 28)  -- Limitar día a 28 para evitar fechas inválidas
                )
            ELSE NULL
        END AS fecha_pago
    FROM public.pagos_400 p
    WHERE
        (p_cuenta = '' OR p_cuenta IS NULL OR p.cuenta::TEXT ILIKE '%' || p_cuenta || '%')
        AND (p_anio IS NULL OR p.axopag = p_anio OR (p.axopag < 100 AND p.axopag = p_anio - 1900))
    ORDER BY p.axopag DESC, p.mespag DESC, p.diapag DESC, p.opepag DESC
    LIMIT 100;

END;
$$;

-- Comentarios sobre el mapeo:
-- public.pagos_400 -> Tabla de pagos del impuesto predial 400
--
-- Mapeo de campos:
-- id_pago → ROW_NUMBER (generado)
-- cuenta → cuenta (número de cuenta predial)
-- anio → axopag (año de pago, formato corto: 90=1990)
-- mes → mespag (mes de pago 1-12)
-- dia → diapag (día de pago 1-31)
-- oficina → ofnpag (oficina de pago)
-- cajero → cajpag (cajero que procesó)
-- operacion → opepag (número de operación)
-- tipo_operacion → tpopag (M=Manual, A=Automático)
-- secuencia → secpag (secuencia)
-- recaudacion → recaud (código de recaudación)
-- importe → impto (importe del pago)
-- fecha_pago → derivado de axopag+mespag+diapag
--
-- BÚSQUEDA:
-- El filtro p_cuenta busca en:
-- - cuenta (número de cuenta predial)
--
-- El filtro p_anio busca en:
-- - axopag (año de pago, maneja formato corto: 90=1990)
--
-- IMPORTANTE:
-- - Búsqueda con ILIKE (case-insensitive)
-- - Límite de 100 registros por consulta
-- - Ordenamiento: año, mes, día descendente (más recientes primero)
-- - Años en formato corto: 90=1990, 95=1995, etc.
-- - fecha_pago se construye a partir de año+mes+día
-- - tipo_operacion: M=Manual, A=Automático
-- - Día limitado a 28 en MAKE_DATE para evitar fechas inválidas
--
-- ESTADÍSTICAS:
-- Total pagos: 6,403,164
-- Años: principalmente formato corto (90-99 = 1990-1999)
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_pagosmultfrm('', NULL);  -- Últimos 100 pagos
-- SELECT * FROM publico.recaudadora_pagosmultfrm('19748', NULL);  -- Buscar por cuenta
-- SELECT * FROM publico.recaudadora_pagosmultfrm('', 1990);  -- Buscar por año
-- SELECT * FROM publico.recaudadora_pagosmultfrm('19748', 1990);  -- Ambos filtros
