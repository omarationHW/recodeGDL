-- Stored Procedure: sp_cargar_pagos_diversos_esp
-- Tipo: CRUD
-- Descripción: Carga los pagos realizados por diversos, graba en pagos_local y elimina el adeudo correspondiente.
-- Generado para formulario: CargaDiversosEsp
-- Fecha: 2025-08-26 22:49:31

CREATE OR REPLACE FUNCTION sp_cargar_pagos_diversos_esp(
    p_pagos_json JSON,
    p_usuario INTEGER,
    p_fecha_pago DATE
) RETURNS JSON AS $$
DECLARE
    pago RECORD;
    pagos_arr JSON[];
    result JSON := '[]'::JSON;
    local_id INTEGER;
    local_row RECORD;
    inserted_count INTEGER := 0;
    error_count INTEGER := 0;
BEGIN
    pagos_arr := ARRAY(SELECT json_array_elements(p_pagos_json));
    FOREACH pago IN ARRAY pagos_arr LOOP
        -- Buscar local
        SELECT * INTO local_row FROM ta_11_locales
        WHERE oficina=5 AND num_mercado=(pago->>'MER')::INTEGER
          AND categoria=(pago->>'CAT')::INTEGER
          AND seccion='SS'
          AND local=(pago->>'LOCAL')::INTEGER
          AND (letra_local = NULLIF(pago->>'LET','') OR (pago->>'LET' = '' AND letra_local IS NULL))
          AND bloque IS NULL;
        IF NOT FOUND THEN
            error_count := error_count + 1;
            CONTINUE;
        END IF;
        -- Insertar pago
        INSERT INTO ta_11_pagos_local (
            id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
        ) VALUES (
            DEFAULT,
            local_row.id_local,
            (pago->>'AÑO')::INTEGER,
            (pago->>'MES')::INTEGER,
            p_fecha_pago,
            5,
            (pago->>'REC'),
            (pago->>'OPER')::INTEGER,
            (pago->>'RENTA')::NUMERIC,
            (pago->>'PARTIDA'),
            NOW(),
            p_usuario
        );
        -- Eliminar adeudo
        DELETE FROM ta_11_adeudo_local
        WHERE id_local=local_row.id_local
          AND axo=(pago->>'AÑO')::INTEGER
          AND periodo=(pago->>'MES')::INTEGER;
        inserted_count := inserted_count + 1;
    END LOOP;
    RETURN json_build_object('inserted', inserted_count, 'errors', error_count);
END;
$$ LANGUAGE plpgsql;