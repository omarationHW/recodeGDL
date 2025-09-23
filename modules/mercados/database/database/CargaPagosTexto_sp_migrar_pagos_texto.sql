-- Stored Procedure: sp_migrar_pagos_texto
-- Tipo: CRUD
-- Descripción: Procesa un lote de pagos de texto, inserta en ta_11_pagos_local y borra adeudos correspondientes. Devuelve resumen.
-- Generado para formulario: CargaPagosTexto
-- Fecha: 2025-08-26 19:06:32

-- Entrada: pagos_json (JSONB array de objetos)
-- Salida: grabados, nograbados, borrados, total, importe
CREATE OR REPLACE FUNCTION sp_migrar_pagos_texto(pagos_json JSONB)
RETURNS TABLE(grabados INT, nograbados INT, borrados INT, total INT, importe NUMERIC) AS $$
DECLARE
    pago JSONB;
    i INT := 0;
    v_grabados INT := 0;
    v_nograbados INT := 0;
    v_borrados INT := 0;
    v_total INT := 0;
    v_importe NUMERIC := 0;
    v_id_local INT;
    v_axo INT;
    v_periodo INT;
    v_importe_pago NUMERIC;
    v_adeudo_id INT;
BEGIN
    FOR pago IN SELECT * FROM jsonb_array_elements(pagos_json) LOOP
        i := i + 1;
        v_id_local := (pago->>'id_local')::INT;
        v_axo := (pago->>'axo')::INT;
        v_periodo := (pago->>'periodo')::INT;
        v_importe_pago := (pago->>'importe_pago')::NUMERIC;
        v_total := v_total + 1;
        v_importe := v_importe + v_importe_pago;
        BEGIN
            INSERT INTO ta_11_pagos_local (
                id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
            ) VALUES (
                DEFAULT,
                v_id_local,
                v_axo,
                v_periodo,
                to_date(pago->>'fecha_pago', 'DD/MM/YYYY'),
                (pago->>'oficina_pago')::INT,
                (pago->>'caja_pago'),
                (pago->>'operacion_pago')::INT,
                v_importe_pago,
                (pago->>'folio'),
                now(),
                (pago->>'id_usuario')::INT
            );
            v_grabados := v_grabados + 1;
        EXCEPTION WHEN OTHERS THEN
            v_nograbados := v_nograbados + 1;
        END;
        -- Borrar adeudo si existe
        SELECT id_adeudo_local INTO v_adeudo_id FROM ta_11_adeudo_local WHERE id_local = v_id_local AND axo = v_axo AND periodo = v_periodo LIMIT 1;
        IF FOUND THEN
            BEGIN
                DELETE FROM ta_11_adeudo_local WHERE id_adeudo_local = v_adeudo_id;
                v_borrados := v_borrados + 1;
            EXCEPTION WHEN OTHERS THEN
                -- ignore
            END;
        END IF;
    END LOOP;
    RETURN QUERY SELECT v_grabados, v_nograbados, v_borrados, v_total, v_importe;
END;
$$ LANGUAGE plpgsql;