-- Stored Procedure: get_pagados
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados para un control específico.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-27 23:39:10

CREATE OR REPLACE FUNCTION get_pagados(p_Control integer)
RETURNS SETOF t34_pagos AS $$
BEGIN
    RETURN QUERY
    SELECT a.* FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_Control AND b.cve_stat = 'P'
    ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;