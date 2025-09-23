-- Stored Procedure: sp_update_cve_cuota
-- Tipo: CRUD
-- Descripción: Actualiza una clave de cuota existente
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

CREATE OR REPLACE FUNCTION sp_update_cve_cuota(_clave integer, _descripcion varchar)
RETURNS TABLE(clave_cuota integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_cve_cuota SET descripcion = UPPER(_descripcion) WHERE clave_cuota = _clave;
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota WHERE clave_cuota = _clave;
END; $$;