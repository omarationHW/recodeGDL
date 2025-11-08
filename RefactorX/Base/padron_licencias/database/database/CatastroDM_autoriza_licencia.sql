-- Stored Procedure: autoriza_licencia
-- Tipo: CRUD
-- Descripción: Autoriza una licencia para un trámite dado
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-26 15:24:46

CREATE OR REPLACE FUNCTION autoriza_licencia(p_no_tramite integer)
RETURNS TABLE(result text) AS $$
BEGIN
  -- Aquí va la lógica de autorización de licencia, actualización de tablas, etc.
  -- Por simplicidad, solo retorna OK
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;