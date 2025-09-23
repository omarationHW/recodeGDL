-- Stored Procedure: sp_get_ejecutores
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de ejecutores vigentes.
-- Generado para formulario: Empresas
-- Fecha: 2025-08-27 01:35:17

CREATE OR REPLACE FUNCTION sp_get_ejecutores()
RETURNS TABLE(cveejecutor SMALLINT, ejecutor TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT cveejecutor, TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres) AS ejecutor
    FROM ejecutor
    WHERE vigencia = 'V' AND fecinic >= DATE '2022-01-01';
END;
$$ LANGUAGE plpgsql;