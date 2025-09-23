-- Stored Procedure: rpt_pagos_desarrollo
-- Tipo: Report
-- Descripción: Obtiene el reporte de pagos de desarrollo por fondo y año de obra en un rango de fechas.
-- Generado para formulario: RptPagosDesarrollo
-- Fecha: 2025-08-27 15:46:39

CREATE OR REPLACE FUNCTION rpt_pagos_desarrollo(fecdesde DATE, fechasta DATE)
RETURNS TABLE (
    tipo SMALLINT,
    axo_obra SMALLINT,
    ingreso NUMERIC,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.tipo,
        a.axo_obra,
        SUM(c.importe) AS ingreso,
        t.descripcion
    FROM ta_17_calles a
    JOIN ta_17_convenios b ON a.colonia = b.colonia AND a.calle = b.calle
    JOIN ta_17_pagos c ON b.id_convenio = c.id_convenio
    JOIN ta_17_tipos t ON a.tipo = t.tipo
    WHERE c.fecha_pago BETWEEN fecdesde AND fechasta
      AND (a.tipo = 11 OR a.tipo >= 15)
    GROUP BY a.tipo, a.axo_obra, t.descripcion
    ORDER BY a.tipo, a.axo_obra;
END;
$$ LANGUAGE plpgsql;