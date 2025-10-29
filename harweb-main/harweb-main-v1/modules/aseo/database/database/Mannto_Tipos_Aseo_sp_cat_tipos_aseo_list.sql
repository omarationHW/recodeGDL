-- Stored Procedure: sp_cat_tipos_aseo_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de aseo
-- Generado para formulario: Mannto_Tipos_Aseo
-- Fecha: 2025-08-27 14:50:41

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_list()
RETURNS TABLE (
    ctrol_aseo integer,
    tipo_aseo varchar(1),
    descripcion varchar(80),
    cta_aplicacion integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion
    FROM ta_16_tipo_aseo
    ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;