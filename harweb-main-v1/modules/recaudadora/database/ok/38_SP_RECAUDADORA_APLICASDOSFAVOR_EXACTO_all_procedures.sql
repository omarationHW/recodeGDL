-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: APLICASDOSFAVOR (EXACTO del archivo original)
-- Archivo: 38_SP_RECAUDADORA_APLICASDOSFAVOR_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: aplica_saldo_favor
-- Tipo: CRUD
-- Descripción: Aplica el saldo a favor a los adeudos de una cuenta, actualiza pagos y registros relacionados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION aplica_saldo_favor(
    p_id_solic INTEGER,
    p_cvecuenta INTEGER,
    p_bimi INTEGER,
    p_axoi INTEGER,
    p_bimf INTEGER,
    p_axof INTEGER,
    p_importe NUMERIC,
    p_usuario VARCHAR,
    p_fecha TIMESTAMP
) RETURNS JSON AS $$
DECLARE
    v_saldo_favor NUMERIC;
    v_numpago INTEGER;
    v_imp_pago NUMERIC;
    v_result JSON;
BEGIN
    -- Obtener saldo actual
    SELECT saldo_favor, numpago, imp_pago INTO v_saldo_favor, v_numpago, v_imp_pago
    FROM sdosfavor WHERE id_solic = p_id_solic;

    IF v_saldo_favor IS NULL OR v_saldo_favor < p_importe THEN
        RAISE EXCEPTION 'Saldo a favor insuficiente';
    END IF;

    -- Registrar pago en tabla de pagos (ejemplo, ajustar según modelo)
    INSERT INTO pagos (cvecuenta, fecha, importe, capturista, cveconcepto)
    VALUES (p_cvecuenta, p_fecha, p_importe, p_usuario, 19)
    RETURNING cvepago INTO v_numpago;

    -- Actualizar detsaldos (ejemplo, ajustar según lógica de negocio)
    UPDATE detsaldos SET imppag = imppag + p_importe
    WHERE cvecuenta = p_cvecuenta AND ((axosal > p_axoi OR (axosal = p_axoi AND bimsal >= p_bimi))
      AND (axosal < p_axof OR (axosal = p_axof AND bimsal <= p_bimf)));

    -- Actualizar sdosfavor
    UPDATE sdosfavor SET
        saldo_favor = saldo_favor - p_importe,
        numpago = numpago + 1,
        imp_pago = p_importe,
        fecha_pago = p_fecha,
        capturista = p_usuario
    WHERE id_solic = p_id_solic;

    -- Insertar en pagosapl_sdosfavor
    INSERT INTO pagosapl_sdosfavor (id_solic, impuesto, recargos, feccap, capturista, cvecuenta, bimi, axoi, bimf, axof)
    VALUES (p_id_solic, p_importe, 0, p_fecha, p_usuario, p_cvecuenta, p_bimi, p_axoi, p_bimf, p_axof);

    v_result := json_build_object('status', 'ok', 'message', 'Saldo aplicado correctamente');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

