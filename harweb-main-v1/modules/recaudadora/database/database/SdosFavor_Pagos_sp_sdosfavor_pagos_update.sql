-- Stored Procedure: sp_sdosfavor_pagos_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de pago a favor.
-- Generado para formulario: SdosFavor_Pagos
-- Fecha: 2025-08-27 15:40:42

CREATE OR REPLACE FUNCTION sp_sdosfavor_pagos_update(
    p_reca VARCHAR(3),
    p_caja VARCHAR(2),
    p_folio VARCHAR(10),
    p_importe NUMERIC(12,2),
    p_fecha DATE,
    p_old_folio VARCHAR(10)
) RETURNS TABLE (
    reca VARCHAR(3),
    caja VARCHAR(2),
    folio VARCHAR(10),
    importe NUMERIC(12,2),
    fecha DATE
) AS $$
BEGIN
    UPDATE sdosfavor_pagos
       SET reca = p_reca,
           caja = p_caja,
           folio = p_folio,
           importe = p_importe,
           fecha = p_fecha
     WHERE reca = p_reca AND caja = p_caja AND folio = p_old_folio;
    RETURN QUERY SELECT reca, caja, folio, importe, fecha
      FROM sdosfavor_pagos
      WHERE reca = p_reca AND caja = p_caja AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;