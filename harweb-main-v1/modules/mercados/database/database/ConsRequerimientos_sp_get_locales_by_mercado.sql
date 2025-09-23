-- Stored Procedure: sp_get_locales_by_mercado
-- Tipo: Catalog
-- Descripción: Obtiene locales por mercado y filtros
-- Generado para formulario: ConsRequerimientos
-- Fecha: 2025-08-26 23:23:01

CREATE OR REPLACE FUNCTION sp_get_locales_by_mercado(
    p_oficina smallint,
    p_num_mercado smallint,
    p_categoria smallint,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    calcregistro varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque,
        (oficina||'-'||num_mercado||'-'||categoria||'-'||seccion||'-'||local||'-'||COALESCE(letra_local,' ')||'-'||COALESCE(bloque,' ')) AS calcregistro
    FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND (p_letra_local IS NULL OR letra_local = p_letra_local OR (p_letra_local = '' AND letra_local IS NULL))
      AND (p_bloque IS NULL OR bloque = p_bloque OR (p_bloque = '' AND bloque IS NULL));
END;
$$ LANGUAGE plpgsql;