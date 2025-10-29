-- Stored Procedure: sp_get_adeudos_by_local
-- Tipo: Catalog
-- Descripción: Obtiene los adeudos de un local
-- Generado para formulario: RptCaratulaDatos
-- Fecha: 2025-08-27 00:44:44

CREATE OR REPLACE FUNCTION sp_get_adeudos_by_local(p_id_local INTEGER)
RETURNS TABLE(
  id_local INTEGER,
  axo SMALLINT,
  periodo SMALLINT,
  importe NUMERIC,
  recargos NUMERIC,
  percadena VARCHAR,
  impcalc NUMERIC,
  leyenda VARCHAR
) AS $$
DECLARE
  per TEXT;
BEGIN
  FOR id_local, axo, periodo, importe IN
    SELECT id_local, axo, periodo, importe FROM ta_11_adeudo_local WHERE id_local = p_id_local ORDER BY axo, periodo
  LOOP
    IF periodo < 10 THEN
      per := '0';
    ELSE
      per := '';
    END IF;
    percadena := axo::TEXT || '-' || per || periodo::TEXT;
    recargos := 0; -- Se puede calcular con otro SP
    impcalc := importe; -- Lógica de descuento puede ir aquí
    leyenda := '';
    RETURN NEXT;
  END LOOP;
END;
$$ LANGUAGE plpgsql;