-- Stored Procedure: sp_subtipo_last_by_tipo
-- Tipo: Catalog
-- Descripción: Obtiene el último subtipo registrado para un tipo dado
-- Generado para formulario: SubTipo
-- Fecha: 2025-08-27 15:59:10

CREATE OR REPLACE FUNCTION sp_subtipo_last_by_tipo(p_tipo smallint)
RETURNS TABLE (
    tipo smallint,
    subtipo smallint,
    desc_subtipo varchar,
    cuenta_ingreso integer,
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT tipo, subtipo, desc_subtipo, cuenta_ingreso, id_usuario, fecha_actual
    FROM ta_17_subtipo_conv
    WHERE tipo = p_tipo
    ORDER BY subtipo DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;