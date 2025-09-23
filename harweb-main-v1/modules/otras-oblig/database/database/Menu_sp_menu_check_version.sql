-- Stored Procedure: sp_menu_check_version
-- Tipo: CRUD
-- Descripción: Verifica si hay una nueva versión disponible para el proyecto.
-- Generado para formulario: Menu
-- Fecha: 2025-08-28 13:23:04

CREATE OR REPLACE FUNCTION sp_menu_check_version(p_proyecto TEXT, p_version TEXT)
RETURNS TABLE(update_required BOOLEAN) AS $$
BEGIN
  RETURN QUERY
    SELECT NOT EXISTS (
      SELECT 1 FROM ta_versiones WHERE proyecto = p_proyecto AND version = p_version
    ) AS update_required;
END;
$$ LANGUAGE plpgsql;