-- Stored Procedure: sp_delete_tipo
-- Tipo: CRUD
-- Descripción: Elimina un tipo de convenio por su clave.
-- Generado para formulario: Tipos
-- Fecha: 2025-08-27 16:02:02

CREATE OR REPLACE FUNCTION sp_delete_tipo(p_tipo integer)
RETURNS boolean AS $$
BEGIN
    DELETE FROM ta_17_tipos WHERE tipo = p_tipo;
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;