-- Stored Procedure: sp_add_tipo
-- Tipo: CRUD
-- Descripción: Agrega un nuevo tipo de convenio a la tabla ta_17_tipos.
-- Generado para formulario: Tipos
-- Fecha: 2025-08-27 16:02:02

CREATE OR REPLACE FUNCTION sp_add_tipo(p_tipo integer, p_descripcion varchar)
RETURNS boolean AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_17_tipos WHERE tipo = p_tipo) THEN
        RETURN FALSE;
    END IF;
    INSERT INTO ta_17_tipos (tipo, descripcion) VALUES (p_tipo, p_descripcion);
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;