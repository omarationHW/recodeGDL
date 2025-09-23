-- Stored Procedure: sp_ligarequisito_add
-- Tipo: CRUD
-- Descripción: Agrega un requisito a un giro (tabla giro_req)
-- Generado para formulario: LigaRequisitos
-- Fecha: 2025-08-27 18:39:43

CREATE OR REPLACE PROCEDURE sp_ligarequisito_add(p_id_giro INTEGER, p_req INTEGER, p_usuario TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM giro_req WHERE id_giro = p_id_giro AND req = p_req) THEN
        RAISE EXCEPTION 'El requisito ya está ligado a este giro';
    END IF;
    INSERT INTO giro_req (id_giro, req) VALUES (p_id_giro, p_req);
    -- Opcional: registrar en bitácora
END;
$$;