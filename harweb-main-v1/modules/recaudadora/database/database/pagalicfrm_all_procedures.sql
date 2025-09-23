-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: pagalicfrm
-- Generado: 2025-08-27 14:01:39
-- Total SPs: 2
-- ============================================

-- SP 1/2: calc_sdosl
-- Tipo: CRUD
-- Descripción: Recalcula los saldos de una licencia después de marcar como pagado.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE calc_sdosl(IN id_licencia_in integer)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Aquí va la lógica de recálculo de saldos para la licencia
    -- Por ejemplo, actualizar campos de saldo en detsal_lic, licencias, etc.
    -- Esta lógica debe ser adaptada a las reglas de negocio reales
    UPDATE detsal_lic
    SET saldo = 0
    WHERE id_licencia = id_licencia_in AND cvepago = 999999999;
    -- Otras actualizaciones necesarias...
END;
$$;

-- ============================================

-- SP 2/2: calc_sdosl_anuncio
-- Tipo: CRUD
-- Descripción: Recalcula los saldos de un anuncio después de marcar como pagado.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE calc_sdosl_anuncio(IN id_anuncio_in integer)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Lógica de recálculo de saldos para el anuncio
    UPDATE detsal_lic
    SET saldo = 0
    WHERE id_anuncio = id_anuncio_in AND cvepago = 999999999;
    -- Otras actualizaciones necesarias...
END;
$$;

-- ============================================

