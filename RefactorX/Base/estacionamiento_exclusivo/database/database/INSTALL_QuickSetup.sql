-- ============================================
-- INSTALACIÓN RÁPIDA DE STORED PROCEDURES
-- Proyecto: ApremiosSVN
-- Generado: 2025-08-27 20:59:09
-- ============================================

-- Este script contiene solo las definiciones de SPs sin comentarios
-- para una instalación rápida en producción

CREATE OR REPLACE FUNCTION date_to_words(p_date DATE)
RETURNS TEXT AS $$
DECLARE
    meses TEXT[] := ARRAY['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    dia INT;
    mes INT;
    anio INT;
BEGIN
    dia := EXTRACT(DAY FROM p_date);
    mes := EXTRACT(MONTH FROM p_date);
    anio := EXTRACT(YEAR FROM p_date);
    RETURN dia::TEXT || ' de ' || meses[mes] || ' de ' || anio::TEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_check_new_version(p_proyecto TEXT, p_version TEXT)
RETURNS TABLE (
    nueva_version BOOLEAN
) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_versiones WHERE proyecto = p_proyecto AND version = p_version) THEN
        RETURN QUERY SELECT FALSE;
    ELSE
        RETURN QUERY SELECT TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_apremio(p_modulo integer, p_folio integer, p_recaudadora integer)
