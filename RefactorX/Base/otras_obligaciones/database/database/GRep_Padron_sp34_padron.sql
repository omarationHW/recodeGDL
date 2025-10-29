-- Stored Procedure: sp34_padron
-- Tipo: Report
-- Descripción: Obtiene el padrón de concesiones con adeudos filtrado por tabla y vigencia.
-- Generado para formulario: GRep_Padron
-- Fecha: 2025-08-28 13:21:45

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