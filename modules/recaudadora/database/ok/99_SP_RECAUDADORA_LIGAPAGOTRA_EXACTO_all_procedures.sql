-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LIGAPAGOTRA (EXACTO del archivo original)
-- Archivo: 99_SP_RECAUDADORA_LIGAPAGOTRA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LIGAPAGOTRA (EXACTO del archivo original)
-- Archivo: 99_SP_RECAUDADORA_LIGAPAGOTRA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LIGAPAGOTRA (EXACTO del archivo original)
-- Archivo: 99_SP_RECAUDADORA_LIGAPAGOTRA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