RETURNS TABLE (
    id_control integer,
    zona smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado varchar,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    clave_secuestro smallint,
    clave_remate varchar,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    caja varchar,
    operacion integer,
    importe_pago numeric,
    vigencia varchar,
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        id_control, zona, modulo, control_otr, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos, zona_apremio, fecha_emision, clave_practicado, fecha_practicado, fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, clave_secuestro, clave_remate, fecha_remate, porcentaje_multa, observaciones, fecha_pago, recaudadora, caja, operacion, importe_pago, vigencia, fecha_actualiz, usuario, clave_mov
    FROM ta_15_apremios
    WHERE modulo = p_modulo AND folio = p_folio AND zona = p_recaudadora;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_user_by_credentials(p_usuario TEXT, p_clave TEXT)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario TEXT,
    nombre TEXT,
    estado TEXT,
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora TEXT,
    domicilio TEXT,
    tel TEXT,
    recaudador TEXT,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_usuario, a.usuario, a.nombre, a.estado, a.id_rec, b.id_zona, b.recaudadora, b.domicilio, b.tel, b.recaudador, a.nivel
    FROM ta_12_passwords a
    JOIN ta_12_recaudadoras b ON a.id_rec = b.id_rec
    WHERE a.usuario = p_usuario
      AND a.clave = p_clave
      AND a.estado = 'A';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_historial_apremio(p_id_control integer)
RETURNS TABLE (
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar,
    observaciones varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha_actualiz, usuario, clave_mov, observaciones
    FROM ta_15_historia
    WHERE id_control = p_id_control
    ORDER BY fecha_actualiz DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_lista_eje_get(p_rec integer, p_rec1 integer)
RETURNS TABLE (
    id_ejecutor integer,
    cve_eje integer,
    ini_rfc varchar(4),
    fec_rfc date,
    hom_rfc varchar(3),
    nombre varchar(60),
    id_rec smallint,
    categoria varchar(60),
    observacion varchar(60),
    oficio varchar(14),
    fecinic date,
    fecterm date,
    vigencia varchar(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_ejecutor, cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, categoria, observacion, oficio, fecinic, fecterm, vigencia
    FROM ta_15_ejecutores
    WHERE id_rec >= p_rec AND id_rec <= p_rec1
    ORDER BY id_rec, cve_eje;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listxFec_get_ejecutores(p_rec INT)
RETURNS TABLE(cve_eje INT, nombre VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT cve_eje, nombre FROM ta_15_ejecutores WHERE id_rec = p_rec ORDER BY cve_eje;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listxFec_get_recaudadoras()
RETURNS TABLE(id_rec INT, recaudadora VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listxFec_get_vigencias()
RETURNS TABLE(clave VARCHAR, descrip VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT clave, descrip FROM ta_15_claves WHERE tipo_clave=5 ORDER BY clave;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listxFec_report(
  p_rec INT,
  p_modulo INT,
  p_tipo_fecha INT, -- 1: actualiz, 2: practicado, 3: citado, 4: pago, 5: emision, 6: entrega
  p_fecha1 DATE,
  p_fecha2 DATE,
  p_vigencia VARCHAR,
  p_ejecutor VARCHAR
)
RETURNS TABLE(
  folio INT,
  fecha DATE,
  ejecutor_nombre VARCHAR,
  vigencia VARCHAR,
  importe_global NUMERIC,
  datos VARCHAR
) AS $$
DECLARE
  v_sql TEXT;
BEGIN
  v_sql := 'SELECT a.folio, ';
  CASE p_tipo_fecha
    WHEN 1 THEN v_sql := v_sql || 'a.fecha_actualiz AS fecha, '
    WHEN 2 THEN v_sql := v_sql || 'a.fecha_practicado AS fecha, '
    WHEN 3 THEN v_sql := v_sql || 'a.fecha_citatorio AS fecha, '
    WHEN 4 THEN v_sql := v_sql || 'a.fecha_pago AS fecha, '
    WHEN 5 THEN v_sql := v_sql || 'a.fecha_emision AS fecha, '
    WHEN 6 THEN v_sql := v_sql || 'a.fecha_entrega1 AS fecha, '
    ELSE v_sql := v_sql || 'a.fecha_actualiz AS fecha, '
  END CASE;
  v_sql := v_sql || 'b.nombre AS ejecutor_nombre, a.vigencia, a.importe_global, '
    || 'COALESCE(a.datos, '''') AS datos '
    || 'FROM ta_15_apremios a '
    || 'LEFT JOIN ta_15_ejecutores b ON a.ejecutor = b.cve_eje AND a.zona = b.id_rec '
    || 'WHERE a.zona = $1 ';
  IF p_modulo IS NOT NULL AND p_modulo <> 99 THEN
    v_sql := v_sql || 'AND a.modulo = $2 ';
  END IF;
  IF p_vigencia IS NOT NULL AND p_vigencia <> 'todas' THEN
    IF p_vigencia = '2' THEN
      v_sql := v_sql || 'AND (a.vigencia = ''2'' OR a.vigencia = ''P'') ';
    ELSE
      v_sql := v_sql || 'AND a.vigencia = $3 ';
    END IF;
  END IF;
  IF p_ejecutor IS NOT NULL AND p_ejecutor <> 'todos' AND p_ejecutor <> 'ninguno' THEN
    v_sql := v_sql || 'AND a.ejecutor = $4 ';
  END IF;
  -- Fecha filtro
  CASE p_tipo_fecha
    WHEN 1 THEN v_sql := v_sql || 'AND a.fecha_actualiz BETWEEN $5 AND $6 ';
    WHEN 2 THEN v_sql := v_sql || 'AND a.fecha_practicado BETWEEN $5 AND $6 ';
    WHEN 3 THEN v_sql := v_sql || 'AND a.fecha_citatorio BETWEEN $5 AND $6 ';
    WHEN 4 THEN v_sql := v_sql || 'AND a.fecha_pago BETWEEN $5 AND $6 ';
    WHEN 5 THEN v_sql := v_sql || 'AND a.fecha_emision BETWEEN $5 AND $6 ';
    WHEN 6 THEN v_sql := v_sql || 'AND a.fecha_entrega1 BETWEEN $5 AND $6 ';
    ELSE v_sql := v_sql || 'AND a.fecha_actualiz BETWEEN $5 AND $6 ';
  END CASE;
  v_sql := v_sql || 'ORDER BY a.folio';
  RETURN QUERY EXECUTE v_sql
    USING p_rec, p_modulo, p_vigencia, p_ejecutor, p_fecha1, p_fecha2;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_modificar_apremio(
    p_id_control integer,
    p_modulo integer,
    p_folio integer,
    p_usuario integer,
    p_params_json jsonb
) RETURNS TABLE (result text) AS $$
DECLARE
    v_old RECORD;
    v_new RECORD;
    v_hist_id integer;
BEGIN
    -- Obtener registro actual
    SELECT * INTO v_old FROM ta_15_apremios WHERE id_control = p_id_control AND modulo = p_modulo AND folio = p_folio;
    IF NOT FOUND THEN
        RETURN QUERY SELECT 'No existe el folio';
        RETURN;
    END IF;
    -- Actualizar registro
    UPDATE ta_15_apremios SET
        usuario = p_usuario,
        fecha_actualiz = CURRENT_DATE,
        zona_apremio = COALESCE((p_params_json->>'zona_apremio')::smallint, zona_apremio),
        observaciones = COALESCE(p_params_json->>'observaciones', observaciones),
        porcentaje_multa = COALESCE((p_params_json->>'porcentaje_multa')::smallint, porcentaje_multa),
        clave_mov = COALESCE(p_params_json->>'clave_mov', clave_mov),
        importe_gastos = COALESCE((p_params_json->>'importe_gastos')::numeric, importe_gastos),
        importe_multa = COALESCE((p_params_json->>'importe_multa')::numeric, importe_multa),
        clave_practicado = COALESCE(p_params_json->>'clave_practicado', clave_practicado),
        fecha_practicado = COALESCE((p_params_json->>'fecha_practicado')::date, fecha_practicado),
        hora_practicado = COALESCE((p_params_json->>'hora_practicado')::time, hora_practicado),
        fecha_citatorio = COALESCE((p_params_json->>'fecha_citatorio')::date, fecha_citatorio),
        hora = COALESCE((p_params_json->>'hora')::time, hora),
        ejecutor = COALESCE((p_params_json->>'ejecutor')::smallint, ejecutor),
        fecha_entrega1 = COALESCE((p_params_json->>'fecha_entrega1')::date, fecha_entrega1),
        fecha_entrega2 = COALESCE((p_params_json->>'fecha_entrega2')::date, fecha_entrega2),
        fecha_pago = COALESCE((p_params_json->>'fecha_pago')::date, fecha_pago),
        recaudadora = COALESCE((p_params_json->>'recaudadora')::smallint, recaudadora),
        caja = COALESCE(p_params_json->>'caja', caja),
        operacion = COALESCE((p_params_json->>'operacion')::integer, operacion),
        importe_pago = COALESCE((p_params_json->>'importe_pago')::numeric, importe_pago),
        clave_secuestro = COALESCE((p_params_json->>'clave_secuestro')::smallint, clave_secuestro),
        clave_remate = COALESCE(p_params_json->>'clave_remate', clave_remate),
        fecha_remate = COALESCE((p_params_json->>'fecha_remate')::date, fecha_remate),
        vigencia = COALESCE(p_params_json->>'vigencia', vigencia)
    WHERE id_control = p_id_control AND modulo = p_modulo AND folio = p_folio;
    -- Insertar historial
    INSERT INTO ta_15_historia (
        id_control, control, zona, modulo, control_otr, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos, zona_apremio, fecha_emision, clave_practicado, fecha_practicado, fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, clave_secuestro, clave_remate, fecha_remate, porcentaje_multa, observaciones, fecha_pago, recaudadora, caja, operacion, importe_pago, vigencia, fecha_actualiz, usuario, clave_mov, hora_practicado
    ) VALUES (
        v_old.id_control, v_old.control, v_old.zona, v_old.modulo, v_old.control_otr, v_old.folio, v_old.diligencia, v_old.importe_global, v_old.importe_multa, v_old.importe_recargo, v_old.importe_gastos, v_old.zona_apremio, v_old.fecha_emision, v_old.clave_practicado, v_old.fecha_practicado, v_old.fecha_entrega1, v_old.fecha_entrega2, v_old.fecha_citatorio, v_old.hora, v_old.ejecutor, v_old.clave_secuestro, v_old.clave_remate, v_old.fecha_remate, v_old.porcentaje_multa, v_old.observaciones, v_old.fecha_pago, v_old.recaudadora, v_old.caja, v_old.operacion, v_old.importe_pago, v_old.vigencia, v_old.fecha_actualiz, v_old.usuario, v_old.clave_mov, v_old.hora_practicado
    );
    RETURN QUERY SELECT 'ok';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION spd_12_gastoscob(p_fechad DATE, p_fechah DATE, p_rec INTEGER)
RETURNS TABLE (
    r_fecp DATE,
    r_rec INTEGER,
    r_caja VARCHAR(2),
    r_oper INTEGER,
    r_imptecta NUMERIC,
    r_totcert NUMERIC,
    r_folio INTEGER,
    r_ofnaf INTEGER,
    r_fecemi DATE,
    r_fecpra DATE,
    r_fecent DATE,
    r_imptegf NUMERIC,
    r_ejecutor INTEGER,
    r_nomeje VARCHAR(70),
    r_datos VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.fecha AS r_fecp,
        p.id_rec AS r_rec,
        p.caja AS r_caja,
        p.operacion AS r_oper,
        p.impte_gastos AS r_imptecta,
        p.importe AS r_totcert,
        a.folio AS r_folio,
        a.recaudadora AS r_ofnaf,
        a.fecha_emision AS r_fecemi,
        a.fecha_practicado AS r_fecpra,
        a.fecha_entrega1 AS r_fecent,
        a.importe_gastos AS r_imptegf,
        a.ejecutor AS r_ejecutor,
        e.nombre AS r_nomeje,
        CASE WHEN a.modulo=11 THEN CONCAT('MERCADO ', m.num_mercado, '-', m.categoria, '-', m.seccion, '-', m.local, '-', m.letra_local, '-', m.bloque)
             WHEN a.modulo=16 THEN CONCAT('ASEO ', aseo.tipo_aseo, '-', aseo.num_contrato)
             ELSE '' END AS r_datos
    FROM ta_12_recibos p
    JOIN ta_15_apremios a ON a.fecha_pago = p.fecha AND a.recaudadora = p.id_rec AND a.caja = p.caja AND a.operacion = p.operacion
    LEFT JOIN ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    LEFT JOIN ta_11_locales m ON a.control_otr = m.id_local AND a.modulo = 11
    LEFT JOIN ta_16_contratos aseo ON a.control_otr = aseo.control_contrato AND a.modulo = 16
    WHERE p.fecha BETWEEN p_fechad AND p_fechah
      AND p.id_rec = p_rec
      AND p.impte_gastos > 0
    ORDER BY p.fecha, p.id_rec, p.caja, p.operacion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION spd_12_gastoscobxrec(p_fechad DATE, p_fechah DATE, p_rec INTEGER)
RETURNS TABLE (
    r_fecp DATE,
    r_rec INTEGER,
    r_caja VARCHAR(2),
    r_oper INTEGER,
    r_imptecta NUMERIC,
    r_totcert NUMERIC,
    r_folio INTEGER,
    r_ofnaf INTEGER,
    r_fecemi DATE,
    r_fecpra DATE,
    r_fecent DATE,
    r_imptegf NUMERIC,
    r_ejecutor INTEGER,
    r_nomeje VARCHAR(70),
    r_datos VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.fecha AS r_fecp,
        p.id_rec AS r_rec,
        p.caja AS r_caja,
        p.operacion AS r_oper,
        p.impte_gastos AS r_imptecta,
        p.importe AS r_totcert,
        a.folio AS r_folio,
        a.recaudadora AS r_ofnaf,
        a.fecha_emision AS r_fecemi,
        a.fecha_practicado AS r_fecpra,
        a.fecha_entrega1 AS r_fecent,
        a.importe_gastos AS r_imptegf,
        a.ejecutor AS r_ejecutor,
        e.nombre AS r_nomeje,
        CASE WHEN a.modulo=11 THEN CONCAT('MERCADO ', m.num_mercado, '-', m.categoria, '-', m.seccion, '-', m.local, '-', m.letra_local, '-', m.bloque)
             WHEN a.modulo=16 THEN CONCAT('ASEO ', aseo.tipo_aseo, '-', aseo.num_contrato)
             ELSE '' END AS r_datos
    FROM ta_12_recibos p
    JOIN ta_15_apremios a ON a.fecha_pago = p.fecha AND a.recaudadora = p.id_rec AND a.caja = p.caja AND a.operacion = p.operacion
    LEFT JOIN ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    LEFT JOIN ta_11_locales m ON a.control_otr = m.id_local AND a.modulo = 11
    LEFT JOIN ta_16_contratos aseo ON a.control_otr = aseo.control_contrato AND a.modulo = 16
    WHERE p.fecha BETWEEN p_fechad AND p_fechah
      AND p.id_rec = p_rec
      AND p.impte_gastos > 0
    ORDER BY p.fecha, p.id_rec, p.caja, p.operacion;
END;
$$ LANGUAGE plpgsql;

