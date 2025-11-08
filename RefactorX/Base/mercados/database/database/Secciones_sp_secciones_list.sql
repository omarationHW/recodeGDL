-- Stored Procedure: sp_secciones_list
-- Tipo: Catalog
-- Descripción: Lista todas las secciones ordenadas por clave.
-- Generado para formulario: Secciones
-- Fecha: 2025-08-27 01:30:23

CREATE OR REPLACE FUNCTION sp_secciones_list()
RETURNS TABLE(seccion VARCHAR(2), descripcion VARCHAR(30)) AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion ASC;
END;
$$ LANGUAGE plpgsql;