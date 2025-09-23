-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTEDOCUENTA (EXACTO del archivo original)
-- Archivo: 77_SP_CONVENIOS_RPTEDOCUENTA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_get_edo_cuenta
-- Tipo: Report
-- Descripción: Obtiene el listado de convenios de regularización de predios para un tipo y subtipo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_edo_cuenta(p_tipo INTEGER, p_subtipo INTEGER)
RETURNS TABLE (
  manzana VARCHAR,
  lote INTEGER,
  letra VARCHAR,
  id_conv_resto INTEGER,
  nombre VARCHAR,
  calle VARCHAR,
  num_exterior SMALLINT,
  num_interior SMALLINT,
  inciso VARCHAR,
  cantidad_total NUMERIC,
  pago_parcial SMALLINT,
  fecha_pago DATE,
  oficina_pago SMALLINT,
  caja_pago VARCHAR,
  operacion_pago INTEGER,
  importe_pago NUMERIC,
  importe_recargo NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.manzana, a.lote, a.letra, b.id_conv_resto, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total,
         d.pago_parcial, d.fecha_pago, d.oficina_pago, d.caja_pago, d.operacion_pago, d.importe_pago, d.importe_recargo
    FROM public.ta_17_con_reg_pred a
    JOIN public.ta_17_conv_d_resto b ON b.tipo = a.tipo AND b.id_conv_diver = a.id_conv_predio
    JOIN public.ta_17_adeudos_div c ON c.id_conv_resto = b.id_conv_resto
    LEFT JOIN public.ta_17_conv_pagos d ON d.id_conv_resto = b.id_conv_resto
   WHERE a.tipo = p_tipo AND a.subtipo = p_subtipo AND c.clave_pago IS NULL
   GROUP BY a.manzana, a.lote, a.letra, b.id_conv_resto, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total,
            d.pago_parcial, d.fecha_pago, d.oficina_pago, d.caja_pago, d.operacion_pago, d.importe_pago, d.importe_recargo
   ORDER BY a.manzana, a.lote, a.letra, d.pago_parcial;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTEDOCUENTA (EXACTO del archivo original)
-- Archivo: 77_SP_CONVENIOS_RPTEDOCUENTA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_get_adeudos_predio
-- Tipo: Report
-- Descripción: Obtiene los adeudos (parcialidades) de un predio/convenio, calculando recargos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_predio(p_id_conv_resto INTEGER)
RETURNS TABLE (
  pago_parcial SMALLINT,
  importe NUMERIC,
  fecha_venc DATE,
  recargos NUMERIC
) AS $$
DECLARE
  r RECORD;
  alo INT;
  mes INT;
  dia INT;
  alov INT;
  mesv INT;
  diav INT;
  dvenc INT;
  porc FLOAT;
  rec NUMERIC;
  fecha1 DATE;
  mes_c TEXT;
  fecha TEXT;
  cont INT;
  fecha_venc_calc DATE;
BEGIN
  SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO alo;
  SELECT EXTRACT(MONTH FROM CURRENT_DATE) INTO mes;
  SELECT EXTRACT(DAY FROM CURRENT_DATE) INTO dia;
  FOR r IN SELECT * FROM public.ta_17_adeudos_div WHERE id_conv_resto = p_id_conv_resto ORDER BY pago_parcial LOOP
    SELECT EXTRACT(YEAR FROM r.fecha_venc), EXTRACT(MONTH FROM r.fecha_venc), EXTRACT(DAY FROM r.fecha_venc)
      INTO alov, mesv, diav;
    -- Calcular día de vencimiento
    SELECT day(fecha_venc) FROM public.ta_17_adeudos_div WHERE id_conv_resto = p_id_conv_resto AND EXTRACT(YEAR FROM fecha_venc) = alo AND EXTRACT(MONTH FROM fecha_venc) = mes
      INTO dvenc;
    IF dvenc IS NULL THEN
      mes_c := lpad(mes::text, 2, '0');
      fecha := '19/' || mes_c || '/' || alo::text;
      fecha1 := to_date(fecha, 'DD/MM/YYYY');
      cont := 5;
      WHILE cont = 5 LOOP
        IF extract(dow from fecha1) > 1 AND extract(dow from fecha1) < 7 THEN
          IF NOT EXISTS (SELECT 1 FROM public.ta_12_diasinhabil WHERE fecha = fecha1) THEN
            cont := 10;
          ELSE
            fecha1 := fecha1 + INTERVAL '1 day';
          END IF;
        ELSE
          fecha1 := fecha1 + INTERVAL '1 day';
        END IF;
      END LOOP;
      dvenc := extract(day from fecha1);
    END IF;
    -- Calcular recargos
    porc := 0;
    SELECT COALESCE(SUM(porcentaje_parcial),0) INTO porc FROM public.ta_13_recargosrcm
      WHERE (axo = alov AND mes >= mesv)
        AND ((alov >= alo AND axo = alo AND mes <= (CASE WHEN dia <= dvenc THEN mes-1 ELSE mes END))
             OR (axo > alov AND axo < alo));
    rec := (r.importe * porc) / 100.0;
    IF rec > 0 THEN
      rec := trunc(rec * 100) / 100.0;
    END IF;
    RETURN NEXT (r.pago_parcial, r.importe, r.fecha_venc, rec);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTEDOCUENTA (EXACTO del archivo original)
-- Archivo: 77_SP_CONVENIOS_RPTEDOCUENTA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

