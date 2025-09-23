-- Stored Procedure: sp_get_reportes_exec
-- Tipo: Report
-- Descripción: Obtiene el reporte de estacionamientos exclusivos por clasificación y agrupación (número de exclusivo o propietario).
-- Generado para formulario: SFRM_REPORTES_EXEC
-- Fecha: 2025-08-27 14:25:55

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