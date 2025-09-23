-- Stored Procedure: sp34_vigencias_concesion
-- Tipo: Catalog
-- Descripción: Obtiene las vigencias de concesión disponibles para una tabla.
-- Generado para formulario: GRep_Padron
-- Fecha: 2025-08-28 13:21:45

CREATE OR REPLACE FUNCTION sp34_vigencias_concesion(par_tab integer)
RETURNS TABLE(descripcion text) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT b.descripcion
    FROM t34_datos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_tab
    ORDER BY b.descripcion;
END;
$$ LANGUAGE plpgsql;