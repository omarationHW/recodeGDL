-- Stored Procedure: sp34_padron
-- Tipo: Report
-- Descripción: Obtiene el padrón de concesionarios filtrado por tabla y vigencia.
-- Generado para formulario: AuxRep
-- Fecha: 2025-08-28 12:38:35

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