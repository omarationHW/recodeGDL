-- Stored Procedure: sp_mensaje_list
-- Tipo: Catalog
-- Descripción: Devuelve todos los mensajes guardados.
-- Generado para formulario: Mensajes
-- Fecha: 2025-08-27 14:55:35

CREATE OR REPLACE FUNCTION sp_mensaje_list()
RETURNS TABLE(id INTEGER, imagen INTEGER, mensaje VARCHAR, fecha TIMESTAMP) AS $$
BEGIN
    RETURN QUERY SELECT id, imagen, mensaje, fecha FROM mensajes ORDER BY fecha DESC;
END;
$$ LANGUAGE plpgsql;