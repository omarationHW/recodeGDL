-- Stored Procedure: get_locales
-- Tipo: CRUD
-- Descripción: Obtiene locales filtrados por parámetros
-- Generado para formulario: LocalesMtto
-- Fecha: 2025-08-27 00:12:40

CREATE OR REPLACE FUNCTION get_locales(
  oficina integer, num_mercado integer, categoria integer, seccion text, local integer, letra_local text, bloque text
) RETURNS SETOF ta_11_locales AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM ta_11_locales
    WHERE oficina = get_locales.oficina
      AND num_mercado = get_locales.num_mercado
      AND categoria = get_locales.categoria
      AND seccion = get_locales.seccion
      AND local = get_locales.local
      AND (letra_local = get_locales.letra_local OR (get_locales.letra_local IS NULL AND letra_local IS NULL))
      AND (bloque = get_locales.bloque OR (get_locales.bloque IS NULL AND bloque IS NULL));
END; $$ LANGUAGE plpgsql;