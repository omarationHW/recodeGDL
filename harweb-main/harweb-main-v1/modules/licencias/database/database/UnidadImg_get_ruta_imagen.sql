-- Stored Procedure: get_ruta_imagen
-- Tipo: CRUD
-- Descripción: Devuelve la ruta completa de la imagen según id_tramite e id_imagen, siguiendo la lógica de negocio.
-- Generado para formulario: UnidadImg
-- Fecha: 2025-08-26 18:23:35

CREATE OR REPLACE FUNCTION get_ruta_imagen(p_id_tramite INTEGER, p_id_imagen INTEGER)
RETURNS TABLE(ruta TEXT) AS $$
DECLARE
  unidad TEXT;
  destino TEXT;
BEGIN
  SELECT valor INTO unidad FROM configuracion WHERE clave = 'UnidadImg' LIMIT 1;
  IF unidad IS NULL OR TRIM(unidad) = '' THEN
    unidad := 'N:';
  END IF;
  IF p_id_tramite BETWEEN 1 AND 999 THEN
    destino := unidad || 'trlic00000/' || p_id_imagen;
  ELSIF p_id_tramite BETWEEN 1000 AND 9999 THEN
    destino := unidad || 'trlic0' || (p_id_tramite / 1000)::int || '000/' || p_id_imagen;
  ELSIF p_id_tramite BETWEEN 10000 AND 999999 THEN
    destino := unidad || 'trlic' || (p_id_tramite / 1000)::int || '000/' || p_id_imagen;
  ELSE
    destino := unidad || 'no_encontro';
  END IF;
  RETURN QUERY SELECT destino;
END;
$$ LANGUAGE plpgsql;