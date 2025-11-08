-- Stored Procedure: sp_create_licencia_reglamentada
-- Tipo: CRUD
-- Descripción: Crea una nueva licencia reglamentada.
-- Generado para formulario: frmImpLicenciaReglamentada
-- Fecha: 2025-08-27 18:04:38

CREATE OR REPLACE FUNCTION sp_create_licencia_reglamentada(
    p_nombre VARCHAR,
    p_descripcion TEXT,
    p_usuario_id INTEGER
) RETURNS TABLE(
    id INTEGER,
    nombre VARCHAR,
    descripcion TEXT,
    usuario_id INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO licencias_reglamentadas (nombre, descripcion, usuario_id, created_at, updated_at)
    VALUES (p_nombre, p_descripcion, p_usuario_id, NOW(), NOW())
    RETURNING id INTO new_id;
    RETURN QUERY SELECT id, nombre, descripcion, usuario_id, created_at, updated_at FROM licencias_reglamentadas WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;