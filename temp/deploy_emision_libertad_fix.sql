-- ============================================
-- FIX: STORED PROCEDURES EmisionLibertad
-- Corregido: Referencias de public.ta_* a comun.ta_*
-- ============================================

-- SP 1/5: sp_get_recaudadoras (para padron_licencias)
-- Nota: Este SP debe estar en la base padron_licencias según el componente Vue
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_get_recaudadoras();
CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(id_rec INT, recaudadora TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora::TEXT FROM comun.ta_12_recaudadoras WHERE id_rec >= 1 ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_mercados_by_recaudadora (para padron_licencias)
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(INT);
CREATE OR REPLACE FUNCTION sp_get_mercados_by_recaudadora(p_oficina INT)
RETURNS TABLE(num_mercado_nvo INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT num_mercado_nvo, descripcion::TEXT
    FROM comun.ta_11_mercados
    WHERE oficina = p_oficina AND tipo_emision = 'D'
    ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: generar_emision_libertad (para mercados según el componente Vue)
-- --------------------------------------------

DROP FUNCTION IF EXISTS generar_emision_libertad(INT, JSON, INT, INT, INT);
CREATE OR REPLACE FUNCTION generar_emision_libertad(
  p_oficina INT,
  p_mercados JSON,
  p_axo INT,
  p_periodo INT,
  p_usuario_id INT
) RETURNS TABLE(
  id_local INT,
  nombre TEXT,
  descripcion TEXT,
  descripcion_local TEXT,
  oficina INT,
  num_mercado INT,
  categoria INT,
  seccion TEXT,
  local INT,
  letra_local TEXT,
  bloque TEXT,
  renta NUMERIC,
  descuento NUMERIC,
  adeudos NUMERIC,
  recargos NUMERIC,
  subtotal NUMERIC,
  multas NUMERIC,
  gastos NUMERIC,
  folios TEXT
) AS $$
DECLARE
  mercado_ids INT[];
  rec RECORD;
  meses TEXT;
  folios_req TEXT;
  total_adeudos NUMERIC;
  total_recargos NUMERIC;
  total_multas NUMERIC;
  total_gastos NUMERIC;
  v_subtotal NUMERIC;
  v_renta NUMERIC;
  v_descuento NUMERIC;
BEGIN
  -- Convertir JSON array a array de enteros
  SELECT ARRAY(SELECT json_array_elements_text(p_mercados)::INT) INTO mercado_ids;

  -- Recorrer locales
  FOR rec IN
    SELECT
      a.*,
      b.descripcion as mercado_desc,
      c.importe_cuota,
      c.clave_cuota,
      c.seccion as cuo_seccion
    FROM comun.ta_11_locales a
    JOIN comun.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN comun.ta_11_cuo_locales c ON a.categoria = c.categoria
      AND a.seccion = c.seccion
      AND a.clave_cuota = c.clave_cuota
      AND c.axo = p_axo
    WHERE a.oficina = p_oficina
      AND a.num_mercado = ANY(mercado_ids)
      AND a.vigencia = 'A'
      AND a.bloqueo < 4
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque
  LOOP
    -- Calcular renta
    IF rec.seccion = 'PS' THEN
      IF rec.clave_cuota = 4 THEN
        v_renta := rec.superficie * rec.importe_cuota;
      ELSE
        v_renta := rec.importe_cuota * rec.superficie * 30;
      END IF;
    ELSE
      v_renta := rec.superficie * rec.importe_cuota;
    END IF;

    v_descuento := round(v_renta * 0.90, 2);

    -- Adeudos y recargos
    SELECT
      COALESCE(SUM(importe),0),
      COALESCE(SUM(recargos),0)
    INTO total_adeudos, total_recargos
    FROM comun.ta_11_adeudo_local
    WHERE id_local = rec.id_local
      AND (axo < p_axo OR (axo = p_axo AND periodo < p_periodo));

    -- Multas y gastos (requerimientos)
    SELECT
      string_agg(folio::TEXT, ','),
      COALESCE(SUM(importe_multa),0),
      COALESCE(SUM(importe_gastos),0)
    INTO folios_req, total_multas, total_gastos
    FROM comun.ta_15_apremios
    WHERE modulo = 11
      AND control_otr = rec.id_local
      AND vigencia = '1'
      AND clave_practicado = 'P';

    v_subtotal := total_adeudos + total_recargos;

    -- Obtener meses de adeudos
    SELECT string_agg(periodo::TEXT, ',')
    INTO meses
    FROM comun.ta_11_adeudo_local
    WHERE id_local = rec.id_local
      AND (axo < p_axo OR (axo = p_axo AND periodo < p_periodo));

    -- Retornar fila
    RETURN QUERY SELECT
      rec.id_local,
      rec.nombre::TEXT,
      rec.mercado_desc::TEXT,
      rec.descripcion_local::TEXT,
      rec.oficina,
      rec.num_mercado,
      rec.categoria,
      rec.seccion::TEXT,
      rec.local,
      rec.letra_local::TEXT,
      rec.bloque::TEXT,
      v_renta,
      v_descuento,
      total_adeudos,
      total_recargos,
      v_subtotal,
      total_multas,
      total_gastos,
      folios_req;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: exportar_emision_libertad
-- --------------------------------------------

DROP FUNCTION IF EXISTS exportar_emision_libertad(INT, JSON, INT, INT, INT);
CREATE OR REPLACE FUNCTION exportar_emision_libertad(
  p_oficina INT,
  p_mercados JSON,
  p_axo INT,
  p_periodo INT,
  p_usuario_id INT
) RETURNS TABLE(file_url TEXT) AS $$
DECLARE
  row RECORD;
  file_name TEXT;
  out_txt TEXT;
BEGIN
  file_name := 'RecibosMdo_' || p_oficina || '_' || p_axo || '-' || p_periodo || '.txt';
  out_txt := '';

  FOR row IN
    SELECT * FROM generar_emision_libertad(p_oficina, p_mercados, p_axo, p_periodo, p_usuario_id)
  LOOP
    -- Formatear línea (pipe-delimited para exportación)
    out_txt := out_txt ||
      row.id_local || '|' ||
      COALESCE(row.nombre, '') || '|' ||
      COALESCE(row.descripcion, '') || '|' ||
      row.renta || '|' ||
      row.descuento || '|' ||
      row.adeudos || '|' ||
      row.recargos || '|' ||
      row.subtotal || '|' ||
      row.multas || '|' ||
      row.gastos || '|' ||
      COALESCE(row.folios, '') || E'\n';
  END LOOP;

  -- Nota: pg_file_write requiere permisos especiales, por ahora solo retornamos el contenido
  RETURN QUERY SELECT out_txt;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: get_emision_libertad_detalle
-- --------------------------------------------

DROP FUNCTION IF EXISTS get_emision_libertad_detalle(INT, JSON, INT, INT);
CREATE OR REPLACE FUNCTION get_emision_libertad_detalle(
  p_oficina INT,
  p_mercados JSON,
  p_axo INT,
  p_periodo INT
) RETURNS TABLE(
  id_local INT,
  nombre TEXT,
  descripcion TEXT,
  descripcion_local TEXT,
  oficina INT,
  num_mercado INT,
  categoria INT,
  seccion TEXT,
  local INT,
  letra_local TEXT,
  bloque TEXT,
  renta NUMERIC,
  descuento NUMERIC,
  adeudos NUMERIC,
  recargos NUMERIC,
  subtotal NUMERIC,
  multas NUMERIC,
  gastos NUMERIC,
  folios TEXT
) AS $$
BEGIN
  RETURN QUERY SELECT * FROM generar_emision_libertad(p_oficina, p_mercados, p_axo, p_periodo, 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
