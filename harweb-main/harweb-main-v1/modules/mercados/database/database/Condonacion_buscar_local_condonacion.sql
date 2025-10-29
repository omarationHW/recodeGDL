-- Stored Procedure: buscar_local_condonacion
-- Tipo: CRUD
-- Descripción: Busca un local activo y vigente para condonación según los parámetros.
-- Generado para formulario: Condonacion
-- Fecha: 2025-08-26 23:10:57

CREATE OR REPLACE FUNCTION buscar_local_condonacion(
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
    descripcion_local varchar,
    superficie numeric,
    clave_cuota integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, descripcion_local, superficie, clave_cuota
    FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND (letra_local = p_letra_local OR (p_letra_local IS NULL AND letra_local IS NULL))
      AND (bloque = p_bloque OR (p_bloque IS NULL AND bloque IS NULL))
      AND vigencia = 'A' AND bloqueo < 4
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;