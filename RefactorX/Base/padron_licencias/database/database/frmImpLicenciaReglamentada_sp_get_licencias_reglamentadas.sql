-- Stored Procedure: sp_get_licencias_reglamentadas
-- Tipo: Catalog
-- Descripción: Obtiene todas las licencias reglamentadas.
-- Generado para formulario: frmImpLicenciaReglamentada
-- Fecha: 2025-08-27 18:04:38

CREATE OR REPLACE FUNCTION sp_get_licencias_reglamentadas()
RETURNS TABLE(
    id INTEGER,
    nombre VARCHAR,
    descripcion TEXT,
    usuario_id INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY SELECT id, nombre, descripcion, usuario_id, created_at, updated_at FROM licencias_reglamentadas ORDER BY id;
END;
$$ LANGUAGE plpgsql;