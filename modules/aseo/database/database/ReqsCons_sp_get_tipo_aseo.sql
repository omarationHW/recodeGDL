-- Stored Procedure: sp_get_tipo_aseo
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de tipos de aseo.
-- Generado para formulario: ReqsCons
-- Fecha: 2025-08-27 20:45:14

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo()
RETURNS TABLE(ctrol_aseo INTEGER, tipo_aseo VARCHAR, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;