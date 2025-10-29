-- Stored Procedure: sp16_tipos_aseo
-- Tipo: Catalog
-- Descripción: Catálogo de tipos de aseo
-- Generado para formulario: Licencias_Relacionadas
-- Fecha: 2025-08-27 14:41:43

-- PostgreSQL version for catálogo de tipos de aseo
CREATE OR REPLACE FUNCTION sp16_tipos_aseo() RETURNS TABLE(
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;