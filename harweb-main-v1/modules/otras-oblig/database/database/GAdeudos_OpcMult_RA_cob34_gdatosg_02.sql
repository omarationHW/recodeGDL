-- Stored Procedure: cob34_gdatosg_02
-- Tipo: CRUD
-- Descripción: Obtiene los datos generales de adeudos para una tabla y control específico, similar al stored procedure de Informix.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-27 23:39:10

CREATE OR REPLACE FUNCTION cob34_gdatosg_02(par_tab integer, par_control text)
RETURNS TABLE (
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
    SELECT
        CASE WHEN d.id_datos IS NULL THEN -1 ELSE 1 END AS status,
        ''::text AS concepto_status,
        d.id_datos,
        d.concesionario,
        d.ubicacion,
        d.nomcomercial,
        d.lugar,
        d.obs,
        d.adicionales,
        d.statusregistro,
        d.unidades,
        d.categoria,
        d.seccion,
        d.bloque,
        d.sector,
        d.superficie,
        d.fechainicio,
        d.fechafin,
        d.recaudadora,
        d.zona,
        d.licencia,
        d.giro
    FROM t34_datosg d
    WHERE d.cve_tab = par_tab::text AND d.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;