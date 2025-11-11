-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: EstadxFolio
-- Generado: 2025-08-27 13:45:25
-- Total SPs: 2
-- ============================================

-- SP 1/2: estadxfolio_stats
-- Tipo: Report
-- Descripción: Obtiene estadísticas agrupadas por vigencia y clave_practicado para un rango de folios, módulo y recaudadora.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION estadxfolio_stats(
    p_modulo integer,
    p_rec integer,
    p_fol1 integer,
    p_fol2 integer
)
RETURNS TABLE (
    vigencia text,
    clave_practicado text,
    cuantos integer,
    gastos_pago numeric,
    gastos_gasto numeric,
    adeudo numeric,
    recargos numeric,
    vigencia_str text,
    pract_str text
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        vigencia,
        clave_practicado,
        COUNT(*) AS cuantos,
        SUM(importe_pago) AS gastos_pago,
        SUM(importe_gastos) AS gastos_gasto,
        SUM(importe_global) AS adeudo,
        SUM(importe_recargo) AS recargos,
        CASE
            WHEN vigencia = '1' THEN 'VIGENTE'
            WHEN vigencia = '3' THEN 'CANCELADO'
            ELSE 'PAGADO'
        END AS vigencia_str,
        CASE
            WHEN clave_practicado = 'P' THEN 'PRACTICADO'
            WHEN clave_practicado = 'N' THEN 'NO LOCALIZADO'
            WHEN clave_practicado = 'C' THEN 'CITADO'
            ELSE 'SIN MOVIMIENTO'
        END AS pract_str
    FROM ta_15_apremios
    WHERE modulo = p_modulo
      AND zona = p_rec
      AND folio BETWEEN p_fol1 AND p_fol2
    GROUP BY vigencia, clave_practicado
    ORDER BY vigencia, clave_practicado;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: estadxfolio_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION estadxfolio_recaudadoras()
RETURNS TABLE (
    id_rec integer,
    recaudadora text
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_rec, recaudadora FROM padron_licencias.comun.ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

