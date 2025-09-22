-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LIGAPAGO (EXACTO del archivo original)
-- Archivo: 100_SP_RECAUDADORA_LIGAPAGO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_ligar_pago
-- Tipo: CRUD
-- Descripción: Liga un pago a un folio de requerimiento predial o transmisión patrimonial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ligar_pago(
    p_cvepago INTEGER,
    p_cvecuenta INTEGER,
    p_usuario TEXT,
    p_tipo INTEGER, -- 2: predial, 22: transmision
    p_folio INTEGER DEFAULT NULL,
    p_fecha DATE DEFAULT NULL
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_exento TEXT;
    v_vigente TEXT;
BEGIN
    SELECT exento, vigente INTO v_exento, v_vigente FROM cuentas WHERE cvecuenta = p_cvecuenta;
    IF v_exento = 'S' THEN
        RETURN QUERY SELECT 'Cuenta exenta. No puede usar esta opción';
        RETURN;
    END IF;
    IF v_vigente = 'C' THEN
        RETURN QUERY SELECT 'Cuenta cancelada. No puede usar esta opción';
        RETURN;
    END IF;
    IF p_tipo = 2 THEN
        -- Liga pago a requerimiento predial
        UPDATE reqpredial SET cvepago = p_cvepago, usuario = p_usuario, fecha_pago = COALESCE(p_fecha, NOW())
        WHERE cvecuenta = p_cvecuenta AND vigencia = 'V' AND cvepago IS NULL;
        RETURN QUERY SELECT 'Pago ligado a requerimiento predial';
    ELSIF p_tipo = 22 THEN
        -- Liga pago a transmisión patrimonial
        UPDATE transmision SET cvepago = p_cvepago, usuario = p_usuario, fecha_pago = COALESCE(p_fecha, NOW())
        WHERE folio = p_folio AND cvecuenta = p_cvecuenta AND cvepago IS NULL;
        RETURN QUERY SELECT 'Pago ligado a transmisión patrimonial';
    ELSE
        RETURN QUERY SELECT 'Tipo de liga no soportado';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LIGAPAGO (EXACTO del archivo original)
-- Archivo: 100_SP_RECAUDADORA_LIGAPAGO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

