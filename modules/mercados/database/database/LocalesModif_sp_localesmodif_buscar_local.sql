-- Stored Procedure: sp_localesmodif_buscar_local
-- Tipo: CRUD
-- Descripción: Busca un local por criterios únicos (oficina, mercado, categoria, seccion, local, letra, bloque)
-- Generado para formulario: LocalesModif
-- Fecha: 2025-08-27 00:10:52

CREATE OR REPLACE FUNCTION sp_localesmodif_buscar_local(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
) RETURNS TABLE (
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    domicilio varchar,
    sector varchar,
    zona integer,
    descripcion_local varchar,
    superficie numeric,
    giro integer,
    fecha_alta date,
    fecha_baja date,
    vigencia varchar,
    clave_cuota integer,
    bloqueo integer,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, domicilio, sector, zona, descripcion_local, superficie, giro, fecha_alta, fecha_baja, vigencia, clave_cuota, bloqueo, id_usuario
    FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND (letra_local = p_letra_local OR (letra_local IS NULL AND p_letra_local IS NULL))
      AND (bloque = p_bloque OR (bloque IS NULL AND p_bloque IS NULL))
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;