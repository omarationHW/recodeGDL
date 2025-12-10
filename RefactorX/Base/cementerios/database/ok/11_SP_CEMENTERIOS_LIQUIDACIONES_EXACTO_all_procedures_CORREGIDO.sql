-- =============================================
-- CEMENTERIOS - LIQUIDACIONES (CORREGIDO 2025-11-25)
-- =============================================
-- Archivo: 11_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures_CORREGIDO.sql
-- Descripción: Stored Procedure para cálculo de liquidaciones de cementerios
-- Fecha: 2025-11-25
--
-- CORRECCIÓN CRÍTICA: Implementa lógica EXACTA del Pascal con distinción año 2008
--
-- LÓGICA ORIGINAL PASCAL (Liquidaciones.pas líneas 103-183):
--   - Query 1 (líneas 126-148): Años < 2008 → cuota × METROS REALES
--   - Query 2 (líneas 149-155): Años ≥ 2008 → cuota × 1 (sin multiplicar metros)
--   - UNION ALL de ambas queries
--   - Recargos según porcentaje_global del mes actual
--   - Si CheckBNvo.Checked = true → recargos = 0
--
-- PROBLEMA DEL SP ORIGINAL:
--   - Usaba loop simple que SIEMPRE multiplicaba por metros
--   - NO implementaba la distinción año 2008
--   - NO usaba UNION de 2 queries diferentes
--
-- ESQUEMAS según postgreok.csv:
--   - ta_13_rcmcuotas → cementerio.public
--   - ta_13_recargosrcm → cementerio.public
--   - tc_13_cementerios → cementerio.public
-- =============================================

-- =============================================
-- SP: sp_liquidaciones_calcular (VERSIÓN CORREGIDA)
-- Descripción: Calcula liquidación con lógica EXACTA del Pascal (distinción 2008)
-- Parámetros:
--   - p_cementerio: Código del cementerio (SMALLINT según tc_13_cementerios)
--   - p_anio_desde: Año inicial del rango
--   - p_anio_hasta: Año final del rango
--   - p_metros: Metros cuadrados del espacio
--   - p_tipo: Tipo de espacio ('F'=Fosa, 'U'=Urna, 'G'=Gaveta, 'O'=Otros)
--   - p_nuevo: Si es nuevo (TRUE = sin recargos)
--   - p_mes: Mes actual para cálculo de recargos
-- Retorna: TABLE con axo_cuota, manten, recargos
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_liquidaciones_calcular(p_cementerio CHAR(1), p_anio_desde integer, p_anio_hasta integer, p_metros numeric, p_tipo CHAR(1), p_nuevo boolean, p_mes integer)
 RETURNS TABLE(axo_cuota integer, manten NUMERIC(16,2), recargos NUMERIC(16,2))
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_cuota_col TEXT;
    v_desde_ajustado INTEGER;
