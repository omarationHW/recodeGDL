-- Stored Procedure: sp_save_pagos_tcultural
-- Tipo: CRUD
-- Descripción: Guarda los pagos del Tianguis Cultural y elimina los adeudos correspondientes. Aplica descuento si corresponde.
-- Generado para formulario: CargaTCultural
-- Fecha: 2025-08-26 23:03:00

CREATE OR REPLACE FUNCTION sp_save_pagos_tcultural(
    p_pagos_json JSON,
    p_user_id INTEGER
) RETURNS JSON AS $$
DECLARE
    pagos RECORD;
    l_renta NUMERIC;
    l_renta_desc NUMERIC;
    inserted_count INTEGER := 0;
    deleted_count INTEGER := 0;
BEGIN
    FOR pagos IN SELECT * FROM json_populate_recordset(NULL::record, p_pagos_json) LOOP
        IF pagos.fecha_pago IS NULL OR pagos.rec IS NULL OR pagos.caja IS NULL OR pagos.operacion IS NULL OR pagos.partida IS NULL THEN
            CONTINUE;
        END IF;
        -- Calcular descuento si aplica
        IF pagos.descuento IS NOT NULL AND pagos.descuento > 0 THEN
            l_renta := pagos.importe;
            l_renta_desc := round(l_renta - (l_renta * pagos.descuento / 100.0), 2);
        ELSE
            l_renta_desc := pagos.importe;
        END IF;
        -- Insertar pago
        INSERT INTO ta_11_pagos_local (
            id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
        ) VALUES (
            DEFAULT, pagos.id_local, pagos.axo, pagos.periodo, pagos.fecha_pago::date, pagos.rec, pagos.caja, pagos.operacion, l_renta_desc, pagos.partida, NOW(), p_user_id
        );
        inserted_count := inserted_count + 1;
        -- Eliminar adeudo
        DELETE FROM ta_11_adeudo_local
        WHERE id_local = pagos.id_local AND axo = pagos.axo AND periodo = pagos.periodo;
        deleted_count := deleted_count + 1;
    END LOOP;
    RETURN json_build_object('inserted', inserted_count, 'deleted', deleted_count);
END;
$$ LANGUAGE plpgsql;