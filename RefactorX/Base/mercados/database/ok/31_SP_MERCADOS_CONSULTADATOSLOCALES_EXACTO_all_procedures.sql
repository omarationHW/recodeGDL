-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsultaDatosLocales
-- Generado: 2025-08-26 23:26:39
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(id_rec smallint, recaudadora text) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM public.ta_12_recaudadoras ORDER BY id_rec;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_get_secciones
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de secciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_secciones()
RETURNS TABLE(seccion text) AS $$
BEGIN
  RETURN QUERY SELECT seccion FROM public.ta_11_secciones ORDER BY seccion;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_get_mercados_por_oficina
-- Tipo: Catalog
-- Descripción: Devuelve los mercados de una oficina
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercados_por_oficina(p_oficina smallint)
RETURNS TABLE(num_mercado_nvo smallint, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion FROM public.ta_11_mercados WHERE oficina = p_oficina ORDER BY num_mercado_nvo;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_buscar_locales
-- Tipo: CRUD
-- Descripción: Busca locales por filtros (oficina, mercado, etc)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_locales(
  p_oficina smallint,
  p_num_mercado smallint,
  p_categoria smallint,
  p_seccion text,
  p_local integer,
  p_letra_local text,
  p_bloque text,
  p_orden text
)
RETURNS TABLE(
  id_local integer,
  oficina smallint,
  num_mercado smallint,
  categoria smallint,
  seccion text,
  local integer,
  letra_local text,
  bloque text,
  nombre text
) AS $$
BEGIN
  RETURN QUERY EXECUTE format('
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre
    FROM public.ta_11_locales
    WHERE ($1::smallint IS NULL OR oficina = $1)
      AND ($2::smallint IS NULL OR num_mercado = $2)
      AND ($3::smallint IS NULL OR categoria = $3)
      AND ($4::text IS NULL OR seccion = $4)
      AND ($5::integer IS NULL OR local = $5)
      AND ($6::text IS NULL OR (letra_local = $6 OR ($6 = '''' AND letra_local IS NULL)))
      AND ($7::text IS NULL OR (bloque = $7 OR ($7 = '''' AND bloque IS NULL)))
    ORDER BY ' || coalesce(p_orden, 'oficina,num_mercado,categoria,seccion,local,letra_local,bloque')
  )
  USING p_oficina, p_num_mercado, p_categoria, p_seccion, p_local, p_letra_local, p_bloque;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_buscar_locales_nombre
-- Tipo: CRUD
-- Descripción: Busca locales por nombre (LIKE, mayúsculas)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_locales_nombre(p_nombre text)
RETURNS TABLE(
  id_local integer,
  oficina smallint,
  num_mercado smallint,
  categoria smallint,
  seccion text,
  local integer,
  letra_local text,
  bloque text,
  nombre text
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre
    FROM public.ta_11_locales
    WHERE upper(nombre) LIKE upper(p_nombre) || '%'
    ORDER BY nombre ASC;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_get_local_individual
-- Tipo: CRUD
-- Descripción: Devuelve todos los datos de un local individual
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_local_individual(p_id_local integer)
RETURNS TABLE(
  id_local integer,
  oficina smallint,
  num_mercado smallint,
  categoria smallint,
  seccion text,
  local integer,
  letra_local text,
  bloque text,
  nombre text,
  arrendatario text,
  domicilio text,
  sector text,
  zona smallint,
  descripcion_local text,
  superficie float,
  giro smallint,
  fecha_alta date,
  fecha_baja date,
  fecha_modificacion timestamp,
  vigencia text,
  id_usuario integer,
  clave_cuota smallint
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, arrendatario, domicilio, sector, zona, descripcion_local, superficie, giro, fecha_alta, fecha_baja, fecha_modificacion, vigencia, id_usuario, clave_cuota
    FROM public.ta_11_locales
    WHERE id_local = p_id_local;
END; $$ LANGUAGE plpgsql;

-- ============================================

