-- Stored Procedure: sp_get_locales_by_adeudo_row
-- Tipo: CRUD
-- Descripción: Obtiene el local correspondiente a una fila de adeudo (usado para validación antes de grabar pago).
-- Generado para formulario: CargaDiversosEsp
-- Fecha: 2025-08-26 19:48:04

CREATE OR REPLACE FUNCTION sp_get_locales_by_adeudo_row(
    p_oficina INTEGER,
    p_num_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER,
    p_letra_local VARCHAR,
    p_bloque VARCHAR,
    p_tipo_rbo VARCHAR
) RETURNS TABLE (
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
      AND (CASE WHEN p_letra_local IS NULL OR p_letra_local = '' THEN letra_local IS NULL ELSE letra_local = p_letra_local END)
      AND (bloque IS NULL);
END;
$$ LANGUAGE plpgsql;