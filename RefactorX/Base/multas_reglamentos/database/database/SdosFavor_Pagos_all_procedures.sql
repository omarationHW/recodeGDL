-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: SdosFavor_Pagos
-- Generado: 2025-08-27 15:40:42
-- Total SPs: 6
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

-- SP 2/6: sp_sdosfavor_pagos_read
-- Tipo: CRUD
-- Descripción: Obtiene un registro de pago a favor por clave primaria.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sdosfavor_pagos_read(
    p_reca VARCHAR(3),
    p_caja VARCHAR(2),
    p_folio VARCHAR(10)
) RETURNS TABLE (
    reca VARCHAR(3),
    caja VARCHAR(2),
    folio VARCHAR(10),
    importe NUMERIC(12,2),
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY SELECT reca, caja, folio, importe, fecha
      FROM sdosfavor_pagos
      WHERE reca = p_reca AND caja = p_caja AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

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

-- SP 4/6: sp_sdosfavor_pagos_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de pago a favor.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sdosfavor_pagos_delete(
    p_reca VARCHAR(3),
    p_caja VARCHAR(2),
    p_folio VARCHAR(10)
) RETURNS TABLE (
    reca VARCHAR(3),
    caja VARCHAR(2),
    folio VARCHAR(10),
    importe NUMERIC(12,2),
    fecha DATE
) AS $$
DECLARE
    v_row sdosfavor_pagos%ROWTYPE;
BEGIN
    SELECT * INTO v_row FROM sdosfavor_pagos WHERE reca = p_reca AND caja = p_caja AND folio = p_folio;
    DELETE FROM sdosfavor_pagos WHERE reca = p_reca AND caja = p_caja AND folio = p_folio;
    RETURN QUERY SELECT v_row.reca, v_row.caja, v_row.folio, v_row.importe, v_row.fecha;
END;
$$ LANGUAGE plpgsql;

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

-- SP 6/6: sp_sdosfavor_pagos_find
-- Tipo: Catalog
-- Descripción: Busca un pago a favor por clave primaria (igual que read, pero para compatibilidad).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sdosfavor_pagos_find(
    p_reca VARCHAR(3),
    p_caja VARCHAR(2),
    p_folio VARCHAR(10)
) RETURNS TABLE (
    reca VARCHAR(3),
    caja VARCHAR(2),
    folio VARCHAR(10),
    importe NUMERIC(12,2),
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY SELECT reca, caja, folio, importe, fecha
      FROM sdosfavor_pagos
      WHERE reca = p_reca AND caja = p_caja AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

