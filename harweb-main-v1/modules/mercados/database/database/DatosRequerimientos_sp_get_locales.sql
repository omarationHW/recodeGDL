-- Stored Procedure: sp_get_locales
-- Tipo: Catalog
-- Descripción: Obtiene los datos de un local por id_local
-- Generado para formulario: DatosRequerimientos
-- Fecha: 2025-08-26 23:47:56

CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    descripcion_local varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, letra_local, bloque, nombre, descripcion_local
    FROM ta_11_locales
    WHERE id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;