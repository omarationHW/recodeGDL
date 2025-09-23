-- Stored Procedure: sp_insert_pagos_especial
-- Tipo: CRUD
-- Descripción: Inserta pagos especiales y elimina los adeudos correspondientes.
-- Generado para formulario: CargaPagEspecial
-- Fecha: 2025-08-26 19:53:42

CREATE OR REPLACE FUNCTION sp_insert_pagos_especial(
  p_pagos JSONB,
  p_usuario_id INTEGER
) RETURNS JSONB AS $$
DECLARE
  pago JSONB;
  idx INTEGER := 0;
  total_insertados INTEGER := 0;
  total_borrados INTEGER := 0;
  v_id_local INTEGER;
  v_axo SMALLINT;
  v_periodo SMALLINT;
  v_fecha_pago DATE;
  v_oficina_pago SMALLINT;
  v_caja_pago VARCHAR;
  v_operacion_pago INTEGER;
  v_importe_pago NUMERIC;
  v_partida VARCHAR;
BEGIN
  FOR idx IN 0 .. jsonb_array_length(p_pagos) - 1 LOOP
    pago := p_pagos -> idx;
    v_id_local := (pago ->> 'id_local')::INTEGER;
    v_axo := (pago ->> 'axo')::SMALLINT;
    v_periodo := (pago ->> 'periodo')::SMALLINT;
    v_fecha_pago := (pago ->> 'fecha_pago')::DATE;
    v_oficina_pago := (pago ->> 'oficina_pago')::SMALLINT;
    v_caja_pago := (pago ->> 'caja_pago');
    v_operacion_pago := (pago ->> 'operacion_pago')::INTEGER;
    v_importe_pago := (pago ->> 'importe_pago')::NUMERIC;
    v_partida := (pago ->> 'partida');

    -- Insertar pago
    INSERT INTO ta_11_pagos_local (
      id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
    ) VALUES (
      DEFAULT, v_id_local, v_axo, v_periodo, v_fecha_pago, v_oficina_pago, v_caja_pago, v_operacion_pago, v_importe_pago, v_partida, NOW(), p_usuario_id
    );
    total_insertados := total_insertados + 1;

    -- Borrar adeudo
    DELETE FROM ta_11_adeudo_local
    WHERE id_local = v_id_local AND axo = v_axo AND periodo = v_periodo;
    total_borrados := total_borrados + 1;
  END LOOP;
  RETURN jsonb_build_object('insertados', total_insertados, 'borrados', total_borrados);
END;
$$ LANGUAGE plpgsql;