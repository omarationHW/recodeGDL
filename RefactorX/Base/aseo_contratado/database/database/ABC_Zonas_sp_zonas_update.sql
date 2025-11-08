-- Stored Procedure: sp_zonas_update
-- Tipo: CRUD
-- Descripción: Actualiza una zona existente
-- Generado para formulario: ABC_Zonas
-- Fecha: 2025-08-27 13:32:50

CREATE OR REPLACE FUNCTION sp_zonas_update(p_ctrol_zona integer, p_zona integer, p_sub_zona integer, p_descripcion varchar)
RETURNS TABLE(ctrol_zona integer, zona integer, sub_zona integer, descripcion varchar) AS $$
BEGIN
    UPDATE ta_16_zonas
    SET zona = p_zona, sub_zona = p_sub_zona, descripcion = p_descripcion
    WHERE ctrol_zona = p_ctrol_zona
    RETURNING ctrol_zona, zona, sub_zona, descripcion;
END;
$$ LANGUAGE plpgsql;