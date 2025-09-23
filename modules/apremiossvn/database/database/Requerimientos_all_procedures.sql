-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Requerimientos
-- Generado: 2025-08-27 14:28:57
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_get_mercados
-- Tipo: Catalog
-- Descripción: Obtiene la lista de mercados disponibles para el usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercados(p_user_id INT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_mercado, descripcion FROM mercados WHERE user_id = p_user_id OR p_user_id = 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_get_secciones
-- Tipo: Catalog
-- Descripción: Obtiene la lista de secciones de mercados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_secciones()
RETURNS TABLE(seccion TEXT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM secciones;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_get_tipos_aseo
-- Tipo: Catalog
-- Descripción: Obtiene los tipos de aseo disponibles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipos_aseo()
RETURNS TABLE(ctrol_aseo INT, tipo_aseo TEXT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion FROM tipos_aseo ORDER BY ctrol_aseo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_buscar_mercados_adeudos
-- Tipo: Report
-- Descripción: Busca adeudos de mercados según filtros.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_mercados_adeudos(
  p_oficina INT,
  p_num_mercado_desde INT,
  p_num_mercado_hasta INT,
  p_local_desde INT,
  p_local_hasta INT,
  p_seccion TEXT,
  p_filtro_tipo TEXT,
  p_filtro_valor TEXT,
  p_adeudo_desde NUMERIC,
  p_adeudo_hasta NUMERIC,
  p_user_id INT
) RETURNS TABLE(
  id INT,
  descripcion TEXT,
  adeudo NUMERIC,
  periodo TEXT,
  importe NUMERIC,
  recargos NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT m.id_mercado, m.descripcion, SUM(a.importe) AS adeudo, '2024-1' AS periodo, SUM(a.importe) AS importe, SUM(a.recargos) AS recargos
  FROM mercados m
  JOIN adeudos a ON a.id_mercado = m.id_mercado
  WHERE m.oficina = p_oficina
    AND m.num_mercado BETWEEN p_num_mercado_desde AND p_num_mercado_hasta
    AND a.local BETWEEN p_local_desde AND p_local_hasta
    AND (p_seccion IS NULL OR m.seccion = p_seccion)
    AND (a.importe BETWEEN p_adeudo_desde AND p_adeudo_hasta)
  GROUP BY m.id_mercado, m.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_buscar_aseo_adeudos
-- Tipo: Report
-- Descripción: Busca adeudos de aseo según filtros.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_aseo_adeudos(
  p_tipo_aseo TEXT,
  p_contrato_desde INT,
  p_contrato_hasta INT,
  p_filtro_tipo TEXT,
  p_filtro_valor TEXT,
  p_adeudo_desde NUMERIC,
  p_adeudo_hasta NUMERIC,
  p_user_id INT
) RETURNS TABLE(
  id INT,
  tipo_aseo TEXT,
  num_contrato INT,
  adeudo NUMERIC,
  periodo TEXT,
  importe NUMERIC,
  recargos NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.id_contrato, c.tipo_aseo, c.num_contrato, SUM(a.importe) AS adeudo, '2024-1' AS periodo, SUM(a.importe) AS importe, SUM(a.recargos) AS recargos
  FROM contratos_aseo c
  JOIN adeudos_aseo a ON a.id_contrato = c.id_contrato
  WHERE c.tipo_aseo = p_tipo_aseo
    AND c.num_contrato BETWEEN p_contrato_desde AND p_contrato_hasta
    AND (a.importe BETWEEN p_adeudo_desde AND p_adeudo_hasta)
  GROUP BY c.id_contrato, c.tipo_aseo, c.num_contrato;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_emitir_requerimientos_mercado
-- Tipo: CRUD
-- Descripción: Emite requerimientos para mercados seleccionados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_emitir_requerimientos_mercado(
  p_oficina INT,
  p_num_mercado_desde INT,
  p_num_mercado_hasta INT,
  p_local_desde INT,
  p_local_hasta INT,
  p_seccion TEXT,
  p_filtro_tipo TEXT,
  p_filtro_valor TEXT,
  p_adeudo_desde NUMERIC,
  p_adeudo_hasta NUMERIC,
  p_user_id INT
) RETURNS TABLE(
  folio INT,
  id_mercado INT,
  resultado TEXT
) AS $$
DECLARE
  r RECORD;
  v_folio INT;
BEGIN
  FOR r IN SELECT id_mercado FROM mercados WHERE oficina = p_oficina AND num_mercado BETWEEN p_num_mercado_desde AND p_num_mercado_hasta LOOP
    v_folio := nextval('seq_folio_requerimiento');
    INSERT INTO requerimientos (folio, id_mercado, user_id, fecha_emision)
    VALUES (v_folio, r.id_mercado, p_user_id, now());
    RETURN NEXT (v_folio, r.id_mercado, 'OK');
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_emitir_requerimientos_aseo
-- Tipo: CRUD
-- Descripción: Emite requerimientos para aseo seleccionados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_emitir_requerimientos_aseo(
  p_tipo_aseo TEXT,
  p_contrato_desde INT,
  p_contrato_hasta INT,
  p_filtro_tipo TEXT,
  p_filtro_valor TEXT,
  p_adeudo_desde NUMERIC,
  p_adeudo_hasta NUMERIC,
  p_user_id INT
) RETURNS TABLE(
  folio INT,
  id_contrato INT,
  resultado TEXT
) AS $$
DECLARE
  r RECORD;
  v_folio INT;
BEGIN
  FOR r IN SELECT id_contrato FROM contratos_aseo WHERE tipo_aseo = p_tipo_aseo AND num_contrato BETWEEN p_contrato_desde AND p_contrato_hasta LOOP
    v_folio := nextval('seq_folio_requerimiento');
    INSERT INTO requerimientos_aseo (folio, id_contrato, user_id, fecha_emision)
    VALUES (v_folio, r.id_contrato, p_user_id, now());
    RETURN NEXT (v_folio, r.id_contrato, 'OK');
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

