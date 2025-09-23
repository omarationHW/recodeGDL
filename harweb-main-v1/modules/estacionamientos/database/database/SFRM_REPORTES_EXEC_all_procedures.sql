-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: SFRM_REPORTES_EXEC
-- Generado: 2025-08-27 14:25:55
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_get_reportes_exec
-- Tipo: Report
-- Descripción: Obtiene el reporte de estacionamientos exclusivos por clasificación y agrupación (número de exclusivo o propietario).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_reportes_exec(order_by TEXT, group_by TEXT)
RETURNS TABLE(
    id INT,
    ex_propietario_id INT,
    no_exclusivo INT,
    zona VARCHAR,
    total_bateria FLOAT,
    total_cordon FLOAT,
    solicitud INT,
    control INT,
    folio_cancelacion INT,
    estatus VARCHAR,
    factor FLOAT,
    fecha_in TIMESTAMP,
    fecha_at TIMESTAMP,
    id_clasificacion INT,
    vialidad VARCHAR,
    fecha_inicial DATE,
    usuario INT,
    pc VARCHAR,
    id_1 INT,
    rfc VARCHAR,
    sociedad VARCHAR,
    propietario VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    celular VARCHAR,
    email VARCHAR,
    fecha_in_1 TIMESTAMP,
    fecha_at_1 TIMESTAMP,
    password VARCHAR,
    clasificacion VARCHAR,
    tipo_est VARCHAR,
    calle VARCHAR,
    colonia_1 VARCHAR,
    extension_de FLOAT,
    acera VARCHAR,
    interseccion1 VARCHAR
) AS $$
DECLARE
    sql TEXT;
BEGIN
    sql := 'SELECT a.*, b.*, c.concepto AS clasificacion, ub.tipo_est, ub.calle, ub.colonia AS colonia_1, ub.extension_de, ub.acera, ub.interseccion1 '
        || 'FROM ex_contrato a '
        || 'JOIN ex_propietario b ON a.ex_propietario_id = b.id '
        || 'JOIN ex_clasificacion c ON c.id = a.id_clasificacion '
        || 'LEFT JOIN ex_ubicacion ub ON ub.ex_contrato_id = a.id AND ub.estatus = ''V'' '
        || 'WHERE a.estatus <> ''C'' '
        || 'ORDER BY c.concepto, ' || group_by || ', ub.calle';
    RETURN QUERY EXECUTE sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_adeudos_exec
