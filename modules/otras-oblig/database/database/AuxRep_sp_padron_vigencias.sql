-- Stored Procedure: sp_padron_vigencias
-- Tipo: Catalog
-- Descripción: Obtiene las vigencias distintas de las concesiones para el combo de filtro.
-- Generado para formulario: AuxRep
-- Fecha: 2025-08-27 23:08:15

CREATE OR REPLACE FUNCTION sp_padron_vigencias(par_tab integer)
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