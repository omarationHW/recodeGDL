-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CatalogoActividadesFrm
-- Generado: 2025-08-27 16:45:56
-- Total SPs: 6
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

-- SP 2/6: catalogo_actividades_get
-- Tipo: Catalog
-- Descripción: Obtiene una actividad por ID
-- --------------------------------------------

CREATE OR REPLACE FUNCTION catalogo_actividades_get(id INTEGER)
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
    WHERE id_actividad = $1;
END;
$$ LANGUAGE plpgsql;

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

-- SP 4/6: catalogo_actividades_update
-- Tipo: CRUD
-- Descripción: Actualiza una actividad existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION catalogo_actividades_update(
  id INTEGER,
  id_giro INTEGER,
  descripcion TEXT,
  observaciones TEXT,
  vigente CHAR(1),
  usuario_mod VARCHAR(50)
) RETURNS TABLE (id_actividad INTEGER) AS $$
BEGIN
  UPDATE c_actividades_lic
  SET id_giro = id_giro,
      descripcion = descripcion,
      observaciones = observaciones,
      vigente = vigente,
      fecha_alta = CASE WHEN vigente = 'V' THEN NOW() ELSE fecha_alta END,
      usuario_alta = CASE WHEN vigente = 'V' THEN usuario_mod ELSE usuario_alta END,
      fecha_baja = CASE WHEN vigente = 'C' THEN NOW() ELSE NULL END,
      usuario_baja = CASE WHEN vigente = 'C' THEN usuario_mod ELSE NULL END
  WHERE id_actividad = id;
  RETURN QUERY SELECT id;
END;
$$ LANGUAGE plpgsql;

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

-- SP 6/6: catalogo_giros_list
-- Tipo: Catalog
-- Descripción: Lista todos los giros vigentes para selección
-- --------------------------------------------

CREATE OR REPLACE FUNCTION catalogo_giros_list()
RETURNS TABLE (
  id_giro INTEGER,
  descripcion TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_giro, descripcion FROM c_giros WHERE vigente = 'V' AND id_giro > 500 ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

