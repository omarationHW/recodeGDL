-- ============================================
-- SCRIPT MAESTRO DE STORED PROCEDURES
-- Proyecto: mercados
-- Generado: 2025-08-27 20:48:45
-- Total SPs: 25
-- ============================================

-- NOTA: Ejecutar este script en PostgreSQL para crear todos los stored procedures
-- del módulo. Se recomienda ejecutar en el siguiente orden:
-- 1. CATALOG procedures (consultas básicas)
-- 2. CRUD procedures (operaciones de datos)
-- 3. PROCESS procedures (procesos de negocio)
-- 4. REPORT procedures (reportes y análisis)

-- ============================================
-- STORED PROCEDURES TIPO: Catalog
-- ============================================

-- SP 1/4 del tipo Catalog
-- Nombre: sp_get_categorias
-- Descripción: Obtiene todas las categorías
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_categorias()
RETURNS TABLE(categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria ORDER BY categoria;
END; $$;

-- --------------------------------------------

-- SP 2/4 del tipo Catalog
-- Nombre: sp_get_cve_cuotas
-- Descripción: Obtiene todas las claves de cuota
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cve_cuotas()
RETURNS TABLE(clave_cuota integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota ORDER BY clave_cuota;
END; $$;

-- --------------------------------------------

-- SP 3/4 del tipo Catalog
-- Nombre: sp_get_mercados
-- Descripción: Obtiene todos los mercados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercados()
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar, cuenta_ingreso integer, cuenta_energia integer, id_zona integer, tipo_emision varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision FROM ta_11_mercados ORDER BY oficina, num_mercado_nvo;
END; $$;

-- --------------------------------------------

-- SP 4/4 del tipo Catalog
-- Nombre: sp_get_secciones
-- Descripción: Obtiene todas las secciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_secciones()
RETURNS TABLE(seccion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion;
END; $$;

-- --------------------------------------------

-- ============================================
-- STORED PROCEDURES TIPO: CRUD
-- ============================================

-- SP 1/13 del tipo CRUD
-- Nombre: sp_add_categoria
-- Descripción: Agrega una nueva categoría
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 2/13 del tipo CRUD
-- Nombre: sp_add_cve_cuota
-- Descripción: Agrega una nueva clave de cuota
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_cve_cuota(_clave integer, _descripcion varchar)
RETURNS TABLE(clave_cuota integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_cve_cuota (clave_cuota, descripcion) VALUES (_clave, UPPER(_descripcion));
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota WHERE clave_cuota = _clave;
END; $$;

-- --------------------------------------------

-- SP 3/13 del tipo CRUD
-- Nombre: sp_add_mercado
-- Descripción: Agrega un nuevo mercado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_mercado(_oficina integer, _num_mercado_nvo integer, _categoria integer, _descripcion varchar, _cuenta_ingreso integer, _cuenta_energia integer, _zona integer, _tipo_emision varchar)
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_mercados (oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision)
  VALUES (_oficina, _num_mercado_nvo, _categoria, UPPER(_descripcion), _cuenta_ingreso, _cuenta_energia, _zona, _tipo_emision);
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion FROM ta_11_mercados WHERE oficina = _oficina AND num_mercado_nvo = _num_mercado_nvo;
END; $$;

-- --------------------------------------------

-- SP 4/13 del tipo CRUD
-- Nombre: sp_add_seccion
-- Descripción: Agrega una nueva sección
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_seccion(_seccion varchar, _descripcion varchar)
RETURNS TABLE(seccion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_secciones (seccion, descripcion) VALUES (UPPER(_seccion), UPPER(_descripcion));
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones WHERE seccion = UPPER(_seccion);
END; $$;

-- --------------------------------------------

-- SP 5/13 del tipo CRUD
-- Nombre: sp_consulta_general_adeudos_local
-- Descripción: Obtiene adeudos de un local
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 6/13 del tipo CRUD
-- Nombre: sp_consulta_general_buscar_local
-- Descripción: Busca locales por parámetros principales
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 7/13 del tipo CRUD
-- Nombre: sp_consulta_general_detalle_local
-- Descripción: Obtiene detalle completo de un local
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 8/13 del tipo CRUD
-- Nombre: sp_consulta_general_pagos_local
-- Descripción: Obtiene pagos de un local
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 9/13 del tipo CRUD
-- Nombre: sp_consulta_general_requerimientos_local
-- Descripción: Obtiene requerimientos de un local
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 10/13 del tipo CRUD
-- Nombre: sp_update_categoria
-- Descripción: Actualiza una categoría existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_categoria(_categoria integer, _descripcion varchar)
RETURNS TABLE(categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_categoria SET descripcion = UPPER(_descripcion) WHERE categoria = _categoria;
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria WHERE categoria = _categoria;
END; $$;

-- --------------------------------------------

-- SP 11/13 del tipo CRUD
-- Nombre: sp_update_cve_cuota
-- Descripción: Actualiza una clave de cuota existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_cve_cuota(_clave integer, _descripcion varchar)
RETURNS TABLE(clave_cuota integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_cve_cuota SET descripcion = UPPER(_descripcion) WHERE clave_cuota = _clave;
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota WHERE clave_cuota = _clave;
END; $$;

-- --------------------------------------------

-- SP 12/13 del tipo CRUD
-- Nombre: sp_update_mercado
-- Descripción: Actualiza un mercado existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_mercado(_oficina integer, _num_mercado_nvo integer, _categoria integer, _descripcion varchar, _cuenta_ingreso integer, _cuenta_energia integer, _zona integer, _tipo_emision varchar)
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_mercados SET categoria=_categoria, descripcion=UPPER(_descripcion), cuenta_ingreso=_cuenta_ingreso, cuenta_energia=_cuenta_energia, id_zona=_zona, tipo_emision=_tipo_emision
  WHERE oficina=_oficina AND num_mercado_nvo=_num_mercado_nvo;
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion FROM ta_11_mercados WHERE oficina=_oficina AND num_mercado_nvo=_num_mercado_nvo;
END; $$;

-- --------------------------------------------

-- SP 13/13 del tipo CRUD
-- Nombre: sp_update_seccion
-- Descripción: Actualiza una sección existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_seccion(_seccion varchar, _descripcion varchar)
RETURNS TABLE(seccion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_secciones SET descripcion = UPPER(_descripcion) WHERE seccion = UPPER(_seccion);
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones WHERE seccion = UPPER(_seccion);
END; $$;

-- --------------------------------------------

-- ============================================
-- STORED PROCEDURES TIPO: Report
-- ============================================

-- SP 1/8 del tipo Report
-- Nombre: sp_get_fecha_descuento
-- Descripción: Obtiene la fecha de descuento para un mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_fecha_descuento(p_mes integer)
RETURNS TABLE(
  fecha_descuento date,
  fecha_recargos date
) AS $$
BEGIN
  RETURN QUERY
  SELECT fecha_descuento, fecha_recargos FROM ta_11_fecha_desc WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 2/8 del tipo Report
-- Nombre: sp_get_locales_emision_laser
-- Descripción: Obtiene los locales para la emisión laser según filtros.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_locales_emision_laser(p_oficina integer, p_mercado integer, p_axo integer, p_periodo integer)
RETURNS TABLE(
  id_local integer,
  nombre varchar,
  descripcion_local varchar,
  meses varchar,
  rentaaxos numeric,
  recargos numeric,
  subtotal numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_local, a.nombre, a.descripcion_local, '' AS meses, 0 AS rentaaxos, 0 AS recargos, 0 AS subtotal
  FROM ta_11_locales a
  WHERE a.oficina = p_oficina AND a.num_mercado = p_mercado AND a.vigencia = 'A' AND a.bloqueo < 4;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 3/8 del tipo Report
-- Nombre: sp_get_mes_adeudo
-- Descripción: Obtiene los meses de adeudo de un local para un año.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mes_adeudo(p_id_local integer, p_axo integer)
RETURNS TABLE(
  id_adeudo_local integer,
  axo smallint,
  periodo smallint,
  importe numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_adeudo_local, axo, periodo, importe
  FROM ta_11_adeudo_local
  WHERE id_local = p_id_local AND axo = p_axo
  ORDER BY axo, periodo;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 4/8 del tipo Report
-- Nombre: sp_get_pagos_local
-- Descripción: Obtiene los pagos de un local para un año y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pagos_local(p_id_local integer, p_axo integer, p_periodo integer)
RETURNS TABLE(
  id_pago_local integer,
  fecha_pago date,
  importe_pago numeric,
  folio varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_pago_local, fecha_pago, importe_pago, folio
  FROM ta_11_pagos_local
  WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 5/8 del tipo Report
-- Nombre: sp_get_recargos_mes
-- Descripción: Obtiene los recargos de un año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recargos_mes(p_axo integer, p_mes integer)
RETURNS TABLE(
  porcentaje_mes numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT porcentaje_mes FROM ta_12_recargos WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 6/8 del tipo Report
-- Nombre: sp_get_requerimientos
-- Descripción: Obtiene los requerimientos de un local para un módulo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_requerimientos(p_modulo integer, p_id_local integer)
RETURNS TABLE(
  folio integer,
  importe_multa numeric,
  importe_gastos numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT folio, importe_multa, importe_gastos
  FROM ta_15_apremios
  WHERE modulo = p_modulo AND control_otr = p_id_local AND vigencia = '1' AND clave_practicado = 'P'
  ORDER BY folio;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 7/8 del tipo Report
-- Nombre: sp_get_subtotal_local
-- Descripción: Obtiene el subtotal de adeudo y recargos de un local.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_subtotal_local(p_id_local integer, p_axo integer, p_periodo integer)
RETURNS TABLE(
  adeudo numeric,
  recargos numeric,
  subtotalcalc numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT COALESCE(SUM(d.importe),0) AS adeudo,
         COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS recargos,
         COALESCE(SUM(d.importe),0) + COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS subtotalcalc
  FROM ta_11_adeudo_local d
  WHERE d.id_local = p_id_local AND ((d.axo = p_axo AND d.periodo < p_periodo) OR (d.axo < p_axo));
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 8/8 del tipo Report
-- Nombre: sp_rpt_emision_laser
-- Descripción: Obtiene el reporte principal de emisión laser para una oficina, año, periodo y mercado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpt_emision_laser(p_oficina integer, p_axo integer, p_periodo integer, p_mercado integer)
RETURNS TABLE(
  id_local integer,
  oficina smallint,
  num_mercado smallint,
  categoria smallint,
  seccion varchar,
  local smallint,
  letra_local varchar,
  bloque varchar,
  nombre varchar,
  descripcion_local varchar,
  axo smallint,
  categoria_1 smallint,
  seccion_1 varchar,
  clave_cuota smallint,
  importe_cuota numeric,
  axo_1 smallint,
  adeudo numeric,
  recargos numeric,
  subtotal numeric,
  rentaaxos numeric,
  meses varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, a.descripcion_local,
         c.axo, c.categoria, c.seccion, c.clave_cuota, c.importe_cuota, d.axo,
         COALESCE(SUM(d.importe),0) AS adeudo,
         COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS recargos,
         COALESCE(SUM(d.importe),0) + COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS subtotal,
         0 AS rentaaxos, -- Se calcula en frontend o con otro SP
         '' AS meses
  FROM ta_11_locales a
  JOIN ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
  JOIN ta_11_cuo_locales c ON a.categoria = c.categoria AND a.seccion = c.seccion AND a.clave_cuota = c.clave_cuota AND c.axo = p_axo
  LEFT JOIN ta_11_adeudo_local d ON a.id_local = d.id_local AND ((d.axo = p_axo AND d.periodo < p_periodo) OR (d.axo < p_axo))
  WHERE a.oficina = p_oficina AND a.num_mercado = p_mercado AND a.vigencia = 'A' AND a.bloqueo < 4
    AND a.id_local NOT IN (
      SELECT id_local FROM ta_11_pagos_local WHERE id_local = a.id_local AND axo = p_axo AND periodo = p_periodo
    )
  GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, a.descripcion_local,
           c.axo, c.categoria, c.seccion, c.clave_cuota, c.importe_cuota, d.axo
  ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, d.axo;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- ============================================
-- FIN DEL SCRIPT MAESTRO
-- Total de 25 stored procedures incluidos
-- ============================================
