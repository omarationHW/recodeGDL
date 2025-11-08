-- Stored Procedure: sp16_operaciones_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de operación
-- Generado para formulario: Mannto_Operaciones
-- Fecha: 2025-08-27 14:45:58

CREATE OR REPLACE FUNCTION sp16_operaciones_list()
RETURNS TABLE (
  ctrol_operacion integer,
  cve_operacion varchar(1),
  descripcion varchar(80)
) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion ORDER BY ctrol_operacion;
END;
$$ LANGUAGE plpgsql;