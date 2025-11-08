-- Stored Procedure: sp_buscar_locales_nombre
-- Tipo: CRUD
-- Descripción: Busca locales por nombre (LIKE, mayúsculas)
-- Generado para formulario: ConsultaDatosLocales
-- Fecha: 2025-08-26 23:26:39

CREATE OR REPLACE FUNCTION sp_buscar_locales_nombre(p_nombre text)
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
  RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre
    FROM ta_11_locales
    WHERE upper(nombre) LIKE upper(p_nombre) || '%'
    ORDER BY nombre ASC;
END; $$ LANGUAGE plpgsql;