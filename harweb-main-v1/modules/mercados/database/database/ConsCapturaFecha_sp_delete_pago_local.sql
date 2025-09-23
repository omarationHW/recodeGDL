-- Stored Procedure: sp_delete_pago_local
-- Tipo: CRUD
-- Descripción: Elimina un pago local y regenera el adeudo si corresponde.
-- Generado para formulario: ConsCapturaFecha
-- Fecha: 2025-08-26 23:13:33

CREATE OR REPLACE FUNCTION sp_delete_pago_local(
    p_id_local INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_usuario INTEGER
) RETURNS TEXT AS $$
DECLARE
    v_count INTEGER;
    v_categoria SMALLINT;
    v_seccion VARCHAR;
    v_clave_cuota SMALLINT;
    v_superficie NUMERIC;
    v_importe_pago NUMERIC;
    v_renta NUMERIC;
BEGIN
    -- Verifica si existe adeudo
    SELECT COUNT(*) INTO v_count FROM ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    IF v_count = 0 THEN
        -- Obtener datos del local y pago
        SELECT categoria, seccion, clave_cuota, superficie INTO v_categoria, v_seccion, v_clave_cuota, v_superficie FROM ta_11_locales WHERE id_local = p_id_local;
        SELECT importe_pago INTO v_importe_pago FROM ta_11_pagos_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
        IF p_axo >= 2003 THEN
            SELECT importe_cuota INTO v_renta FROM ta_11_cuo_locales WHERE axo = p_axo AND categoria = v_categoria AND seccion = v_seccion AND clave_cuota = v_clave_cuota;
            IF v_seccion = 'PS' AND v_clave_cuota = 4 THEN
                v_renta := v_superficie * v_renta;
            ELSIF v_seccion = 'PS' THEN
                v_renta := (v_renta * v_superficie) * 30;
            ELSE
                v_renta := v_superficie * v_renta;
            END IF;
        ELSE
            v_renta := v_importe_pago;
        END IF;
        INSERT INTO ta_11_adeudo_local (id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario)
        VALUES (DEFAULT, p_id_local, p_axo, p_periodo, v_renta, CURRENT_TIMESTAMP, p_usuario);
    END IF;
    -- Borra el pago
    DELETE FROM ta_11_pagos_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;