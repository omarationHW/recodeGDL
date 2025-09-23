-- Stored Procedure: rpt_estadxfolio
-- Tipo: Report
-- Descripción: Reporte estadístico de notificaciones por folio, agrupando por vigencia y clave_practicado, con sumatorias.
-- Generado para formulario: RprtEstadxfolio
-- Fecha: 2025-08-27 14:32:03

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