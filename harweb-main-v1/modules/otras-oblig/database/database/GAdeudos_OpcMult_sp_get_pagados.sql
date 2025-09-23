-- Stored Procedure: sp_get_pagados
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados para un dato/concesión.
-- Generado para formulario: GAdeudos_OpcMult
-- Fecha: 2025-08-27 20:44:01

CREATE OR REPLACE FUNCTION sp_get_pagados(p_Control integer)
RETURNS TABLE(
    id_34_pagos integer,
    id_datos integer,
    periodo date,
    importe numeric,
    recargo numeric,
    fecha_hora_pago timestamp,
    id_recaudadora integer,
    caja text,
    operacion integer,
    folio_recibo text,
    usuario text,
    id_stat integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_34_pagos, p.id_datos, p.periodo, p.importe, p.recargo, p.fecha_hora_pago, p.id_recaudadora, p.caja, p.operacion, p.folio_recibo, p.usuario, p.id_stat
    FROM t34_pagos p
    WHERE p.id_datos = p_Control AND p.id_stat IN (SELECT id_34_stat FROM t34_status WHERE cve_stat = 'P')
    ORDER BY p.periodo;
END;
$$ LANGUAGE plpgsql;