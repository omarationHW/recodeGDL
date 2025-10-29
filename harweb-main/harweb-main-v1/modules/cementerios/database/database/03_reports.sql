CREATE OR REPLACE FUNCTION sp_total_sanandres()
RETURNS integer AS $$
DECLARE
    total integer;
BEGIN
    SELECT COUNT(*) INTO total FROM datos;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_estad_adeudo_resumen()
RETURNS TABLE(
    cementerio VARCHAR,
    uap INTEGER,
    cuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT cementerio, (axo_pagado-5) AS uap, COUNT(*) AS cuenta
    FROM ta_13_datosrcm
    GROUP BY cementerio, (axo_pagado-5)
    ORDER BY cementerio, uap;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_estad_adeudo_listado(axop INTEGER)
RETURNS TABLE(
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR,
    nombre_1 VARCHAR,
    nombre_2 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_rcm, a.cementerio, a.clase, a.clase_alfa, a.seccion, a.seccion_alfa, a.linea, a.linea_alfa, a.fosa, a.fosa_alfa, a.axo_pagado, a.metros, a.nombre, a.domicilio, a.exterior, a.interior, a.colonia, a.observaciones, a.usuario, a.fecha_mov, a.tipo, c.nombre AS nombre_1, e.nombre AS nombre_2
    FROM ta_13_datosrcm a
    JOIN tc_13_cementerios c ON a.cementerio = c.cementerio
    JOIN ta_12_passwords e ON a.usuario = e.id_usuario
    WHERE a.axo_pagado <= axop;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for List_Mov
CREATE OR REPLACE FUNCTION sp_list_movements(
    p_fecha1 DATE,
    p_fecha2 DATE,
    p_reca INTEGER
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR,
    nombre_1 VARCHAR,
    llave VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.control_rcm,
        a.cementerio,
        a.clase,
        a.clase_alfa,
        a.seccion,
        a.seccion_alfa,
        a.linea,
        a.linea_alfa,
        a.fosa,
        a.fosa_alfa,
        a.axo_pagado,
        a.metros,
        a.nombre,
        a.domicilio,
        a.exterior,
        a.interior,
        a.colonia,
        a.observaciones,
        a.usuario,
        a.fecha_mov,
        a.tipo,
        b.nombre as nombre_1,
        CONCAT_WS('-', a.cementerio, a.clase, a.clase_alfa, a.seccion, a.seccion_alfa, a.linea, a.linea_alfa, a.fosa, a.fosa_alfa) as llave
    FROM ta_13_datosrcm a
    JOIN ta_12_passwords b ON a.usuario = b.id_usuario
    WHERE a.fecha_mov BETWEEN p_fecha1 AND p_fecha2
      AND b.id_rec = p_reca;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for MultipleFecha
CREATE OR REPLACE FUNCTION sp_multiple_fecha(
    p_fecha DATE,
    p_rec SMALLINT,
    p_caja VARCHAR(10)
)
RETURNS TABLE (
    tipopag VARCHAR(10),
    fecing DATE,
    recing SMALLINT,
    cajing VARCHAR(10),
    opcaja INTEGER,
    control_id INTEGER,
    control_rcm INTEGER,
    cementerio VARCHAR(10),
    clase INTEGER,
    clase_alfa VARCHAR(10),
    seccion INTEGER,
    seccion_alfa VARCHAR(10),
    linea INTEGER,
    linea_alfa VARCHAR(10),
    fosa INTEGER,
    fosa_alfa VARCHAR(10),
    axo_pago_desde INTEGER,
    axo_pago_hasta INTEGER,
    importe_anual NUMERIC,
    importe_recargos NUMERIC,
    vigencia VARCHAR(2),
    usuario INTEGER,
    fecha_mov DATE,
    obser VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'Manten' AS tipopag,
           fecing, recing, cajing, opcaja, control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pago_desde, axo_pago_hasta, importe_anual, importe_recargos, vigencia, usuario, fecha_mov, '' AS obser
      FROM ta_13_pagosrcm
     WHERE fecing = p_fecha AND recing >= p_rec AND cajing >= p_caja
    UNION ALL
    SELECT 'Titulo' AS tipopag,
           fecha AS fecing, id_rec AS recing, caja AS cajing, operacion AS opcaja, 0 AS control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, tipo AS axo_pago_desde, titulo AS axo_pago_hasta, importe, 0, '', 0, CURRENT_DATE, observaciones
      FROM ta_13_titulos
     WHERE fecha = p_fecha AND id_rec >= p_rec AND caja >= p_caja
    ORDER BY fecing, recing, cajing, opcaja;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for detalle individual
CREATE OR REPLACE FUNCTION sp_pago_detalle(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR(10),
    clase INTEGER,
    clase_alfa VARCHAR(10),
    seccion INTEGER,
    seccion_alfa VARCHAR(10),
    linea INTEGER,
    linea_alfa VARCHAR(10),
    fosa INTEGER,
    fosa_alfa VARCHAR(10),
    axo_pagado INTEGER,
    metros NUMERIC,
    nombre VARCHAR(100),
    domicilio VARCHAR(100),
    exterior VARCHAR(20),
    interior VARCHAR(20),
    colonia VARCHAR(50),
    observaciones VARCHAR(255),
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR(2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov, tipo
      FROM ta_13_datosrcm
     WHERE control_rcm = p_control_rcm;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_multiple_nombre_search(
    p_nombre VARCHAR,
    p_cuenta INTEGER,
    p_cem1 VARCHAR,
    p_cem2 VARCHAR,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov
    FROM ta_13_datosrcm
    WHERE nombre ILIKE p_nombre
      AND control_rcm > p_cuenta
      AND cementerio >= p_cem1 AND cementerio <= p_cem2
    ORDER BY nombre
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_multiple_rcm_search(
    p_cementerio VARCHAR,
    p_clase INTEGER,
    p_clase_alfa VARCHAR,
    p_seccion INTEGER,
    p_seccion_alfa VARCHAR,
    p_linea INTEGER,
    p_linea_alfa VARCHAR,
    p_fosa INTEGER,
    p_fosa_alfa VARCHAR,
    p_cuenta INTEGER
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase INTEGER,
    clase_alfa VARCHAR,
    seccion INTEGER,
    seccion_alfa VARCHAR,
    linea INTEGER,
    linea_alfa VARCHAR,
    fosa INTEGER,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa,
        axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov
    FROM ta_13_datosrcm
    WHERE cementerio = p_cementerio
      AND clase >= p_clase
      AND clase_alfa >= p_clase_alfa
      AND seccion >= p_seccion
      AND seccion_alfa >= p_seccion_alfa
      AND linea >= p_linea
      AND linea_alfa >= p_linea_alfa
      AND fosa >= p_fosa
      AND fosa <= (p_fosa + 100)
      AND fosa_alfa >= p_fosa_alfa
      AND control_rcm > p_cuenta
    ORDER BY clase, seccion, linea, fosa
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for report
CREATE OR REPLACE FUNCTION sp_rep_a_cobrar(par_mes integer, par_id_rec integer)
RETURNS TABLE(
    ano integer,
    mantenimiento numeric,
    recargos numeric
) AS $$
BEGIN
    -- Simulación: Debe ajustarse a la lógica real de cálculo
    RETURN QUERY
    SELECT
        t.axo_cuota AS ano,
        SUM(t.cuota1 * t.metros) AS mantenimiento,
        SUM(t.cuota1 * t.metros * r.porcentaje_global / 100) AS recargos
    FROM ta_13_rcmcuotas t
    JOIN ta_13_datosrcm d ON d.cementerio = t.cementerio
    JOIN ta_12_recaudadoras rca ON rca.id_rec = par_id_rec
    JOIN ta_13_recargosrcm r ON r.axo = t.axo_cuota AND r.mes = par_mes
    WHERE d.id_rec = par_id_rec
    GROUP BY t.axo_cuota
    ORDER BY t.axo_cuota;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure para reporte de bonificaciones
CREATE OR REPLACE FUNCTION sp_rep_bon_listar(
    p_recaudadora INTEGER,
    p_tipo VARCHAR -- 'pendientes' o 'todos'
)
RETURNS TABLE (
    control_bon INTEGER,
    oficio INTEGER,
    axo SMALLINT,
    doble VARCHAR,
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    fecha_ofic DATE,
    importe_bonificar NUMERIC,
    importe_bonificado NUMERIC,
    importe_resto NUMERIC,
    usuario INTEGER,
    fecha_mov DATE,
    nombre VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.control_bon,
        a.oficio,
        a.axo,
        a.doble,
        a.control_rcm,
        a.cementerio,
        a.clase,
        a.clase_alfa,
        a.seccion,
        a.seccion_alfa,
        a.linea,
        a.linea_alfa,
        a.fosa,
        a.fosa_alfa,
        a.fecha_ofic,
        a.importe_bonificar,
        a.importe_bonificado,
        a.importe_resto,
        a.usuario,
        a.fecha_mov,
        (SELECT nombre FROM ta_12_passwords WHERE id_usuario = a.usuario) AS nombre
    FROM ta_13_bonifrcm a
    WHERE a.doble = p_recaudadora::VARCHAR
      AND (
        (p_tipo = 'pendientes' AND a.importe_resto > 0)
        OR (p_tipo = 'todos')
      )
    ORDER BY a.oficio DESC;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION rpt_titulos_get_report(fechapag date, fol integer)
RETURNS TABLE (
    titulo integer,
    control_rcm integer,
    fecha date,
    id_rec smallint,
    caja varchar,
    operacion integer,
    importe numeric,
    observaciones varchar,
    control_rcm_1 integer,
    cementerio varchar,
    clase smallint,
    clase_alfa varchar,
    seccion smallint,
    seccion_alfa varchar,
    linea smallint,
    linea_alfa varchar,
    fosa smallint,
    fosa_alfa varchar,
    axo_pagado integer,
    metros float,
    nombre varchar,
    domicilio varchar,
    exterior varchar,
    interior varchar,
    colonia varchar,
    observaciones_1 varchar,
    usuario integer,
    fecha_mov date,
    tipo varchar,
    nombre_1 varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.titulo, a.control_rcm, a.fecha, a.id_rec, a.caja, a.operacion, a.importe, a.observaciones,
           b.control_rcm as control_rcm_1, b.cementerio, b.clase, b.clase_alfa, b.seccion, b.seccion_alfa, b.linea, b.linea_alfa, b.fosa, b.fosa_alfa, b.axo_pagado, b.metros, b.nombre, b.domicilio, b.exterior, b.interior, b.colonia, b.observaciones as observaciones_1, b.usuario, b.fecha_mov, b.tipo,
           c.nombre as nombre_1
    FROM ta_13_titulos a
    JOIN ta_13_datosrcm b ON a.control_rcm = b.control_rcm
    JOIN tc_13_cementerios c ON b.cementerio = c.cementerio
    WHERE a.fecha = fechapag AND a.control_rcm = fol;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_titulos_print(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    control_rcm INTEGER,
    titulo INTEGER,
    libro INTEGER,
    axo INTEGER,
    folio_libro INTEGER,
    nombre_beneficiario TEXT,
    domicilio_beneficiario TEXT,
    colonia_beneficiario TEXT,
    telefono_beneficiario TEXT,
    partida TEXT,
    datos_json JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.control_rcm, t.titulo, t.libro, t.axo, t.folio, t.nombre_beneficiario, t.domicilio_beneficiario, t.colonia_beneficiario, t.telefono_beneficiario, t.partida,
           to_jsonb(t) as datos_json
    FROM ta_13_titulos t
    WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion;
END;
$$ LANGUAGE plpgsql;