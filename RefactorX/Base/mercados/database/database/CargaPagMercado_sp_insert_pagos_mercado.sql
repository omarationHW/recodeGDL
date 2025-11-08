-- Stored Procedure: sp_insert_pagos_mercado
-- Tipo: CRUD
-- Descripción: Carga pagos de mercado y elimina adeudos correspondientes (transaccional)
-- Generado para formulario: CargaPagMercado
-- Fecha: 2025-08-26 22:58:28

CREATE OR REPLACE FUNCTION sp_insert_pagos_mercado(
    p_fecha_pago date,
    p_oficina integer,
    p_caja varchar,
    p_operacion integer,
    p_usuario integer,
    p_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_pagos json
) RETURNS TABLE(
    status text,
    message text
) AS $$
DECLARE
    pago json;
    v_id_local integer;
    v_axo smallint;
    v_periodo smallint;
    v_importe numeric;
    v_partida varchar;
BEGIN
    FOR pago IN SELECT * FROM json_array_elements(p_pagos)
    LOOP
        v_id_local := (pago->>'id_local')::integer;
        v_axo := (pago->>'axo')::smallint;
        v_periodo := (pago->>'periodo')::smallint;
        v_importe := (pago->>'importe')::numeric;
        v_partida := (pago->>'partida');
        IF v_partida IS NULL OR v_partida = '' OR v_partida = '0' THEN
            CONTINUE;
        END IF;
        INSERT INTO ta_11_pagos_local (
            id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
        ) VALUES (
            DEFAULT, v_id_local, v_axo, v_periodo, p_fecha_pago, p_oficina, p_caja, p_operacion, v_importe, v_partida, NOW(), p_usuario
        );
        DELETE FROM ta_11_adeudo_local WHERE id_local = v_id_local AND axo = v_axo AND periodo = v_periodo;
    END LOOP;
    RETURN QUERY SELECT 'OK', 'Pagos cargados correctamente';
END;
$$ LANGUAGE plpgsql;