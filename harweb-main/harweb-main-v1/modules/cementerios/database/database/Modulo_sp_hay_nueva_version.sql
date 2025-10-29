-- Stored Procedure: sp_hay_nueva_version
-- Tipo: CRUD
-- Descripción: Verifica si hay una nueva versión para el proyecto.
-- Generado para formulario: Modulo
-- Fecha: 2025-08-27 14:38:06

CREATE OR REPLACE FUNCTION sp_hay_nueva_version(p_proyecto VARCHAR, p_version VARCHAR)
RETURNS TABLE(hay_nueva BOOLEAN) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_versiones WHERE proyecto = p_proyecto AND version = p_version;
    IF v_count = 1 THEN
        RETURN QUERY SELECT FALSE;
    ELSE
        RETURN QUERY SELECT TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;