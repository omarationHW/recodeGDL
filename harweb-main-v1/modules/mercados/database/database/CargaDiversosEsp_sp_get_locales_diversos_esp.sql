-- Stored Procedure: sp_get_locales_diversos_esp
-- Tipo: Catalog
-- Descripción: Obtiene información de un local específico para validación de pagos.
-- Generado para formulario: CargaDiversosEsp
-- Fecha: 2025-08-26 22:49:31

CREATE OR REPLACE FUNCTION sp_get_locales_diversos_esp(
    p_oficina INTEGER,
    p_num_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER,
    p_letra_local VARCHAR,
    p_bloque VARCHAR
)
RETURNS TABLE(
    id_local INTEGER,
    oficina INTEGER,
    num_mercado INTEGER,
    categoria INTEGER,
    seccion VARCHAR,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque
    FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND (letra_local = p_letra_local OR (p_letra_local IS NULL AND letra_local IS NULL))
      AND (bloque = p_bloque OR (p_bloque IS NULL AND bloque IS NULL));
END;
$$ LANGUAGE plpgsql;