-- Stored Procedure: sp_rbaja_verificar_adeudos
-- Tipo: CRUD
-- Descripción: Verifica si existen adeudos pasados para el local/concesión antes del periodo dado.
-- Generado para formulario: RBaja
-- Fecha: 2025-08-28 13:35:33

CREATE OR REPLACE FUNCTION sp_rbaja_verificar_adeudos(p_id_34_datos INTEGER, p_periodo VARCHAR)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos
      AND a.periodo < p_periodo
      AND b.cve_stat = 'V';
END;
$$ LANGUAGE plpgsql;