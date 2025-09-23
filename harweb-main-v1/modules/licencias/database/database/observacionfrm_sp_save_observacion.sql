-- Stored Procedure: sp_save_observacion
-- Tipo: CRUD
-- Descripción: Guarda una nueva observación en la tabla observaciones y retorna el registro insertado.
-- Generado para formulario: observacionfrm
-- Fecha: 2025-08-27 18:48:48

CREATE OR REPLACE FUNCTION sp_save_observacion(p_observacion TEXT)
RETURNS TABLE(id BIGINT, observacion TEXT, created_at TIMESTAMP) AS $$
BEGIN
    INSERT INTO observaciones (observacion, created_at)
    VALUES (UPPER(p_observacion), NOW());
    RETURN QUERY
        SELECT id, observacion, created_at
        FROM observaciones
        WHERE id = currval('observaciones_id_seq');
END;
$$ LANGUAGE plpgsql;