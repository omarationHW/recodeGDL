-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: EmisionLibertad
-- Generado: 2025-08-26 23:51:55
-- Total SPs: 5
-- ============================================

-- SP 1/5: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene la lista de recaudadoras activas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_recaudadoras()
RETURNS TABLE(id_rec INT, recaudadora TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM public.ta_12_recaudadoras WHERE id_rec >= 1 ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: get_mercados_by_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los mercados de una recaudadora con tipo_emision = 'D' (diskette/caja).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_mercados_by_recaudadora(p_oficina INT)
RETURNS TABLE(num_mercado_nvo INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion FROM public.ta_11_mercados WHERE oficina = p_oficina AND tipo_emision = 'D' ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: generar_emision_libertad
-- Tipo: CRUD
-- Descripción: Genera la emisión de recibos para mercados con caja de cobro, devolviendo el detalle para la vista.
-- --------------------------------------------

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
  subtotal NUMERIC;
  renta NUMERIC;
  descuento NUMERIC;
BEGIN
  SELECT ARRAY(SELECT json_array_elements_text(p_mercados)::INT) INTO mercado_ids;
  FOR rec IN
    SELECT a.*, b.descripcion as mercado_desc, c.importe_cuota, c.clave_cuota, c.seccion as cuo_seccion
    FROM public.ta_11_locales a
    JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN public.ta_11_cuo_locales c ON a.categoria = c.categoria AND a.seccion = c.seccion AND a.clave_cuota = c.clave_cuota AND c.axo = p_axo
    WHERE a.oficina = p_oficina
      AND a.num_mercado = ANY(mercado_ids)
      AND a.vigencia = 'A'
      AND a.bloqueo < 4
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque
  LOOP
    -- Calcular renta
    IF rec.seccion = 'PS' THEN
      IF rec.clave_cuota = 4 THEN
        renta := rec.superficie * rec.importe_cuota;
      ELSE
        renta := rec.importe_cuota * rec.superficie * 30;
      END IF;
    ELSE
      renta := rec.superficie * rec.importe_cuota;
    END IF;
    descuento := round(renta * 0.90, 2);
    -- Adeudos y recargos
    SELECT COALESCE(SUM(importe),0), COALESCE(SUM(recargos),0)
      INTO total_adeudos, total_recargos
      FROM public.ta_11_adeudo_local
      WHERE id_local = rec.id_local
        AND (axo < p_axo OR (axo = p_axo AND periodo < p_periodo));
    -- Multas y gastos (requerimientos)
    SELECT string_agg(folio::TEXT, ','), COALESCE(SUM(importe_multa),0), COALESCE(SUM(importe_gastos),0)
      INTO folios_req, total_multas, total_gastos
      FROM public.ta_15_apremios
      WHERE modulo = 11 AND control_otr = rec.id_local AND vigencia = '1' AND clave_practicado = 'P';
    subtotal := total_adeudos + total_recargos;
    meses := (SELECT string_agg(periodo::TEXT, ',') FROM public.ta_11_adeudo_local WHERE id_local = rec.id_local AND (axo < p_axo OR (axo = p_axo AND periodo < p_periodo)));
    RETURN NEXT (
      rec.id_local, rec.nombre, rec.mercado_desc, rec.descripcion_local, rec.oficina, rec.num_mercado, rec.categoria, rec.seccion, rec.local, rec.letra_local, rec.bloque,
      renta, descuento, total_adeudos, total_recargos, subtotal, total_multas, total_gastos, folios_req
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: exportar_emision_libertad
-- Tipo: CRUD
-- Descripción: Genera y guarda el archivo TXT de la emisión, devuelve la URL de descarga.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION exportar_emision_libertad(
  p_oficina INT,
  p_mercados JSON,
  p_axo INT,
  p_periodo INT,
  p_usuario_id INT
) RETURNS TABLE(file_url TEXT) AS $$
DECLARE
  row RECORD;
  file_path TEXT;
  file_name TEXT;
  f TEXT;
  out_txt TEXT;
  meses TEXT;
  folios_req TEXT;
  total_adeudos NUMERIC;
  total_recargos NUMERIC;
  total_multas NUMERIC;
  total_gastos NUMERIC;
  subtotal NUMERIC;
  renta NUMERIC;
  descuento NUMERIC;
  fh TEXT;
BEGIN
  file_name := 'RecibosMdo_' || p_oficina || '_' || p_axo || '-' || p_periodo || '.txt';
  file_path := '/var/www/html/exports/' || file_name;
  out_txt := '';
  FOR row IN SELECT * FROM generar_emision_libertad(p_oficina, p_mercados, p_axo, p_periodo, p_usuario_id) LOOP
    -- Formatear línea (puede mejorarse según reglas de negocio)
    out_txt := out_txt || lpad(row.id_local::TEXT,6,'0') || lpad(coalesce(row.nombre,''),30,' ') || lpad(coalesce(row.descripcion,''),30,' ') || lpad(coalesce(row.descripcion_local,''),20,' ') || lpad(row.oficina::TEXT,3,'0') || lpad(row.num_mercado::TEXT,3,'0') || lpad(row.categoria::TEXT,1,'0') || lpad(row.seccion,2,' ') || lpad(row.local::TEXT,5,'0') || lpad(coalesce(row.letra_local,''),1,' ') || lpad(coalesce(row.bloque,''),1,' ') || to_char(row.descuento,'FM000000.00') || to_char(row.adeudos,'FM000000.00') || to_char(row.renta,'FM000000.00') || to_char(row.subtotal,'FM000000.00') || to_char(row.recargos,'FM000000.00') || to_char(row.multas,'FM000000.00') || to_char(row.gastos,'FM000000.00') || coalesce(row.folios,'') || E'\n';
  END LOOP;
  -- Guardar archivo
  PERFORM pg_catalog.pg_file_write(file_path, out_txt, false);
  RETURN QUERY SELECT '/exports/' || file_name;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: get_emision_libertad_detalle
-- Tipo: Report
-- Descripción: Devuelve el detalle de la emisión para mostrar en la tabla.
-- --------------------------------------------

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

