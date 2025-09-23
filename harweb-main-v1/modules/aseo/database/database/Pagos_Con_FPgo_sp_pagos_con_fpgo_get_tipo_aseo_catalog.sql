-- Stored Procedure: sp_pagos_con_fpgo_get_tipo_aseo_catalog
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de tipos de aseo
-- Generado para formulario: Pagos_Con_FPgo
-- Fecha: 2025-08-27 15:02:16

CREATE OR REPLACE FUNCTION sp_pagos_con_fpgo_get_tipo_aseo_catalog()
RETURNS TABLE (
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion
    FROM ta_16_tipo_aseo
    ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;