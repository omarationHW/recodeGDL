-- Stored Procedure: sp_get_cuentas
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de cuentas de aplicación
-- Generado para formulario: CallesMntto
-- Fecha: 2025-08-27 13:59:54

CREATE OR REPLACE FUNCTION sp_get_cuentas() RETURNS TABLE(cta_aplicacion integer, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT cta_aplicacion, descripcion FROM cg_12_cuentas;
END;
$$ LANGUAGE plpgsql;