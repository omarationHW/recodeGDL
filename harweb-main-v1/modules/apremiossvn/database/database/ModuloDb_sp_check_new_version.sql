-- Stored Procedure: sp_check_new_version
-- Tipo: CRUD
-- Descripción: Verifica si hay una nueva versión para un proyecto dado.
-- Generado para formulario: ModuloDb
-- Fecha: 2025-08-27 20:58:42

CREATE OR REPLACE FUNCTION sp_check_new_version(p_proyecto TEXT, p_version TEXT)
RETURNS TABLE (
    nueva_version BOOLEAN
) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_versiones WHERE proyecto = p_proyecto AND version = p_version) THEN
        RETURN QUERY SELECT FALSE;
    ELSE
        RETURN QUERY SELECT TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;