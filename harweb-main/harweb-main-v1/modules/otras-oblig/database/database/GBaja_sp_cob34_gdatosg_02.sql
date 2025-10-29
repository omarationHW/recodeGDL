-- Stored Procedure: sp_cob34_gdatosg_02
-- Tipo: CRUD
-- Descripción: Obtiene los datos generales de la concesión por tabla y control.
-- Generado para formulario: GBaja
-- Fecha: 2025-08-27 13:58:32

CREATE OR REPLACE FUNCTION sp_cob34_gdatosg_02(par_tab TEXT, par_control TEXT)
RETURNS TABLE (
    status INTEGER,
    concepto_status TEXT,
    id_datos INTEGER,
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
    superficie NUMERIC,
    fechainicio DATE,
    fechafin DATE,
    recaudadora INTEGER,
    zona INTEGER,
    licencia INTEGER,
    giro INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN d.id_34_datos IS NULL THEN -1 ELSE 1 END AS status,
        CASE WHEN d.id_34_datos IS NULL THEN 'No existe registro' ELSE 'OK' END AS concepto_status,
        d.id_34_datos, d.concesionario, d.ubicacion, d.nomcomercial, d.lugar, d.obs, d.adicionales,
        s.descripcion AS statusregistro, d.unidades, d.categoria, d.seccion, d.bloque, d.sector,
        d.superficie, d.fecha_inicio, d.fecha_fin, d.recaudadora, d.zona, d.licencia, d.giro
    FROM t34_datos d
    LEFT JOIN t34_status s ON d.id_stat = s.id_34_stat
    WHERE d.cve_tab = par_tab AND d.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;