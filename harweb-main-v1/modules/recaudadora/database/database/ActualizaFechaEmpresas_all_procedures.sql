-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ActualizaFechaEmpresas
-- Generado: 2025-08-26 20:38:17
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_actualiza_fecha_practica
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de práctica (fecent) de un folio de requerimiento de empresa
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_actualiza_fecha_practica(
    IN p_cvereq INTEGER,
    IN p_fecha_practica DATE
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE reqpredial
    SET fecent = p_fecha_practica
    WHERE cvereq = p_cvereq;
END;
$$;

-- ============================================

