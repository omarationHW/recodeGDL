-- Stored Procedure: sp_get_pagosrcm
-- Tipo: Report
-- Descripción: Obtiene pagos y títulos para un control_rcm
-- Generado para formulario: ConIndividual
-- Fecha: 2025-08-28 17:50:28

CREATE OR REPLACE PROCEDURE sp_get_pagosrcm(IN folp integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT 'Manten' AS tipopag, *, '' AS obser
    FROM ta_13_pagosrcm WHERE control_rcm = folp
  UNION
  SELECT 'Titulo', fecha, id_rec, caja, operacion, 0, control_rcm, '', 0, '', 0, '', 0, '', tipo, titulo, importe, 0, '', 0, CURRENT_DATE, observaciones
    FROM ta_13_titulos WHERE control_rcm = folp
  ORDER BY 2 DESC;
END;
$$;