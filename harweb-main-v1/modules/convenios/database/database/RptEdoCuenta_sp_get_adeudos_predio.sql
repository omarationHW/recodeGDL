-- Stored Procedure: sp_get_adeudos_predio
-- Tipo: Report
-- Descripción: Obtiene los adeudos (parcialidades) de un predio/convenio, calculando recargos.
-- Generado para formulario: RptEdoCuenta
-- Fecha: 2025-08-27 15:37:22

CREATE OR REPLACE FUNCTION sp_get_adeudos_predio(p_id_conv_resto INTEGER)
RETURNS TABLE (
  pago_parcial SMALLINT,
  importe NUMERIC,
  fecha_venc DATE,
  recargos NUMERIC
) AS $$
DECLARE
  r RECORD;
  alo INT;
  mes INT;
  dia INT;
  alov INT;
  mesv INT;
  diav INT;
  dvenc INT;
  porc FLOAT;
  rec NUMERIC;
  fecha1 DATE;
  mes_c TEXT;
  fecha TEXT;
  cont INT;
  fecha_venc_calc DATE;
BEGIN
  SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO alo;
  SELECT EXTRACT(MONTH FROM CURRENT_DATE) INTO mes;
  SELECT EXTRACT(DAY FROM CURRENT_DATE) INTO dia;
  FOR r IN SELECT * FROM ta_17_adeudos_div WHERE id_conv_resto = p_id_conv_resto ORDER BY pago_parcial LOOP
    SELECT EXTRACT(YEAR FROM r.fecha_venc), EXTRACT(MONTH FROM r.fecha_venc), EXTRACT(DAY FROM r.fecha_venc)
      INTO alov, mesv, diav;
    -- Calcular día de vencimiento
    SELECT day(fecha_venc) FROM ta_17_adeudos_div WHERE id_conv_resto = p_id_conv_resto AND EXTRACT(YEAR FROM fecha_venc) = alo AND EXTRACT(MONTH FROM fecha_venc) = mes
      INTO dvenc;
    IF dvenc IS NULL THEN
      mes_c := lpad(mes::text, 2, '0');
      fecha := '19/' || mes_c || '/' || alo::text;
      fecha1 := to_date(fecha, 'DD/MM/YYYY');
      cont := 5;
      WHILE cont = 5 LOOP
        IF extract(dow from fecha1) > 1 AND extract(dow from fecha1) < 7 THEN
          IF NOT EXISTS (SELECT 1 FROM ta_12_diasinhabil WHERE fecha = fecha1) THEN
            cont := 10;
          ELSE
            fecha1 := fecha1 + INTERVAL '1 day';
          END IF;
        ELSE
          fecha1 := fecha1 + INTERVAL '1 day';
        END IF;
      END LOOP;
      dvenc := extract(day from fecha1);
    END IF;
    -- Calcular recargos
    porc := 0;
    SELECT COALESCE(SUM(porcentaje_parcial),0) INTO porc FROM ta_13_recargosrcm
      WHERE (axo = alov AND mes >= mesv)
        AND ((alov >= alo AND axo = alo AND mes <= (CASE WHEN dia <= dvenc THEN mes-1 ELSE mes END))
             OR (axo > alov AND axo < alo));
    rec := (r.importe * porc) / 100.0;
    IF rec > 0 THEN
      rec := trunc(rec * 100) / 100.0;
    END IF;
    RETURN NEXT (r.pago_parcial, r.importe, r.fecha_venc, rec);
  END LOOP;
END;
$$ LANGUAGE plpgsql;