-- Stored Procedure: sp_cob34_pagados
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados de una concesión.
-- Generado para formulario: GBaja
-- Fecha: 2025-08-27 13:58:32

CREATE OR REPLACE FUNCTION sp_cob34_pagados(p_Control INTEGER)
RETURNS TABLE (
    id_34_pagos INTEGER,
    id_datos INTEGER,
    periodo DATE,
    importe NUMERIC,
    recargo NUMERIC,
    fecha_hora_pago TIMESTAMP,
    id_recaudadora INTEGER,
    caja TEXT,
    operacion INTEGER,
    folio_recibo TEXT,
    usuario TEXT,
    id_stat INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_34_pagos, p.id_datos, p.periodo, p.importe, p.recargo, p.fecha_hora_pago, p.id_recaudadora, p.caja, p.operacion, p.folio_recibo, p.usuario, p.id_stat
    FROM t34_pagos p
    WHERE p.id_datos = p_Control AND p.id_stat IN (SELECT id_34_stat FROM t34_status WHERE cve_stat = 'P')
    ORDER BY p.periodo;
END;
$$ LANGUAGE plpgsql;