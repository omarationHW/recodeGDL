-- Stored Procedure: sp_mensaje_show
-- Tipo: CRUD
-- Descripción: Registra o procesa la visualización de un mensaje del sistema. Puede ser extendido para logging o auditoría.
-- Generado para formulario: mensaje
-- Fecha: 2025-08-27 13:51:13

CREATE OR REPLACE FUNCTION sp_mensaje_show(p_tipo TEXT, p_msg TEXT, p_icono TEXT)
RETURNS TABLE(tipo TEXT, msg TEXT, icono TEXT) AS $$
BEGIN
    -- Aquí se podría registrar el mensaje en una tabla de logs si se desea
    -- Por ejemplo:
    -- INSERT INTO mensaje_log(tipo, msg, icono, fecha) VALUES (p_tipo, p_msg, p_icono, NOW());
    RETURN QUERY SELECT p_tipo, p_msg, p_icono;
END;
$$ LANGUAGE plpgsql;