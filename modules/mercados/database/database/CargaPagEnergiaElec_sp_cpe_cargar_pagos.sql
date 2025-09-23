-- Stored Procedure: sp_cpe_cargar_pagos
-- Tipo: CRUD
-- Descripción: Carga pagos de energía eléctrica y elimina adeudos correspondientes (transaccional)
-- Generado para formulario: CargaPagEnergiaElec
-- Fecha: 2025-08-26 19:52:08

CREATE OR REPLACE FUNCTION sp_cpe_cargar_pagos(
    p_pagos JSONB,
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER,
    p_id_usuario INTEGER,
    p_glo_id_usuario INTEGER,
    p_commit BOOLEAN DEFAULT TRUE
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    pago JSONB;
    _id_energia INTEGER;
    _axo SMALLINT;
    _periodo SMALLINT;
    _importe NUMERIC;
    _cve_consumo VARCHAR;
    _cantidad FLOAT;
    _folio VARCHAR;
    _partida VARCHAR;
BEGIN
    FOR pago IN SELECT * FROM jsonb_array_elements(p_pagos) LOOP
        _id_energia := (pago->>'id_energia')::INTEGER;
        _axo := (pago->>'axo')::SMALLINT;
        _periodo := (pago->>'periodo')::SMALLINT;
        _importe := (pago->>'importe')::NUMERIC;
        _cve_consumo := pago->>'cve_consumo';
        _cantidad := (pago->>'cantidad')::FLOAT;
        _folio := pago->>'folio';
        _partida := pago->>'partida';
        IF _partida IS NULL OR _partida = '' OR _partida = '0' THEN
            CONTINUE;
        END IF;
        INSERT INTO ta_11_pago_energia (
            id_pago_energia, id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio, fecha_modificacion, id_usuario
        ) VALUES (
            DEFAULT, _id_energia, _axo, _periodo, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, _importe, _cve_consumo, _cantidad, _partida, CURRENT_TIMESTAMP, p_glo_id_usuario
        );
        DELETE FROM ta_11_adeudo_energ WHERE id_energia = _id_energia AND axo = _axo AND periodo = _periodo;
    END LOOP;
    RETURN QUERY SELECT 'OK';
    IF p_commit THEN
        COMMIT;
    END IF;
END;
$$ LANGUAGE plpgsql;