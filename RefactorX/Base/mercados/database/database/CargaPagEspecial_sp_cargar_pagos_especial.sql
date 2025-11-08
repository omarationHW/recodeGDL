-- Stored Procedure: sp_cargar_pagos_especial
-- Tipo: CRUD
-- Descripción: Carga pagos especiales para años anteriores sin fecha de ingreso. Inserta pagos y elimina adeudos correspondientes.
-- Generado para formulario: CargaPagEspecial
-- Fecha: 2025-08-26 22:54:46

CREATE OR REPLACE FUNCTION sp_cargar_pagos_especial(
    p_pagos_json JSONB,
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER,
    p_usuario_id INTEGER
) RETURNS TABLE (status TEXT, message TEXT) AS $$
DECLARE
    pago RECORD;
    v_renta NUMERIC;
    v_renta_desc NUMERIC;
    v_id_pago_local INTEGER;
BEGIN
    FOR pago IN SELECT * FROM jsonb_to_recordset(p_pagos_json) AS (
        id_local INTEGER,
        axo SMALLINT,
        periodo SMALLINT,
        importe NUMERIC,
        partida VARCHAR
    ) LOOP
        IF pago.partida IS NULL OR pago.partida = '' OR pago.partida = '0' THEN
            CONTINUE;
        END IF;
        -- Regla de descuento: si axo=2005 y periodo=10, aplicar 10% desc.
        IF pago.axo = 2005 AND pago.periodo = 10 THEN
            v_renta := pago.importe;
            v_renta_desc := trunc((v_renta - (v_renta * 0.10)) * 100) / 100;
        ELSE
            v_renta_desc := pago.importe;
        END IF;
        -- Insertar pago
        INSERT INTO ta_11_pagos_local (
            id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
        ) VALUES (
            DEFAULT, pago.id_local, pago.axo, pago.periodo, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, v_renta_desc, pago.partida, NOW(), p_usuario_id
        ) RETURNING id_pago_local INTO v_id_pago_local;
        -- Eliminar adeudo
        DELETE FROM ta_11_adeudo_local
        WHERE id_local = pago.id_local AND axo = pago.axo AND periodo = pago.periodo;
    END LOOP;
    RETURN QUERY SELECT 'OK', 'Pagos cargados correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 'ERROR', SQLERRM;
END;
$$ LANGUAGE plpgsql;