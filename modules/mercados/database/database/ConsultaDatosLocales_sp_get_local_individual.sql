-- Stored Procedure: sp_get_local_individual
-- Tipo: CRUD
-- Descripción: Devuelve todos los datos de un local individual
-- Generado para formulario: ConsultaDatosLocales
-- Fecha: 2025-08-26 23:26:39

CREATE OR REPLACE FUNCTION sp_get_local_individual(p_id_local integer)
RETURNS TABLE(
  id_local integer,
  oficina smallint,
  num_mercado smallint,
  categoria smallint,
  seccion text,
  local integer,
  letra_local text,
  bloque text,
  nombre text,
  arrendatario text,
  domicilio text,
  sector text,
  zona smallint,
  descripcion_local text,
  superficie float,
  giro smallint,
  fecha_alta date,
  fecha_baja date,
  fecha_modificacion timestamp,
  vigencia text,
  id_usuario integer,
  clave_cuota smallint
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, arrendatario, domicilio, sector, zona, descripcion_local, superficie, giro, fecha_alta, fecha_baja, fecha_modificacion, vigencia, id_usuario, clave_cuota
    FROM ta_11_locales
    WHERE id_local = p_id_local;
END; $$ LANGUAGE plpgsql;