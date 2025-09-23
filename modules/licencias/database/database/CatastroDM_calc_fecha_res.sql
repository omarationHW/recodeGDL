-- Stored Procedure: calc_fecha_res
-- Tipo: CRUD
-- Descripción: Calcula la fecha de resolución considerando días no laborables y tipo de trámite
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-26 15:24:46

CREATE OR REPLACE FUNCTION calc_fecha_res(p_fecha_tram date, p_tipo text, p_autoev boolean)
RETURNS TABLE(fechares date) AS $$
DECLARE
  dias integer;
  fecha_salida date;
  dias_nolabor integer;
  i integer := 1;
BEGIN
  fecha_salida := p_fecha_tram;
  IF p_autoev THEN
    fecha_salida := p_fecha_tram + INTERVAL '3 days';
  ELSE
    IF p_tipo = 'A' OR p_tipo = 'B' THEN
      fecha_salida := p_fecha_tram + INTERVAL '15 days';
    ELSIF p_tipo = 'C' THEN
      fecha_salida := p_fecha_tram + INTERVAL '10 days';
    ELSIF p_tipo = 'D' THEN
      fecha_salida := p_fecha_tram + INTERVAL '20 days';
    ELSE
      fecha_salida := p_fecha_tram + INTERVAL '1 day';
    END IF;
  END IF;
  SELECT count(*) INTO dias_nolabor FROM no_laboralesLic WHERE fecha BETWEEN p_fecha_tram AND fecha_salida;
  i := 1;
  WHILE i <= dias_nolabor LOOP
    fecha_salida := fecha_salida + INTERVAL '1 day';
    IF NOT EXISTS (SELECT 1 FROM no_laboralesLic WHERE fecha = fecha_salida) THEN
      i := i + 1;
    END IF;
  END LOOP;
  RETURN QUERY SELECT fecha_salida;
END;
$$ LANGUAGE plpgsql;