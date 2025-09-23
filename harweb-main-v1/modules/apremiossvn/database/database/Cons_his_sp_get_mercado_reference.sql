-- Stored Procedure: sp_get_mercado_reference
-- Tipo: Catalog
-- Descripción: Obtiene la referencia de mercado para un local dado.
-- Generado para formulario: Cons_his
-- Fecha: 2025-08-27 13:42:45

CREATE OR REPLACE FUNCTION sp_get_mercado_reference(p_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local smallint,
    letra_local varchar,
    bloque varchar,
    id_contribuy_prop integer,
    id_contribuy_renta integer,
    nombre varchar,
    arrendatario varchar,
    domicilio varchar,
    sector varchar,
    zona smallint,
    descripcion_local varchar,
    superficie float,
    giro smallint,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    vigencia varchar,
    id_usuario integer,
    clave_cuota smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, id_contribuy_prop, id_contribuy_renta, nombre, arrendatario, domicilio, sector, zona, descripcion_local, superficie, giro, fecha_alta, fecha_baja, fecha_modificacion, vigencia, id_usuario, clave_cuota
    FROM ta_11_locales
    WHERE id_local = p_local;
END;
$$ LANGUAGE plpgsql;