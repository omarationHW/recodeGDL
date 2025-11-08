-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ModuloBD
-- Generado: 2025-08-27 20:46:50
-- Total SPs: 12
-- ============================================

-- SP 1/12: sp_get_categorias
-- Tipo: Catalog
-- Descripción: Obtiene todas las categorías
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_categorias()
RETURNS TABLE(categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria ORDER BY categoria;
END; $$;

-- ============================================

-- SP 2/12: sp_add_categoria
-- Tipo: CRUD
-- Descripción: Agrega una nueva categoría
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_categoria(_descripcion varchar)
RETURNS TABLE(categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
DECLARE
  new_id integer;
BEGIN
  SELECT COALESCE(MAX(categoria),0)+1 INTO new_id FROM ta_11_categoria;
  INSERT INTO ta_11_categoria (categoria, descripcion) VALUES (new_id, UPPER(_descripcion));
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria WHERE categoria = new_id;
END; $$;

-- ============================================

-- SP 3/12: sp_update_categoria
-- Tipo: CRUD
-- Descripción: Actualiza una categoría existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_categoria(_categoria integer, _descripcion varchar)
RETURNS TABLE(categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_categoria SET descripcion = UPPER(_descripcion) WHERE categoria = _categoria;
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria WHERE categoria = _categoria;
END; $$;

-- ============================================

-- SP 4/12: sp_get_secciones
-- Tipo: Catalog
-- Descripción: Obtiene todas las secciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_secciones()
RETURNS TABLE(seccion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion;
END; $$;

-- ============================================

-- SP 5/12: sp_add_seccion
-- Tipo: CRUD
-- Descripción: Agrega una nueva sección
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_seccion(_seccion varchar, _descripcion varchar)
RETURNS TABLE(seccion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_secciones (seccion, descripcion) VALUES (UPPER(_seccion), UPPER(_descripcion));
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones WHERE seccion = UPPER(_seccion);
END; $$;

-- ============================================

-- SP 6/12: sp_update_seccion
-- Tipo: CRUD
-- Descripción: Actualiza una sección existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_seccion(_seccion varchar, _descripcion varchar)
RETURNS TABLE(seccion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_secciones SET descripcion = UPPER(_descripcion) WHERE seccion = UPPER(_seccion);
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones WHERE seccion = UPPER(_seccion);
END; $$;

-- ============================================

-- SP 7/12: sp_get_cve_cuotas
-- Tipo: Catalog
-- Descripción: Obtiene todas las claves de cuota
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cve_cuotas()
RETURNS TABLE(clave_cuota integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota ORDER BY clave_cuota;
END; $$;

-- ============================================

-- SP 8/12: sp_add_cve_cuota
-- Tipo: CRUD
-- Descripción: Agrega una nueva clave de cuota
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_cve_cuota(_clave integer, _descripcion varchar)
RETURNS TABLE(clave_cuota integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_cve_cuota (clave_cuota, descripcion) VALUES (_clave, UPPER(_descripcion));
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota WHERE clave_cuota = _clave;
END; $$;

-- ============================================

-- SP 9/12: sp_update_cve_cuota
-- Tipo: CRUD
-- Descripción: Actualiza una clave de cuota existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_cve_cuota(_clave integer, _descripcion varchar)
RETURNS TABLE(clave_cuota integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_cve_cuota SET descripcion = UPPER(_descripcion) WHERE clave_cuota = _clave;
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota WHERE clave_cuota = _clave;
END; $$;

-- ============================================

-- SP 10/12: sp_get_mercados
-- Tipo: Catalog
-- Descripción: Obtiene todos los mercados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercados()
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar, cuenta_ingreso integer, cuenta_energia integer, id_zona integer, tipo_emision varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision FROM ta_11_mercados ORDER BY oficina, num_mercado_nvo;
END; $$;

-- ============================================

-- SP 11/12: sp_add_mercado
-- Tipo: CRUD
-- Descripción: Agrega un nuevo mercado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_mercado(_oficina integer, _num_mercado_nvo integer, _categoria integer, _descripcion varchar, _cuenta_ingreso integer, _cuenta_energia integer, _zona integer, _tipo_emision varchar)
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_mercados (oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision)
  VALUES (_oficina, _num_mercado_nvo, _categoria, UPPER(_descripcion), _cuenta_ingreso, _cuenta_energia, _zona, _tipo_emision);
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion FROM ta_11_mercados WHERE oficina = _oficina AND num_mercado_nvo = _num_mercado_nvo;
END; $$;

-- ============================================

-- SP 12/12: sp_update_mercado
-- Tipo: CRUD
-- Descripción: Actualiza un mercado existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_mercado(_oficina integer, _num_mercado_nvo integer, _categoria integer, _descripcion varchar, _cuenta_ingreso integer, _cuenta_energia integer, _zona integer, _tipo_emision varchar)
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_mercados SET categoria=_categoria, descripcion=UPPER(_descripcion), cuenta_ingreso=_cuenta_ingreso, cuenta_energia=_cuenta_energia, id_zona=_zona, tipo_emision=_tipo_emision
  WHERE oficina=_oficina AND num_mercado_nvo=_num_mercado_nvo;
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion FROM ta_11_mercados WHERE oficina=_oficina AND num_mercado_nvo=_num_mercado_nvo;
END; $$;

-- ============================================

