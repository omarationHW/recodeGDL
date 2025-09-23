-- Stored Procedure: get_tipo_aseo_catalog
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de tipos de aseo.
-- Generado para formulario: Rep_AdeudCond
-- Fecha: 2025-08-27 15:05:40

CREATE OR REPLACE FUNCTION get_tipo_aseo_catalog()
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