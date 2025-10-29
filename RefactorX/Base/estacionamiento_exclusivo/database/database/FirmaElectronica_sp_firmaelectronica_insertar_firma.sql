-- Stored Procedure: sp_firmaelectronica_insertar_firma
-- Tipo: CRUD
-- Descripción: Inserta la firma electrónica en la tabla de apremios firmados.
-- Generado para formulario: FirmaElectronica
-- Fecha: 2025-08-27 13:50:15

CREATE OR REPLACE FUNCTION sp_firmaelectronica_insertar_firma(
  psec integer,
  pdigver varchar,
  pcvereg integer,
  pfalta date,
  pvig varchar,
  pfirmante varchar,
  pcargo varchar,
  pvalidez varchar,
  pffirma varchar,
  phash varchar
) RETURNS TABLE(
  graba integer,
  existe integer
) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM apremios_firmados WHERE secuencia = psec) THEN
    RETURN QUERY SELECT 0, 1;
  ELSE
    INSERT INTO apremios_firmados(secuencia, digverificador, id_modulo, fecha_graba, vigencia, firmante, cargo, validez, fecha_firmado, hash)
    VALUES (psec, pdigver, pcvereg, pfalta, pvig, pfirmante, pcargo, pvalidez, pffirma, phash);
    RETURN QUERY SELECT 1, 0;
  END IF;
END;
$$ LANGUAGE plpgsql;