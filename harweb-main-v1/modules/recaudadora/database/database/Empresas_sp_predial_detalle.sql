-- Stored Procedure: sp_predial_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de predial para un ejecutor y fecha.
-- Generado para formulario: Empresas
-- Fecha: 2025-08-27 01:35:17

CREATE OR REPLACE FUNCTION sp_predial_detalle(
  pejec INTEGER,
  pfecha DATE
) RETURNS SETOF predial_detalle AS $$
-- predial_detalle debe ser un tipo compuesto o tabla con los campos requeridos
BEGIN
  RETURN QUERY
    SELECT * FROM predial_detalle WHERE cveejecutor = pejec AND fecha = pfecha;
END;
$$ LANGUAGE plpgsql;