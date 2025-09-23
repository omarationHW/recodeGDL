-- Stored Procedure: colonias_list
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo completo de colonias con zona y usuario.
-- Generado para formulario: Colonias
-- Fecha: 2025-08-27 14:05:29

CREATE OR REPLACE FUNCTION colonias_list()
RETURNS TABLE (
    colonia SMALLINT,
    descripcion VARCHAR,
    id_rec SMALLINT,
    id_zona INTEGER,
    col_obra94 SMALLINT,
    id_usuario INTEGER,
    fecha_actual TIMESTAMP,
    zona VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.colonia, a.descripcion, a.id_rec, a.id_zona, a.col_obra94, a.id_usuario, a.fecha_actual,
           upper(b.zona) as zona, c.usuario
    FROM ta_17_colonias a
    JOIN ta_12_zonas b ON a.id_zona = b.id_zona
    JOIN ta_12_passwords c ON a.id_usuario = c.id_usuario
    ORDER BY a.colonia;
END;
$$ LANGUAGE plpgsql;