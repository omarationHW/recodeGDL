-- Stored Procedure: sp_recalcula_proporcional_baja
-- Tipo: CRUD
-- Descripción: Recalcula la parte proporcional de adeudos para baja de licencia
-- Generado para formulario: TramiteBajaLic
-- Fecha: 2025-08-26 18:22:43

CREATE OR REPLACE FUNCTION sp_recalcula_proporcional_baja(p_licencia integer)
RETURNS TABLE(axo integer, derechos numeric, saldo numeric) AS $$
DECLARE
  v_axo integer;
  v_mes integer;
  v_cuatrimestre integer;
  v_monto numeric;
  rec RECORD;
BEGIN
  v_axo := EXTRACT(YEAR FROM CURRENT_DATE);
  v_mes := EXTRACT(MONTH FROM CURRENT_DATE);
  v_cuatrimestre := FLOOR((v_mes / 4) + 0.75);
  FOR rec IN SELECT * FROM detsal_lic WHERE id_licencia = p_licencia AND axo = v_axo AND cvepago = 0 LOOP
    v_monto := rec.derechos;
    IF v_cuatrimestre = 2 THEN
      v_monto := v_monto - (v_monto * 0.30);
    ELSIF v_cuatrimestre = 3 THEN
      v_monto := v_monto - (v_monto * 0.70);
    END IF;
    RETURN NEXT (rec.axo, v_monto, rec.forma + v_monto + rec.recargos);
  END LOOP;
END;
$$ LANGUAGE plpgsql;