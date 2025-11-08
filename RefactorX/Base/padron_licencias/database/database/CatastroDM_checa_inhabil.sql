-- Stored Procedure: checa_inhabil
-- Tipo: CRUD
-- Descripción: Verifica si una fecha es inhábil
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-26 15:24:46

CREATE OR REPLACE FUNCTION checa_inhabil(p_fecha date)
RETURNS TABLE(inhabil boolean) AS $$
BEGIN
  RETURN QUERY SELECT EXISTS(SELECT 1 FROM no_laboralesLic WHERE fecha = p_fecha);
END;
$$ LANGUAGE plpgsql;