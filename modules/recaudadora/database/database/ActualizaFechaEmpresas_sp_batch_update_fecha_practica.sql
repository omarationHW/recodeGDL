-- Stored Procedure: sp_batch_update_fecha_practica
-- Tipo: CRUD
-- Descripción: Actualiza en lote la fecha de práctica de varios folios.
-- Generado para formulario: ActualizaFechaEmpresas
-- Fecha: 2025-08-26 20:24:51

CREATE OR REPLACE PROCEDURE sp_batch_update_fecha_practica(p_folios JSONB, p_fecha_trabajo DATE)
LANGUAGE plpgsql
AS $$
DECLARE
  folio JSONB;
  cvecuenta INTEGER;
  folioreq INTEGER;
  axoreq INTEGER;
  cvereq INTEGER;
BEGIN
  FOR folio IN SELECT * FROM jsonb_array_elements(p_folios) LOOP
    cvecuenta := (folio->>'clave_cuenta_int')::INTEGER;
    folioreq := (folio->>'folio')::INTEGER;
    axoreq := (folio->>'anio_folio')::INTEGER;
    SELECT cvereq INTO cvereq FROM reqpredial WHERE cvecuenta = cvecuenta AND folioreq = folioreq AND axoreq = axoreq LIMIT 1;
    IF cvereq IS NOT NULL THEN
      UPDATE reqpredial SET fecent = p_fecha_trabajo WHERE cvereq = cvereq;
    END IF;
  END LOOP;
END;
$$;