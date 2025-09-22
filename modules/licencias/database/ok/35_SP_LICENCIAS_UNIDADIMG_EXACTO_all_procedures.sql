-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: UNIDADIMG (EXACTO del archivo original)
-- Archivo: 35_SP_LICENCIAS_UNIDADIMG_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: UNIDADIMG (EXACTO del archivo original)
-- Archivo: 35_SP_LICENCIAS_UNIDADIMG_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: UNIDADIMG (EXACTO del archivo original)
-- Archivo: 35_SP_LICENCIAS_UNIDADIMG_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

