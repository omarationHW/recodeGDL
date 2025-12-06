-- Stored Procedure: sp_get_locales
-- Tipo: Catalog
-- Descripción: Obtiene los datos de un local por id_local
-- Generado para formulario: DatosRequerimientos
-- Fecha: 2025-08-26 23:47:56

DROP FUNCTION IF EXISTS sp_get_locales(integer);

CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion char(2),
    letra_local varchar(3),
    bloque varchar(2),
    nombre varchar(60),
    descripcion_local char(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.letra_local, a.bloque, a.nombre, a.descripcion_local
    FROM publico.ta_11_locales a
    WHERE a.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;