-- Stored Procedure: sp_rep_a_cobrar
-- Tipo: Report
-- Descripción: Genera el reporte de cementerios a cobrar para una recaudadora y mes dados.
-- Generado para formulario: Rep_a_Cobrar
-- Fecha: 2025-08-27 14:47:41

-- PostgreSQL stored procedure for report
CREATE OR REPLACE FUNCTION sp_rep_a_cobrar(par_mes integer, par_id_rec integer)
RETURNS TABLE(
    ano integer,
    mantenimiento numeric,
    recargos numeric
) AS $$
BEGIN
    -- Simulación: Debe ajustarse a la lógica real de cálculo
    RETURN QUERY
    SELECT
        t.axo_cuota AS ano,
        SUM(t.cuota1 * t.metros) AS mantenimiento,
        SUM(t.cuota1 * t.metros * r.porcentaje_global / 100) AS recargos
    FROM ta_13_rcmcuotas t
    JOIN ta_13_datosrcm d ON d.cementerio = t.cementerio
    JOIN ta_12_recaudadoras rca ON rca.id_rec = par_id_rec
    JOIN ta_13_recargosrcm r ON r.axo = t.axo_cuota AND r.mes = par_mes
    WHERE d.id_rec = par_id_rec
    GROUP BY t.axo_cuota
    ORDER BY t.axo_cuota;
END;
$$ LANGUAGE plpgsql;