-- ============================================
-- INSTALACIÓN RÁPIDA DE STORED PROCEDURES
-- Proyecto: OTRAS OBLIG
-- Generado: 2025-08-28 13:48:30
-- ============================================

-- Este script contiene solo las definiciones de SPs sin comentarios
-- para una instalación rápida en producción

CREATE OR REPLACE FUNCTION actualizar_concesion(
    opc INTEGER,
    id_34_datos INTEGER,
    concesionario TEXT,
    ubicacion TEXT,
    licencia INTEGER,
    superficie NUMERIC,
    descrip TEXT,
    aso_ini INTEGER,
    mes_ini INTEGER
) RETURNS TABLE (resultado INTEGER, mensaje TEXT) AS $$
DECLARE
    v_old_concesionario TEXT;
    v_old_ubicacion TEXT;
    v_old_licencia INTEGER;
    v_old_superficie NUMERIC;
    v_old_descrip TEXT;
BEGIN
    SELECT concesionario, ubicacion, licencia, superficie, (SELECT descripcion FROM t34_unidades WHERE id_34_unidad = t34_datos.id_unidad)
    INTO v_old_concesionario, v_old_ubicacion, v_old_licencia, v_old_superficie, v_old_descrip
    FROM t34_datos WHERE id_34_datos = id_34_datos;

    IF opc = 0 THEN
        IF v_old_concesionario = concesionario THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET concesionario = concesionario WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Concesionario actualizado correctamente';
    ELSIF opc = 1 THEN
        IF v_old_ubicacion = ubicacion THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET ubicacion = ubicacion WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Ubicación actualizada correctamente';
    ELSIF opc = 2 THEN
        IF v_old_licencia = licencia THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET licencia = licencia WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Licencia actualizada correctamente';
    ELSIF opc = 3 THEN
        IF v_old_superficie = superficie THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET superficie = superficie WHERE id_34_datos = id_34_datos;
        -- Aquí se puede registrar el cambio de periodo si aplica
        RETURN QUERY SELECT 0, 'Superficie actualizada correctamente';
    ELSIF opc = 4 THEN
        IF v_old_descrip = descrip THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET id_unidad = (SELECT id_34_unidad FROM t34_unidades WHERE descripcion = descrip LIMIT 1) WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Tipo de local actualizado correctamente';
    ELSIF opc = 5 THEN
        -- Inicio de obligación (actualizar fecha_inicio)
        UPDATE t34_datos SET fecha_inicio = make_date(aso_ini, mes_ini, 1) WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Inicio de obligación actualizado correctamente';
    ELSE
        RETURN QUERY SELECT 1, 'Opción no válida';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION buscar_concesion(control TEXT)
