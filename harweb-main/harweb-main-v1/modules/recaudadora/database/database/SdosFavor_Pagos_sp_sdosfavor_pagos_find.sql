-- Stored Procedure: sp_sdosfavor_pagos_find
-- Tipo: Catalog
-- Descripción: Busca un pago a favor por clave primaria (igual que read, pero para compatibilidad).
-- Generado para formulario: SdosFavor_Pagos
-- Fecha: 2025-08-27 15:40:42

CREATE OR REPLACE FUNCTION sp_sdosfavor_pagos_find(
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
BEGIN
    RETURN QUERY SELECT reca, caja, folio, importe, fecha
      FROM sdosfavor_pagos
      WHERE reca = p_reca AND caja = p_caja AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;