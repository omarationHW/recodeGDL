-- Stored Procedure: get_etiq
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de la tabla específica.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-27 23:39:10

CREATE OR REPLACE FUNCTION get_etiq(par_tab integer)
RETURNS SETOF t34_etiq AS $$
BEGIN
    RETURN QUERY SELECT * FROM t34_etiq WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;