-- Stored Procedure: sp34_vigencias
-- Tipo: Catalog
-- Descripción: Obtiene las vigencias disponibles para la tabla.
-- Generado para formulario: AuxRep
-- Fecha: 2025-08-28 12:38:35

CREATE OR REPLACE FUNCTION sp34_vigencias(par_tab integer)
RETURNS TABLE(
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT b.descripcion
    FROM t34_datos a, t34_status b
    WHERE a.cve_tab = par_tab
      AND b.id_34_stat = a.id_stat
    GROUP BY b.descripcion
    ORDER BY b.descripcion;
END;
$$ LANGUAGE plpgsql;