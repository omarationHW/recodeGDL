-- Stored Procedure: rpt_colonias_list
-- Tipo: Report
-- Descripción: Devuelve el catálogo de colonias con su zona asociada, para reporte.
-- Generado para formulario: RptColonias
-- Fecha: 2025-08-27 15:35:13

CREATE OR REPLACE FUNCTION rpt_colonias_list()
RETURNS TABLE (
    colonia smallint,
    descripcion varchar(50),
    id_rec smallint,
    id_zona integer,
    col_obra94 smallint,
    id_usuario integer,
    fecha_actual timestamp,
    zona varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.colonia, a.descripcion, a.id_rec, a.id_zona, a.col_obra94, a.id_usuario, a.fecha_actual, UPPER(b.zona) AS zona
    FROM ta_17_colonias a
    JOIN ta_12_zonas b ON a.id_zona = b.id_zona
    ORDER BY a.colonia;
END;
$$ LANGUAGE plpgsql;