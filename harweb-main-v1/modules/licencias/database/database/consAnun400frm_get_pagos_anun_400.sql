-- Stored Procedure: get_pagos_anun_400
-- Tipo: Report
-- Descripción: Obtiene todos los pagos asociados a un anuncio del AS/400 por número de anuncio.
-- Generado para formulario: consAnun400frm
-- Fecha: 2025-08-26 15:32:34

CREATE OR REPLACE FUNCTION get_pagos_anun_400(numanu_in integer)
RETURNS SETOF pago_anun_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM pago_anun_400 WHERE numanu = numanu_in;
END;
$$ LANGUAGE plpgsql;