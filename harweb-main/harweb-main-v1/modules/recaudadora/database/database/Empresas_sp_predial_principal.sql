-- Stored Procedure: sp_predial_principal
-- Tipo: Report
-- Descripción: Obtiene los datos principales de predial para un ejecutor y fecha.
-- Generado para formulario: Empresas
-- Fecha: 2025-08-27 01:35:17

CREATE OR REPLACE FUNCTION sp_predial_principal(
  pejec INTEGER,
  pfecha DATE
) RETURNS SETOF predial_principal AS $$
-- predial_principal debe ser un tipo compuesto o tabla con los campos requeridos
BEGIN
  RETURN QUERY
    SELECT * FROM predial_principal WHERE cveejecutor = pejec AND fecha = pfecha;
END;
$$ LANGUAGE plpgsql;