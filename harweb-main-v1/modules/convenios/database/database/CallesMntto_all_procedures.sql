-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CallesMntto
-- Generado: 2025-08-27 13:59:54
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_get_colonias
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de colonias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_colonias() RETURNS TABLE(colonia smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT colonia, descripcion FROM ta_17_colonias ORDER BY colonia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_get_tipos
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de tipos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipos() RETURNS TABLE(tipo smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_get_servicios
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de servicios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_servicios() RETURNS TABLE(servicio smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT servicio, descripcion FROM ta_17_servicios ORDER BY servicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_get_cuentas
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de cuentas de aplicación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cuentas() RETURNS TABLE(cta_aplicacion integer, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT cta_aplicacion, descripcion FROM cg_12_cuentas;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_get_calle
-- Tipo: Catalog
-- Descripción: Obtiene una o varias calles por colonia y calle
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_calle(p_colonia smallint, p_calle smallint)
RETURNS TABLE(
  colonia smallint,
  calle smallint,
  tipo smallint,
  servicio smallint,
  desc_calle varchar,
  axo_obra smallint,
  cuenta_ingreso integer,
  vigencia_obra varchar,
  id_usuario integer,
  fecha_actual timestamp,
  plazo smallint,
  clave_plazo varchar,
  cuenta_rezago integer
) AS $$
BEGIN
  RETURN QUERY
    SELECT colonia, calle, tipo, servicio, desc_calle, axo_obra, cuenta_ingreso, vigencia_obra, id_usuario, fecha_actual, plazo, clave_plazo, cuenta_rezago
    FROM ta_17_calles
    WHERE colonia = p_colonia AND calle = p_calle;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_insert_calle
-- Tipo: CRUD
-- Descripción: Inserta una nueva calle en el catálogo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_calle(
  p_colonia smallint,
  p_calle smallint,
  p_tipo smallint,
  p_servicio smallint,
  p_desc_calle varchar,
  p_axo_obra smallint,
  p_cuenta_ingreso integer,
  p_vigencia_obra varchar,
  p_id_usuario integer,
  p_plazo smallint,
  p_clave_plazo varchar,
  p_cuenta_rezago integer
) RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  INSERT INTO ta_17_calles (
    colonia, calle, tipo, servicio, desc_calle, axo_obra, cuenta_ingreso, vigencia_obra, id_usuario, fecha_actual, plazo, clave_plazo, cuenta_rezago
  ) VALUES (
    p_colonia, p_calle, p_tipo, p_servicio, p_desc_calle, p_axo_obra, p_cuenta_ingreso, p_vigencia_obra, p_id_usuario, CURRENT_TIMESTAMP, p_plazo, p_clave_plazo, p_cuenta_rezago
  );
  RETURN QUERY SELECT true, 'Calle insertada correctamente';
EXCEPTION WHEN OTHERS THEN
  RETURN QUERY SELECT false, 'Error al insertar la calle: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_update_calle
-- Tipo: CRUD
-- Descripción: Actualiza una calle existente en el catálogo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_calle(
  p_colonia smallint,
  p_calle smallint,
  p_tipo smallint,
  p_servicio smallint,
  p_desc_calle varchar,
  p_axo_obra smallint,
  p_cuenta_ingreso integer,
  p_vigencia_obra varchar,
  p_id_usuario integer,
  p_plazo smallint,
  p_clave_plazo varchar,
  p_cuenta_rezago integer
) RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  UPDATE ta_17_calles SET
    tipo = p_tipo,
    servicio = p_servicio,
    desc_calle = p_desc_calle,
    axo_obra = p_axo_obra,
    cuenta_ingreso = p_cuenta_ingreso,
    vigencia_obra = p_vigencia_obra,
    id_usuario = p_id_usuario,
    fecha_actual = CURRENT_TIMESTAMP,
    plazo = p_plazo,
    clave_plazo = p_clave_plazo,
    cuenta_rezago = p_cuenta_rezago
  WHERE colonia = p_colonia AND calle = p_calle;
  IF FOUND THEN
    RETURN QUERY SELECT true, 'Calle actualizada correctamente';
  ELSE
    RETURN QUERY SELECT false, 'No se encontró la calle para actualizar';
  END IF;
EXCEPTION WHEN OTHERS THEN
  RETURN QUERY SELECT false, 'Error al actualizar la calle: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

