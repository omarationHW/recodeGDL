-- Stored Procedure: buscar_local_energia_mtto
-- Tipo: CRUD
-- Descripción: Busca un local para alta de energía, verifica que no tenga energía registrada
-- Generado para formulario: EnergiaMtto
-- Fecha: 2025-08-26 23:57:51

CREATE OR REPLACE FUNCTION buscar_local_energia_mtto(
  p_oficina integer, p_num_mercado integer, p_categoria integer, p_seccion text, p_local integer, p_letra_local text, p_bloque text, p_user integer
) RETURNS TABLE(id_local integer, oficina integer, num_mercado integer, categoria integer, seccion text, local integer, letra_local text, bloque text) AS $$
BEGIN
  RETURN QUERY
    SELECT l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque
    FROM ta_11_locales l
    LEFT JOIN ta_11_energia e ON e.id_local = l.id_local
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local IS NULL OR l.letra_local = p_letra_local)
      AND (l.bloque IS NULL OR l.bloque = p_bloque)
      AND e.id_energia IS NULL
    LIMIT 1;
END; $$ LANGUAGE plpgsql;