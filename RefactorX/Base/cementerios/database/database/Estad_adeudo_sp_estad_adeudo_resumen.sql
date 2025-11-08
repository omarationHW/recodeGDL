-- Stored Procedure: sp_estad_adeudo_resumen
-- Tipo: Report
-- Descripción: Devuelve el resumen de adeudos por cementerio y año (UAP, cuenta).
-- Generado para formulario: Estad_adeudo
-- Fecha: 2025-08-27 14:32:35

CREATE OR REPLACE FUNCTION sp_estad_adeudo_resumen()
RETURNS TABLE(
    cementerio VARCHAR,
    uap INTEGER,
    cuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT cementerio, (axo_pagado-5) AS uap, COUNT(*) AS cuenta
    FROM ta_13_datosrcm
    GROUP BY cementerio, (axo_pagado-5)
    ORDER BY cementerio, uap;
END;
$$ LANGUAGE plpgsql;