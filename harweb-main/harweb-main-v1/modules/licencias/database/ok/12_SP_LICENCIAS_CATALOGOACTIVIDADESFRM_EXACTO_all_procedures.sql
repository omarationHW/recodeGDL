-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CATALOGOACTIVIDADESFRM (EXACTO del archivo original)
-- Archivo: 12_SP_LICENCIAS_CATALOGOACTIVIDADESFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: catalogo_actividades_list
-- Tipo: Catalog
-- Descripción: Lista actividades filtrando por descripción (opcional, case-insensitive)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION catalogo_actividades_list(descripcion TEXT DEFAULT NULL)
RETURNS TABLE (
  id_actividad INTEGER,
  id_giro INTEGER,
  descripcion TEXT,
  observaciones TEXT,
  vigente CHAR(1),
  fecha_alta TIMESTAMP,
  usuario_alta VARCHAR(50),
  fecha_baja TIMESTAMP,
  usuario_baja VARCHAR(50),
  motivo_baja TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_actividad, id_giro, descripcion, observaciones, vigente, fecha_alta, usuario_alta, fecha_baja, usuario_baja, motivo_baja
    FROM c_actividades_lic
    WHERE (descripcion IS NULL OR unaccent(lower(descripcion)) ILIKE '%' || unaccent(lower($1)) || '%')
    ORDER BY id_actividad DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CATALOGOACTIVIDADESFRM (EXACTO del archivo original)
-- Archivo: 12_SP_LICENCIAS_CATALOGOACTIVIDADESFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: catalogo_actividades_create
-- Tipo: CRUD
-- Descripción: Crea una nueva actividad
-- --------------------------------------------

CREATE OR REPLACE FUNCTION catalogo_actividades_create(
  id_giro INTEGER,
  descripcion TEXT,
  observaciones TEXT,
  vigente CHAR(1),
  usuario_alta VARCHAR(50)
) RETURNS TABLE (id_actividad INTEGER) AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO c_actividades_lic (id_giro, descripcion, observaciones, vigente, fecha_alta, usuario_alta)
  VALUES (id_giro, descripcion, observaciones, vigente, NOW(), usuario_alta)
  RETURNING id_actividad INTO new_id;
  RETURN QUERY SELECT new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CATALOGOACTIVIDADESFRM (EXACTO del archivo original)
-- Archivo: 12_SP_LICENCIAS_CATALOGOACTIVIDADESFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: catalogo_actividades_delete
-- Tipo: CRUD
-- Descripción: Marca una actividad como cancelada (baja lógica)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION catalogo_actividades_delete(
  id INTEGER,
  usuario_baja VARCHAR(50),
  motivo_baja TEXT
) RETURNS TABLE (id_actividad INTEGER) AS $$
BEGIN
  UPDATE c_actividades_lic
  SET vigente = 'C', fecha_baja = NOW(), usuario_baja = usuario_baja, motivo_baja = motivo_baja
  WHERE id_actividad = id;
  RETURN QUERY SELECT id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CATALOGOACTIVIDADESFRM (EXACTO del archivo original)
-- Archivo: 12_SP_LICENCIAS_CATALOGOACTIVIDADESFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

