-- Stored Procedure: sp_gadeudos_etiquetas
-- Tipo: Catalog
-- Descripción: Devuelve las etiquetas de la tabla para mostrar en el frontend
-- Generado para formulario: GAdeudos
-- Fecha: 2025-08-28 12:49:54

CREATE OR REPLACE FUNCTION sp_gadeudos_etiquetas(par_tab TEXT)
RETURNS TABLE(
    cve_tab TEXT,
    abreviatura TEXT,
    etiq_control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie TEXT,
    fecha_inicio TEXT,
    fecha_fin TEXT,
    recaudadora TEXT,
    sector TEXT,
    zona TEXT,
    licencia TEXT,
    fecha_cancelacion TEXT,
    unidad TEXT,
    categoria TEXT,
    seccion TEXT,
    bloque TEXT,
    nombre_comercial TEXT,
    lugar TEXT,
    obs TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;