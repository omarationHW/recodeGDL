-- Stored Procedure: sp_check_empresa_diferente
-- Tipo: CRUD
-- Descripción: Verifica si la cuenta existe para otra empresa (ejecutor) distinta.
-- Generado para formulario: Empresas
-- Fecha: 2025-08-27 01:35:17

CREATE OR REPLACE FUNCTION sp_check_empresa_diferente(
  ecta INTEGER,
  eeje INTEGER
) RETURNS TABLE(existe INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT COUNT(*) FROM ctaempexterna WHERE cvecuenta = ecta AND fecha_trabajo >= DATE '2022-01-01' AND cveejecutor <> eeje;
END;
$$ LANGUAGE plpgsql;