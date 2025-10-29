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