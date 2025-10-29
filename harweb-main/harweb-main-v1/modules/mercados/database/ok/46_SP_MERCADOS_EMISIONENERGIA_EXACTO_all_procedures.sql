-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: EmisionEnergia
-- Generado: 2025-08-26 23:50:10
-- Total SPs: 5
-- ============================================

-- SP 1/5: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve la lista de recaudadoras activas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_recaudadoras() RETURNS TABLE(id_rec INT, recaudadora TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM public.ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: get_mercados_by_recaudadora
-- Tipo: Catalog
-- Descripción: Devuelve los mercados asociados a una public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_mercados_by_recaudadora(p_oficina INT) RETURNS TABLE(num_mercado_nvo INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion FROM public.ta_11_mercados WHERE oficina = p_oficina ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: get_emision_energia
-- Tipo: Report
-- Descripción: Obtiene la emisión de energía para una recaudadora, mercado, año y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_emision_energia(p_oficina INT, p_mercado INT, p_axo INT, p_periodo INT)
RETURNS TABLE(
  id_local INT,
  oficina INT,
  num_mercado INT,
  categoria INT,
  seccion TEXT,
  local INT,
  letra_local TEXT,
  bloque TEXT,
  nombre TEXT,
  descripcion TEXT,
  cuenta_energia INT,
  local_adicional TEXT,
  axo INT,
  periodo INT,
  importe NUMERIC,
  id_energia INT,
  cve_consumo TEXT,
  cantidad NUMERIC,
  importe_energia NUMERIC
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
           a.nombre, b.descripcion, b.cuenta_energia, d.local_adicional, c.axo, c.periodo, c.importe,
           d.id_energia, d.cve_consumo, d.cantidad,
           (d.cantidad * c.importe) AS importe_energia
    FROM public.ta_11_locales a
    JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN public.ta_11_kilowhatts c ON c.axo = p_axo AND c.periodo = p_periodo
    JOIN public.ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND a.vigencia = 'A'
      AND d.vigencia = 'E'
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: grabar_emision_energia
-- Tipo: CRUD
-- Descripción: Graba la emisión de energía para un mercado y periodo, evitando duplicados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION grabar_emision_energia(p_oficina INT, p_mercado INT, p_axo INT, p_periodo INT, p_usuario INT)
RETURNS TABLE(status TEXT, message TEXT) AS $$
DECLARE
  v_count INT;
  v_id_energia INT;
  v_cve_consumo TEXT;
  v_cantidad NUMERIC;
  v_importe NUMERIC;
  v_row RECORD;
BEGIN
  SELECT COUNT(*) INTO v_count
    FROM public.ta_11_adeudo_energ a
    JOIN public.ta_11_locales b ON a.id_energia = b.id_local
    WHERE a.axo = p_axo AND a.periodo = p_periodo AND b.oficina = p_oficina AND b.num_mercado = p_mercado;
  IF v_count > 0 THEN
    RETURN QUERY SELECT 'error', 'La Emisión de Energía Eléctrica ya está grabada, NO puedes volver a grabar';
    RETURN;
  END IF;
  FOR v_row IN
    SELECT d.id_energia, d.cve_consumo, d.cantidad, c.importe
    FROM public.ta_11_locales a
    JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN public.ta_11_kilowhatts c ON c.axo = p_axo AND c.periodo = p_periodo
    JOIN public.ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND a.vigencia = 'A'
      AND d.vigencia = 'E'
  LOOP
    INSERT INTO public.ta_11_adeudo_energ (id_adeudo_energia, id_energia, axo, periodo, cve_consumo, cantidad, importe, fecha_alta, id_usuario)
    VALUES (DEFAULT, v_row.id_energia, p_axo, p_periodo, v_row.cve_consumo, v_row.cantidad, v_row.cantidad * v_row.importe, NOW(), p_usuario);
  END LOOP;
  RETURN QUERY SELECT 'ok', 'La Emisión de Energía Eléctrica se grabó correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: facturar_emision_energia
-- Tipo: Report
-- Descripción: Devuelve los datos para la facturación de la emisión de energía.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION facturar_emision_energia(p_oficina INT, p_mercado INT, p_axo INT, p_periodo INT)
RETURNS TABLE(
  oficina INT,
  num_mercado INT,
  categoria INT,
  seccion TEXT,
  local INT,
  letra_local TEXT,
  bloque TEXT,
  nombre TEXT,
  local_adicional TEXT,
  cantidad NUMERIC,
  importe NUMERIC,
  descripcion TEXT,
  importe_1 NUMERIC
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
           a.nombre, d.local_adicional, d.cantidad, c.importe, b.descripcion, (d.cantidad * c.importe) AS importe_1
    FROM public.ta_11_locales a
    JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN public.ta_11_kilowhatts c ON c.axo = p_axo AND c.periodo = p_periodo
    JOIN public.ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND a.vigencia = 'A'
      AND d.vigencia = 'E';
END;
$$ LANGUAGE plpgsql;

-- ============================================

