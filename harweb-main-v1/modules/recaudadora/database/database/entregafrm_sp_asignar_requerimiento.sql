-- Stored Procedure: sp_asignar_requerimiento
-- Tipo: CRUD
-- Descripción: Asigna un requerimiento a un ejecutor y actualiza los contadores de asignados/pendientes.
-- Generado para formulario: entregafrm
-- Fecha: 2025-08-27 11:57:32

CREATE OR REPLACE PROCEDURE sp_asignar_requerimiento(
    p_folio INTEGER,
    p_recaud INTEGER,
    p_cveejecutor INTEGER,
    p_fecha DATE,
    p_usuario VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE reqpredial
    SET cveejecut = p_cveejecutor,
        fecejec = p_fecha,
        capturista = p_usuario,
        feccap = NOW()
    WHERE folioreq = p_folio AND recaud = p_recaud;
    -- Actualiza detalle ejecutor
    UPDATE detejecutor
    SET asignados = asignados + 1,
        pendientes = pendientes + 1,
        ultfec_entrega = NOW()
    WHERE cveejecutor = p_cveejecutor AND recaud = p_recaud;
END;
$$;