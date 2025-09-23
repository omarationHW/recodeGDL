-- Stored Procedure: rpt_calles_get_by_axo
-- Tipo: Report
-- Descripción: Obtiene el catálogo de calles y colonias para un año de obra específico, incluyendo estado calculado.
-- Generado para formulario: RptCalles
-- Fecha: 2025-08-27 15:32:04

CREATE OR REPLACE FUNCTION rpt_calles_get_by_axo(p_axo smallint)
RETURNS TABLE (
    colonia smallint,
    calle smallint,
    desc_calle varchar(50),
    vigencia_obra char(1),
    axo_obra smallint,
    descripcion varchar(50),
    descripcion_1 varchar(50),
    descripcion_2 varchar(50),
    estado varchar(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.colonia,
        a.calle,
        a.desc_calle,
        a.vigencia_obra,
        a.axo_obra,
        b.descripcion,
        c.descripcion as descripcion_1,
        d.descripcion as descripcion_2,
        CASE WHEN a.vigencia_obra = 'A' THEN 'VIGENTE' ELSE 'CANCELADA' END as estado
    FROM ta_17_calles a
    JOIN ta_17_servicios b ON a.servicio = b.servicio
    JOIN ta_17_colonias c ON a.colonia = c.colonia
    JOIN ta_17_tipos d ON a.tipo = d.tipo
    WHERE a.axo_obra = p_axo
    GROUP BY a.colonia, a.calle, a.desc_calle, a.vigencia_obra, a.axo_obra, b.descripcion, c.descripcion, d.descripcion
    ORDER BY a.colonia, a.calle, a.desc_calle, a.vigencia_obra, a.axo_obra, b.descripcion, c.descripcion, d.descripcion;
END;
$$ LANGUAGE plpgsql;