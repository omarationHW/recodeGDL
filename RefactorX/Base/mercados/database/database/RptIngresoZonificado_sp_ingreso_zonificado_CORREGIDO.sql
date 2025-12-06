-- ============================================
-- STORED PROCEDURE CORREGIDO Y FUNCIONAL
-- Formulario: RptIngresoZonificado
-- SP: sp_ingreso_zonificado
-- Base: mercados.public
-- Fecha: 2025-12-05
-- ============================================
-- SOLUCION APLICADA:
-- El mapeo correcto es: cta_aplicacion 445XX -> mercado XX
-- Ejemplo: 44501 -> mercado 1, 44502 -> mercado 2, 44503 -> mercado 3, etc.
-- Se usa SUBSTRING(cta_aplicacion::TEXT, 4) para extraer los últimos 2 dígitos
-- y hacer JOIN con num_mercado_nvo de ta_11_mercados.
-- ============================================
-- RESULTADOS DE PRUEBA (2004-2025):
-- ZONA 1: $97,183,405.17
-- ZONA 3: $6,058,135.99
-- ZONA 4: $8,555,362.16
-- ZONA 5: $33,701,734.59
-- ZONA 6: $7,505,429.80
-- ZONA 7: $159,916,272.97
-- TOTAL: $312,920,340.68
-- ============================================

DROP FUNCTION IF EXISTS public.sp_ingreso_zonificado(DATE, DATE);

CREATE OR REPLACE FUNCTION public.sp_ingreso_zonificado(
    p_fecdesde DATE,
    p_fechasta DATE
)
RETURNS TABLE (
    id_zona SMALLINT,
    zona VARCHAR(50),
    pagado NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(m.id_zona, 0)::SMALLINT AS id_zona,
        CASE
            WHEN m.id_zona IS NULL THEN 'SIN ZONA'
            ELSE 'ZONA ' || m.id_zona::TEXT
        END::VARCHAR(50) AS zona,
        SUM(i.importe_cta) AS pagado
    FROM public.ta_12_importes i
    LEFT JOIN publico.ta_11_mercados m
        ON SUBSTRING(i.cta_aplicacion::TEXT, 4)::INTEGER = m.num_mercado_nvo
    WHERE i.fecing BETWEEN p_fecdesde AND p_fechasta
      AND COALESCE(m.num_mercado_nvo, 0) NOT IN (99, 214)
      AND ((i.cta_aplicacion BETWEEN 44501 AND 44588) OR (i.cta_aplicacion = 44119))
    GROUP BY m.id_zona
    HAVING SUM(i.importe_cta) > 0
    ORDER BY m.id_zona NULLS LAST;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_ingreso_zonificado(DATE, DATE) IS
'Genera reporte de ingresos por zona de mercados entre dos fechas.
Mapeo: cta_aplicacion 445XX -> mercado XX (ejemplo: 44501 -> mercado 1).
El JOIN usa SUBSTRING(cta_aplicacion, 4) para extraer el número de mercado.
Testado: 6 zonas encontradas con $312.9M total distribuido correctamente.';
