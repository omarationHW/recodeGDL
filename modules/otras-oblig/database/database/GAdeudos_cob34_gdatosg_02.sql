-- Stored Procedure: cob34_gdatosg_02
-- Tipo: Report
-- Descripción: Obtiene los datos generales de un contrato/concesión por tabla y control.
-- Generado para formulario: GAdeudos
-- Fecha: 2025-08-27 23:20:17

CREATE OR REPLACE FUNCTION cob34_gdatosg_02(par_tab TEXT, par_control TEXT)
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
    giro INTEGER,
    tipoobligacion TEXT,
    control TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN COUNT(*) = 0 THEN -1 ELSE 1 END AS status,
        CASE WHEN COUNT(*) = 0 THEN 'No existe registro' ELSE 'OK' END AS concepto_status,
        id_34_datos, concesionario, ubicacion, nomcomercial, lugar, obs, adicionales, statusregistro, unidades, categoria, seccion, bloque, sector, superficie, fechainicio, fechafin, recaudadora, zona, licencia, giro, tipoobligacion, control
    FROM t34_datos
    WHERE cve_tab = par_tab AND control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;