BEGIN
    -- Ajuste de año mínimo
    IF p_anio_desde >= 2008 THEN
        v_desde_ajustado := p_anio_desde;
    ELSE
        v_desde_ajustado := 2008;
    END IF;

    -- Determinar columna de cuota
    CASE p_tipo
        WHEN 'F' THEN v_cuota_col := 'cuota1';
        WHEN 'U' THEN v_cuota_col := 'cuota_urna';
        WHEN 'G' THEN v_cuota_col := 'cuota_gaveta';
        ELSE v_cuota_col := 'cuota2';
    END CASE;

    -- Ejecutar consulta dinámica
    RETURN QUERY
    EXECUTE format('
        SELECT
            c.axo_cuota::INTEGER,
            ROUND(c.%I * $1, 2)::NUMERIC(16,2) AS manten,
            CASE
                WHEN $2 = TRUE THEN 0.00::NUMERIC(16,2)
                ELSE COALESCE(
                    ROUND(
                        ROUND(c.%I * $1, 2) *
                        (SELECT r.porcentaje_global FROM cementerio.public.ta_13_recargosrcm r
                         WHERE r.axo = c.axo_cuota AND r.mes = $3) / 100,
                        2
                    ), 0.00
                )::NUMERIC(16,2)
            END AS recargos
        FROM cementerio.public.ta_13_rcmcuotas c
        WHERE c.cementerio = $4
          AND c.axo_cuota >= $5
          AND c.axo_cuota < 2008

        UNION ALL

        SELECT
            c.axo_cuota::INTEGER,
            ROUND(c.%I * 1, 2)::NUMERIC(16,2) AS manten,
            CASE
                WHEN $2 = TRUE THEN 0.00::NUMERIC(16,2)
                ELSE COALESCE(
                    ROUND(
                        ROUND(c.%I * 1, 2) *
                        (SELECT r.porcentaje_global FROM cementerio.public.ta_13_recargosrcm r
                         WHERE r.axo = c.axo_cuota AND r.mes = $3) / 100,
                        2
                    ), 0.00
                )::NUMERIC(16,2)
            END AS recargos
        FROM cementerio.public.ta_13_rcmcuotas c
        WHERE c.cementerio = $4
          AND c.axo_cuota BETWEEN $6 AND $7

        ORDER BY axo_cuota
    ', v_cuota_col, v_cuota_col, v_cuota_col, v_cuota_col)
    USING
        p_metros,
        p_nuevo,
        p_mes,
        p_cementerio,
        p_anio_desde,
        v_desde_ajustado,
        p_anio_hasta;
END;
$function$
;

COMMENT ON FUNCTION cementerio.sp_liquidaciones_calcular IS 'Calcula liquidación de cementerios con lógica exacta del Pascal: años <2008 usan metros reales, años ≥2008 usan multiplicador 1 (UNION ALL de 2 queries diferentes)';

-- =============================================
-- PERMISOS
-- =============================================
-- GRANT EXECUTE ON FUNCTION cementerio.sp_liquidaciones_calcular TO role_cementerio;

-- =============================================
-- NOTAS DE MIGRACIÓN Y CORRECCIÓN
-- =============================================
-- 1. PROBLEMA ORIGINAL: SP usaba loop simple que siempre multiplicaba por metros
-- 2. CORRECCIÓN: Implementa UNION de 2 queries diferentes como en Pascal:
--    - Query 1: años < 2008 → cuota × metros (línea 138 Pascal)
--    - Query 2: años ≥ 2008 → cuota × 1 (línea 151 Pascal)
-- 3. Checkbox "Nuevo" (Pascal CheckBNvo líneas 139-140):
--    - TRUE: recargos = 0
--    - FALSE: recargos calculados según porcentaje_global
-- 4. Ajuste año desde >= 2008 (Pascal líneas 106-109)
-- 5. Tipo de espacio mapea a columnas de cuota (Pascal líneas 127-136):
--    - F → cuota1 (Fosa)
--    - U → cuota_urna (Urna)
--    - G → cuota_gaveta (Gaveta)
--    - O → cuota2 (Otros)
-- 6. Recargos según porcentaje_global del mes actual (Pascal línea 144)
-- 7. UNION ALL mantiene orden original del Pascal (línea 149)
-- 8. ROUND con 2 decimales como en Pascal TRUNC (líneas 138, 143, 151, 153)

-- =============================================
-- EJEMPLO DE USO
-- =============================================
-- Calcular liquidación Fosa, 2.5 m², años 2005-2010, cementerio 1, mes actual 11, NO nuevo:
-- SELECT * FROM cementerio.sp_liquidaciones_calcular(1, 2005, 2010, 2.5, 'F', FALSE, 11);
--
-- Resultado esperado:
-- - Años 2005-2007: manten = cuota1 × 2.5, recargos calculados
-- - Años 2008-2010: manten = cuota1 × 1, recargos calculados
--
-- Calcular liquidación Urna, 1.0 m², año actual, cementerio 2, mes 11, NUEVO (sin recargos):
-- SELECT * FROM cementerio.sp_liquidaciones_calcular(2, 2025, 2025, 1.0, 'U', TRUE, 11);
--
-- Resultado esperado:
-- - Año 2025: manten = cuota_urna × 1, recargos = 0 (nuevo)

-- =============================================
-- FIN DE ARCHIVO
-- =============================================
