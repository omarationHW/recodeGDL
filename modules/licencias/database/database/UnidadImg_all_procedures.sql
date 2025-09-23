-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: UnidadImg
-- Generado: 2025-08-27 19:49:13
-- Total SPs: 4
-- ============================================

-- SP 1/4: get_unidad_img
-- Tipo: Catalog
-- Descripción: Obtiene la unidad de imágenes configurada en la tabla de configuración.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_unidad_img()
RETURNS TABLE(unidad_img VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT valor FROM configuracion WHERE clave = 'UnidadImg' LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: set_unidad_img
-- Tipo: CRUD
-- Descripción: Guarda o actualiza la unidad de imágenes en la tabla de configuración.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION set_unidad_img(p_unidad VARCHAR)
RETURNS TABLE(success BOOLEAN, msg TEXT) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM configuracion WHERE clave = 'UnidadImg') THEN
    UPDATE configuracion SET valor = TRIM(p_unidad) WHERE clave = 'UnidadImg';
    RETURN QUERY SELECT TRUE, 'Actualizado correctamente';
  ELSE
    INSERT INTO configuracion(clave, valor) VALUES ('UnidadImg', TRIM(p_unidad));
    RETURN QUERY SELECT TRUE, 'Insertado correctamente';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: rutaimagen
-- Tipo: CRUD
-- Descripción: Devuelve la ruta completa de la imagen según id_tramite e id_imagen, siguiendo la lógica original.
-- --------------------------------------------

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

-- ============================================

-- SP 4/4: rutadir
-- Tipo: CRUD
-- Descripción: Devuelve la ruta del directorio de imágenes según id_tramite.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rutadir(id_tramite INTEGER)
RETURNS TABLE(ruta TEXT) AS $$
DECLARE
  unidad VARCHAR;
  dir TEXT;
BEGIN
  SELECT valor INTO unidad FROM configuracion WHERE clave = 'UnidadImg' LIMIT 1;
  IF unidad IS NULL OR TRIM(unidad) = '' THEN
    unidad := 'N';
  END IF;
  IF id_tramite BETWEEN 1 AND 999 THEN
    dir := unidad || 'trlic00000';
  ELSIF id_tramite BETWEEN 1000 AND 9999 THEN
    dir := unidad || 'trlic0' || (id_tramite/1000)::INT || '000';
  ELSIF id_tramite BETWEEN 10000 AND 999999 THEN
    dir := unidad || 'trlic' || (id_tramite/1000)::INT || '000';
  ELSE
    dir := unidad;
  END IF;
  RETURN QUERY SELECT dir;
END;
$$ LANGUAGE plpgsql;

-- ============================================

