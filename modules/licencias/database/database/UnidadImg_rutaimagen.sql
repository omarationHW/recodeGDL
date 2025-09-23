-- Stored Procedure: rutaimagen
-- Tipo: CRUD
-- Descripción: Devuelve la ruta completa de la imagen según id_tramite e id_imagen, siguiendo la lógica original.
-- Generado para formulario: UnidadImg
-- Fecha: 2025-08-27 19:49:13

CREATE OR REPLACE FUNCTION rutaimagen(id_tramite INTEGER, id_imagen INTEGER)
RETURNS TABLE(ruta TEXT) AS $$
DECLARE
  unidad VARCHAR;
  destino TEXT;
BEGIN
  SELECT valor INTO unidad FROM configuracion WHERE clave = 'UnidadImg' LIMIT 1;
  IF unidad IS NULL OR TRIM(unidad) = '' THEN
    unidad := 'N';
  END IF;
  IF id_tramite BETWEEN 1 AND 999 THEN
    destino := unidad || 'trlic00000/' || id_imagen;
  ELSIF id_tramite BETWEEN 1000 AND 9999 THEN
    destino := unidad || 'trlic0' || (id_tramite/1000)::INT || '000/' || id_imagen;
  ELSIF id_tramite BETWEEN 10000 AND 999999 THEN
    destino := unidad || 'trlic' || (id_tramite/1000)::INT || '000/' || id_imagen;
  ELSE
    destino := unidad || 'no_encontro';
  END IF;
  RETURN QUERY SELECT destino;
END;
$$ LANGUAGE plpgsql;