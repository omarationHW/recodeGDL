-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: Adeudos_EdoCta (EXACTO del archivo original)
-- Archivo: 25_SP_ASEO_ADEUDOS_EDOCTA_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_creadetp
-- Tipo: CRUD
-- Descripción: Crea el detalle de pagos para todos los contratos (limpia y prepara la tabla det_pagos)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_creadetp()
LANGUAGE plpgsql
AS $$
BEGIN
  -- Limpia la tabla det_pagos (o realiza el proceso de preparación)
  TRUNCATE TABLE public.det_pagos;
  -- Aquí se puede poblar det_pagos según la lógica de negocio
  -- Por ejemplo, copiar de pagos vigentes, etc.
  -- ...
END;
$$;

-- ============================================

-- SP 2/3: sp_detpagos
-- Tipo: CRUD
-- Descripción: Genera el detalle de pagos para un contrato y periodo dado
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_detpagos(
  IN p_control_contrato INTEGER,
  IN p_ejercicio INTEGER,
  IN p_per1 VARCHAR,
  IN p_per2 VARCHAR,
  IN p_per3 VARCHAR,
  IN p_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Elimina registros previos del contrato
  DELETE FROM public.det_pagos WHERE control_contrato = p_control_contrato;
  -- Inserta los nuevos detalles (ejemplo, sumariza pagos por periodo)
  INSERT INTO public.det_pagos (control_contrato, ejercicio, detalle, importe_adeudos, importe_recargos, importe_multas, importe_gastos)
  SELECT
    p_control_contrato,
    p_ejercicio,
    CONCAT('Periodo ', p_per1, ' a ', p_per2),
    SUM(CASE WHEN status_vigencia = p_status THEN importe ELSE 0 END) AS importe_adeudos,
    SUM(CASE WHEN status_vigencia = p_status THEN recargos ELSE 0 END) AS importe_recargos,
    SUM(CASE WHEN status_vigencia = p_status THEN multa ELSE 0 END) AS importe_multas,
    SUM(CASE WHEN status_vigencia = p_status THEN gastos ELSE 0 END) AS importe_gastos
  FROM public.ta_16_pagos
  WHERE control_contrato = p_control_contrato
    AND aso_mes_pago BETWEEN p_per1 AND p_per2
  GROUP BY p_control_contrato, p_ejercicio;
END;
$$;

-- ============================================

-- SP 3/3: sp_detapremios
-- Tipo: CRUD
-- Descripción: Genera el detalle de apremios para un contrato
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_detapremios(
  IN p_control_contrato INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Aquí se puede poblar una tabla temporal de apremios si es necesario
  -- Ejemplo: INSERT INTO det_apremios ...
  -- O simplemente actualizar datos relacionados
  -- ...
END;
$$;

-- ============================================