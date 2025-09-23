-- Stored Procedure: sp_buscar_locales
-- Tipo: CRUD
-- Descripción: Busca locales por filtros (oficina, mercado, etc)
-- Generado para formulario: ConsultaDatosLocales
-- Fecha: 2025-08-26 23:26:39

CREATE OR REPLACE FUNCTION sp_buscar_locales(
  p_oficina smallint,
  p_num_mercado smallint,
  p_categoria smallint,
  p_seccion text,
  p_local integer,
  p_letra_local text,
  p_bloque text,
  p_orden text
)
RETURNS TABLE(
  id_local integer,
  oficina smallint,
  num_mercado smallint,
  categoria smallint,
  seccion text,
  local integer,
  letra_local text,
  bloque text,
  nombre text
) AS $$
BEGIN
  RETURN QUERY EXECUTE format('
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre
    FROM ta_11_locales
    WHERE ($1::smallint IS NULL OR oficina = $1)
      AND ($2::smallint IS NULL OR num_mercado = $2)
      AND ($3::smallint IS NULL OR categoria = $3)
      AND ($4::text IS NULL OR seccion = $4)
      AND ($5::integer IS NULL OR local = $5)
      AND ($6::text IS NULL OR (letra_local = $6 OR ($6 = '''' AND letra_local IS NULL)))
      AND ($7::text IS NULL OR (bloque = $7 OR ($7 = '''' AND bloque IS NULL)))
    ORDER BY ' || coalesce(p_orden, 'oficina,num_mercado,categoria,seccion,local,letra_local,bloque')
  )
  USING p_oficina, p_num_mercado, p_categoria, p_seccion, p_local, p_letra_local, p_bloque;
END; $$ LANGUAGE plpgsql;