-- Stored Procedure: cob34_gdatosg_02
-- Tipo: CRUD
-- Descripción: Obtiene encabezado de control para Otras Obligaciones
-- Generado para formulario: DMultaOtrasObligaciones
-- Fecha: 2025-08-27 00:31:21

CREATE OR REPLACE FUNCTION cob34_gdatosg_02(par_tabla TEXT, par_control TEXT)
RETURNS TABLE (
    status INTEGER,
    concepto_status TEXT,
    id_datos INTEGER,
    control TEXT,
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
    superficie FLOAT,
    fechainicio DATE,
    fechafin DATE,
    recaudadora INTEGER,
    zona INTEGER,
    licencia INTEGER,
    giro INTEGER,
    tipoobligacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.status,
        o.concepto_status,
        o.id_datos,
        o.control,
        o.concesionario,
        o.ubicacion,
        o.nomcomercial,
        o.lugar,
        o.obs,
        o.adicionales,
        o.statusregistro,
        o.unidades,
        o.categoria,
        o.seccion,
        o.bloque,
        o.sector,
        o.superficie,
        o.fechainicio,
        o.fechafin,
        o.recaudadora,
        o.zona,
        o.licencia,
        o.giro,
        o.tipoobligacion
    FROM t34_control o
    WHERE o.tabla = par_tabla AND o.control = par_control;
END;
$$ LANGUAGE plpgsql;