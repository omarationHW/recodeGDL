-- Stored Procedure: grabar_emision_energia
-- Tipo: CRUD
-- Descripción: Graba la emisión de energía para un mercado y periodo, evitando duplicados.
-- Generado para formulario: EmisionEnergia
-- Fecha: 2025-08-26 23:50:10

CREATE OR REPLACE FUNCTION grabar_emision_energia(p_oficina INT, p_mercado INT, p_axo INT, p_periodo INT, p_usuario INT)
RETURNS TABLE(status TEXT, message TEXT) AS $$
DECLARE
  v_count INT;
  v_id_energia INT;
  v_cve_consumo TEXT;
  v_cantidad NUMERIC;
  v_importe NUMERIC;
  v_row RECORD;
BEGIN
  SELECT COUNT(*) INTO v_count
    FROM ta_11_adeudo_energ a
    JOIN ta_11_locales b ON a.id_energia = b.id_local
    WHERE a.axo = p_axo AND a.periodo = p_periodo AND b.oficina = p_oficina AND b.num_mercado = p_mercado;
  IF v_count > 0 THEN
    RETURN QUERY SELECT 'error', 'La Emisión de Energía Eléctrica ya está grabada, NO puedes volver a grabar';
    RETURN;
  END IF;
  FOR v_row IN
    SELECT d.id_energia, d.cve_consumo, d.cantidad, c.importe
    FROM ta_11_locales a
    JOIN ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN ta_11_kilowhatts c ON c.axo = p_axo AND c.periodo = p_periodo
    JOIN ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND a.vigencia = 'A'
      AND d.vigencia = 'E'
  LOOP
    INSERT INTO ta_11_adeudo_energ (id_adeudo_energia, id_energia, axo, periodo, cve_consumo, cantidad, importe, fecha_alta, id_usuario)
    VALUES (DEFAULT, v_row.id_energia, p_axo, p_periodo, v_row.cve_consumo, v_row.cantidad, v_row.cantidad * v_row.importe, NOW(), p_usuario);
  END LOOP;
  RETURN QUERY SELECT 'ok', 'La Emisión de Energía Eléctrica se grabó correctamente';
END;
$$ LANGUAGE plpgsql;