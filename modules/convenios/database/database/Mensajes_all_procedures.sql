-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Mensajes
-- Generado: 2025-08-27 14:55:35
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_mensaje_save
-- Tipo: CRUD
-- Descripción: Guarda un mensaje en la tabla mensajes. Si no existe la tabla, debe crearse.
-- --------------------------------------------

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

-- ============================================

-- SP 2/2: sp_mensaje_list
-- Tipo: Catalog
-- Descripción: Devuelve todos los mensajes guardados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_mensaje_list()
RETURNS TABLE(id INTEGER, imagen INTEGER, mensaje VARCHAR, fecha TIMESTAMP) AS $$
BEGIN
    RETURN QUERY SELECT id, imagen, mensaje, fecha FROM mensajes ORDER BY fecha DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

