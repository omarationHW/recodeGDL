-- Stored Procedure: sp_sdosfavor_pagos_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de pago a favor.
-- Generado para formulario: SdosFavor_Pagos
-- Fecha: 2025-08-27 15:40:42

CREATE OR REPLACE FUNCTION sp_sdosfavor_pagos_delete(
    p_reca VARCHAR(3),
    p_caja VARCHAR(2),
    p_folio VARCHAR(10)
) RETURNS TABLE (
    reca VARCHAR(3),
    caja VARCHAR(2),
    folio VARCHAR(10),
    importe NUMERIC(12,2),
    fecha DATE
) AS $$
DECLARE
    v_row sdosfavor_pagos%ROWTYPE;
BEGIN
    SELECT * INTO v_row FROM sdosfavor_pagos WHERE reca = p_reca AND caja = p_caja AND folio = p_folio;
    DELETE FROM sdosfavor_pagos WHERE reca = p_reca AND caja = p_caja AND folio = p_folio;
    RETURN QUERY SELECT v_row.reca, v_row.caja, v_row.folio, v_row.importe, v_row.fecha;
END;
$$ LANGUAGE plpgsql;