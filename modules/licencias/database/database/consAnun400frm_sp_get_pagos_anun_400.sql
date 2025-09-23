-- Stored Procedure: sp_get_pagos_anun_400
-- Tipo: Report
-- Descripción: Obtiene todos los pagos asociados a un anuncio del AS/400 por número de anuncio.
-- Generado para formulario: consAnun400frm
-- Fecha: 2025-08-27 17:10:26

CREATE OR REPLACE FUNCTION sp_get_pagos_anun_400(numanu_in integer)
RETURNS SETOF pago_anun_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM pago_anun_400 WHERE numanu = numanu_in;
END;
$$ LANGUAGE plpgsql;