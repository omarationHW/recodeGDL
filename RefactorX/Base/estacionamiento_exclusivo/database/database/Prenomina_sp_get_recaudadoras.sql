-- Stored Procedure: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de recaudadoras activas.
-- Generado para formulario: Prenomina
-- Fecha: 2025-08-27 14:21:26

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(id_rec smallint, nombre text, recaudadora text) AS $$
BEGIN
  RETURN QUERY
    SELECT id_rec, nombre, recaudadora
    FROM padron_licencias.comun.ta_12_recaudadoras
    WHERE id_rec < 8
    ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;