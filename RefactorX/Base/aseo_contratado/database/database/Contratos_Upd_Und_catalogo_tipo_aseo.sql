-- Stored Procedure: catalogo_tipo_aseo
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de tipos de aseo.
-- Generado para formulario: Contratos_Upd_Und
-- Fecha: 2025-08-27 14:29:48

CREATE OR REPLACE FUNCTION catalogo_tipo_aseo()
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