-- Stored Procedure: sp_cargar_pagos_diversos
-- Tipo: CRUD
-- Descripción: Carga pagos diversos especiales en lote, validando locales y eliminando adeudos correspondientes.
-- Generado para formulario: CargaDiversosEsp
-- Fecha: 2025-08-26 19:48:04

CREATE OR REPLACE FUNCTION sp_cargar_pagos_diversos(
    p_pagos_json JSONB,
    p_fecha_pago DATE,
    p_usuario_id INTEGER
) RETURNS JSONB AS $$
DECLARE
    pago RECORD;
    local RECORD;
    pagos_arr JSONB[];
    idx INTEGER := 0;
    total INTEGER := 0;
    errores TEXT := '';
BEGIN
    pagos_arr := ARRAY(SELECT jsonb_array_elements(p_pagos_json));
    FOREACH pago IN ARRAY pagos_arr LOOP
        IF pago->>'partida' IS NULL OR pago->>'partida' = '0' THEN
            CONTINUE;
        END IF;
        -- Buscar local
        SELECT * INTO local FROM ta_11_locales
        WHERE oficina = (pago->>'oficina')::INTEGER
          AND num_mercado = (pago->>'num_mercado')::INTEGER
          AND categoria = (pago->>'categoria')::INTEGER
          AND seccion = (pago->>'seccion')
          AND local = (pago->>'colonia')::INTEGER
          AND (CASE WHEN (pago->>'letras') IS NULL OR (pago->>'letras') = '' THEN letra_local IS NULL ELSE letra_local = (pago->>'letras') END)
          AND bloque IS NULL
        LIMIT 1;
        IF NOT FOUND THEN
            errores := errores || 'No se encontró local para pago: ' || pago::TEXT || E'\n';
            CONTINUE;
        END IF;
        -- Insertar pago
        INSERT INTO ta_11_pagos_local (
            id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
        ) VALUES (
            DEFAULT,
            local.id_local,
            (pago->>'axo_desde')::INTEGER,
            (pago->>'mes_desde')::INTEGER,
            p_fecha_pago,
            (pago->>'oficina')::INTEGER,
            (pago->>'cajing'),
            (pago->>'opcaja')::INTEGER,
            (pago->>'pagado')::NUMERIC,
            (pago->>'partida'),
            NOW(),
            p_usuario_id
        );
        -- Borrar adeudo
        DELETE FROM ta_11_adeudo_local
        WHERE id_local = local.id_local
          AND axo = (pago->>'axo_desde')::INTEGER
          AND periodo = (pago->>'mes_desde')::INTEGER;
        total := total + 1;
    END LOOP;
    RETURN jsonb_build_object('total', total, 'errores', errores);
END;
$$ LANGUAGE plpgsql;