-- Stored Procedure: sp_get_totals_libertad
-- Tipo: Report
-- Descripción: Obtiene los totales globales de pagos y renta pagada para el Mercado Libertad en un mes/año.
-- Generado para formulario: IngresoLib
-- Fecha: 2025-08-27 00:06:35

CREATE OR REPLACE FUNCTION sp_get_totals_libertad(p_mes integer, p_anio integer, p_mercado integer)
RETURNS TABLE (
    total_pagos integer,
    total_importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(*) AS total_pagos, COALESCE(SUM(b.importe_pago),0) AS total_importe
    FROM ta_11_locales a
    JOIN ta_11_pagos_local b ON a.id_local = b.id_local
    WHERE a.num_mercado = p_mercado
      AND EXTRACT(MONTH FROM b.fecha_pago) = p_mes
      AND EXTRACT(YEAR FROM b.fecha_pago) = p_anio;
END;
$$ LANGUAGE plpgsql;