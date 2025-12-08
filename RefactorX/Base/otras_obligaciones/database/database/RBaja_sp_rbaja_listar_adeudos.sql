-- Stored Procedure: sp_rbaja_listar_adeudos
-- Tipo: Report
-- Descripción: Lista todos los adeudos pendientes de un local/concesión
-- Generado para formulario: RBaja
-- Fecha: 2025-12-02

CREATE OR REPLACE FUNCTION sp_rbaja_listar_adeudos(p_id_34_datos INTEGER)
RETURNS TABLE (
    periodo DATE,
    importe NUMERIC,
    recargo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.periodo, a.importe, a.recargo
    FROM otrasoblig.t34_pagos a
    JOIN otrasoblig.t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos
      AND b.cve_stat = 'V'  -- Solo adeudos vigentes
    ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;
