-- Stored Procedure: sp_consulta_general_buscar_local
-- Tipo: CRUD
-- Descripción: Busca locales por parámetros principales
-- Generado para formulario: ConsultaGeneral
-- Fecha: 2025-08-27 20:45:14

CREATE OR REPLACE FUNCTION sp_consulta_general_buscar_local(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar DEFAULT NULL,
    p_bloque varchar DEFAULT NULL
) RETURNS TABLE(
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    arrendatario varchar,
    domicilio varchar,
    sector varchar,
    zona integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, arrendatario, domicilio, sector, zona
    FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND ( (p_letra_local IS NULL AND letra_local IS NULL) OR letra_local = p_letra_local )
      AND ( (p_bloque IS NULL AND bloque IS NULL) OR bloque = p_bloque );
END;
$$ LANGUAGE plpgsql;