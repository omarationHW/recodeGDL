-- Stored Procedure: sp_get_adeudos_energia
-- Tipo: Catalog
-- Descripción: Obtiene los adeudos de energía eléctrica para un local, incluyendo cálculo de recargos
-- Generado para formulario: ConsultaDatosEnergia
-- Fecha: 2025-08-26 23:25:04

CREATE OR REPLACE FUNCTION sp_get_adeudos_energia(p_id_local INT)
RETURNS TABLE (
  axo SMALLINT,
  periodo SMALLINT,
  importe NUMERIC,
  recargos NUMERIC
) AS $$
DECLARE
  r RECORD;
  recargo NUMERIC;
BEGIN
  FOR r IN SELECT a.axo, a.periodo, a.importe, a.id_energia FROM ta_11_adeudo_energ a
           JOIN ta_11_energia e ON a.id_energia = e.id_energia
           WHERE e.id_local = p_id_local
           ORDER BY a.axo, a.periodo
  LOOP
    -- Cálculo de recargos (simplificado, debe ajustarse según reglas reales)
    SELECT COALESCE(SUM(porcentaje_mes),0) INTO recargo
      FROM ta_12_recargos
      WHERE axo = r.axo AND mes >= r.periodo;
    RETURN NEXT (r.axo, r.periodo, r.importe, (r.importe * recargo / 100));
  END LOOP;
END;
$$ LANGUAGE plpgsql;