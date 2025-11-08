-- Stored Procedure: sp_contratos_upd_undc_listar_tipos_aseo
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de aseo disponibles.
-- Generado para formulario: Contratos_Upd_UndC
-- Fecha: 2025-08-27 14:31:21

CREATE OR REPLACE FUNCTION sp_contratos_upd_undc_listar_tipos_aseo()
RETURNS TABLE (
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    cta_aplicacion INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion
    FROM ta_16_tipo_aseo
    ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;