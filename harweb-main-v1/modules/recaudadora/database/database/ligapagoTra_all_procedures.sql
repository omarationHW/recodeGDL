-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ligapagoTra
-- Generado: 2025-08-27 12:45:03
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_ligar_pago_transmision
-- Tipo: CRUD
-- Descripción: Liga un pago diverso a una transmisión patrimonial, actualiza tablas de control y diferencia si aplica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ligar_pago_transmision(
    p_cvepago INTEGER,
    p_cvecta INTEGER,
    p_usuario VARCHAR,
    p_tipo INTEGER,
    p_fecha DATE,
    p_folio_transmision INTEGER
) RETURNS TABLE(res TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verifica que el pago exista
    SELECT COUNT(*) INTO v_exists FROM pagos WHERE cvepago = p_cvepago;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT 'No existe el pago a ligar';
        RETURN;
    END IF;
    -- Verifica que la transmisión exista
    SELECT COUNT(*) INTO v_exists FROM actostransm WHERE folio = p_folio_transmision;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT 'No existe el folio de transmisión';
        RETURN;
    END IF;
    -- Inserta en tabla de control de liga
    INSERT INTO qligapago (id_control, cvepago, cvecta, usuario, fecha_act, tipo)
    VALUES (DEFAULT, p_cvepago, p_cvecta, p_usuario, NOW(), p_tipo);
    -- Si es diferencia, actualiza diferencias_glosa
    IF p_tipo = 2 THEN
        UPDATE diferencias_glosa
        SET cvepago = p_cvepago, vigencia = 'P', fecha_pago = p_fecha, cvecuenta = p_cvecta
        WHERE foliot = p_folio_transmision;
    END IF;
    -- Actualiza actostransm
    UPDATE actostransm
    SET cvepago = p_cvepago, status = CASE WHEN p_tipo = 2 THEN 'P' ELSE 'V' END
    WHERE folio = p_folio_transmision;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_buscar_pago
-- Tipo: Report
-- Descripción: Busca un pago por fecha, recaudadora, caja y folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_pago(
    p_fecha DATE,
    p_recaud INTEGER,
    p_caja VARCHAR,
    p_folio INTEGER
) RETURNS SETOF pagos AS $$
BEGIN
    RETURN QUERY SELECT * FROM pagos WHERE fecha = p_fecha AND recaud = p_recaud AND caja = p_caja AND folio = p_folio AND cveconcepto = 4;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_buscar_transmision
-- Tipo: Report
-- Descripción: Busca una transmisión patrimonial por folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_transmision(
    p_folio INTEGER
) RETURNS SETOF actostransm AS $$
BEGIN
    RETURN QUERY SELECT * FROM actostransm WHERE folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_buscar_diferencia_transmision
-- Tipo: Report
-- Descripción: Obtiene información de diferencia de transmisión por folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_diferencia_transmision(
    p_folio INTEGER
) RETURNS SETOF diferencias_glosa AS $$
BEGIN
    RETURN QUERY SELECT * FROM diferencias_glosa WHERE foliot = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

