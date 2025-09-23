-- Stored Procedure: update_licencia_reglamentada
-- Tipo: CRUD
-- Descripción: Actualiza una licencia reglamentada existente.
-- Generado para formulario: frmImpLicenciaReglamentada
-- Fecha: 2025-08-26 16:31:02

CREATE OR REPLACE FUNCTION update_licencia_reglamentada(
    p_id INTEGER,
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
BEGIN
    UPDATE licencias_reglamentadas
    SET nombre = p_nombre,
        descripcion = p_descripcion,
        fecha_emision = p_fecha_emision,
        usuario_id = p_usuario_id
    WHERE id = p_id;
    RETURN QUERY SELECT id, nombre, descripcion, fecha_emision, usuario_id FROM licencias_reglamentadas WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;