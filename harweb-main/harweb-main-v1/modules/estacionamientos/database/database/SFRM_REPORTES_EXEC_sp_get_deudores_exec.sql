-- Stored Procedure: sp_get_deudores_exec
-- Tipo: Report
-- Descripción: Obtiene el reporte de deudores de estacionamientos exclusivos.
-- Generado para formulario: SFRM_REPORTES_EXEC
-- Fecha: 2025-08-27 14:25:55

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