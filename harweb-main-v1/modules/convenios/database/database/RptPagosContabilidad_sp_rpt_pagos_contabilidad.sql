-- Stored Procedure: sp_rpt_pagos_contabilidad
-- Tipo: Report
-- Descripción: Reporte de pagos de contabilidad agrupado por tipo, año de obra y cuenta de ingreso, con descripción del fondo.
-- Generado para formulario: RptPagosContabilidad
-- Fecha: 2025-08-27 15:44:23

CREATE OR REPLACE FUNCTION sp_rpt_pagos_contabilidad(p_fecdesde DATE, p_fechasta DATE)
RETURNS TABLE (
    tipo SMALLINT,
    axo_obra SMALLINT,
    cuenta_ingreso INTEGER,
    ingreso NUMERIC(18,2),
    descripcion VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.tipo,
        c.axo_obra,
        c.cuenta_ingreso,
        SUM(p.importe) AS ingreso,
        t.descripcion
    FROM ta_17_calles c
    JOIN ta_17_convenios v ON c.colonia = v.colonia AND c.calle = v.calle
    JOIN ta_17_pagos p ON v.id_convenio = p.id_convenio
    JOIN ta_17_tipos t ON c.tipo = t.tipo
    WHERE p.fecha_pago BETWEEN p_fecdesde AND p_fechasta
      AND c.tipo >= 15
    GROUP BY c.tipo, c.axo_obra, c.cuenta_ingreso, t.descripcion
    ORDER BY c.tipo, c.axo_obra, c.cuenta_ingreso;
END;
$$ LANGUAGE plpgsql;