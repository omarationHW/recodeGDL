-- Stored Procedure: sp_cob34_gdatosg_02
-- Tipo: Report
-- Descripción: Obtiene los datos generales de la concesión/dato por control y tabla.
-- Generado para formulario: GAdeudos_OpcMult
-- Fecha: 2025-08-27 20:44:01

CREATE OR REPLACE FUNCTION sp_cob34_gdatosg_02(par_tab integer, par_control text)
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
    SELECT 
        CASE WHEN d.id_34_datos IS NULL THEN -1 ELSE 1 END AS status,
        CASE WHEN d.id_34_datos IS NULL THEN 'No existe registro' ELSE 'OK' END AS concepto_status,
        d.id_34_datos, d.concesionario, d.ubicacion, d.nomcomercial, d.lugar, d.obs, d.adicionales, s.descripcion as statusregistro,
        d.unidades, d.categoria, d.seccion, d.bloque, d.sector, d.superficie, d.fecha_inicio, d.fecha_fin, d.id_recaudadora, d.id_zona, d.licencia, d.giro
    FROM t34_datos d
    LEFT JOIN t34_status s ON d.id_stat = s.id_34_stat
    WHERE d.cve_tab = par_tab AND d.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;