-- Stored Procedure: sp_listxFec_get_ejecutores
-- Tipo: Catalog
-- Descripción: Obtiene ejecutores por recaudadora
-- Generado para formulario: ListxFec
-- Fecha: 2025-08-27 20:48:46

CREATE OR REPLACE FUNCTION sp_listxFec_get_ejecutores(p_rec INT)
RETURNS TABLE(cve_eje INT, nombre VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT cve_eje, nombre FROM ta_15_ejecutores WHERE id_rec = p_rec ORDER BY cve_eje;
END;
$$ LANGUAGE plpgsql;