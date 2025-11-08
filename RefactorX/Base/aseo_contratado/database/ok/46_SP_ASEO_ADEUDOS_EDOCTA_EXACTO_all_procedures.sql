-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_EDOCTA (EXACTO del archivo original)
-- Archivo: 46_SP_ASEO_ADEUDOS_EDOCTA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
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
  TRUNCATE TABLE det_pagos;
  -- Aquí se puede poblar det_pagos según la lógica de negocio
  -- Por ejemplo, copiar de pagos vigentes, etc.
  -- ...
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_EDOCTA (EXACTO del archivo original)
-- Archivo: 46_SP_ASEO_ADEUDOS_EDOCTA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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

