-- Stored Procedure: sp_ligarequisito_remove
-- Tipo: CRUD
-- Descripción: Elimina un requisito de un giro (tabla giro_req)
-- Generado para formulario: LigaRequisitos
-- Fecha: 2025-08-27 18:39:43

CREATE OR REPLACE PROCEDURE sp_ligarequisito_remove(p_id_giro INTEGER, p_req INTEGER, p_usuario TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM giro_req WHERE id_giro = p_id_giro AND req = p_req) THEN
        RAISE EXCEPTION 'El requisito no está ligado a este giro';
    END IF;
    DELETE FROM giro_req WHERE id_giro = p_id_giro AND req = p_req;
    -- Opcional: registrar en bitácora
END;
$$;