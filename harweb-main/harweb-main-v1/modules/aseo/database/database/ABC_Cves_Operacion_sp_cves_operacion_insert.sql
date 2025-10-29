-- Stored Procedure: sp_cves_operacion_insert
-- Tipo: CRUD
-- Descripción: Inserta una nueva clave de operación
-- Generado para formulario: ABC_Cves_Operacion
-- Fecha: 2025-08-27 13:21:19

CREATE OR REPLACE FUNCTION sp_cves_operacion_insert(
    p_cve_operacion varchar(1),
    p_descripcion varchar(80)
) RETURNS TABLE (
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion varchar(80)
) AS $$
DECLARE
    new_id integer;
BEGIN
    -- Validar unicidad de clave
    IF EXISTS (SELECT 1 FROM ta_16_operacion WHERE cve_operacion = p_cve_operacion) THEN
        RAISE EXCEPTION 'Ya existe una clave con ese valor';
    END IF;
    INSERT INTO ta_16_operacion (cve_operacion, descripcion)
    VALUES (p_cve_operacion, p_descripcion)
    RETURNING ctrol_operacion, cve_operacion, descripcion INTO new_id, p_cve_operacion, p_descripcion;
    RETURN QUERY SELECT new_id, p_cve_operacion, p_descripcion;
END;
$$ LANGUAGE plpgsql;