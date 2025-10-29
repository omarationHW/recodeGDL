-- Stored Procedure: sp_zonas_delete
-- Tipo: CRUD
-- Descripción: Elimina una zona si no tiene empresas relacionadas
-- Generado para formulario: ABC_Zonas
-- Fecha: 2025-08-27 13:32:50

CREATE OR REPLACE FUNCTION sp_zonas_delete(p_ctrol_zona integer)
RETURNS TABLE(status text, message text) AS $$
DECLARE
    emp_count integer;
BEGIN
    SELECT COUNT(*) INTO emp_count FROM ta_16_empresas WHERE ctrol_zona = p_ctrol_zona;
    IF emp_count > 0 THEN
        RETURN QUERY SELECT 'error', 'No se puede eliminar: existen empresas con esta zona.';
        RETURN;
    END IF;
    DELETE FROM ta_16_zonas WHERE ctrol_zona = p_ctrol_zona;
    RETURN QUERY SELECT 'success', 'Zona eliminada correctamente';
END;
$$ LANGUAGE plpgsql;