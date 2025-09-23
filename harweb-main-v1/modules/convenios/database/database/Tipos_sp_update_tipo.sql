-- Stored Procedure: sp_update_tipo
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un tipo de convenio existente.
-- Generado para formulario: Tipos
-- Fecha: 2025-08-27 16:02:02

CREATE OR REPLACE FUNCTION sp_update_tipo(p_tipo integer, p_descripcion varchar)
RETURNS boolean AS $$
BEGIN
    UPDATE ta_17_tipos SET descripcion = p_descripcion WHERE tipo = p_tipo;
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;