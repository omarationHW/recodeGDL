-- Stored Procedure: check_rfc_exists
-- Tipo: Catalog
-- Descripción: Verifica si un RFC ya existe en la tabla ta14_personas.
-- Generado para formulario: sfrm_abc_propietario
-- Fecha: 2025-08-27 14:05:45

CREATE OR REPLACE FUNCTION check_rfc_exists(p_rfc VARCHAR)
RETURNS TABLE (rfc_exists BOOLEAN)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT EXISTS(SELECT 1 FROM ta14_personas WHERE rfc = UPPER(TRIM(p_rfc)));
END;
$$;