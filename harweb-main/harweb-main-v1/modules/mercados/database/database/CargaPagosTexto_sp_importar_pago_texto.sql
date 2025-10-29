-- Stored Procedure: sp_importar_pago_texto
-- Tipo: CRUD
-- Descripción: Importa un pago desde archivo de texto, inserta en ta_11_pagos_local y elimina adeudo si corresponde. Devuelve flags de grabado y adeudo borrado.
-- Generado para formulario: CargaPagosTexto
-- Fecha: 2025-08-26 22:59:53

CREATE OR REPLACE FUNCTION sp_importar_pago_texto(
    p_id_local INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER,
    p_fecha_pago TEXT,
    p_oficina_pago INTEGER,
    p_caja_pago TEXT,
    p_operacion_pago INTEGER,
    p_importe_pago NUMERIC,
    p_folio TEXT,
    p_fecha_actualizacion TEXT,
    p_id_usuario INTEGER,
    p_rec TEXT,
    p_merc TEXT,
    p_id_usuario_sistema INTEGER
) RETURNS TABLE(grabado BOOLEAN, adeudo_borrado BOOLEAN) AS $$
DECLARE
    v_exists INTEGER;
    v_adeudo_exists INTEGER;
BEGIN
    -- Verifica si ya existe el pago
    SELECT COUNT(*) INTO v_exists FROM ta_11_pagos_local
    WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    IF v_exists = 0 THEN
        INSERT INTO ta_11_pagos_local (
            id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
        ) VALUES (
            DEFAULT, p_id_local, p_axo, p_periodo, to_date(p_fecha_pago, 'DD/MM/YYYY'), p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe_pago, p_folio, now(), p_id_usuario_sistema
        );
        grabado := TRUE;
    ELSE
        grabado := FALSE;
    END IF;
    -- Borra adeudo si existe
    SELECT COUNT(*) INTO v_adeudo_exists FROM ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    IF v_adeudo_exists = 1 THEN
        DELETE FROM ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
        adeudo_borrado := TRUE;
    ELSE
        adeudo_borrado := FALSE;
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;