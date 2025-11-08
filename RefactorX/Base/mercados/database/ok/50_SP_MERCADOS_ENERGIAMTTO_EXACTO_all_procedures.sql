-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: EnergiaMtto
-- Generado: 2025-08-26 23:57:51
-- Total SPs: 5
-- ============================================

-- SP 1/5: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras activas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_recaudadoras() RETURNS TABLE(id integer, nombre text) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM public.ta_12_recaudadoras WHERE estado = 'A' ORDER BY id_rec;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: get_secciones
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de secciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_secciones() RETURNS TABLE(id text, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM public.ta_11_secciones ORDER BY seccion;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: get_mercados_by_oficina
-- Tipo: Catalog
-- Descripción: Devuelve los mercados de una recaudadora con energía
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_mercados_by_oficina(p_oficina integer) RETURNS TABLE(num_mercado_nvo integer, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion FROM public.ta_11_mercados WHERE oficina = p_oficina AND cuenta_energia IS NOT NULL ORDER BY num_mercado_nvo;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: buscar_local_energia_mtto
-- Tipo: CRUD
-- Descripción: Busca un local para alta de energía, verifica que no tenga energía registrada
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_local_energia_mtto(
  p_oficina integer, p_num_mercado integer, p_categoria integer, p_seccion text, p_local integer, p_letra_local text, p_bloque text, p_user integer
) RETURNS TABLE(id_local integer, oficina integer, num_mercado integer, categoria integer, seccion text, local integer, letra_local text, bloque text) AS $$
BEGIN
  RETURN QUERY
    SELECT l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque
    FROM public.ta_11_locales l
    LEFT JOIN public.ta_11_energia e ON e.id_local = l.id_local
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local IS NULL OR l.letra_local = p_letra_local)
      AND (l.bloque IS NULL OR l.bloque = p_bloque)
      AND e.id_energia IS NULL
    LIMIT 1;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: alta_energia_mtto
-- Tipo: CRUD
-- Descripción: Da de alta un registro de energía para un local, crea historial y adeudos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION alta_energia_mtto(
  p_id_local integer, p_cve_consumo text, p_descripcion text, p_cantidad numeric, p_vigencia text, p_fecha_alta date, p_axo integer, p_numero text, p_user integer, p_oficina integer, p_num_mercado integer, p_categoria integer, p_seccion text
) RETURNS TABLE(result text) AS $$
DECLARE
  v_id_energia integer;
  v_periodo integer;
  v_peralt date;
  v_cant numeric;
  v_mes integer;
  v_dia integer;
  v_alo integer;
BEGIN
  -- Insertar en ta_11_energia
  INSERT INTO public.ta_11_energia (id_local, cve_consumo, local_adicional, cantidad, vigencia, fecha_alta, fecha_baja, fecha_modificacion, id_usuario)
  VALUES (p_id_local, p_cve_consumo, p_descripcion, p_cantidad, p_vigencia, p_fecha_alta, NULL, NOW(), p_user)
  RETURNING id_energia INTO v_id_energia;

  -- Insertar en historial
  INSERT INTO public.ta_11_energia_hist (id_energia, axo, numero, cve_consumo, local_adicional, cantidad, vigencia, fecha_alta, fecha_baja, fecha_modificacion, id_usuario, tipo_mov, fecha_mov, id_usuario_mov)
  VALUES (v_id_energia, p_axo, p_numero, p_cve_consumo, p_descripcion, p_cantidad, p_vigencia, p_fecha_alta, NULL, NOW(), p_user, 'A', NOW(), p_user);

  -- Generar adeudos desde fecha de alta hasta hoy
  v_peralt := p_fecha_alta;
  WHILE v_peralt <= CURRENT_DATE LOOP
    v_alo := EXTRACT(YEAR FROM v_peralt);
    v_mes := EXTRACT(MONTH FROM v_peralt);
    v_dia := EXTRACT(DAY FROM v_peralt);
    IF v_alo <= 2002 THEN
      -- Bimestral
      IF v_mes BETWEEN 1 AND 2 THEN v_periodo := 1;
      ELSIF v_mes BETWEEN 3 AND 4 THEN v_periodo := 2;
      ELSIF v_mes BETWEEN 5 AND 6 THEN v_periodo := 3;
      ELSIF v_mes BETWEEN 7 AND 8 THEN v_periodo := 4;
      ELSIF v_mes BETWEEN 9 AND 10 THEN v_periodo := 5;
      ELSE v_periodo := 6; END IF;
      v_cant := p_cantidad * 2;
    ELSE
      v_periodo := v_mes;
      v_cant := p_cantidad;
    END IF;
    INSERT INTO public.ta_11_adeudo_energ (id_energia, axo, periodo, cve_consumo, cantidad, importe, fecha_alta, id_usuario)
    VALUES (v_id_energia, v_alo, v_periodo, p_cve_consumo, v_cant, v_cant, NOW(), p_user);
    -- Siguiente periodo
    IF v_alo <= 2002 THEN
      v_peralt := v_peralt + INTERVAL '60 days';
    ELSE
      v_peralt := v_peralt + INTERVAL '30 days';
    END IF;
  END LOOP;
  RETURN QUERY SELECT 'OK';
END; $$ LANGUAGE plpgsql;

-- ============================================

