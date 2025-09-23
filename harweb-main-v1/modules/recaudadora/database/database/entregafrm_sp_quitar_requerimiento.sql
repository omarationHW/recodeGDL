-- Stored Procedure: sp_quitar_requerimiento
-- Tipo: CRUD
-- Descripción: Quita la asignación de un requerimiento a un ejecutor y actualiza los contadores.
-- Generado para formulario: entregafrm
-- Fecha: 2025-08-27 11:57:32

CREATE OR REPLACE PROCEDURE sp_quitar_requerimiento(
    p_folio INTEGER,
    p_recaud INTEGER,
    p_cveejecutor INTEGER,
    p_usuario VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE reqpredial
    SET cveejecut = NULL,
        fecejec = NULL,
        capturista = p_usuario,
        feccap = NOW()
    WHERE folioreq = p_folio AND recaud = p_recaud AND cveejecut = p_cveejecutor;
    -- Actualiza detalle ejecutor
    UPDATE detejecutor
    SET asignados = GREATEST(asignados - 1, 0),
        pendientes = GREATEST(pendientes - 1, 0)
    WHERE cveejecutor = p_cveejecutor AND recaud = p_recaud;
END;
$$;