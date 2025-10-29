-- Stored Procedure: buscar_pago
-- Tipo: CRUD
-- Descripción: Busca un pago en la tabla pagos según recaud, folio, caja, fecha e importe.
-- Generado para formulario: trasladosfrm
-- Fecha: 2025-08-27 15:54:53

CREATE OR REPLACE FUNCTION buscar_pago(
    recaud TEXT,
    folio TEXT,
    caja TEXT,
    fecha DATE,
    importe NUMERIC
) RETURNS TABLE(
    id BIGINT,
    cuenta TEXT,
    folio TEXT,
    anio INT,
    importe NUMERIC,
    caja TEXT,
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cuenta, folio, anio, importe, caja, fecha
    FROM pagos
    WHERE recaud = recaud
      AND folio = folio
      AND caja = caja
      AND fecha = fecha
      AND importe = importe;
END;
$$ LANGUAGE plpgsql;