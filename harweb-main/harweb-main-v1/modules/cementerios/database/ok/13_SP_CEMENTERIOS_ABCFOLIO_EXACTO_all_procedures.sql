-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: ABCFolio (EXACTO del archivo original)
-- Archivo: 13_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_13_historia
-- Tipo: CRUD
-- Descripción: Guarda un registro histórico de la modificación de un folio
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_13_historia(IN par_control INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.ta_13_datosrcm_historico (
    control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov, tipo, fecha_alta, vigencia, fecha_his
  )
  SELECT control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov, tipo, fecha_alta, vigencia, now()
  FROM public.ta_13_datosrcm WHERE control_rcm = par_control;
END;
$$;

-- ============================================

-- SP 2/2: spd_abc_adercm
-- Tipo: CRUD
-- Descripción: Recalcula adeudos de un folio según la operación (1=alta, 2=baja, 3=modificación)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE spd_abc_adercm(IN par_control INTEGER, IN par_opc INTEGER, IN par_usu INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
  IF par_opc = 1 THEN
    -- Alta: genera adeudos para nueva fosa
    INSERT INTO public.ta_13_adeudosrcm (control_rcm, axo_adeudo, importe, importe_recargos, descto_impote, descto_recargos, actualizacion, vigencia, usuario, fecha_mov)
    SELECT par_control, y, 0, 0, 0, 0, 0, 'V', par_usu, now()
    FROM generate_series(EXTRACT(YEAR FROM now())-6, EXTRACT(YEAR FROM now())::int) AS y;
  ELSIF par_opc = 2 THEN
    -- Baja: marca adeudos como baja
    UPDATE public.ta_13_adeudosrcm SET vigencia = 'B', usuario = par_usu, fecha_mov = now() WHERE control_rcm = par_control;
  ELSIF par_opc = 3 THEN
    -- Modificación: recalcula adeudos si es necesario (ejemplo: si axo_pagado cambió)
    -- Aquí se puede agregar lógica específica según reglas de negocio
    UPDATE public.ta_13_adeudosrcm SET usuario = par_usu, fecha_mov = now() WHERE control_rcm = par_control;
  END IF;
END;
$$;

-- ============================================
