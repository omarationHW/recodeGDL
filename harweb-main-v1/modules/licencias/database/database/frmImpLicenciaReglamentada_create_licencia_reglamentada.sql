-- Stored Procedure: create_licencia_reglamentada
-- Tipo: CRUD
-- Descripción: Crea una nueva licencia reglamentada.
-- Generado para formulario: frmImpLicenciaReglamentada
-- Fecha: 2025-08-26 16:31:02

CREATE OR REPLACE FUNCTION create_licencia_reglamentada(
    p_nombre VARCHAR,
    p_descripcion VARCHAR,
    p_fecha_emision DATE,
    p_usuario_id INTEGER
)
RETURNS TABLE (
    id INTEGER,
    nombre VARCHAR,
    descripcion VARCHAR,
    fecha_emision DATE,
    usuario_id INTEGER
) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO licencias_reglamentadas (nombre, descripcion, fecha_emision, usuario_id)
    VALUES (p_nombre, p_descripcion, p_fecha_emision, p_usuario_id)
    RETURNING id INTO new_id;
    RETURN QUERY SELECT id, nombre, descripcion, fecha_emision, usuario_id FROM licencias_reglamentadas WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;