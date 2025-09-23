-- Stored Procedure: get_licencias_reglamentadas
-- Tipo: Catalog
-- Descripción: Obtiene todas las licencias reglamentadas.
-- Generado para formulario: frmImpLicenciaReglamentada
-- Fecha: 2025-08-26 16:31:02

CREATE OR REPLACE FUNCTION get_licencias_reglamentadas()
RETURNS TABLE (
    id SERIAL,
    nombre VARCHAR,
    descripcion VARCHAR,
    fecha_emision DATE,
    usuario_id INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT id, nombre, descripcion, fecha_emision, usuario_id FROM licencias_reglamentadas ORDER BY id DESC;
END;
$$ LANGUAGE plpgsql;