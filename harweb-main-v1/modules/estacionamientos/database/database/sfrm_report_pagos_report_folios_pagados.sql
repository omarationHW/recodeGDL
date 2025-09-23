-- Stored Procedure: report_folios_pagados
-- Tipo: Report
-- Descripción: Devuelve los folios pagados en recaudadora para una fecha y recaudadora específica.
-- Generado para formulario: sfrm_report_pagos
-- Fecha: 2025-08-27 14:28:30

CREATE OR REPLACE FUNCTION report_folios_pagados(p_reca integer, p_fechora date)
RETURNS TABLE (
    reca smallint,
    caja varchar(10),
    operacion integer,
    axo smallint,
    folio integer,
    placa varchar(10),
    fecha_folio date,
    estado smallint,
    infraccion smallint,
    tarifa numeric(12,2),
    codigo_movto smallint
) AS $$
BEGIN
    IF p_reca <> 9 THEN
        RETURN QUERY
        SELECT rp.reca, rp.caja, rp.operacion, a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa, a.codigo_movto
        FROM ta14_refrecibo rp
        JOIN ta14_folios_histo a ON rp.control = a.control
        JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        WHERE rp.reca = p_reca AND rp.fecha_recibo = p_fechora
        ORDER BY 1,2,3,5,4;
    ELSE
        RETURN QUERY
        SELECT rp.reca, rp.caja, rp.operacion, a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa, a.codigo_movto
        FROM ta14_refrecibo rp
        JOIN ta14_folios_histo a ON rp.control = a.control
        JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        WHERE rp.fecha_recibo = p_fechora
        ORDER BY 1,2,3,5,4;
    END IF;
END;
$$ LANGUAGE plpgsql;