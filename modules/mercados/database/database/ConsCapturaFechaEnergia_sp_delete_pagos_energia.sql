-- Stored Procedure: sp_delete_pagos_energia
-- Tipo: CRUD
-- Descripción: Elimina pagos de energía seleccionados y regenera adeudos si corresponde.
-- Generado para formulario: ConsCapturaFechaEnergia
-- Fecha: 2025-08-26 23:14:48

CREATE OR REPLACE FUNCTION sp_delete_pagos_energia(
    p_pagos_ids INTEGER[],
    p_user_id INTEGER,
    p_fecha_pago DATE,
    p_oficina_pago INTEGER,
    p_operacion_pago INTEGER
) RETURNS JSON AS $$
DECLARE
    v_id_pago INTEGER;
    v_id_energia INTEGER;
    v_axo SMALLINT;
    v_periodo SMALLINT;
    v_cve_consumo VARCHAR;
    v_cantidad NUMERIC;
    v_importe_pago NUMERIC;
    v_result JSON := '[]'::JSON;
BEGIN
    FOREACH v_id_pago IN ARRAY p_pagos_ids LOOP
        SELECT id_energia, axo, periodo, cve_consumo, cantidad, importe_pago
        INTO v_id_energia, v_axo, v_periodo, v_cve_consumo, v_cantidad, v_importe_pago
        FROM ta_11_pago_energia WHERE id_pago_energia = v_id_pago;

        -- Verifica si existe adeudo
        IF NOT EXISTS (SELECT 1 FROM ta_11_adeudo_energ WHERE id_energia = v_id_energia AND axo = v_axo AND periodo = v_periodo) THEN
            -- Regenera adeudo
            INSERT INTO ta_11_adeudo_energ (id_adeudo_energia, id_energia, axo, periodo, cve_consumo, cantidad, importe, fecha_alta, id_usuario)
            VALUES (DEFAULT, v_id_energia, v_axo, v_periodo, v_cve_consumo, v_cantidad, v_importe_pago, NOW(), p_user_id);
        END IF;
        -- Borra el pago
        DELETE FROM ta_11_pago_energia WHERE id_pago_energia = v_id_pago;
        v_result = v_result || to_jsonb(v_id_pago);
    END LOOP;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;