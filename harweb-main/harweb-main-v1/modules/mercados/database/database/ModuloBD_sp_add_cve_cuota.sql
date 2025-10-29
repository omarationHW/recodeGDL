-- Stored Procedure: sp_add_cve_cuota
-- Tipo: CRUD
-- Descripción: Agrega una nueva clave de cuota
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

CREATE OR REPLACE FUNCTION sp_add_cve_cuota(_clave integer, _descripcion varchar)
RETURNS TABLE(clave_cuota integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_cve_cuota (clave_cuota, descripcion) VALUES (_clave, UPPER(_descripcion));
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota WHERE clave_cuota = _clave;
END; $$;