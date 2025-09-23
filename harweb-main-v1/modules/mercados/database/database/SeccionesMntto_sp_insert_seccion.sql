-- Stored Procedure: sp_insert_seccion
-- Tipo: CRUD
-- Descripción: Inserta una nueva sección en ta_11_secciones. Retorna éxito o mensaje de error si ya existe.
-- Generado para formulario: SeccionesMntto
-- Fecha: 2025-08-27 01:31:35

CREATE OR REPLACE FUNCTION sp_insert_seccion(p_seccion VARCHAR(2), p_descripcion VARCHAR(30))
RETURNS TABLE(success boolean, msg text) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_11_secciones WHERE seccion = p_seccion) THEN
        RETURN QUERY SELECT false, 'La sección ya existe';
        RETURN;
    END IF;
    INSERT INTO ta_11_secciones(seccion, descripcion) VALUES (p_seccion, p_descripcion);
    RETURN QUERY SELECT true, 'Sección insertada correctamente';
END;
$$ LANGUAGE plpgsql;