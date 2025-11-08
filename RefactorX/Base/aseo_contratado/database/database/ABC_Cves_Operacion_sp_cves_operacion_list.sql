-- Stored Procedure: sp_cves_operacion_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de operación
-- Generado para formulario: ABC_Cves_Operacion
-- Fecha: 2025-08-27 13:21:19

CREATE OR REPLACE FUNCTION sp_cves_operacion_list()
RETURNS TABLE (
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion varchar(80)
) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_operacion, cve_operacion, descripcion
    FROM ta_16_operacion
    ORDER BY ctrol_operacion;
END;
$$ LANGUAGE plpgsql;