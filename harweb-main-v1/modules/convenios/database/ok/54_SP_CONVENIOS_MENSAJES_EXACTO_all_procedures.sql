-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MENSAJES (EXACTO del archivo original)
-- Archivo: 54_SP_CONVENIOS_MENSAJES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MENSAJES (EXACTO del archivo original)
-- Archivo: 54_SP_CONVENIOS_MENSAJES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

