-- Stored Procedure: sp_rbaja_verificar_adeudos_post
-- Tipo: CRUD
-- Descripción: Verifica si existen adeudos posteriores o con otro status para el local/concesión en el periodo dado o después.
-- Generado para formulario: RBaja
-- Fecha: 2025-08-28 13:35:33

CREATE OR REPLACE FUNCTION sp_rbaja_verificar_adeudos_post(p_id_34_datos INTEGER, p_periodo VARCHAR)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos
      AND a.periodo >= p_periodo
      AND b.cve_stat <> 'V';
END;
$$ LANGUAGE plpgsql;