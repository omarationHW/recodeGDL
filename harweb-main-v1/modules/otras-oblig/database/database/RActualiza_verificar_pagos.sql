-- Stored Procedure: verificar_pagos
-- Tipo: CRUD
-- Descripción: Verifica si existen pagos realizados a partir de un periodo para un local/concesión
-- Generado para formulario: RActualiza
-- Fecha: 2025-08-28 13:26:50

CREATE OR REPLACE FUNCTION verificar_pagos(id_datos INTEGER, periodo TEXT)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = id_datos
      AND to_char(a.periodo, 'YYYY-MM') >= periodo
      AND b.cve_stat = 'P';
END;
$$ LANGUAGE plpgsql;