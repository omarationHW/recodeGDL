-- Stored Procedure: sp_get_tipo_aseo
-- Tipo: Catalog
-- Descripción: Devuelve todos los tipos de aseo activos para el combo.
-- Generado para formulario: Pagos_Cons_ContAsc
-- Fecha: 2025-08-27 15:00:04

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo()
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