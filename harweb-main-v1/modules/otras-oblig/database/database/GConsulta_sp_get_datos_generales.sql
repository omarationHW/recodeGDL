-- Stored Procedure: sp_get_datos_generales
-- Tipo: Report
-- Descripción: Obtiene los datos generales del contrato/concesión para mostrar en la consulta.
-- Generado para formulario: GConsulta
-- Fecha: 2025-08-27 16:02:36

CREATE OR REPLACE FUNCTION sp_get_datos_generales(par_tab integer, par_control varchar)
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
    giro integer,
    control varchar,
    tipoobligacion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN a.id_34_datos IS NULL THEN -1 ELSE 0 END AS status,
        CASE WHEN a.id_34_datos IS NULL THEN 'No existe registro' ELSE 'OK' END AS concepto_status,
        a.id_34_datos, a.concesionario, a.ubicacion, a.nomcomercial, a.lugar, a.obs, a.adicionales, a.statusregistro, a.unidades, a.categoria, a.seccion, a.bloque, a.sector, a.superficie, a.fechainicio, a.fechafin, a.recaudadora, a.zona, a.licencia, a.giro, a.control, a.tipoobligacion
    FROM t34_datos a
    WHERE a.cve_tab = par_tab AND a.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;