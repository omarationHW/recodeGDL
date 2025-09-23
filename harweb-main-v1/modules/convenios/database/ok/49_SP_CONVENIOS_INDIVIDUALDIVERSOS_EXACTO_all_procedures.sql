-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: INDIVIDUALDIVERSOS (EXACTO del archivo original)
-- Archivo: 49_SP_CONVENIOS_INDIVIDUALDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_individual_diversos_resumen
-- Tipo: Report
-- Descripción: Devuelve resumen de adeudos, pagos, intereses, recargos y totales para un convenio diverso
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_individual_diversos_resumen(p_id_conv_resto integer)
RETURNS TABLE(
  total_adeudos numeric,
  total_recargos numeric,
  total_intereses numeric,
  total_pagos numeric,
  total numeric
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      COALESCE(SUM(a.importe),0) AS total_adeudos,
      COALESCE(SUM(a.recargos),0) AS total_recargos,
      COALESCE(SUM(a.interes),0) AS total_intereses,
      (SELECT COALESCE(SUM(p.importe_pago),0) FROM public.ta_17_conv_pagos p WHERE p.id_conv_resto = p_id_conv_resto) AS total_pagos,
      COALESCE(SUM(a.importe + a.recargos + a.interes),0) AS total
    FROM public.ta_17_adeudos_div a
    WHERE a.id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: INDIVIDUALDIVERSOS (EXACTO del archivo original)
-- Archivo: 49_SP_CONVENIOS_INDIVIDUALDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_individual_diversos_pagos
-- Tipo: Report
-- Descripción: Devuelve el detalle de pagos de un convenio diverso
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_individual_diversos_pagos(p_id_conv_resto integer)
RETURNS TABLE(
  id_conv_pago integer,
  fecha_pago date,
  oficina_pago smallint,
  caja_pago varchar,
  operacion_pago integer,
  pago_parcial smallint,
  importe_pago numeric,
  importe_recargo numeric,
  intereses numeric
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      id_conv_pago,
      fecha_pago,
      oficina_pago,
      caja_pago,
      operacion_pago,
      pago_parcial,
      importe_pago,
      importe_recargo,
      (SELECT COALESCE(SUM(importe),0) FROM public.ta_12_recibosdet WHERE fecha = p.fecha_pago AND id_rec = p.oficina_pago AND caja = p.caja_pago AND operacion = p.operacion_pago AND cuenta IN (173002,173003,453041,453051,453031,453021,453071,453061,453091,453011,453001,46508,550200000,220102000,220301000,220302000,551100000,220601000,220603000,221301000,221701000,221800000,221901000,220101000)) AS intereses
    FROM public.ta_17_conv_pagos p
    WHERE id_conv_resto = p_id_conv_resto
    ORDER BY pago_parcial;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: INDIVIDUALDIVERSOS (EXACTO del archivo original)
-- Archivo: 49_SP_CONVENIOS_INDIVIDUALDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

