-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - TRAMITE-TRUNK
-- Formulario: abstenmov (EXACTO del archivo original)
-- Archivo: 01_SP_TRAMITETRUNK_ABSTENMOV_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_get_predio_data
-- Tipo: CRUD
-- Descripción: Obtiene los datos del predio, propietario y ubicación para la abstención de movimientos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_predio_data(p_cvecuenta INTEGER)
RETURNS TABLE(
    predio JSONB,
    propietario JSONB,
    ubicacion JSONB,
    regprop JSONB
) AS $$
DECLARE
    v_predio RECORD;
    v_ubicacion RECORD;
    v_regprop RECORD;
    v_contrib RECORD;
BEGIN
    SELECT * INTO v_predio FROM tramitetrunk.catastro WHERE cvecuenta = p_cvecuenta;
    SELECT * INTO v_ubicacion FROM tramitetrunk.ubicacion WHERE cvecuenta = p_cvecuenta;
    SELECT * INTO v_regprop FROM tramitetrunk.regprop WHERE cvecuenta = p_cvecuenta AND vigencia = 'V' AND encabeza = 'S';
    IF v_regprop IS NOT NULL THEN
        SELECT * INTO v_contrib FROM tramitetrunk.contrib WHERE cvecont = v_regprop.cvecont;
    END IF;
    predio := to_jsonb(v_predio);
    propietario := to_jsonb(v_contrib);
    ubicacion := to_jsonb(v_ubicacion);
    regprop := to_jsonb(v_regprop);
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_registrar_abstencion
-- Tipo: CRUD
-- Descripción: Registra la abstención de movimientos para una cuenta catastral.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_registrar_abstencion(
    p_cvecuenta INTEGER,
    p_axoefec INTEGER,
    p_bimefec INTEGER,
    p_observacion TEXT,
    p_usuario TEXT
) RETURNS TEXT AS $$
DECLARE
    v_convcta RECORD;
    v_catastro RECORD;
BEGIN
    SELECT * INTO v_convcta FROM tramitetrunk.convcta WHERE cvecuenta = p_cvecuenta;
    IF v_convcta IS NULL OR v_convcta.claveutm = '' THEN
        RAISE EXCEPTION 'No hay cuenta activa!';
    END IF;
    SELECT * INTO v_catastro FROM tramitetrunk.catastro WHERE cvecuenta = p_cvecuenta;
    IF v_catastro.vigente = 'C' THEN
        RAISE EXCEPTION 'Esta cuenta está cancelada, la abstención no es posible!';
    END IF;
    IF v_catastro.cvemov = 12 THEN
        RAISE EXCEPTION 'Ya existe una abstención activa.';
    END IF;
    UPDATE tramitetrunk.catastro SET
        cvemov = 12,
        axoefec = p_axoefec,
        bimefec = p_bimefec,
        observacion = p_observacion,
        feccap = NOW(),
        capturista = p_usuario
    WHERE cvecuenta = p_cvecuenta;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_eliminar_abstencion
-- Tipo: CRUD
-- Descripción: Elimina la abstención de movimientos para una cuenta catastral.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_eliminar_abstencion(
    p_cvecuenta INTEGER,
    p_axoefec INTEGER,
    p_bimefec INTEGER,
    p_observacion TEXT,
    p_usuario TEXT
) RETURNS TEXT AS $$
DECLARE
    v_convcta RECORD;
    v_catastro RECORD;
BEGIN
    SELECT * INTO v_convcta FROM tramitetrunk.convcta WHERE cvecuenta = p_cvecuenta;
    IF v_convcta IS NULL OR v_convcta.claveutm = '' THEN
        RAISE EXCEPTION 'No hay cuenta activa!';
    END IF;
    SELECT * INTO v_catastro FROM tramitetrunk.catastro WHERE cvecuenta = p_cvecuenta;
    IF v_catastro.vigente = 'C' THEN
        RAISE EXCEPTION 'Esta cuenta está cancelada, la abstención no es posible!';
    END IF;
    IF v_catastro.cvemov != 12 THEN
        RAISE EXCEPTION 'No existe abstención activa para eliminar.';
    END IF;
    UPDATE tramitetrunk.catastro SET
        cvemov = 14,
        observacion = p_observacion,
        feccap = NOW(),
        capturista = p_usuario
    WHERE cvecuenta = p_cvecuenta;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================