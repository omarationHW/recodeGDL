-- Stored Procedure: sp_sdosfavor_pagos_list
-- Tipo: Catalog
-- Descripción: Lista todos los pagos a favor.
-- Generado para formulario: SdosFavor_Pagos
-- Fecha: 2025-08-27 15:40:42

CREATE OR REPLACE FUNCTION sp_sdosfavor_pagos_list()
RETURNS TABLE (
    reca VARCHAR(3),
    caja VARCHAR(2),
    folio VARCHAR(10),
    importe NUMERIC(12,2),
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY SELECT reca, caja, folio, importe, fecha FROM sdosfavor_pagos ORDER BY fecha DESC, reca, caja, folio;
END;
$$ LANGUAGE plpgsql;