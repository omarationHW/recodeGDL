-- Stored Procedure: edo_cuenta_calc_recargos
-- Tipo: CRUD
-- Descripción: Calcula los recargos para un adeudo específico según la lógica de vencimiento y días inhábiles.
-- Generado para formulario: EdoCuenta
-- Fecha: 2025-08-27 14:27:45

CREATE OR REPLACE FUNCTION edo_cuenta_calc_recargos(p_id_conv_resto integer, p_pago_parcial integer)
RETURNS TABLE(
  recargos numeric
) AS $$
DECLARE
  alo integer;
  mes integer;
  dia integer;
  alov integer;
  mesv integer;
  diav integer;
  dvenc integer;
  fecha1 date;
  fecha text;
  mes_c text;
  cont integer;
  porc numeric;
  importe numeric;
BEGIN
  SELECT EXTRACT(YEAR FROM CURRENT_DATE), EXTRACT(MONTH FROM CURRENT_DATE), EXTRACT(DAY FROM CURRENT_DATE)
    INTO alo, mes, dia;
  mes_c := lpad(mes::text, 2, '0');
  SELECT fecha_venc, importe INTO fecha1, importe FROM ta_17_adeudos_div WHERE id_conv_resto = p_id_conv_resto AND pago_parcial = p_pago_parcial;
  IF fecha1 IS NULL THEN RETURN; END IF;
  SELECT EXTRACT(YEAR FROM fecha1), EXTRACT(MONTH FROM fecha1), EXTRACT(DAY FROM fecha1) INTO alov, mesv, diav;
  SELECT day(fecha_venc) INTO dvenc FROM ta_17_adeudos_div WHERE id_conv_resto = p_id_conv_resto AND EXTRACT(YEAR FROM fecha_venc) = alo AND EXTRACT(MONTH FROM fecha_venc) = mes LIMIT 1;
  IF dvenc IS NULL THEN
    fecha := '19/' || mes_c || '/' || alo::text;
    fecha1 := to_date(fecha, 'DD/MM/YYYY');
    cont := 5;
    WHILE cont = 5 LOOP
      IF extract(dow from fecha1) > 1 AND extract(dow from fecha1) < 7 THEN
        IF NOT EXISTS (SELECT 1 FROM ta_12_diasinhabil WHERE fecha = fecha1) THEN
          cont := 10;
        ELSE
          fecha1 := fecha1 + interval '1 day';
        END IF;
      ELSE
        fecha1 := fecha1 + interval '1 day';
      END IF;
    END LOOP;
    dvenc := EXTRACT(DAY FROM fecha1);
  END IF;
  SELECT COALESCE(SUM(porcentaje_parcial),0) INTO porc FROM ta_13_recargosrcm WHERE (axo = alov AND mes >= mesv) OR (axo = alo AND mes <= CASE WHEN dia <= dvenc THEN mes-1 ELSE mes END) OR (axo > alov AND axo < alo);
  recargos := (importe * porc) / 100.0;
  IF recargos > 0 THEN
    recargos := trunc(recargos * 100) / 100.0;
  END IF;
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;