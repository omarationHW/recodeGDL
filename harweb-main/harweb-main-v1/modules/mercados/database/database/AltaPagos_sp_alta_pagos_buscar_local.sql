-- Stored Procedure: sp_alta_pagos_buscar_local
-- Tipo: CRUD
-- Descripción: Busca un local vigente y no bloqueado según los parámetros.
-- Generado para formulario: AltaPagos
-- Fecha: 2025-08-26 20:25:40

CREATE OR REPLACE FUNCTION sp_alta_pagos_buscar_local(
    p_oficina integer, p_num_mercado integer, p_categoria integer, p_seccion text, p_local integer, p_letra_local text, p_bloque text
) RETURNS TABLE(
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion text,
    local integer,
    letra_local text,
    bloque text,
    superficie numeric,
    clave_cuota integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, superficie, clave_cuota
    FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND (letra_local IS NULL OR letra_local = NULLIF(p_letra_local, ''))
      AND (bloque IS NULL OR bloque = NULLIF(p_bloque, ''))
      AND vigencia = 'A'
      AND bloqueo < 4
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;