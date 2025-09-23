-- Stored Procedure: sp_consulta_permiso
-- Tipo: Catalog
-- Descripción: Consulta permisos de usuario para descuentos
-- Generado para formulario: drecgoLic
-- Fecha: 2025-08-27 00:52:37

CREATE OR REPLACE FUNCTION sp_consulta_permiso(p_usuario VARCHAR) RETURNS TABLE(
  usuario VARCHAR,
  num_tag INTEGER
) AS $$
BEGIN
  RETURN QUERY SELECT usuario, num_tag FROM autoriza WHERE usuario=p_usuario;
END;
$$ LANGUAGE plpgsql;