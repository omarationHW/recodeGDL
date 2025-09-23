-- Stored Procedure: sp_update_seccion
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una sección existente.
-- Generado para formulario: SeccionesMntto
-- Fecha: 2025-08-27 01:31:35

CREATE OR REPLACE FUNCTION sp_update_seccion(p_seccion VARCHAR(2), p_descripcion VARCHAR(30))
RETURNS TABLE(success boolean, msg text) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ta_11_secciones WHERE seccion = p_seccion) THEN
        RETURN QUERY SELECT false, 'La sección no existe';
        RETURN;
    END IF;
    UPDATE ta_11_secciones SET descripcion = p_descripcion WHERE seccion = p_seccion;
    RETURN QUERY SELECT true, 'Sección actualizada correctamente';
END;
$$ LANGUAGE plpgsql;