-- Stored Procedure: alta_local
-- Tipo: CRUD
-- Descripción: Da de alta un nuevo local, inserta en ta_11_locales, ta_11_movimientos y genera adeudos
-- Generado para formulario: LocalesMtto
-- Fecha: 2025-08-27 00:12:40

CREATE OR REPLACE FUNCTION alta_local(
  oficina integer, num_mercado integer, categoria integer, seccion text, local integer, letra_local text, bloque text,
  nombre text, domicilio text, sector text, zona integer, descripcion_local text, superficie numeric, giro integer,
  fecha_alta date, clave_cuota integer, id_usuario integer, vigencia text, numero_memo integer, axo integer
) RETURNS TABLE(id_local integer) AS $$
DECLARE
  new_id_local integer;
  peralt date;
  periodoalt text;
  m text;
  d text;
  aloalt integer;
  mesalt integer;
  diaalt integer;
  renta numeric;
BEGIN
  -- Insertar en ta_11_locales
  INSERT INTO ta_11_locales (
    oficina, num_mercado, categoria, seccion, local, letra_local, bloque, id_contribuy_prop, id_contribuy_renta,
    nombre, arrendatario, domicilio, sector, zona, descripcion_local, superficie, giro, fecha_alta, fecha_baja,
    fecha_modificacion, vigencia, id_usuario, clave_cuota, bloqueo
  ) VALUES (
    oficina, num_mercado, categoria, seccion, local, letra_local, bloque, 1, NULL,
    nombre, NULL, domicilio, sector, zona, descripcion_local, superficie, giro, fecha_alta, NULL,
    NOW(), vigencia, id_usuario, clave_cuota, 0
  ) RETURNING id_local INTO new_id_local;

  -- Insertar en ta_11_movimientos
  INSERT INTO ta_11_movimientos (
    id_local, axo_memo, numero_memo, nombre, arrendatario, domicilio, sector, zona, drescripcion_local, superficie,
    giro, fecha_alta, fecha_baja, vigencia, clave_cuota, tipo_movimiento, fecha, id_usuario, bloqueo
  ) VALUES (
    new_id_local, axo, numero_memo, nombre, NULL, domicilio, sector, zona, descripcion_local, superficie,
    giro, fecha_alta, NULL, vigencia, clave_cuota, 1, NOW(), id_usuario, 0
  );

  -- Generar adeudos desde fecha_alta hasta fecha actual
  peralt := fecha_alta;
  LOOP
    aloalt := EXTRACT(YEAR FROM peralt)::integer;
    mesalt := EXTRACT(MONTH FROM peralt)::integer;
    diaalt := EXTRACT(DAY FROM peralt)::integer;
    -- Obtener renta
    SELECT importe_cuota INTO renta FROM ta_11_cuo_locales
      WHERE axo = aloalt AND categoria = categoria AND seccion = seccion AND clave_cuota = clave_cuota LIMIT 1;
    IF renta IS NULL THEN
      renta := 0;
    END IF;
    -- Insertar adeudo
    INSERT INTO ta_11_adeudo_local (id_local, axo, periodo, importe, fecha_alta, id_usuario)
      VALUES (new_id_local, aloalt, mesalt, superficie * renta, NOW(), id_usuario);
    -- Siguiente mes
    peralt := peralt + INTERVAL '1 month';
    IF peralt > NOW()::date THEN
      EXIT;
    END IF;
  END LOOP;
  RETURN QUERY SELECT new_id_local;
END; $$ LANGUAGE plpgsql;