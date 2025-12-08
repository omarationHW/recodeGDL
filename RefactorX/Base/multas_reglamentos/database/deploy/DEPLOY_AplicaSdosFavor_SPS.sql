-- ============================================
-- STORED PROCEDURES PARA AplicaSdosFavor
-- Modulo: multas_reglamentos
-- Fecha: 2025-11-25
-- ============================================

-- SP 1: aplicasdosfavor_sp_busca_solicitud
-- Busca una solicitud de saldos a favor por folio y año
-- --------------------------------------------
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_busca_solicitud(p_params JSONB)
RETURNS TABLE(
    id_solic INTEGER,
    folio INTEGER,
    axofol SMALLINT,
    cvecuenta INTEGER,
    status TEXT,
    saldo_favor NUMERIC,
    importe NUMERIC,
    fecha_termino DATE
) AS $$
DECLARE
    v_folio INTEGER;
    v_axofol SMALLINT;
BEGIN
    v_folio := (p_params->>'folio')::INTEGER;
    v_axofol := COALESCE((p_params->>'axofol')::SMALLINT, EXTRACT(YEAR FROM CURRENT_DATE)::SMALLINT);

    RETURN QUERY
    SELECT
        s.id_solic,
        s.folio,
        s.axofol,
        s.cvecuenta,
        TRIM(COALESCE(s.status, 'P'))::TEXT AS status,
        COALESCE(sf.saldo_favor, 0)::NUMERIC AS saldo_favor,
        COALESCE(sf.imp_inconform, 0)::NUMERIC AS importe,
        sf.fecha_pago AS fecha_termino
    FROM solic_sdosfavor s
    LEFT JOIN sdosfavor sf ON sf.id_solic = s.id_solic
    WHERE s.folio = v_folio
      AND s.axofol = v_axofol
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- SP 2: aplicasdosfavor_sp_get_convcta
-- Obtiene datos de convenio/cuenta
-- --------------------------------------------
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_get_convcta(p_params JSONB)
RETURNS TABLE(
    cvecuenta INTEGER,
    recaud SMALLINT,
    cuenta INTEGER,
    urbrus TEXT
) AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    v_cvecuenta := (p_params->>'cvecuenta')::INTEGER;

    RETURN QUERY
    SELECT
        v_cvecuenta AS cvecuenta,
        1::SMALLINT AS recaud,
        v_cvecuenta AS cuenta,
        'U'::TEXT AS urbrus
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- SP 3: aplicasdosfavor_sp_get_contrib
-- Obtiene datos del contribuyente
-- --------------------------------------------
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_get_contrib(p_params JSONB)
RETURNS TABLE(
    cvecuenta INTEGER,
    ncompleto TEXT,
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    ultcomp INTEGER,
    axoultcomp SMALLINT
) AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    v_cvecuenta := (p_params->>'cvecuenta')::INTEGER;

    RETURN QUERY
    SELECT
        v_cvecuenta AS cvecuenta,
        COALESCE(
            TRIM(COALESCE(r.nombres, '')) || ' ' ||
            TRIM(COALESCE(r.paterno, '')) || ' ' ||
            TRIM(COALESCE(r.materno, '')),
            'SIN NOMBRE'
        )::TEXT AS ncompleto,
        ''::TEXT AS calle,
        TRIM(COALESCE(r.noexterior, ''))::TEXT AS noexterior,
        ''::TEXT AS interior,
        0 AS ultcomp,
        0::SMALLINT AS axoultcomp
    FROM receptcontrib r
    WHERE r.cvecont = v_cvecuenta
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- SP 4: aplicasdosfavor_sp_get_saldos
-- Obtiene saldos a favor registrados para una solicitud
-- --------------------------------------------
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_get_saldos(p_params JSONB)
RETURNS TABLE(
    id_pago_favor INTEGER,
    id_solic INTEGER,
    cvecuenta INTEGER,
    imp_inconform NUMERIC,
    saldo_favor NUMERIC,
    tipo_apl TEXT,
    concepto SMALLINT
) AS $$
DECLARE
    v_id_solic INTEGER;
