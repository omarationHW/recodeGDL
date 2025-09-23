-- Stored Procedure: sp_cves_operacion_update
-- Tipo: CRUD
-- Descripción: Actualiza una clave de operación existente
-- Generado para formulario: ABC_Cves_Operacion
-- Fecha: 2025-08-27 13:21:19

CREATE OR REPLACE FUNCTION sp_cves_operacion_update(
    p_ctrol_operacion integer,
    p_cve_operacion varchar(1),
    p_descripcion varchar(80)
) RETURNS TABLE (
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion varchar(80)
) AS $$
BEGIN
    UPDATE ta_16_operacion
    SET cve_operacion = p_cve_operacion,
        descripcion = p_descripcion
    WHERE ctrol_operacion = p_ctrol_operacion;
    RETURN QUERY SELECT ctrol_operacion, cve_operacion, descripcion
    FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
END;
$$ LANGUAGE plpgsql;