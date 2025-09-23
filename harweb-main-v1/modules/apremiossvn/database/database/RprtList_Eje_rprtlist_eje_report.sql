-- Stored Procedure: rprtlist_eje_report
-- Tipo: Report
-- Descripción: Genera el listado de requerimientos (RprtList_Eje) según los filtros y lógica del formulario Delphi.
-- Generado para formulario: RprtList_Eje
-- Fecha: 2025-08-27 14:47:41

-- Stored Procedure: rprtlist_eje_report
-- Parámetros:
--   varios TEXT (lista de ejecutores, separados por coma)
--   vvig TEXT ('1' = Vigentes, '2' = Pagados)
--   vrec TEXT (zona/recaudadora)
--   vopc INTEGER (1=fecha_practicado, 2=fecha_actualiz, 3=fecha_pago y fecha_practicado, 4=fecha_entrega1)
--   vfec1 DATE
--   vfec2 DATE
--   vrecaudadora INTEGER
--   vfecP1 DATE (solo si vopc=3)
--   vfecP2 DATE (solo si vopc=3)
--   vnombre TEXT (nombre ejecutor, solo para mostrar)
--   v90d TEXT ('S' = solo <91 días)

CREATE OR REPLACE FUNCTION rprtlist_eje_report(
    varios TEXT,
    vvig TEXT,
    vrec TEXT,
    vopc INTEGER,
    vfec1 DATE,
    vfec2 DATE,
    vrecaudadora INTEGER,
    vfecP1 DATE,
    vfecP2 DATE,
    vnombre TEXT,
    v90d TEXT
)
RETURNS TABLE (
    id_control INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia TEXT,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado TEXT,
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate TEXT,
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones TEXT,
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja TEXT,
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia TEXT,
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov TEXT,
    hora_practicado TIMESTAMP,
    nombre TEXT,
    gtos_requer NUMERIC,
    totcer NUMERIC,
    diaspas INTEGER,
    datos TEXT,
    aplicacion TEXT,
    totalnotif NUMERIC
) AS $$
DECLARE
    sql TEXT;
BEGIN
    -- Construir la consulta dinámica
    sql := $$
    SELECT a.id_control, a.zona, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos, a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago, a.vigencia, a.fecha_actualiz, a.usuario, a.clave_mov, a.hora_practicado, b.nombre,
      g.gtos_requer,
      COALESCE((SELECT importe FROM ta_12_recibos WHERE fecha=a.fecha_pago AND id_rec=a.recaudadora AND caja=a.caja AND operacion=a.operacion),0) AS totcer,
      (a.fecha_pago - a.fecha_practicado) AS diaspas,
      NULL::TEXT AS datos,
      NULL::TEXT AS aplicacion,
      COALESCE((a.importe_global+a.importe_multa+a.importe_recargo+a.importe_gastos+a.importe_actualizacion),0) AS totalnotif
    FROM ta_15_apremios a
    JOIN ta_15_ejecutores b ON b.cve_eje=a.ejecutor AND b.id_rec=a.zona
    LEFT JOIN ta_15_gastos g ON year(a.fecha_practicado)=g.fecha_axo AND month(a.fecha_practicado)=g.fecha_mes
    WHERE a.ejecutor = ANY (string_to_array($1, ',')::int[])
    $$;

    -- Vigencia
    IF vvig = '1' THEN
        sql := sql || ' AND a.vigencia = ''1'' ';
    ELSE
        sql := sql || ' AND (a.vigencia = ''2'' OR a.vigencia = ''P'') AND a.clave_practicado = ''P'' ';
    END IF;

    -- Filtros de fecha
    IF vopc = 1 THEN
        sql := sql || ' AND a.fecha_practicado >= $5 AND a.fecha_practicado <= $6 ';
    ELSIF vopc = 2 THEN
        sql := sql || ' AND a.fecha_actualiz >= $5 AND a.fecha_actualiz <= $6 ';
    ELSIF vopc = 3 THEN
        sql := sql || ' AND a.fecha_pago >= $5 AND a.fecha_pago <= $6 ';
        sql := sql || ' AND a.fecha_practicado >= $8 AND a.fecha_practicado <= $9 ';
    ELSE
        sql := sql || ' AND a.fecha_entrega1 >= $5 AND a.fecha_entrega1 <= $6 ';
    END IF;

    -- Filtro de recaudadora
    IF vrecaudadora > 0 THEN
        sql := sql || ' AND a.zona = ' || vrecaudadora::TEXT;
    END IF;

    sql := sql || ' ORDER BY a.ejecutor, a.modulo, a.folio ';

    RETURN QUERY EXECUTE sql USING varios, vvig, vrec, vopc, vfec1, vfec2, vrecaudadora, vfecP1, vfecP2, vnombre, v90d;
END;
$$ LANGUAGE plpgsql;
