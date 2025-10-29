-- Stored Procedure: alta_energia_mtto
-- Tipo: CRUD
-- Descripción: Da de alta un registro de energía para un local, crea historial y adeudos
-- Generado para formulario: EnergiaMtto
-- Fecha: 2025-08-26 23:57:51

CREATE OR REPLACE FUNCTION alta_energia_mtto(
  p_id_local integer, p_cve_consumo text, p_descripcion text, p_cantidad numeric, p_vigencia text, p_fecha_alta date, p_axo integer, p_numero text, p_user integer, p_oficina integer, p_num_mercado integer, p_categoria integer, p_seccion text
) RETURNS TABLE(result text) AS $$
DECLARE
  v_id_energia integer;
  v_periodo integer;
  v_peralt date;
  v_cant numeric;
  v_mes integer;
  v_dia integer;
  v_alo integer;
BEGIN
  -- Insertar en ta_11_energia
  INSERT INTO ta_11_energia (id_local, cve_consumo, local_adicional, cantidad, vigencia, fecha_alta, fecha_baja, fecha_modificacion, id_usuario)
  VALUES (p_id_local, p_cve_consumo, p_descripcion, p_cantidad, p_vigencia, p_fecha_alta, NULL, NOW(), p_user)
  RETURNING id_energia INTO v_id_energia;

  -- Insertar en historial
  INSERT INTO ta_11_energia_hist (id_energia, axo, numero, cve_consumo, local_adicional, cantidad, vigencia, fecha_alta, fecha_baja, fecha_modificacion, id_usuario, tipo_mov, fecha_mov, id_usuario_mov)
  VALUES (v_id_energia, p_axo, p_numero, p_cve_consumo, p_descripcion, p_cantidad, p_vigencia, p_fecha_alta, NULL, NOW(), p_user, 'A', NOW(), p_user);

  -- Generar adeudos desde fecha de alta hasta hoy
  v_peralt := p_fecha_alta;
  WHILE v_peralt <= CURRENT_DATE LOOP
    v_alo := EXTRACT(YEAR FROM v_peralt);
    v_mes := EXTRACT(MONTH FROM v_peralt);
    v_dia := EXTRACT(DAY FROM v_peralt);
    IF v_alo <= 2002 THEN
      -- Bimestral
      IF v_mes BETWEEN 1 AND 2 THEN v_periodo := 1;
      ELSIF v_mes BETWEEN 3 AND 4 THEN v_periodo := 2;
      ELSIF v_mes BETWEEN 5 AND 6 THEN v_periodo := 3;
      ELSIF v_mes BETWEEN 7 AND 8 THEN v_periodo := 4;
      ELSIF v_mes BETWEEN 9 AND 10 THEN v_periodo := 5;
      ELSE v_periodo := 6; END IF;
      v_cant := p_cantidad * 2;
    ELSE
      v_periodo := v_mes;
      v_cant := p_cantidad;
    END IF;
    INSERT INTO ta_11_adeudo_energ (id_energia, axo, periodo, cve_consumo, cantidad, importe, fecha_alta, id_usuario)
    VALUES (v_id_energia, v_alo, v_periodo, p_cve_consumo, v_cant, v_cant, NOW(), p_user);
    -- Siguiente periodo
    IF v_alo <= 2002 THEN
      v_peralt := v_peralt + INTERVAL '60 days';
    ELSE
      v_peralt := v_peralt + INTERVAL '30 days';
    END IF;
  END LOOP;
  RETURN QUERY SELECT 'OK';
END; $$ LANGUAGE plpgsql;