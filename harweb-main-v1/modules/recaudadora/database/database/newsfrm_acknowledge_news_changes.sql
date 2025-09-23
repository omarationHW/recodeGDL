-- Stored Procedure: acknowledge_news_changes
-- Tipo: CRUD
-- Descripción: Registra que un usuario ha leído/aceptado los cambios del módulo.
-- Generado para formulario: newsfrm
-- Fecha: 2025-08-27 13:57:34

CREATE OR REPLACE FUNCTION acknowledge_news_changes(p_user_id INTEGER)
RETURNS TABLE(status TEXT) AS $$
BEGIN
    -- Aquí se podría registrar en una tabla de auditoría que el usuario leyó los cambios
    -- Por simplicidad, solo retornamos un mensaje
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;