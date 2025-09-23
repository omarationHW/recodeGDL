-- Stored Procedure: sp_con34_gfact_02
-- Tipo: Report
-- Descripción: Obtiene la facturación general filtrada por tabla, tipo de adeudo, recargos, año y mes.
-- Generado para formulario: GFacturacion
-- Fecha: 2025-08-28 13:15:04

CREATE OR REPLACE FUNCTION sp_con34_gfact_02(
    par_Tab VARCHAR,
    par_Ade VARCHAR,
    Par_Rcgo VARCHAR,
    par_Axo INTEGER,
    par_Mes INTEGER
)
RETURNS TABLE(
    control VARCHAR,
    concesionario VARCHAR,
    superficie NUMERIC,
    tipo VARCHAR,
    licencia INTEGER,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.control,
        d.concesionario,
        d.superficie,
        u.descripcion AS tipo,
        d.licencia,
        SUM(a.importe) AS importe
    FROM t34_datos d
    JOIN t34_unidades u ON d.cve_tab = u.cve_tab
    JOIN t34_adeudos a ON d.id_34_datos = a.id_datos
    WHERE d.cve_tab = par_Tab
      AND (
        (par_Ade = 'A' AND a.status IN ('ADEUDO', 'PAGADO')) OR
        (par_Ade = 'B' AND a.status = 'ADEUDO') OR
        (par_Ade = 'C' AND a.status = 'PAGADO')
      )
      AND (
        (Par_Rcgo = 'S' AND a.recargo > 0) OR
        (Par_Rcgo = 'N')
      )
      AND a.axo = par_Axo
      AND a.mes = par_Mes
    GROUP BY d.control, d.concesionario, d.superficie, u.descripcion, d.licencia;
END;
$$ LANGUAGE plpgsql;