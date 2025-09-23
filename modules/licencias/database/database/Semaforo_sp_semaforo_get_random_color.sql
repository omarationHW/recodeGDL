-- Stored Procedure: sp_semaforo_get_random_color
-- Tipo: CRUD
-- Descripción: Devuelve un color aleatorio (ROJO o VERDE) y el número generado.
-- Generado para formulario: Semaforo
-- Fecha: 2025-08-27 19:32:03

CREATE OR REPLACE FUNCTION sp_semaforo_get_random_color()
RETURNS TABLE(color VARCHAR, numcolor INT) AS $$
DECLARE
  n INT;
BEGIN
  n := floor(random()*100 + 1);
  IF n <= 10 THEN
    color := 'ROJO';
  ELSE
    color := 'VERDE';
  END IF;
  numcolor := n;
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;