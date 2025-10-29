-- Stored Procedure: get_ejecutores_empresas
-- Tipo: Catalog
-- Descripción: Obtiene ejecutores de empresas activos desde una fecha
-- Generado para formulario: ListadoMultiple
-- Fecha: 2025-08-27 12:49:10

CREATE OR REPLACE FUNCTION get_ejecutores_empresas(ftrabajo date)
RETURNS TABLE(
  cveejecutor integer,
  empresa varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT f.cveejecutor, TRIM(e.paterno)||' '||TRIM(e.materno)||' '||TRIM(e.nombres) AS empresa
  FROM ctaempexterna f
  INNER JOIN ejecutor e ON e.cveejecutor=f.cveejecutor
  WHERE f.fecha_trabajo >= ftrabajo;
END;
$$ LANGUAGE plpgsql;