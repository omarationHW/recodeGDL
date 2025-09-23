-- Stored Procedure: sp_zonas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva zona en el catálogo
-- Generado para formulario: ABC_Zonas
-- Fecha: 2025-08-27 13:32:50

CREATE OR REPLACE FUNCTION sp_zonas_create(p_zona integer, p_sub_zona integer, p_descripcion varchar)
RETURNS TABLE(ctrol_zona integer, zona integer, sub_zona integer, descripcion varchar) AS $$
DECLARE
    new_ctrol integer;
BEGIN
    -- Validar existencia
    IF EXISTS (SELECT 1 FROM ta_16_zonas WHERE zona = p_zona AND sub_zona = p_sub_zona) THEN
        RAISE EXCEPTION 'Ya existe una zona con esos datos';
    END IF;
    -- Insertar
    INSERT INTO ta_16_zonas(zona, sub_zona, descripcion)
    VALUES (p_zona, p_sub_zona, p_descripcion)
    RETURNING ctrol_zona, zona, sub_zona, descripcion INTO new_ctrol, p_zona, p_sub_zona, p_descripcion;
    RETURN QUERY SELECT new_ctrol, p_zona, p_sub_zona, p_descripcion;
END;
$$ LANGUAGE plpgsql;