-- Tipo: Report
-- Descripción: Obtiene el reporte de adeudos de estacionamientos exclusivos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_exec()
RETURNS TABLE(
    id INT,
    ex_propietario_id INT,
    no_exclusivo INT,
    zona VARCHAR,
    total_bateria FLOAT,
    total_cordon FLOAT,
    solicitud INT,
    control INT,
    folio_cancelacion INT,
    estatus VARCHAR,
    factor FLOAT,
    fecha_in TIMESTAMP,
    fecha_at TIMESTAMP,
    id_clasificacion INT,
    vialidad VARCHAR,
    fecha_inicial DATE,
    usuario INT,
    pc VARCHAR,
    id_1 INT,
    rfc VARCHAR,
    sociedad VARCHAR,
    propietario VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    celular VARCHAR,
    email VARCHAR,
    fecha_in_1 TIMESTAMP,
    fecha_at_1 TIMESTAMP,
    password VARCHAR,
    clasificacion VARCHAR,
    adeudo_axo INT,
    adeudo_mes INT,
    adeudo_anterior NUMERIC,
    adeudo_actual NUMERIC,
    adeudo_proyec NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.*, b.*, c.concepto AS clasificacion,
        fn_exc_axomin(a.id) AS adeudo_axo,
        fn_exc_mesmin(a.id) AS adeudo_mes,
        fn_exc_ade_ant(a.id) AS adeudo_anterior,
        fn_exc_ade_act(a.id) AS adeudo_actual,
        fn_exc_ade_fut(a.id) AS adeudo_proyec
    FROM ex_contrato a
    JOIN ex_propietario b ON a.ex_propietario_id = b.id
    JOIN ex_clasificacion c ON c.id = a.id_clasificacion
    WHERE a.estatus <> 'C' AND a.id_clasificacion IN (1,3)
    ORDER BY c.concepto, a.no_exclusivo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_get_deudores_exec
-- Tipo: Report
-- Descripción: Obtiene el reporte de deudores de estacionamientos exclusivos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_deudores_exec()
RETURNS TABLE(
    id INT,
    ex_propietario_id INT,
    no_exclusivo INT,
    zona VARCHAR,
    total_bateria FLOAT,
    total_cordon FLOAT,
    solicitud INT,
    control INT,
    folio_cancelacion INT,
    estatus VARCHAR,
    factor FLOAT,
    fecha_in TIMESTAMP,
    fecha_at TIMESTAMP,
    id_clasificacion INT,
    vialidad VARCHAR,
    fecha_inicial DATE,
    usuario INT,
    pc VARCHAR,
    id_1 INT,
    rfc VARCHAR,
    sociedad VARCHAR,
    propietario VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    celular VARCHAR,
    email VARCHAR,
    fecha_in_1 TIMESTAMP,
    fecha_at_1 TIMESTAMP,
    password VARCHAR,
    clasificacion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.*, b.*, c.concepto AS clasificacion
    FROM ex_contrato a
    JOIN ex_propietario b ON a.ex_propietario_id = b.id
    JOIN ex_clasificacion c ON c.id = a.id_clasificacion
    WHERE a.estatus <> 'C' AND a.id_clasificacion IN (1,3)
    ORDER BY c.concepto, a.no_exclusivo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_get_estado_cuenta
-- Tipo: Report
-- Descripción: Obtiene el estado de cuenta de un estacionamiento exclusivo por número de exclusivo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_estado_cuenta(no_exclusivo INT)
RETURNS TABLE(
    id INT,
    ex_propietario_id INT,
    no_exclusivo INT,
    zona VARCHAR,
    total_bateria FLOAT,
    total_cordon FLOAT,
    solicitud INT,
    control INT,
    folio_cancelacion INT,
    estatus VARCHAR,
    factor FLOAT,
    fecha_in TIMESTAMP,
    fecha_at TIMESTAMP,
    id_clasificacion INT,
    vialidad VARCHAR,
    fecha_inicial DATE,
    usuario INT,
    pc VARCHAR,
    id_1 INT,
    rfc VARCHAR,
    sociedad VARCHAR,
    propietario VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    celular VARCHAR,
    email VARCHAR,
    fecha_in_1 TIMESTAMP,
    fecha_at_1 TIMESTAMP,
    password VARCHAR,
    clasificacion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.*, b.*, c.concepto AS clasificacion
    FROM ex_contrato a
    JOIN ex_propietario b ON a.ex_propietario_id = b.id
    JOIN ex_clasificacion c ON c.id = a.id_clasificacion
    WHERE a.no_exclusivo = no_exclusivo
      AND a.estatus <> 'C'
      AND a.id_clasificacion IN (1,3)
    ORDER BY c.concepto, a.no_exclusivo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_adeudos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de un contrato (equivalente a cajero_exc_detalle).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_detalle(contrato_id INT, axo INT, mes INT)
RETURNS TABLE(
    concepto VARCHAR,
    axo INT,
    mes INT,
    adeudo NUMERIC,
    recargos NUMERIC,
    descto_recgos NUMERIC,
    tipo INT,
    id_adeudo INT,
    total NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, axo, mes, adeudo, recargos, descto_recgos, tipo, id_adeudo, (adeudo + recargos) AS total
    FROM cajero_exc_detalle
    WHERE contrato_id = sp_adeudos_detalle.contrato_id
      AND axo = sp_adeudos_detalle.axo
      AND mes = sp_adeudos_detalle.mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

