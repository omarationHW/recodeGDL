-- Stored Procedure: calc_fecha_limite_pago
-- Tipo: CRUD
-- Descripción: Calcula la fecha límite de pago considerando días no laborables
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-26 15:24:46

CREATE OR REPLACE FUNCTION calc_fecha_limite_pago(p_fecha_tram date)
RETURNS TABLE(fechalimitepago date) AS $$
DECLARE
  fecha_salida date;
  dias_nolabor integer;
BEGIN
  fecha_salida := p_fecha_tram + INTERVAL '10 days';
  SELECT count(*) INTO dias_nolabor FROM no_laboralesLic WHERE fecha BETWEEN p_fecha_tram AND fecha_salida;
  fecha_salida := fecha_salida + dias_nolabor;
  WHILE EXISTS (SELECT 1 FROM no_laboralesLic WHERE fecha = fecha_salida) LOOP
    fecha_salida := fecha_salida + INTERVAL '1 day';
  END LOOP;
  RETURN QUERY SELECT fecha_salida;
END;
$$ LANGUAGE plpgsql;