-- Stored Procedure: buscar_local
-- Tipo: CRUD
-- Descripción: Busca si existe un local con los datos dados
-- Generado para formulario: LocalesMtto
-- Fecha: 2025-08-27 00:12:40

CREATE OR REPLACE FUNCTION buscar_local(
  oficina integer, num_mercado integer, categoria integer, seccion text, local integer, letra_local text, bloque text
) RETURNS SETOF ta_11_locales AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM ta_11_locales
    WHERE oficina = buscar_local.oficina
      AND num_mercado = buscar_local.num_mercado
      AND categoria = buscar_local.categoria
      AND seccion = buscar_local.seccion
      AND local = buscar_local.local
      AND (letra_local = buscar_local.letra_local OR (buscar_local.letra_local IS NULL AND letra_local IS NULL))
      AND (bloque = buscar_local.bloque OR (buscar_local.bloque IS NULL AND bloque IS NULL));
END; $$ LANGUAGE plpgsql;