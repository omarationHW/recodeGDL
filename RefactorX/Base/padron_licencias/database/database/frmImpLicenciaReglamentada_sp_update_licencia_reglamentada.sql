-- Stored Procedure: sp_update_licencia_reglamentada
-- Tipo: CRUD
-- Descripción: Actualiza una licencia reglamentada existente.
-- Generado para formulario: frmImpLicenciaReglamentada
-- Fecha: 2025-08-27 18:04:38

CREATE OR REPLACE FUNCTION sp_update_licencia_reglamentada(
    p_id INTEGER,
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
BEGIN
    UPDATE licencias_reglamentadas
    SET nombre = p_nombre,
        descripcion = p_descripcion,
        usuario_id = p_usuario_id,
        updated_at = NOW()
    WHERE id = p_id;
    RETURN QUERY SELECT id, nombre, descripcion, usuario_id, created_at, updated_at FROM licencias_reglamentadas WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;