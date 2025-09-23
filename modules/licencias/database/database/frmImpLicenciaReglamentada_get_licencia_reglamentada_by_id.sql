-- Stored Procedure: get_licencia_reglamentada_by_id
-- Tipo: Catalog
-- Descripción: Obtiene una licencia reglamentada por su ID.
-- Generado para formulario: frmImpLicenciaReglamentada
-- Fecha: 2025-08-26 16:31:02

CREATE OR REPLACE FUNCTION get_licencia_reglamentada_by_id(
    p_id INTEGER
)
RETURNS TABLE (
    id INTEGER,
    nombre VARCHAR,
    descripcion VARCHAR,
    fecha_emision DATE,
    usuario_id INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT id, nombre, descripcion, fecha_emision, usuario_id FROM licencias_reglamentadas WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;