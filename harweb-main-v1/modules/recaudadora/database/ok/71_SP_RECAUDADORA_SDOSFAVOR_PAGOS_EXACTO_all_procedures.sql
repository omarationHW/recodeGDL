-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SDOSFAVOR_PAGOS (EXACTO del archivo original)
-- Archivo: 71_SP_RECAUDADORA_SDOSFAVOR_PAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: sp_sdosfavor_pagos_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de pago a favor.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sdosfavor_pagos_create(
    p_reca VARCHAR(3),
    p_caja VARCHAR(2),
    p_folio VARCHAR(10),
    p_importe NUMERIC(12,2),
    p_fecha DATE
) RETURNS TABLE (
    reca VARCHAR(3),
    caja VARCHAR(2),
    folio VARCHAR(10),
    importe NUMERIC(12,2),
    fecha DATE
) AS $$
BEGIN
    INSERT INTO sdosfavor_pagos (reca, caja, folio, importe, fecha)
    VALUES (p_reca, p_caja, p_folio, p_importe, p_fecha);
    RETURN QUERY SELECT reca, caja, folio, importe, fecha
      FROM sdosfavor_pagos
      WHERE reca = p_reca AND caja = p_caja AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SDOSFAVOR_PAGOS (EXACTO del archivo original)
-- Archivo: 71_SP_RECAUDADORA_SDOSFAVOR_PAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: sp_sdosfavor_pagos_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de pago a favor.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sdosfavor_pagos_update(
    p_reca VARCHAR(3),
    p_caja VARCHAR(2),
    p_folio VARCHAR(10),
    p_importe NUMERIC(12,2),
    p_fecha DATE,
    p_old_folio VARCHAR(10)
) RETURNS TABLE (
    reca VARCHAR(3),
    caja VARCHAR(2),
    folio VARCHAR(10),
    importe NUMERIC(12,2),
    fecha DATE
) AS $$
BEGIN
    UPDATE sdosfavor_pagos
       SET reca = p_reca,
           caja = p_caja,
           folio = p_folio,
           importe = p_importe,
           fecha = p_fecha
     WHERE reca = p_reca AND caja = p_caja AND folio = p_old_folio;
    RETURN QUERY SELECT reca, caja, folio, importe, fecha
      FROM sdosfavor_pagos
      WHERE reca = p_reca AND caja = p_caja AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SDOSFAVOR_PAGOS (EXACTO del archivo original)
-- Archivo: 71_SP_RECAUDADORA_SDOSFAVOR_PAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: sp_sdosfavor_pagos_list
-- Tipo: Catalog
-- Descripción: Lista todos los pagos a favor.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sdosfavor_pagos_list()
RETURNS TABLE (
    reca VARCHAR(3),
    caja VARCHAR(2),
    folio VARCHAR(10),
    importe NUMERIC(12,2),
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY SELECT reca, caja, folio, importe, fecha FROM sdosfavor_pagos ORDER BY fecha DESC, reca, caja, folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SDOSFAVOR_PAGOS (EXACTO del archivo original)
-- Archivo: 71_SP_RECAUDADORA_SDOSFAVOR_PAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

