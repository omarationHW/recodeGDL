-- Stored Procedure: sp_adeudos_pagmult_listar_catalogos
-- Tipo: Catalog
-- Descripción: Devuelve catálogos de tipos de aseo, recaudadoras y cajas para el formulario de pagos múltiples.
-- Generado para formulario: Adeudos_PagMult
-- Fecha: 2025-08-27 13:51:30

-- No es necesario un SP, pero si se requiere:
CREATE OR REPLACE FUNCTION sp_adeudos_pagmult_listar_catalogos()
RETURNS TABLE(
    ctrol_aseo integer, tipo_aseo varchar, descripcion varchar,
    id_rec integer, recaudadora varchar,
    caja varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.ctrol_aseo, t.tipo_aseo, t.descripcion, NULL::integer, NULL::varchar, NULL::varchar FROM ta_16_tipo_aseo t
    UNION ALL
    SELECT NULL, NULL, NULL, r.id_rec, r.recaudadora, NULL FROM ta_12_recaudadoras r
    UNION ALL
    SELECT NULL, NULL, NULL, NULL, NULL, o.caja FROM ta_12_operaciones o;
END;
$$ LANGUAGE plpgsql;