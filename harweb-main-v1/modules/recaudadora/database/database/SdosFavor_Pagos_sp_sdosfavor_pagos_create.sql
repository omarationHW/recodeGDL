-- Stored Procedure: sp_sdosfavor_pagos_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de pago a favor.
-- Generado para formulario: SdosFavor_Pagos
-- Fecha: 2025-08-27 15:40:42

CREATE OR REPLACE FUNCTION sp_sdosfavor_pagos_create(
    p_reca VARCHAR(3),
    p_caja VARCHAR(2),
    p_folio VARCHAR(10),
    p_importe NUMERIC(12,2),
    p_fecha DATE
) RETURNS TABLE (
    reca VARCHAR(3),
    caja VARCHAR(2),
    folio VARCHAR(10),
    importe NUMERIC(12,2),
    fecha DATE
) AS $$
BEGIN
    INSERT INTO sdosfavor_pagos (reca, caja, folio, importe, fecha)
    VALUES (p_reca, p_caja, p_folio, p_importe, p_fecha);
    RETURN QUERY SELECT reca, caja, folio, importe, fecha
      FROM sdosfavor_pagos
      WHERE reca = p_reca AND caja = p_caja AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;