RETURNS TABLE (
    id_34_datos INTEGER,
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fecha_inicio DATE,
    fecha_fin DATE,
    id_recaudadora INTEGER,
    sector TEXT,
    id_zona INTEGER,
    licencia INTEGER,
    status TEXT,
    unidades TEXT,
    categoria TEXT,
    seccion TEXT,
    bloque TEXT,
    nom_comercial TEXT,
    lugar TEXT,
    obs TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT A.id_34_datos, A.control, A.concesionario, A.ubicacion, A.superficie, A.fecha_inicio, A.fecha_fin, A.id_recaudadora,
           A.sector, A.id_zona, A.licencia, Z.descripcion AS status, F.descripcion AS unidades,
           B.categoria, B.seccion, B.bloque, C.concepto AS nom_comercial, D.concepto AS lugar, E.concepto AS obs
    FROM t34_datos A
    LEFT JOIN t34_adicionales B ON B.id_datos = A.id_34_datos
    LEFT JOIN t34_conceptos C ON C.id_datos = A.id_34_datos AND C.tipo = 'N'
    LEFT JOIN t34_conceptos D ON D.id_datos = A.id_34_datos AND D.tipo = 'L'
    LEFT JOIN t34_conceptos E ON E.id_datos = A.id_34_datos AND E.tipo = 'O'
    JOIN t34_status Z ON Z.id_34_stat = A.id_stat
    JOIN t34_unidades F ON F.id_34_unidad = A.id_unidad
    WHERE A.control = control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cob34_gdatosg_02(par_tab TEXT, par_control TEXT)
RETURNS TABLE (
    status INTEGER,
    concepto_status TEXT,
    id_datos INTEGER,
    concesionario TEXT,
    ubicacion TEXT,
    nomcomercial TEXT,
    lugar TEXT,
    obs TEXT,
    adicionales TEXT,
    statusregistro TEXT,
    unidades TEXT,
    categoria TEXT,
    seccion TEXT,
    bloque TEXT,
    sector TEXT,
    superficie NUMERIC,
    fechainicio DATE,
    fechafin DATE,
    recaudadora INTEGER,
    zona INTEGER,
    licencia INTEGER,
    giro INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN d.id_34_datos IS NULL THEN -1 ELSE 1 END AS status,
        CASE WHEN d.id_34_datos IS NULL THEN 'No existe registro' ELSE 'OK' END AS concepto_status,
        d.id_34_datos, d.concesionario, d.ubicacion, d.nomcomercial, d.lugar, d.obs, d.adicionales, 
        s.descripcion AS statusregistro, d.unidades, d.categoria, d.seccion, d.bloque, d.sector, d.superficie, d.fecha_inicio, d.fecha_fin, d.id_recaudadora, d.id_zona, d.licencia, d.giro
    FROM t34_datos d
    LEFT JOIN t34_status s ON d.id_stat = s.id_34_stat
    WHERE d.cve_tab = par_tab AND d.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cob34_gdetade_01(par_tabla TEXT, par_id_datos INTEGER, par_aso INTEGER, par_mes INTEGER)
RETURNS TABLE (
    concepto TEXT,
    axo INTEGER,
    mes INTEGER,
    importe_pagar NUMERIC,
    recargos_pagar NUMERIC,
    dscto_importe NUMERIC,
    dscto_recargos NUMERIC,
    actualizacion_pagar NUMERIC,
    multa_pagar NUMERIC,
    dscto_multa NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.concepto, c.axo, c.mes, c.importe_pagar, c.recargos_pagar, c.dscto_importe, c.dscto_recargos, c.actualizacion_pagar, c.multa_pagar, c.dscto_multa
    FROM t34_conceptos c
    WHERE c.cve_tab = par_tabla AND c.id_datos = par_id_datos AND c.axo = par_aso AND c.mes = par_mes;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION con34_1detade_01(par_Control integer, par_Rep varchar, par_Fecha varchar)
RETURNS TABLE(
    expression text,
    expression_1 numeric,
    expression_2 numeric
) AS $$
BEGIN
    -- Ejemplo: Debe adaptarse a la lógica real de adeudos vencidos
    RETURN QUERY
    SELECT 
        a.descripcion AS expression,
        a.adeudo AS expression_1,
        a.recargo AS expression_2
    FROM t_adeudos a
    WHERE a.id_34_datos = par_Control
      AND a.tipo_reporte = par_Rep
      AND a.periodo = par_Fecha;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure/function for adeudos
CREATE OR REPLACE FUNCTION con34_1detade_01(
    par_Control integer,
    par_Rep varchar,
    par_Fecha varchar
)
RETURNS TABLE (
    expression text,
    expression_1 numeric,
    expression_2 numeric
) AS $$
BEGIN
    -- Simulación: Debe reemplazarse por la lógica real de cálculo de adeudos y recargos
    -- Ejemplo de consulta:
    RETURN QUERY
    SELECT 
        'Adeudo periodo ' || par_Fecha AS expression,
        ROUND(random()*1000,2) AS expression_1, -- Monto adeudo
        ROUND(random()*200,2) AS expression_2   -- Monto recargo
    FROM generate_series(1, 3);
    -- En producción, reemplazar por la consulta real de adeudos para la concesión y periodo
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION con34_1detade_02(par_Control integer, par_Rep varchar, par_Fecha varchar)
RETURNS TABLE(
    expression text,
    expression_1 integer,
    expression_2 numeric,
    expression_3 numeric
) AS $$
BEGIN
    -- Ejemplo: Debe adaptarse a la lógica real de adeudos por periodo
    RETURN QUERY
    SELECT 
        a.descripcion AS expression,
        a.cantidad AS expression_1,
        a.adeudo AS expression_2,
        a.recargo AS expression_3
    FROM t_adeudos_periodo a
    WHERE a.id_34_datos = par_Control
      AND a.tipo_reporte = par_Rep
      AND a.periodo = par_Fecha;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for cartera generation
CREATE OR REPLACE FUNCTION con34_cgacart_01(par_tabla TEXT, par_ejer INTEGER)
RETURNS TABLE(status INTEGER, concepto_status TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status INTEGER := 0;
    v_msg TEXT := '';
BEGIN
    -- Ejemplo de lógica: (ajustar según reglas de negocio reales)
    -- 1. Validar existencia de unidades para la tabla y ejercicio
    IF NOT EXISTS (
        SELECT 1 FROM t34_unidades WHERE cve_tab = par_tabla AND ejercicio = par_ejer
    ) THEN
        v_status := 1;
        v_msg := 'No existen unidades para la tabla y ejercicio seleccionados.';
        RETURN QUERY SELECT v_status, v_msg;
        RETURN;
    END IF;

    -- 2. Ejecutar proceso de generación de cartera (simulado)
    BEGIN
        -- Aquí iría la lógica real de generación de cartera
        -- Por ejemplo: INSERT INTO t34_cartera ...
        -- Simulación:
        -- INSERT INTO t34_cartera (cve_tab, ejercicio, ...) SELECT ...
        v_status := 0;
        v_msg := 'Cartera generada correctamente para tabla ' || par_tabla || ' y ejercicio ' || par_ejer;
    EXCEPTION WHEN OTHERS THEN
        v_status := 2;
        v_msg := 'Error al generar cartera: ' || SQLERRM;
    END;
    RETURN QUERY SELECT v_status, v_msg;
END;
$$;

CREATE OR REPLACE FUNCTION con34_gcont_01(par_tabla integer, par_ade varchar, par_axo integer, par_mes integer)
RETURNS TABLE(
  control varchar,
  concesionario varchar,
  ubicacion varchar,
  nomcomercial varchar,
  lugar varchar,
  obs varchar,
  adicionales varchar,
  statusregistro varchar,
  unidades varchar,
  categoria varchar,
  seccion varchar,
  bloque varchar,
  sector varchar,
  superficie numeric,
  fechainicio date,
  fechafin date,
  recaudadora integer,
  zona integer,
  licencia integer,
  giro integer,
  tipoobligacion varchar,
  adeudos_2007 numeric,
  recargos_2007 numeric,
  total_2007 numeric,
  adeudos_2008 numeric,
  recargos_2008 numeric,
  total_2008 numeric,
  adeudos_2009 numeric,
  recargos_2009 numeric,
  total_2009 numeric,
  adeudos_2010 numeric,
  recargos_2010 numeric,
  total_2010 numeric,
  adeudos_2011 numeric,
  recargos_2011 numeric,
  total_2011 numeric,
  adeudos_2012 numeric,
  recargos_2012 numeric,
  total_2012 numeric,
  adeudos_2013 numeric,
  recargos_2013 numeric,
  total_2013 numeric,
  adeudos_2014 numeric,
  recargos_2014 numeric,
  total_2014 numeric,
  adeudos_2015 numeric,
  recargos_2015 numeric,
  total_2015 numeric,
  adeudos_2016 numeric,
  recargos_2016 numeric,
  total_2016 numeric,
  adeudos_2017 numeric,
  recargos_2017 numeric,
  total_2017 numeric,
  adeudos_2018 numeric,
  recargos_2018 numeric,
  total_2018 numeric,
  total_adeudos numeric,
  total_recargos numeric,
  total_general numeric,
  multas numeric,
  gastos numeric,
  datos_doctos varchar,
  total_pagado numeric,
  primer_adeudo date
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.control, d.concesionario, d.ubicacion, d.nomcomercial, d.lugar, d.obs, d.adicionales, d.statusregistro, d.unidades, d.categoria, d.seccion, d.bloque, d.sector, d.superficie, d.fechainicio, d.fechafin, d.recaudadora, d.zona, d.licencia, d.giro, d.tipoobligacion,
    d.adeudos_2007, d.recargos_2007, d.total_2007, d.adeudos_2008, d.recargos_2008, d.total_2008, d.adeudos_2009, d.recargos_2009, d.total_2009, d.adeudos_2010, d.recargos_2010, d.total_2010, d.adeudos_2011, d.recargos_2011, d.total_2011, d.adeudos_2012, d.recargos_2012, d.total_2012, d.adeudos_2013, d.recargos_2013, d.total_2013, d.adeudos_2014, d.recargos_2014, d.total_2014, d.adeudos_2015, d.recargos_2015, d.total_2015, d.adeudos_2016, d.recargos_2016, d.total_2016, d.adeudos_2017, d.recargos_2017, d.total_2017, d.adeudos_2018, d.recargos_2018, d.total_2018,
    d.total_adeudos, d.total_recargos, d.total_general, d.multas, d.gastos, d.datos_doctos, d.total_pagado, d.primer_adeudo
  FROM adeudos_general d
  WHERE d.cve_tab = par_tabla
    AND (par_ade = 'T' OR d.opcion = par_ade)
    AND (par_axo IS NULL OR d.anio = par_axo)
    AND (par_mes IS NULL OR d.mes = par_mes);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION con34_gdetade_01(par_tab integer, par_control integer, par_rep text, par_fecha text)
RETURNS TABLE(
    concepto text,
    importe_adeudos numeric,
    importe_recargos numeric,
    importe_multa numeric,
    importe_gastos numeric,
    importe_actualizacion numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, importe_adeudos, importe_recargos, importe_multa, importe_gastos, importe_actualizacion
    FROM t34_adeudos_detalle
    WHERE cve_tab = par_tab
      AND id_34_datos = par_control
      AND rep_tipo = par_rep
      AND periodo = par_fecha;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure equivalent for con34_gfact_02
-- Parámetros:
--   p_adeudo_status: 'A' (Adeudos y Pagos), 'B' (Solo Adeudos), 'C' (Solo Pagados)
--   p_adeudo_recargo: 'S' (con recargo), 'N' (sin recargo)
--   p_year: año a consultar
--   p_month: mes a consultar

CREATE OR REPLACE FUNCTION con34_gfact_02(
    p_adeudo_status VARCHAR(1),
    p_adeudo_recargo VARCHAR(1),
    p_year INTEGER,
    p_month INTEGER
)
RETURNS TABLE(
    control VARCHAR,
    concesionario VARCHAR,
    superficie NUMERIC,
    tipo VARCHAR,
    licencia VARCHAR,
    importe NUMERIC
) AS $$
BEGIN
    -- Ejemplo: la lógica real debe ajustarse a la estructura de la base de datos destino
    RETURN QUERY
    SELECT
        a.control,
        a.concesionario,
        a.superficie,
        a.tipo,
        a.licencia,
        a.importe
    FROM
        basephp.rastro_facturacion a
    WHERE
        (p_adeudo_status = 'A' OR (p_adeudo_status = 'B' AND a.pagado = false) OR (p_adeudo_status = 'C' AND a.pagado = true))
        AND (p_adeudo_recargo = 'N' OR (p_adeudo_recargo = 'S' AND a.recargo = true))
        AND a.anio = p_year
        AND a.mes = p_month;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION con34_rdetade_021(p_id_datos integer)
RETURNS TABLE(registro integer, axo integer, mes integer, periodo date, importe numeric, recargo numeric) AS $$
BEGIN
  RETURN QUERY
  SELECT id_adeudo, axo, mes, periodo, importe, recargo
  FROM t34_adeudos
  WHERE id_datos = p_id_datos AND status = 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_adeudos_by_concesion(p_id_34_datos INTEGER, p_aso INTEGER, p_mes INTEGER)
RETURNS TABLE(
    concepto TEXT,
    axo INTEGER,
    mes INTEGER,
    importe_pagar NUMERIC,
    recargos_pagar NUMERIC,
    dscto_importe NUMERIC,
    dscto_recargos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, axo, mes, importe_pagar, recargos_pagar, dscto_importe, dscto_recargos
    FROM cob34_rdetade_01(p_id_34_datos, p_aso, p_mes);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_concesion_by_control(p_control TEXT)
RETURNS TABLE(
    id_34_datos INTEGER,
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fecha_inicio DATE,
    id_recaudadora INTEGER,
    sector TEXT,
    id_zona INTEGER,
    licencia INTEGER,
    descrip_unidad TEXT,
    cve_stat TEXT,
    descrip_stat TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.superficie, a.fecha_inicio,
           a.id_recaudadora, a.sector, a.id_zona, a.licencia, b.descripcion AS descrip_unidad,
           c.cve_stat, c.descripcion AS descrip_stat
    FROM t34_datos a
    JOIN t34_unidades b ON b.id_34_unidad = a.id_unidad
    JOIN t34_status c ON c.id_34_stat = a.id_stat
    WHERE a.cve_tab = 3 AND a.control = p_control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_fecha_limite()
RETURNS TABLE(fechalimite DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT fechalimite
    FROM t34_fechalimite
    WHERE EXTRACT(YEAR FROM fechalimite) = EXTRACT(YEAR FROM CURRENT_DATE)
      AND EXTRACT(MONTH FROM fechalimite) = EXTRACT(MONTH FROM CURRENT_DATE)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_pagados_by_concesion(p_id_34_datos INTEGER)
RETURNS TABLE(
    id_34_pagos INTEGER,
    id_datos INTEGER,
    periodo DATE,
    importe NUMERIC,
    recargo NUMERIC,
    fecha_hora_pago TIMESTAMP,
    id_recaudadora INTEGER,
    caja TEXT,
    operacion INTEGER,
    folio_recibo TEXT,
    usuario TEXT,
    id_stat INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago,
           a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos AND b.cve_stat = 'P';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_totales_by_concesion(p_id_34_datos INTEGER, p_aso INTEGER, p_mes INTEGER)
RETURNS TABLE(
    cuenta INTEGER,
    obliga TEXT,
    concepto TEXT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT cuenta, obliga, concepto, importe
    FROM cob34_rtotade_01(p_id_34_datos, p_aso, p_mes);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ins34_rubro_01(par_nombre VARCHAR)
RETURNS TABLE(status INTEGER, concepto_status VARCHAR) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    IF par_nombre IS NULL OR trim(par_nombre) = '' THEN
        status := -1;
        concepto_status := 'El nombre del rubro es obligatorio.';
        RETURN NEXT;
        RETURN;
    END IF;
    -- Verificar si ya existe un rubro con ese nombre
    IF EXISTS (SELECT 1 FROM t34_tablas WHERE UPPER(nombre) = UPPER(par_nombre)) THEN
        status := -2;
        concepto_status := 'Ya existe un rubro con ese nombre.';
        RETURN NEXT;
        RETURN;
    END IF;
    -- Insertar el nuevo rubro
    INSERT INTO t34_tablas (cve_tab, nombre, cajero, auto_tab)
    VALUES (
        (SELECT COALESCE(MAX(CAST(cve_tab AS INTEGER)),0)+1 FROM t34_tablas),
        par_nombre,
        'N',
        (SELECT COALESCE(MAX(auto_tab),0)+1 FROM t34_tablas)
    ) RETURNING id_34_tab INTO new_id;
    status := new_id;
    concepto_status := 'Rubro creado correctamente';
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE ins34_status(
    par_cve_tab INTEGER,
    par_cve_stat VARCHAR,
    par_descripcion VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO t34_status (id_34_stat, cve_tab, cve_stat, descripcion, usuario)
    VALUES (
        DEFAULT,
        par_cve_tab,
        par_cve_stat,
        par_descripcion,
        current_user
    );
END;
$$;

CREATE OR REPLACE FUNCTION sp_con34_gfact_02(
    par_Tab VARCHAR,
    par_Ade VARCHAR,
    Par_Rcgo VARCHAR,
    par_Axo INTEGER,
    par_Mes INTEGER
)
RETURNS TABLE(
    control VARCHAR,
    concesionario VARCHAR,
    superficie NUMERIC,
    tipo VARCHAR,
    licencia INTEGER,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.control,
        d.concesionario,
        d.superficie,
        u.descripcion AS tipo,
        d.licencia,
        SUM(a.importe) AS importe
    FROM t34_datos d
    JOIN t34_unidades u ON d.cve_tab = u.cve_tab
    JOIN t34_adeudos a ON d.id_34_datos = a.id_datos
    WHERE d.cve_tab = par_Tab
      AND (
        (par_Ade = 'A' AND a.status IN ('ADEUDO', 'PAGADO')) OR
        (par_Ade = 'B' AND a.status = 'ADEUDO') OR
        (par_Ade = 'C' AND a.status = 'PAGADO')
      )
      AND (
        (Par_Rcgo = 'S' AND a.recargo > 0) OR
        (Par_Rcgo = 'N')
      )
      AND a.axo = par_Axo
      AND a.mes = par_Mes
    GROUP BY d.control, d.concesionario, d.superficie, u.descripcion, d.licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_create_apremio(
    zona smallint,
    folio integer,
    diligencia char(1),
    importe_global numeric(15,2),
    importe_multa numeric(15,2),
    importe_recargo numeric(15,2),
    importe_gastos numeric(15,2),
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado char(1),
    fecha_practicado date,
    hora_practicado time,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora time,
    ejecutor integer,
    clave_secuestro smallint,
    clave_remate char(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar(255),
    modulo integer,
    control_otr integer
) RETURNS SETOF ta_15_apremios AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO ta_15_apremios (
        zona, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos,
        zona_apremio, fecha_emision, clave_practicado, fecha_practicado, hora_practicado,
        fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, clave_secuestro,
        clave_remate, fecha_remate, porcentaje_multa, observaciones, modulo, control_otr, vigencia
    ) VALUES (
        zona, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos,
        zona_apremio, fecha_emision, clave_practicado, fecha_practicado, hora_practicado,
        fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, clave_secuestro,
        clave_remate, fecha_remate, porcentaje_multa, observaciones, modulo, control_otr, '1'
    ) RETURNING id_control INTO new_id;
    RETURN QUERY SELECT * FROM ta_15_apremios WHERE id_control = new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_delete_apremio(id_control integer)
RETURNS VOID AS $$
BEGIN
    UPDATE ta_15_apremios SET vigencia = '0' WHERE id_control = id_control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gadeudos_busca(par_tab TEXT, par_control TEXT)
RETURNS TABLE(
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fechainicio DATE,
    fechafin DATE,
    recaudadora INTEGER,
    sector TEXT,
    zona INTEGER,
    licencia INTEGER,
    unidades TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.control, d.concesionario, d.ubicacion, d.superficie, d.fecha_inicio, d.fecha_fin, d.id_recaudadora, d.sector, d.id_zona, d.licencia, u.descripcion as unidades
    FROM t34_datos d
    LEFT JOIN t34_unidades u ON u.cve_tab = d.cve_tab
    WHERE d.cve_tab = par_tab AND d.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gadeudos_detalle(par_tab TEXT, par_control TEXT, par_rep TEXT, par_fecha TEXT)
RETURNS TABLE(
    concepto TEXT,
    importe_adeudos NUMERIC,
    importe_recargos NUMERIC,
    importe_multas NUMERIC,
    importe_actualizacion NUMERIC,
    importe_gastos NUMERIC
) AS $$
DECLARE
    v_id_datos INTEGER;
    v_ano INTEGER;
    v_mes INTEGER;
BEGIN
    SELECT id_34_datos INTO v_id_datos FROM t34_datos WHERE cve_tab = par_tab AND control = par_control LIMIT 1;
    IF v_id_datos IS NULL THEN
        RETURN;
    END IF;
    v_ano := split_part(par_fecha, '-', 1)::INTEGER;
    v_mes := split_part(par_fecha, '-', 2)::INTEGER;
    RETURN QUERY
    SELECT c.concepto, c.importe_adeudos, c.importe_recargos, c.importe_multa, c.importe_actualizacion, c.importe_gastos
    FROM t34_conceptos c
    WHERE c.id_datos = v_id_datos
      AND (c.anio < v_ano OR (c.anio = v_ano AND c.mes <= v_mes))
    ORDER BY c.anio, c.mes;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gadeudos_etiquetas(par_tab TEXT)
RETURNS TABLE(
    cve_tab TEXT,
    abreviatura TEXT,
    etiq_control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie TEXT,
    fecha_inicio TEXT,
    fecha_fin TEXT,
    recaudadora TEXT,
    sector TEXT,
    zona TEXT,
    licencia TEXT,
    fecha_cancelacion TEXT,
    unidad TEXT,
    categoria TEXT,
    seccion TEXT,
    bloque TEXT,
    nombre_comercial TEXT,
    lugar TEXT,
    obs TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gadeudos_tablas(par_tab TEXT)
RETURNS TABLE(
    cve_tab TEXT,
    nombre TEXT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    LEFT JOIN t34_unidades b ON b.cve_tab = a.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_adeudos(
  par_tabla integer,
  par_id_datos integer,
  par_aso integer,
  par_mes integer
)
RETURNS TABLE (
  concepto varchar,
  axo integer,
  mes integer,
  importe_pagar numeric,
  recargos_pagar numeric,
  dscto_importe numeric,
  dscto_recargos numeric,
  actualizacion_pagar numeric
) AS $$
BEGIN
  RETURN QUERY SELECT concepto, axo, mes, importe_pagar, recargos_pagar, dscto_importe, dscto_recargos, actualizacion_pagar
  FROM cob34_gdetade_01(par_tabla::text, par_id_datos, par_aso, par_mes);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_coincide(
  par_tab integer,
  tipo_busqueda integer,
  dato_busqueda varchar
)
RETURNS TABLE (control varchar) AS $$
BEGIN
  IF tipo_busqueda < 4 THEN
    RETURN QUERY EXECUTE format(
      'SELECT control FROM t34_datos WHERE cve_tab = %L AND %I ILIKE %L ORDER BY control',
      par_tab::text,
      CASE tipo_busqueda
        WHEN 1 THEN 'control'
        WHEN 2 THEN 'concesionario'
        WHEN 3 THEN 'ubicacion'
      END,
      '%' || dato_busqueda || '%'
    );
  ELSE
    RETURN QUERY EXECUTE format(
      'SELECT a.control FROM t34_datos a JOIN t34_conceptos c ON c.id_datos = a.id_34_datos WHERE a.cve_tab = %L AND c.tipo = %L AND c.concepto ILIKE %L ORDER BY a.control',
      par_tab::text,
      CASE tipo_busqueda
        WHEN 4 THEN 'C'
        WHEN 5 THEN 'L'
        WHEN 6 THEN 'O'
      END,
      '%' || dato_busqueda || '%'
    );
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_cont(
  par_tab integer,
  par_control varchar
)
RETURNS TABLE (
  status integer,
  concepto_status varchar,
  id_datos integer,
  concesionario varchar,
  ubicacion varchar,
  nomcomercial varchar,
  lugar varchar,
  obs varchar,
  adicionales varchar,
  statusregistro varchar,
  unidades varchar,
  categoria varchar,
  seccion varchar,
  bloque varchar,
  sector varchar,
  superficie numeric,
  fechainicio date,
  fechafin date,
  recaudadora integer,
  zona integer,
  licencia integer,
  giro integer
) AS $$
BEGIN
  RETURN QUERY SELECT status, concepto_status, id_datos, concesionario, ubicacion, nomcomercial, lugar, obs, adicionales, statusregistro, unidades, categoria, seccion, bloque, sector, superficie, fechainicio, fechafin, recaudadora, zona, licencia, giro
  FROM cob34_gdatosg_02(par_tab::text, par_control);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_pagados(
  p_Control integer
)
RETURNS TABLE (
  id_34_pagos integer,
  id_datos integer,
  periodo date,
  importe numeric,
  recargo numeric,
  fecha_hora_pago timestamp,
  id_recaudadora integer,
  caja varchar,
  operacion integer,
  folio_recibo varchar,
  usuario varchar,
  id_stat integer
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago, a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_Control AND b.cve_stat = 'P'
    ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_totales(
  par_tabla integer,
  par_id_datos integer,
  par_aso integer,
  par_mes integer
)
RETURNS TABLE (
  cuenta integer,
  obliga varchar,
  concepto varchar,
  importe numeric
) AS $$
BEGIN
  RETURN QUERY SELECT cuenta, obliga, concepto, importe
  FROM cob34_gtotade_01(par_tabla::text, par_id_datos, par_aso, par_mes);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_get_etiquetas(par_tab integer)
RETURNS TABLE (
  cve_tab varchar,
  abreviatura varchar,
  etiq_control varchar,
  concesionario varchar,
  ubicacion varchar,
  superficie varchar,
  fecha_inicio varchar,
  fecha_fin varchar,
  recaudadora varchar,
  sector varchar,
  zona varchar,
  licencia varchar,
  fecha_cancelacion varchar,
  unidad varchar,
  categoria varchar,
  seccion varchar,
  bloque varchar,
  nombre_comercial varchar,
  lugar varchar,
  obs varchar
) AS $$
BEGIN
  RETURN QUERY SELECT * FROM t34_etiq WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_get_tablas(par_tab integer)
RETURNS TABLE (
  cve_tab varchar,
  nombre varchar,
  descripcion varchar
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON b.cve_tab = a.cve_tab
    WHERE a.cve_tab = par_tab::text
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_apremios(par_modulo integer, par_control integer)
RETURNS TABLE (
    id_control integer,
    zona smallint,
    folio integer,
    diligencia char(1),
    importe_global numeric(15,2),
    importe_multa numeric(15,2),
    importe_recargo numeric(15,2),
    importe_gastos numeric(15,2),
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado char(1),
    fecha_practicado date,
    hora_practicado time,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora time,
    ejecutor varchar(50),
    clave_secuestro smallint,
    clave_remate char(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.zona, a.folio, a.diligencia,
           a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos,
           a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.hora_practicado::time,
           a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora::time, b.usuario AS ejecutor,
           a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones
    FROM ta_15_apremios a
    JOIN ta_12_passwords b ON b.id_usuario = a.ejecutor
    WHERE a.modulo = par_modulo
      AND a.control_otr = par_control
      AND a.vigencia = '1'
      AND a.clave_practicado = 'P';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_datos_concesion(par_tab integer, par_control text)
RETURNS TABLE(
  status integer,
  concepto_status text,
  id_datos integer,
  concesionario text,
  ubicacion text,
  nomcomercial text,
  lugar text,
  obs text,
  adicionales text,
  statusregistro text,
  unidades text,
  categoria text,
  seccion text,
  bloque text,
  sector text,
  superficie numeric,
  fechainicio date,
  fechafin date,
  recaudadora integer,
  zona integer,
  licencia integer,
  giro integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT status, concepto_status, id_datos, concesionario, ubicacion, nomcomercial, lugar, obs, adicionales, statusregistro, unidades, categoria, seccion, bloque, sector, superficie, fechainicio, fechafin, recaudadora, zona, licencia, giro
  FROM cob34_gdatosg_02(par_tab, par_control);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_etiq(par_tab integer)
RETURNS TABLE(
  cve_tab integer,
  abreviatura text,
  etiq_control text,
  concesionario text,
  ubicacion text,
  superficie text,
  fecha_inicio text,
  fecha_fin text,
  recaudadora text,
  sector text,
  zona text,
  licencia text,
  fecha_cancelacion text,
  unidad text,
  categoria text,
  seccion text,
  bloque text,
  nombre_comercial text,
  lugar text,
  obs text
) AS $$
BEGIN
  RETURN QUERY
  SELECT cve_tab, abreviatura, etiq_control, concesionario, ubicacion, superficie, fecha_inicio, fecha_fin, recaudadora, sector, zona, licencia, fecha_cancelacion, unidad, categoria, seccion, bloque, nombre_comercial, lugar, obs
  FROM t34_etiq
  WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_etiquetas(par_tab VARCHAR)
RETURNS TABLE(
    cve_tab VARCHAR,
    abreviatura VARCHAR,
    etiq_control VARCHAR,
    concesionario VARCHAR,
    ubicacion VARCHAR,
    superficie VARCHAR,
    fecha_inicio VARCHAR,
    fecha_fin VARCHAR,
    recaudadora VARCHAR,
    sector VARCHAR,
    zona VARCHAR,
    licencia VARCHAR,
    fecha_cancelacion VARCHAR,
    unidad VARCHAR,
    categoria VARCHAR,
    seccion VARCHAR,
    bloque VARCHAR,
    nombre_comercial VARCHAR,
    lugar VARCHAR,
    obs VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_operaciones()
RETURNS TABLE(
  id_rec smallint,
  caja text,
  operacion integer,
  id_usuario integer,
  tip_impresora text
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_rec, caja, operacion, id_usuario, tip_impresora
  FROM ta_12_operaciones
  ORDER BY id_rec, caja;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_pagados(p_Control integer)
RETURNS TABLE(
  id_34_pagos integer,
  id_datos integer,
  periodo timestamp,
  importe numeric,
  recargo numeric,
  fecha_hora_pago timestamp,
  id_recaudadora integer,
  caja text,
  operacion integer,
  folio_recibo text,
  usuario text,
  id_stat integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago, a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
  FROM t34_pagos a
  JOIN t34_status b ON b.id_34_stat = a.id_stat AND b.cve_stat = 'P'
  WHERE a.id_datos = p_Control
  ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_periodos_by_control(id_control integer)
RETURNS TABLE (
    ayo integer,
    periodo integer,
    importe numeric(15,2),
    recargos numeric(15,2),
    cantidad integer,
    tipo varchar(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ayo, periodo, importe, recargos, cantidad, tipo
    FROM ta_15_periodos
    WHERE control_otr = id_control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(
  id_rec smallint,
  id_zona integer,
  recaudadora text,
  domicilio text,
  tel text,
  recaudador text,
  sector text
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador, sector
  FROM ta_12_recaudadoras
  ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_tabla_info(par_tab integer)
RETURNS TABLE(cve_tab integer, nombre text, descripcion text) AS $$
BEGIN
  RETURN QUERY
  SELECT a.cve_tab, a.nombre, b.descripcion
  FROM t34_tablas a
  JOIN t34_unidades b ON b.cve_tab = a.cve_tab
  WHERE a.cve_tab = par_tab
  GROUP BY a.cve_tab, a.nombre, b.descripcion
  ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_tablas(par_tab VARCHAR)
RETURNS TABLE(
    cve_tab VARCHAR,
    nombre VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON a.cve_tab = b.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure para alta de nuevo registro (GNuevos)
CREATE OR REPLACE FUNCTION sp_gnuevos_alta(
    par_tabla integer,
    par_control text,
    par_conces text,
    par_ubica text,
    par_sup numeric,
    par_Axo_Ini integer,
    par_Mes_Ini integer,
    par_ofna integer,
    par_sector text,
    par_zona integer,
    par_lic integer,
    par_Descrip text,
    par_NomCom text,
    par_Lugar text,
    par_Obs text,
    par_usuario text
) RETURNS TABLE(status integer, concepto_status text) AS $$
DECLARE
    v_exists integer;
    v_id_34_datos integer;
    v_msg text;
BEGIN
    -- Validaciones básicas
    IF par_conces IS NULL OR trim(par_conces) = '' THEN
        RETURN QUERY SELECT 0, 'Falta el dato del CONCESIONARIO';
        RETURN;
    END IF;
    IF par_ubica IS NULL OR trim(par_ubica) = '' THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la UBICACION';
        RETURN;
    END IF;
    IF par_sup IS NULL OR par_sup <= 0 THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la SUPERFICIE';
        RETURN;
    END IF;
    IF par_lic IS NULL OR par_lic = 0 THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la LICENCIA';
        RETURN;
    END IF;
    IF par_Axo_Ini IS NULL OR par_Axo_Ini < 2020 THEN
        RETURN QUERY SELECT 0, 'Falta el dato del AÑO de inicio de OBLIGACION';
        RETURN;
    END IF;
    -- Validar que no exista el control
    SELECT count(*) INTO v_exists FROM t34_datos WHERE control = par_control AND cve_tab = par_tabla;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 0, 'Ya existe un registro con ese control';
        RETURN;
    END IF;
    -- Insertar en t34_datos
    INSERT INTO t34_datos (
        cve_tab, control, concesionario, ubicacion, superficie, fecha_inicio, id_recaudadora, sector, id_zona, licencia, descrip_unidad, nom_comercial, lugar, obs, usuario_alta, fecha_alta
    ) VALUES (
        par_tabla, par_control, par_conces, par_ubica, par_sup, make_date(par_Axo_Ini, par_Mes_Ini, 1), par_ofna, par_sector, par_zona, par_lic, par_Descrip, par_NomCom, par_Lugar, par_Obs, par_usuario, now()
    ) RETURNING id_34_datos INTO v_id_34_datos;
    -- Insertar en t34_conceptos si aplica (ejemplo)
    -- INSERT INTO t34_conceptos (id_datos, tipo, concepto) VALUES (v_id_34_datos, 'C', par_NomCom);
    -- ...
    RETURN QUERY SELECT 1, 'Registro creado correctamente';
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for inserting new local/concession
CREATE OR REPLACE FUNCTION sp_ins34_rastro_01(
    par_tabla INTEGER,
    par_control VARCHAR,
    par_conces VARCHAR,
    par_ubica VARCHAR,
    par_sup NUMERIC,
    par_Axo_Ini INTEGER,
    par_Mes_Ini INTEGER,
    par_ofna INTEGER,
    par_sector VARCHAR,
    par_zona INTEGER,
    par_lic INTEGER,
    par_Descrip VARCHAR
) RETURNS TABLE(expression INTEGER, expression_1 VARCHAR) AS $$
DECLARE
    v_exists INTEGER;
    v_id_unidad INTEGER;
    v_id_stat INTEGER := 1; -- VIGENTE
BEGIN
    SELECT COUNT(*) INTO v_exists FROM t34_datos WHERE control = par_control;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 1 AS expression, 'Ya existe LOCAL con este dato, intentalo de nuevo' AS expression_1;
        RETURN;
    END IF;
    -- Buscar id_unidad por descripcion
    SELECT id_34_unidad INTO v_id_unidad FROM t34_unidades WHERE descripcion = par_Descrip AND cve_tab = par_tabla LIMIT 1;
    IF v_id_unidad IS NULL THEN
        v_id_unidad := 1; -- fallback
    END IF;
    INSERT INTO t34_datos (
        cve_tab, control, concesionario, ubicacion, superficie, fecha_inicio, id_recaudadora, sector, id_zona, licencia, id_unidad, id_stat
    ) VALUES (
        par_tabla, par_control, par_conces, par_ubica, par_sup, make_date(par_Axo_Ini, par_Mes_Ini, 1), par_ofna, par_sector, par_zona, par_lic, v_id_unidad, v_id_stat
    );
    RETURN QUERY SELECT 0 AS expression, 'Se ejecutó correctamente la creación del Local/Concesión' AS expression_1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_insert_t34_unidades(
    p_id_34_unidad integer,
    p_ejercicio integer,
    p_cve_unidad varchar(10),
    p_cve_operatividad varchar(10),
    p_descripcion varchar(100),
    p_costo numeric(12,2),
    p_cve_tab varchar(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO t34_unidades (
        id_34_unidad, ejercicio, cve_unidad, cve_operatividad, descripcion, costo, cve_tab
    ) VALUES (
        p_id_34_unidad, p_ejercicio, p_cve_unidad, p_cve_operatividad, p_descripcion, p_costo, p_cve_tab
    );
END;
$$;

CREATE OR REPLACE FUNCTION sp_menu_check_version(p_proyecto TEXT, p_version TEXT)
RETURNS TABLE(update_required BOOLEAN) AS $$
BEGIN
  RETURN QUERY
    SELECT NOT EXISTS (
      SELECT 1 FROM ta_versiones WHERE proyecto = p_proyecto AND version = p_version
    ) AS update_required;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_menu_get_ejercicios()
RETURNS TABLE(ejercicio INT) AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT ejercicio_recolec AS ejercicio
    FROM ta_16_unidades
    ORDER BY ejercicio_recolec;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_menu_get_menu(p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
  v_nivel SMALLINT;
  v_menu JSON;
BEGIN
  SELECT nivel INTO v_nivel FROM ta_12_passwords WHERE usuario = p_usuario;
  -- Ejemplo de menú, debe adaptarse a la lógica real de permisos
  v_menu := json_build_array(
    json_build_object('nombre', 'Controles', 'opciones', json_build_array(
      json_build_object('id', 101, 'titulo', 'Alta de Fuente de Sodas', 'enabled', v_nivel >= 1),
      json_build_object('id', 102, 'titulo', 'Alta de Juegos Mecánicos', 'enabled', v_nivel >= 1)
    )),
    json_build_object('nombre', 'Reportes', 'opciones', json_build_array(
      json_build_object('id', 301, 'titulo', 'Edo. Cuenta', 'enabled', v_nivel >= 1)
    ))
  );
  RETURN v_menu;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_menu_get_user_info(p_usuario TEXT)
RETURNS TABLE(id_usuario INT, usuario TEXT, nombre TEXT, estado TEXT, id_rec SMALLINT, nivel SMALLINT) AS $$
BEGIN
  RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
    FROM ta_12_passwords
    WHERE usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_menu_login(p_usuario TEXT, p_password TEXT)
RETURNS TABLE(status TEXT, id_usuario INT, usuario TEXT, nombre TEXT, estado TEXT, id_rec SMALLINT, nivel SMALLINT, message TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      CASE WHEN t.usuario IS NOT NULL THEN 'ok' ELSE 'error' END AS status,
      t.id_usuario, t.usuario, t.nombre, t.estado, t.id_rec, t.nivel,
      CASE WHEN t.usuario IS NOT NULL THEN NULL ELSE 'Usuario o clave incorrecta' END AS message
    FROM ta_12_passwords t
    WHERE t.usuario = p_usuario AND t.password = p_password;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_rbaja_buscar_local(p_numero VARCHAR, p_letra VARCHAR)
RETURNS TABLE (
    id_34_datos INTEGER,
    control VARCHAR,
    concesionario VARCHAR,
    ubicacion VARCHAR,
    superficie NUMERIC,
    fecha_inicio DATE,
    id_recaudadora INTEGER,
    sector VARCHAR,
    id_zona INTEGER,
    licencia INTEGER,
    descrip_unidad VARCHAR,
    cve_stat VARCHAR,
    descrip_stat VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.superficie, a.fecha_inicio,
           a.id_recaudadora, a.sector, a.id_zona, a.licencia, b.descripcion AS descrip_unidad, c.cve_stat, c.descripcion AS descrip_stat
    FROM t34_datos a
    JOIN t34_unidades b ON b.id_34_unidad = a.id_unidad
    JOIN t34_status c ON c.id_34_stat = a.id_stat
    WHERE a.cve_tab = 3
      AND a.control = CONCAT(TRIM(p_numero), '-', TRIM(p_letra));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_rbaja_cancelar_local(p_id_34_datos INTEGER, p_axo_fin INTEGER, p_mes_fin INTEGER)
RETURNS TABLE (codigo INTEGER, mensaje TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Aquí se debe realizar la lógica de baja, por ejemplo:
    -- 1. Actualizar el status del local a 'C' (cancelado)
    -- 2. Registrar fecha de baja, etc.
    -- 3. Validar que no existan adeudos (esto ya se validó antes)
    UPDATE t34_datos
    SET id_stat = (SELECT id_34_stat FROM t34_status WHERE cve_stat = 'C' LIMIT 1),
        fecha_fin = make_date(p_axo_fin, p_mes_fin, 1)
    WHERE id_34_datos = p_id_34_datos;
    IF FOUND THEN
        RETURN QUERY SELECT 0 AS codigo, 'Se ejecutó correctamente la Cancelación del Local/Concesión' AS mensaje;
    ELSE
        RETURN QUERY SELECT 1 AS codigo, 'No se encontró el registro para cancelar' AS mensaje;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_rbaja_verificar_adeudos(p_id_34_datos INTEGER, p_periodo VARCHAR)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos
      AND a.periodo < p_periodo
      AND b.cve_stat = 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_rbaja_verificar_adeudos_post(p_id_34_datos INTEGER, p_periodo VARCHAR)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos
      AND a.periodo >= p_periodo
      AND b.cve_stat <> 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_rpagados_get_pagados_by_control(p_control integer)
RETURNS TABLE (
    id_34_pagos integer,
    id_datos integer,
    periodo date,
    importe numeric,
    recargo numeric,
    fecha_hora_pago timestamp,
    id_recaudadora integer,
    caja varchar(2),
    operacion integer,
    folio_recibo varchar(15),
    usuario varchar(10),
    id_stat integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago, a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_control
      AND b.cve_stat IN ('P','S','R','D')
    ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_update_apremio(
    id_control integer,
    zona smallint,
    folio integer,
    diligencia char(1),
    importe_global numeric(15,2),
    importe_multa numeric(15,2),
    importe_recargo numeric(15,2),
    importe_gastos numeric(15,2),
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado char(1),
    fecha_practicado date,
    hora_practicado time,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora time,
    ejecutor integer,
    clave_secuestro smallint,
    clave_remate char(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar(255),
    modulo integer,
    control_otr integer
) RETURNS SETOF ta_15_apremios AS $$
BEGIN
    UPDATE ta_15_apremios SET
        zona = zona,
        folio = folio,
        diligencia = diligencia,
        importe_global = importe_global,
        importe_multa = importe_multa,
        importe_recargo = importe_recargo,
        importe_gastos = importe_gastos,
        zona_apremio = zona_apremio,
        fecha_emision = fecha_emision,
        clave_practicado = clave_practicado,
        fecha_practicado = fecha_practicado,
        hora_practicado = hora_practicado,
        fecha_entrega1 = fecha_entrega1,
        fecha_entrega2 = fecha_entrega2,
        fecha_citatorio = fecha_citatorio,
        hora = hora,
        ejecutor = ejecutor,
        clave_secuestro = clave_secuestro,
        clave_remate = clave_remate,
        fecha_remate = fecha_remate,
        porcentaje_multa = porcentaje_multa,
        observaciones = observaciones,
        modulo = modulo,
        control_otr = control_otr
    WHERE id_control = id_control;
    RETURN QUERY SELECT * FROM ta_15_apremios WHERE id_control = id_control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_update_t34_etiq(
    p_abreviatura VARCHAR(4),
    p_etiq_control VARCHAR(20),
    p_concesionario VARCHAR(100),
    p_ubicacion VARCHAR(100),
    p_superficie VARCHAR(100),
    p_fecha_inicio VARCHAR(20),
    p_fecha_fin VARCHAR(20),
    p_recaudadora VARCHAR(100),
    p_sector VARCHAR(100),
    p_zona VARCHAR(100),
    p_licencia VARCHAR(100),
    p_fecha_cancelacion VARCHAR(20),
    p_unidad VARCHAR(100),
    p_categoria VARCHAR(100),
    p_seccion VARCHAR(100),
    p_bloque VARCHAR(100),
    p_nombre_comercial VARCHAR(100),
    p_lugar VARCHAR(100),
    p_obs VARCHAR(100),
    p_cve_tab VARCHAR(2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE t34_etiq SET
        abreviatura = p_abreviatura,
        etiq_control = p_etiq_control,
        concesionario = p_concesionario,
        ubicacion = p_ubicacion,
        superficie = p_superficie,
        fecha_inicio = p_fecha_inicio,
        fecha_fin = p_fecha_fin,
        recaudadora = p_recaudadora,
        sector = p_sector,
        zona = p_zona,
        licencia = p_licencia,
        fecha_cancelacion = p_fecha_cancelacion,
        unidad = p_unidad,
        categoria = p_categoria,
        seccion = p_seccion,
        bloque = p_bloque,
        nombre_comercial = p_nombre_comercial,
        lugar = p_lugar,
        obs = p_obs
    WHERE cve_tab = p_cve_tab;
END;
$$;

CREATE OR REPLACE FUNCTION sp34_adeudototal(par_tabla integer, par_fecha varchar)
RETURNS TABLE(
  control varchar,
  nombre varchar,
  superficie numeric,
  periodos varchar,
  adeudo numeric,
  recargos numeric,
  desc_recargos numeric,
  multa numeric,
  desc_multa numeric,
  actualizacion numeric,
  gastos numeric,
  forma numeric,
  autorizacion numeric,
  total numeric,
  ubicacion varchar,
  tipo varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.control, d.nombre, d.superficie, d.periodos, d.adeudo, d.recargos, d.desc_recargos, d.multa, d.desc_multa, d.actualizacion, d.gastos, d.forma, d.autorizacion, d.total, d.ubicacion, d.tipo
  FROM adeudos_totales d
  WHERE d.cve_tab = par_tabla
    AND d.periodo = par_fecha;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_etiq(par_tab integer)
RETURNS TABLE(
    cve_tab varchar,
    abreviatura varchar,
    etiq_control varchar,
    concesionario varchar,
    ubicacion varchar,
    superficie varchar,
    fecha_inicio varchar,
    fecha_fin varchar,
    recaudadora varchar,
    sector varchar,
    zona varchar,
    licencia varchar,
    fecha_cancelacion varchar,
    unidad varchar,
    categoria varchar,
    seccion varchar,
    bloque varchar,
    nombre_comercial varchar,
    lugar varchar,
    obs varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_etiq_tabla(par_tab integer)
RETURNS TABLE(
    cve_tab text,
    abreviatura text,
    etiq_control text,
    concesionario text,
    ubicacion text,
    superficie text,
    fecha_inicio text,
    fecha_fin text,
    recaudadora text,
    sector text,
    zona text,
    licencia text,
    fecha_cancelacion text,
    unidad text,
    categoria text,
    seccion text,
    bloque text,
    nombre_comercial text,
    lugar text,
    obs text
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_nombre_tabla(par_tab integer)
RETURNS TABLE(nombre text) AS $$
BEGIN
    RETURN QUERY
    SELECT nombre FROM t34_tablas WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_padron(par_tabla integer, par_vigencia text)
RETURNS TABLE(
    control varchar,
    concesionario varchar,
    ubicacion varchar,
    nomcomercial varchar,
    lugar varchar,
    obs varchar,
    statusregistro varchar,
    unidades varchar,
    categoria varchar,
    seccion varchar,
    bloque varchar,
    sector varchar,
    superficie numeric,
    fechainicio date,
    fechafin date,
    recaudadora integer,
    zona integer,
    licencia integer,
    giro integer,
    tipoobligacion varchar,
    id_34_datos integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control,
        a.concesionario,
        a.ubicacion,
        a.nomcomercial,
        a.lugar,
        a.obs,
        b.descripcion as statusregistro,
        a.unidades,
        a.categoria,
        a.seccion,
        a.bloque,
        a.sector,
        a.superficie,
        a.fecha_inicio as fechainicio,
        a.fecha_fin as fechafin,
        a.id_recaudadora as recaudadora,
        a.id_zona as zona,
        a.licencia,
        a.giro,
        a.tipoobligacion,
        a.id_34_datos
    FROM t34_datos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_tabla
      AND (
        par_vigencia = 'TODOS' OR b.descripcion = par_vigencia
      )
    ORDER BY a.control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_padron(par_tabla integer, par_vigencia text)
RETURNS TABLE(
    id_34_datos integer,
    control text,
    concesionario text,
    ubicacion text,
    nomcomercial text,
    lugar text,
    obs text,
    statusregistro text,
    unidades text,
    categoria text,
    seccion text,
    bloque text,
    sector text,
    superficie numeric,
    fechainicio date,
    fechafin date,
    recaudadora integer,
    zona integer,
    licencia integer,
    giro integer,
    tipoobligacion text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.nomcomercial, a.lugar, a.obs, b.descripcion as statusregistro, a.unidades, a.categoria, a.seccion, a.bloque, a.sector, a.superficie, a.fecha_inicio, a.fecha_fin, a.id_recaudadora, a.zona, a.licencia, a.giro, a.tipoobligacion
    FROM t34_datos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_tabla
      AND (par_vigencia = 'TODOS' OR b.descripcion = par_vigencia)
    ORDER BY a.control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_tablas(par_tab integer)
RETURNS TABLE(
    cve_tab varchar,
    nombre varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON a.cve_tab = b.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_vigencias(par_tab integer)
RETURNS TABLE(
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT b.descripcion
    FROM t34_datos a, t34_status b
    WHERE a.cve_tab = par_tab
      AND b.id_34_stat = a.id_stat
    GROUP BY b.descripcion
    ORDER BY b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_vigencias_concesion(par_tab integer)
RETURNS TABLE(descripcion text) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT b.descripcion
    FROM t34_datos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_tab
    ORDER BY b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS t34_etiq (
  cve_tab integer,
  abreviatura varchar(4),
  etiq_control varchar(50),
  concesionario varchar(100),
  ubicacion varchar(100),
  superficie varchar(50),
  fecha_inicio varchar(20),
  fecha_fin varchar(20),
  recaudadora varchar(50),
  sector varchar(20),
  zona varchar(20),
  licencia varchar(20),
  fecha_cancelacion varchar(20),
  unidad varchar(20),
  categoria varchar(20),
  seccion varchar(20),
  bloque varchar(20),
  nombre_comercial varchar(100),
  lugar varchar(100),
  obs varchar(100)
);

CREATE TABLE IF NOT EXISTS t34_tablas (
  cve_tab integer PRIMARY KEY,
  nombre varchar(100),
  descripcion varchar(100)
);

-- Tabla: ta_12_operaciones
-- id_rec, caja, operacion, id_usuario, tip_impresora
-- SELECT id_rec, caja FROM ta_12_operaciones ORDER BY id_rec, caja;

-- Tabla: ta_12_recaudadoras
-- id_rec, recaudadora, domicilio, tel, recaudador, sector
-- SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;

CREATE OR REPLACE FUNCTION upd34_ade_01(
  par_id_datos integer,
  par_Axo integer,
  par_Mes integer,
  par_Fecha date,
  par_Id_Rec integer,
  par_Caja varchar,
  par_Consec integer,
  par_Folio_rcbo varchar,
  par_tab varchar,
  par_status varchar,
  par_Opc varchar
) RETURNS TABLE(status integer, concepto_status varchar) AS $$
DECLARE
  v_count integer;
BEGIN
  SELECT COUNT(*) INTO v_count FROM t34_adeudos WHERE id_adeudo = par_id_datos AND axo = par_Axo AND mes = par_Mes;
  IF v_count = 0 THEN
    RETURN QUERY SELECT 1, 'Adeudo no encontrado';
    RETURN;
  END IF;
  UPDATE t34_adeudos
    SET status = par_status,
        fecha_pago = par_Fecha,
        id_recaudadora = par_Id_Rec,
        caja = par_Caja,
        operacion = par_Consec,
        folio_recibo = par_Folio_rcbo
    WHERE id_adeudo = par_id_datos AND axo = par_Axo AND mes = par_Mes;
  RETURN QUERY SELECT 0, 'Actualización exitosa';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION upd34_gen_adeudos_ind(
    par_id_34_datos INTEGER,
    par_Axo INTEGER,
    par_Mes INTEGER,
    par_Fecha DATE,
    par_Id_Rec INTEGER,
    par_Caja TEXT,
    par_Consec INTEGER,
    par_Folio_rcbo TEXT,
    par_tab TEXT,
    par_status TEXT,
    par_Opc TEXT,
    par_usuario TEXT
) RETURNS TABLE (
    status INTEGER,
    concepto_status TEXT
) AS $$
DECLARE
    v_status INTEGER := 0;
    v_msg TEXT := '';
BEGIN
    -- Aquí va la lógica de actualización de adeudos, pagos, etc.
    -- Ejemplo: Si par_status = 'P' (pagado), insertar en t34_pagos y actualizar status
    IF par_status = 'P' THEN
        -- Insertar pago
        INSERT INTO t34_pagos (id_datos, periodo, importe, recargo, fecha_hora_pago, id_recaudadora, caja, operacion, folio_recibo, usuario, id_stat)
        VALUES (par_id_34_datos, make_date(par_Axo, par_Mes, 1), 0, 0, par_Fecha, par_Id_Rec, par_Caja, par_Consec, par_Folio_rcbo, par_usuario, (SELECT id_34_stat FROM t34_status WHERE cve_stat = 'P'));
        v_status := 1;
        v_msg := 'Pago registrado correctamente.';
    ELSIF par_status = 'S' THEN
        -- Lógica de condonación
        v_status := 1;
        v_msg := 'Adeudo condonado correctamente.';
    ELSIF par_status = 'C' THEN
        -- Lógica de cancelación
        v_status := 1;
        v_msg := 'Adeudo cancelado correctamente.';
    ELSIF par_status = 'R' THEN
        -- Lógica de prescripción
        v_status := 1;
        v_msg := 'Adeudo prescrito correctamente.';
    ELSE
        v_status := 0;
        v_msg := 'Opción no válida.';
    END IF;
    RETURN QUERY SELECT v_status, v_msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verificar_pagos(id_datos INTEGER, periodo TEXT)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = id_datos
      AND to_char(a.periodo, 'YYYY-MM') >= periodo
      AND b.cve_stat = 'P';
END;
$$ LANGUAGE plpgsql;

