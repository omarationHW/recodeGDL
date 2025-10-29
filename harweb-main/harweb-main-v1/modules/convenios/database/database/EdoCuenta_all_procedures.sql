-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: EdoCuenta
-- Generado: 2025-08-27 14:27:45
-- Total SPs: 4
-- ============================================

-- SP 1/4: edo_cuenta_list
-- Tipo: Report
-- Descripción: Obtiene el listado de estados de cuenta por tipo y subtipo, incluyendo totales de pagos y recargos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION edo_cuenta_list(p_tipo integer, p_subtipo integer)
RETURNS TABLE(
  manzana text,
  lote integer,
  letra text,
  id_conv_resto integer,
  nombre text,
  calle text,
  num_exterior integer,
  num_interior integer,
  inciso text,
  cantidad_total numeric,
  adeudo numeric,
  total_importe numeric,
  total_recargos numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.manzana,
    a.lote,
    a.letra,
    b.id_conv_resto,
    b.nombre,
    b.calle,
    b.num_exterior,
    b.num_interior,
    b.inciso,
    b.cantidad_total,
    SUM(c.importe) AS adeudo,
    COALESCE((SELECT SUM(importe_pago) FROM ta_17_conv_pagos WHERE id_conv_resto = b.id_conv_resto), 0) AS total_importe,
    COALESCE((SELECT SUM(COALESCE(importe_recargo,0)) FROM ta_17_conv_pagos WHERE id_conv_resto = b.id_conv_resto), 0) AS total_recargos
  FROM ta_17_con_reg_pred a
  JOIN ta_17_conv_d_resto b ON b.tipo = a.tipo AND b.id_conv_diver = a.id_conv_predio
  JOIN ta_17_adeudos_div c ON c.id_conv_resto = b.id_conv_resto AND c.clave_pago IS NULL
  WHERE a.tipo = p_tipo AND a.subtipo = p_subtipo
  GROUP BY a.manzana, a.lote, a.letra, b.id_conv_resto, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total
  ORDER BY a.manzana, a.lote, a.letra;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: edo_cuenta_report
-- Tipo: Report
-- Descripción: Devuelve el reporte detallado de estado de cuenta para impresión, incluyendo pagos y recargos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION edo_cuenta_report(p_tipo integer, p_subtipo integer)
RETURNS TABLE(
  manzana text,
  lote integer,
  letra text,
  id_conv_resto integer,
  nombre text,
  calle text,
  num_exterior integer,
  num_interior integer,
  inciso text,
  cantidad_total numeric,
  adeudo numeric,
  pago_parcial integer,
  fecha_pago date,
  oficina_pago integer,
  caja_pago text,
  operacion_pago integer,
  importe_pago numeric,
  importe_recargo numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.manzana,
    a.lote,
    a.letra,
    b.id_conv_resto,
    b.nombre,
    b.calle,
    b.num_exterior,
    b.num_interior,
    b.inciso,
    b.cantidad_total,
    SUM(c.importe) AS adeudo,
    p.pago_parcial,
    p.fecha_pago,
    p.oficina_pago,
    p.caja_pago,
    p.operacion_pago,
    p.importe_pago,
    COALESCE(p.importe_recargo,0) AS importe_recargo
  FROM ta_17_con_reg_pred a
  JOIN ta_17_conv_d_resto b ON b.tipo = a.tipo AND b.id_conv_diver = a.id_conv_predio
  JOIN ta_17_adeudos_div c ON c.id_conv_resto = b.id_conv_resto AND c.clave_pago IS NULL
  LEFT JOIN ta_17_conv_pagos p ON p.id_conv_resto = b.id_conv_resto
  WHERE a.tipo = p_tipo AND a.subtipo = p_subtipo
  GROUP BY a.manzana, a.lote, a.letra, b.id_conv_resto, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total, p.pago_parcial, p.fecha_pago, p.oficina_pago, p.caja_pago, p.operacion_pago, p.importe_pago, p.importe_recargo
  ORDER BY a.manzana, a.lote, a.letra, p.pago_parcial;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: edo_cuenta_calc_recargos
-- Tipo: CRUD
-- Descripción: Calcula los recargos para un adeudo específico según la lógica de vencimiento y días inhábiles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION edo_cuenta_calc_recargos(p_id_conv_resto integer, p_pago_parcial integer)
RETURNS TABLE(
  recargos numeric
) AS $$
DECLARE
  alo integer;
  mes integer;
  dia integer;
  alov integer;
  mesv integer;
  diav integer;
  dvenc integer;
  fecha1 date;
  fecha text;
  mes_c text;
  cont integer;
  porc numeric;
  importe numeric;
BEGIN
  SELECT EXTRACT(YEAR FROM CURRENT_DATE), EXTRACT(MONTH FROM CURRENT_DATE), EXTRACT(DAY FROM CURRENT_DATE)
    INTO alo, mes, dia;
  mes_c := lpad(mes::text, 2, '0');
  SELECT fecha_venc, importe INTO fecha1, importe FROM ta_17_adeudos_div WHERE id_conv_resto = p_id_conv_resto AND pago_parcial = p_pago_parcial;
  IF fecha1 IS NULL THEN RETURN; END IF;
  SELECT EXTRACT(YEAR FROM fecha1), EXTRACT(MONTH FROM fecha1), EXTRACT(DAY FROM fecha1) INTO alov, mesv, diav;
  SELECT day(fecha_venc) INTO dvenc FROM ta_17_adeudos_div WHERE id_conv_resto = p_id_conv_resto AND EXTRACT(YEAR FROM fecha_venc) = alo AND EXTRACT(MONTH FROM fecha_venc) = mes LIMIT 1;
  IF dvenc IS NULL THEN
    fecha := '19/' || mes_c || '/' || alo::text;
    fecha1 := to_date(fecha, 'DD/MM/YYYY');
    cont := 5;
    WHILE cont = 5 LOOP
      IF extract(dow from fecha1) > 1 AND extract(dow from fecha1) < 7 THEN
        IF NOT EXISTS (SELECT 1 FROM ta_12_diasinhabil WHERE fecha = fecha1) THEN
          cont := 10;
        ELSE
          fecha1 := fecha1 + interval '1 day';
        END IF;
      ELSE
        fecha1 := fecha1 + interval '1 day';
      END IF;
    END LOOP;
    dvenc := EXTRACT(DAY FROM fecha1);
  END IF;
  SELECT COALESCE(SUM(porcentaje_parcial),0) INTO porc FROM ta_13_recargosrcm WHERE (axo = alov AND mes >= mesv) OR (axo = alo AND mes <= CASE WHEN dia <= dvenc THEN mes-1 ELSE mes END) OR (axo > alov AND axo < alo);
  recargos := (importe * porc) / 100.0;
  IF recargos > 0 THEN
    recargos := trunc(recargos * 100) / 100.0;
  END IF;
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: edo_cuenta_sum_pagos
-- Tipo: CRUD
-- Descripción: Suma los pagos y recargos de un convenio para mostrar totales.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION edo_cuenta_sum_pagos(p_id_conv_resto integer)
RETURNS TABLE(
  total_importe numeric,
  total_recargo numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT COALESCE(SUM(importe_pago),0), COALESCE(SUM(COALESCE(importe_recargo,0)),0)
  FROM ta_17_conv_pagos
  WHERE id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;

-- ============================================

