-- Stored Procedure: sp_mensaje_save
-- Tipo: CRUD
-- Descripción: Guarda un mensaje en la tabla mensajes. Si no existe la tabla, debe crearse.
-- Generado para formulario: Mensajes
-- Fecha: 2025-08-27 14:55:35

-- Tabla destino
CREATE TABLE IF NOT EXISTS mensajes (
    id SERIAL PRIMARY KEY,
    imagen INTEGER NULL,
    mensaje VARCHAR(1000) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stored Procedure para guardar mensaje
CREATE OR REPLACE FUNCTION sp_mensaje_save(_imagen INTEGER, _mensaje VARCHAR)
RETURNS TABLE(id INTEGER, imagen INTEGER, mensaje VARCHAR, fecha TIMESTAMP) AS $$
BEGIN
    INSERT INTO mensajes(imagen, mensaje) VALUES (_imagen, _mensaje)
    RETURNING mensajes.id, mensajes.imagen, mensajes.mensaje, mensajes.fecha;
END;
$$ LANGUAGE plpgsql;