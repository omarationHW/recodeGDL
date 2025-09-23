-- Stored Procedure: sp_get_empresa_by_ejecutor
-- Tipo: Catalog
-- Descripción: Obtiene el nombre de la empresa (ejecutor) por clave.
-- Generado para formulario: ActualizaFechaEmpresas
-- Fecha: 2025-08-26 20:24:51

CREATE OR REPLACE FUNCTION sp_get_empresa_by_ejecutor(p_cveejecutor INTEGER)
RETURNS TABLE(empresa TEXT) AS $$
BEGIN
  RETURN QUERY SELECT trim(paterno)||' '||trim(materno)||' '||trim(nombres) as empresa FROM ejecutor WHERE cveejecutor = p_cveejecutor;
END;
$$ LANGUAGE plpgsql;