-- Stored Procedure: sp_check_cuenta
-- Tipo: CRUD
-- Descripción: Verifica si existe la cuenta para el ejecutor y fecha dada.
-- Generado para formulario: Empresas
-- Fecha: 2025-08-27 01:35:17

CREATE OR REPLACE FUNCTION sp_check_cuenta(
  vcta INTEGER,
  veje INTEGER,
  vfec DATE
) RETURNS TABLE(cuentas INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT COUNT(*) FROM ctaempexterna WHERE cvecuenta = vcta AND cveejecutor = veje AND fecha_trabajo = vfec;
END;
$$ LANGUAGE plpgsql;