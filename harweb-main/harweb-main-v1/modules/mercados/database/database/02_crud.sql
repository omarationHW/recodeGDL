CREATE OR REPLACE FUNCTION sp_consulta_general_buscar_local(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar DEFAULT NULL,
    p_bloque varchar DEFAULT NULL
) RETURNS TABLE(
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    arrendatario varchar,
    domicilio varchar,
    sector varchar,
    zona integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, arrendatario, domicilio, sector, zona
    FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND ( (p_letra_local IS NULL AND letra_local IS NULL) OR letra_local = p_letra_local )
      AND ( (p_bloque IS NULL AND bloque IS NULL) OR bloque = p_bloque );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consulta_general_detalle_local(
    p_id_local integer
) RETURNS TABLE(
    id_local integer,
    mercado varchar,
    nombre varchar,
    arrendatario varchar,
    domicilio varchar,
    sector varchar,
    zona integer,
    descripcion_local varchar,
    superficie numeric,
    giro integer,
    fecha_alta date,
    fecha_baja date,
    vigencia varchar,
    usuario varchar,
    renta numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_local, m.descripcion as mercado, l.nombre, l.arrendatario, l.domicilio, l.sector, l.zona, l.descripcion_local, l.superficie, l.giro, l.fecha_alta, l.fecha_baja, l.vigencia, u.usuario, c.importe_cuota * l.superficie as renta
    FROM ta_11_locales l
    LEFT JOIN ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN ta_12_passwords u ON l.id_usuario = u.id_usuario
    LEFT JOIN ta_11_cuo_locales c ON c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND c.categoria = l.categoria AND c.seccion = l.seccion AND c.clave_cuota = l.clave_cuota
    WHERE l.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consulta_general_adeudos_local(
    p_id_local integer
) RETURNS TABLE(
    axo integer,
    periodo integer,
    importe numeric,
    recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.axo, a.periodo, a.importe,
      COALESCE((a.importe * (
        SELECT SUM(porcentaje_mes) FROM ta_12_recargos r
        WHERE (r.axo = a.axo AND r.mes >= a.periodo)
      ) / 100), 0) as recargos
    FROM ta_11_adeudo_local a
    WHERE a.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consulta_general_pagos_local(
    p_id_local integer
) RETURNS TABLE(
    axo integer,
    periodo integer,
    fecha_pago date,
    importe_pago numeric,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.axo, p.periodo, p.fecha_pago, p.importe_pago, u.usuario
    FROM ta_11_pagos_local p
    LEFT JOIN ta_12_passwords u ON p.id_usuario = u.id_usuario
    WHERE p.id_local = p_id_local
    ORDER BY p.axo, p.periodo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consulta_general_requerimientos_local(
    p_id_local integer
) RETURNS TABLE(
    folio integer,
    fecha_emision date,
    importe_multa numeric,
    importe_gastos numeric,
    vigencia varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.folio, r.fecha_emision, r.importe_multa, r.importe_gastos, r.vigencia
    FROM ta_15_apremios r
    WHERE r.control_otr = p_id_local
    ORDER BY r.folio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_add_categoria(_descripcion varchar)
RETURNS TABLE(categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
DECLARE
  new_id integer;
BEGIN
  SELECT COALESCE(MAX(categoria),0)+1 INTO new_id FROM ta_11_categoria;
  INSERT INTO ta_11_categoria (categoria, descripcion) VALUES (new_id, UPPER(_descripcion));
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria WHERE categoria = new_id;
END; $$;

CREATE OR REPLACE FUNCTION sp_update_categoria(_categoria integer, _descripcion varchar)
RETURNS TABLE(categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_categoria SET descripcion = UPPER(_descripcion) WHERE categoria = _categoria;
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria WHERE categoria = _categoria;
END; $$;

CREATE OR REPLACE FUNCTION sp_add_seccion(_seccion varchar, _descripcion varchar)
RETURNS TABLE(seccion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_secciones (seccion, descripcion) VALUES (UPPER(_seccion), UPPER(_descripcion));
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones WHERE seccion = UPPER(_seccion);
END; $$;

CREATE OR REPLACE FUNCTION sp_update_seccion(_seccion varchar, _descripcion varchar)
RETURNS TABLE(seccion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_secciones SET descripcion = UPPER(_descripcion) WHERE seccion = UPPER(_seccion);
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones WHERE seccion = UPPER(_seccion);
END; $$;

CREATE OR REPLACE FUNCTION sp_add_cve_cuota(_clave integer, _descripcion varchar)
RETURNS TABLE(clave_cuota integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_cve_cuota (clave_cuota, descripcion) VALUES (_clave, UPPER(_descripcion));
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota WHERE clave_cuota = _clave;
END; $$;

CREATE OR REPLACE FUNCTION sp_update_cve_cuota(_clave integer, _descripcion varchar)
RETURNS TABLE(clave_cuota integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_cve_cuota SET descripcion = UPPER(_descripcion) WHERE clave_cuota = _clave;
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota WHERE clave_cuota = _clave;
END; $$;

CREATE OR REPLACE FUNCTION sp_add_mercado(_oficina integer, _num_mercado_nvo integer, _categoria integer, _descripcion varchar, _cuenta_ingreso integer, _cuenta_energia integer, _zona integer, _tipo_emision varchar)
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_mercados (oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision)
  VALUES (_oficina, _num_mercado_nvo, _categoria, UPPER(_descripcion), _cuenta_ingreso, _cuenta_energia, _zona, _tipo_emision);
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion FROM ta_11_mercados WHERE oficina = _oficina AND num_mercado_nvo = _num_mercado_nvo;
END; $$;

CREATE OR REPLACE FUNCTION sp_update_mercado(_oficina integer, _num_mercado_nvo integer, _categoria integer, _descripcion varchar, _cuenta_ingreso integer, _cuenta_energia integer, _zona integer, _tipo_emision varchar)
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_mercados SET categoria=_categoria, descripcion=UPPER(_descripcion), cuenta_ingreso=_cuenta_ingreso, cuenta_energia=_cuenta_energia, id_zona=_zona, tipo_emision=_tipo_emision
  WHERE oficina=_oficina AND num_mercado_nvo=_num_mercado_nvo;
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion FROM ta_11_mercados WHERE oficina=_oficina AND num_mercado_nvo=_num_mercado_nvo;
END; $$;