BEGIN
    v_id_solic := (p_params->>'id_solic')::INTEGER;

    RETURN QUERY
    SELECT
        sf.id_pago_favor,
        sf.id_solic,
        sf.cvecuenta,
        sf.imp_inconform,
        sf.saldo_favor,
        TRIM(COALESCE(sf.tipo_apl, ''))::TEXT AS tipo_apl,
        sf.concepto
    FROM sdosfavor sf
    WHERE sf.id_solic = v_id_solic
    ORDER BY sf.id_pago_favor DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- SP 5: aplicasdosfavor_sp_get_detsaldos
-- Obtiene detalle de adeudos por cuenta
-- --------------------------------------------
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_get_detsaldos(p_params JSONB)
RETURNS TABLE(
    bimsal SMALLINT,
    axosal SMALLINT,
    impade NUMERIC,
    totalrec NUMERIC,
    saldo NUMERIC
) AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    v_cvecuenta := (p_params->>'cvecuenta')::INTEGER;

    RETURN QUERY
    SELECT
        ds.bimsal,
        ds.axosal,
        COALESCE(ds.impade, 0)::NUMERIC,
        COALESCE(ds.recfac, 0)::NUMERIC AS totalrec,
        COALESCE(ds.saldo, 0)::NUMERIC
    FROM conv_detsaldos ds
    WHERE ds.cvecuenta = v_cvecuenta
      AND COALESCE(ds.saldo, 0) > 0
    ORDER BY ds.axosal, ds.bimsal;
END;
$$ LANGUAGE plpgsql;

-- SP 6: aplicasdosfavor_sp_aplica_saldo
-- Registra o actualiza un saldo a favor
-- --------------------------------------------
CREATE OR REPLACE FUNCTION aplicasdosfavor_sp_aplica_saldo(p_params JSONB)
RETURNS JSONB AS $$
DECLARE
    v_id_solic INTEGER;
    v_cvecuenta INTEGER;
    v_importe NUMERIC;
    v_tipo_apl TEXT;
    v_concepto SMALLINT;
    v_usuario TEXT;
    v_id_pago_favor INTEGER;
BEGIN
    v_id_solic := (p_params->>'id_solic')::INTEGER;
    v_cvecuenta := (p_params->>'cvecuenta')::INTEGER;
    v_importe := (p_params->>'importe')::NUMERIC;
    v_tipo_apl := COALESCE(p_params->>'tipo_apl', 'N');
    v_concepto := COALESCE((p_params->>'concepto')::SMALLINT, 32);
    v_usuario := COALESCE(p_params->>'usuario', 'SISTEMA');

    -- Verificar si ya existe un registro
    SELECT id_pago_favor INTO v_id_pago_favor
    FROM sdosfavor
    WHERE id_solic = v_id_solic;

    IF v_id_pago_favor IS NOT NULL THEN
        -- Actualizar registro existente
        UPDATE sdosfavor
        SET imp_inconform = v_importe,
            saldo_favor = v_importe,
            tipo_apl = v_tipo_apl,
            concepto = v_concepto,
            capturista = v_usuario
        WHERE id_pago_favor = v_id_pago_favor;
    ELSE
        -- Insertar nuevo registro
        INSERT INTO sdosfavor (
            id_solic, cvecuenta, imp_inconform, saldo_favor,
            tipo_apl, concepto, capturista, fecha_pago, numpago
        ) VALUES (
            v_id_solic, v_cvecuenta, v_importe, v_importe,
            v_tipo_apl, v_concepto, v_usuario, CURRENT_DATE, 1
        )
        RETURNING id_pago_favor INTO v_id_pago_favor;
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'id_pago_favor', v_id_pago_favor,
        'mensaje', 'Saldo registrado correctamente'
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', false,
        'mensaje', SQLERRM
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
