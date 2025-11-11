-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RprtEstadxfolio
-- Generado: 2025-08-27 14:32:03
-- Total SPs: 2
-- ============================================

-- SP 1/2: rpt_estadxfolio
-- Tipo: Report
-- Descripción: Reporte estadístico de notificaciones por folio, agrupando por vigencia y clave_practicado, con sumatorias.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_estadxfolio(
    p_modu integer,
    p_rec integer,
    p_fol1 integer,
    p_fol2 integer
)
RETURNS TABLE (
    vigencia varchar,
    clave_practicado varchar,
    cuantos integer,
    gastos_pago numeric(18,2),
    gastos_gasto numeric(18,2),
    adeudo numeric(18,2),
    recargos numeric(18,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        vigencia,
        clave_practicado,
        COUNT(*) AS cuantos,
        SUM(importe_pago) AS gastos_pago,
        SUM(importe_gastoS) AS gastos_gasto,
        SUM(importe_global) AS adeudo,
        SUM(importe_recargo) AS recargos
    FROM ta_15_apremios
    WHERE modulo = p_modu
      AND zona = p_rec
      AND folio BETWEEN p_fol1 AND p_fol2
    GROUP BY vigencia, clave_practicado
    ORDER BY vigencia, clave_practicado;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: rpt_recaudadora_zona
-- Tipo: Catalog
-- Descripción: Obtiene información de la recaudadora y zona asociada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_recaudadora_zona(
    p_reca integer
)
RETURNS TABLE (
    id_rec smallint,
    id_zona integer,
    recaudadora varchar,
    domicilio varchar,
    tel varchar,
    recaudador varchar,
    sector varchar,
    id_zona_1 integer,
    zona varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.id_zona AS id_zona_1, b.zona
    FROM padron_licencias.comun.ta_12_recaudadoras a
    JOIN padron_licencias.comun.ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.id_rec = p_reca;
END;
$$ LANGUAGE plpgsql;

-- ============================================

