-- Stored Procedure: get_ruta_dir
-- Tipo: CRUD
-- Descripción: Devuelve la ruta del directorio de imágenes según id_tramite.
-- Generado para formulario: UnidadImg
-- Fecha: 2025-08-26 18:23:35

CREATE OR REPLACE FUNCTION get_ruta_dir(p_id_tramite INTEGER)
RETURNS TABLE(ruta TEXT) AS $$
DECLARE
  unidad TEXT;
  dir TEXT;
BEGIN
  SELECT valor INTO unidad FROM configuracion WHERE clave = 'UnidadImg' LIMIT 1;
  IF unidad IS NULL OR TRIM(unidad) = '' THEN
    unidad := 'N:';
  END IF;
  IF p_id_tramite BETWEEN 1 AND 999 THEN
    dir := unidad || 'trlic00000';
  ELSIF p_id_tramite BETWEEN 1000 AND 9999 THEN
    dir := unidad || 'trlic0' || (p_id_tramite / 1000)::int || '000';
  ELSIF p_id_tramite BETWEEN 10000 AND 999999 THEN
    dir := unidad || 'trlic' || (p_id_tramite / 1000)::int || '000';
  ELSE
    dir := unidad;
  END IF;
  RETURN QUERY SELECT dir;
END;
$$ LANGUAGE plpgsql;