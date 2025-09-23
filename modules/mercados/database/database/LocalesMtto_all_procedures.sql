-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: LocalesMtto
-- Generado: 2025-08-27 00:12:40
-- Total SPs: 7
-- ============================================

-- SP 1/7: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de recaudadoras
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_recaudadoras() RETURNS TABLE(id_rec integer, recaudadora text) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: get_secciones
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de secciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_secciones() RETURNS TABLE(seccion text, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: get_zonas
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de zonas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_zonas() RETURNS TABLE(id_zona integer, zona text) AS $$
BEGIN
  RETURN QUERY SELECT id_zona, zona FROM ta_12_zonas ORDER BY id_zona;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: get_cuotas
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de claves de cuota
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_cuotas() RETURNS TABLE(clave_cuota integer, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota ORDER BY clave_cuota;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: buscar_local
-- Tipo: CRUD
-- Descripción: Busca si existe un local con los datos dados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_local(
  oficina integer, num_mercado integer, categoria integer, seccion text, local integer, letra_local text, bloque text
) RETURNS SETOF ta_11_locales AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM ta_11_locales
    WHERE oficina = buscar_local.oficina
      AND num_mercado = buscar_local.num_mercado
      AND categoria = buscar_local.categoria
      AND seccion = buscar_local.seccion
      AND local = buscar_local.local
      AND (letra_local = buscar_local.letra_local OR (buscar_local.letra_local IS NULL AND letra_local IS NULL))
      AND (bloque = buscar_local.bloque OR (buscar_local.bloque IS NULL AND bloque IS NULL));
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: alta_local
-- Tipo: CRUD
-- Descripción: Da de alta un nuevo local, inserta en ta_11_locales, ta_11_movimientos y genera adeudos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION alta_local(
  oficina integer, num_mercado integer, categoria integer, seccion text, local integer, letra_local text, bloque text,
  nombre text, domicilio text, sector text, zona integer, descripcion_local text, superficie numeric, giro integer,
  fecha_alta date, clave_cuota integer, id_usuario integer, vigencia text, numero_memo integer, axo integer
) RETURNS TABLE(id_local integer) AS $$
DECLARE
  new_id_local integer;
  peralt date;
  periodoalt text;
  m text;
  d text;
  aloalt integer;
  mesalt integer;
  diaalt integer;
  renta numeric;
BEGIN
  -- Insertar en ta_11_locales
  INSERT INTO ta_11_locales (
    oficina, num_mercado, categoria, seccion, local, letra_local, bloque, id_contribuy_prop, id_contribuy_renta,
    nombre, arrendatario, domicilio, sector, zona, descripcion_local, superficie, giro, fecha_alta, fecha_baja,
    fecha_modificacion, vigencia, id_usuario, clave_cuota, bloqueo
  ) VALUES (
    oficina, num_mercado, categoria, seccion, local, letra_local, bloque, 1, NULL,
    nombre, NULL, domicilio, sector, zona, descripcion_local, superficie, giro, fecha_alta, NULL,
    NOW(), vigencia, id_usuario, clave_cuota, 0
  ) RETURNING id_local INTO new_id_local;

  -- Insertar en ta_11_movimientos
  INSERT INTO ta_11_movimientos (
    id_local, axo_memo, numero_memo, nombre, arrendatario, domicilio, sector, zona, drescripcion_local, superficie,
    giro, fecha_alta, fecha_baja, vigencia, clave_cuota, tipo_movimiento, fecha, id_usuario, bloqueo
  ) VALUES (
    new_id_local, axo, numero_memo, nombre, NULL, domicilio, sector, zona, descripcion_local, superficie,
    giro, fecha_alta, NULL, vigencia, clave_cuota, 1, NOW(), id_usuario, 0
  );

  -- Generar adeudos desde fecha_alta hasta fecha actual
  peralt := fecha_alta;
  LOOP
    aloalt := EXTRACT(YEAR FROM peralt)::integer;
    mesalt := EXTRACT(MONTH FROM peralt)::integer;
    diaalt := EXTRACT(DAY FROM peralt)::integer;
    -- Obtener renta
    SELECT importe_cuota INTO renta FROM ta_11_cuo_locales
      WHERE axo = aloalt AND categoria = categoria AND seccion = seccion AND clave_cuota = clave_cuota LIMIT 1;
    IF renta IS NULL THEN
      renta := 0;
    END IF;
    -- Insertar adeudo
    INSERT INTO ta_11_adeudo_local (id_local, axo, periodo, importe, fecha_alta, id_usuario)
      VALUES (new_id_local, aloalt, mesalt, superficie * renta, NOW(), id_usuario);
    -- Siguiente mes
    peralt := peralt + INTERVAL '1 month';
    IF peralt > NOW()::date THEN
      EXIT;
    END IF;
  END LOOP;
  RETURN QUERY SELECT new_id_local;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: get_locales
-- Tipo: CRUD
-- Descripción: Obtiene locales filtrados por parámetros
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_locales(
  oficina integer, num_mercado integer, categoria integer, seccion text, local integer, letra_local text, bloque text
) RETURNS SETOF ta_11_locales AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM ta_11_locales
    WHERE oficina = get_locales.oficina
      AND num_mercado = get_locales.num_mercado
      AND categoria = get_locales.categoria
      AND seccion = get_locales.seccion
      AND local = get_locales.local
      AND (letra_local = get_locales.letra_local OR (get_locales.letra_local IS NULL AND letra_local IS NULL))
      AND (bloque = get_locales.bloque OR (get_locales.bloque IS NULL AND bloque IS NULL));
END; $$ LANGUAGE plpgsql;

-- ============================================

