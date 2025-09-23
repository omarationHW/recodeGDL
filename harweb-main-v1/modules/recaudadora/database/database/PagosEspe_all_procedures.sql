-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: PagosEspe
-- Generado: 2025-08-27 14:06:05
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_autpagoesp_list
-- Tipo: Report
-- Descripción: Lista los pagos especiales autorizados para una cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autpagoesp_list(p_cvecuenta integer)
RETURNS TABLE(
    cveaut integer,
    bimini smallint,
    axoini smallint,
    bimfin smallint,
    axofin smallint,
    fecaut date,
    autorizo varchar,
    cvecuenta integer,
    cvepago integer
) AS $$
BEGIN
    RETURN QUERY SELECT cveaut, bimini, axoini, bimfin, axofin, fecaut, autorizo, cvecuenta, cvepago
    FROM autpagoesp WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_autpagoesp_authorize
-- Tipo: CRUD
-- Descripción: Autoriza un pago especial para una cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autpagoesp_authorize(
    p_cvecuenta integer,
    p_bimini smallint,
    p_axoini smallint,
    p_bimfin smallint,
    p_axofin smallint,
    p_autorizo varchar
) RETURNS integer AS $$
DECLARE
    v_id integer;
    v_cuenta record;
    v_regprop record;
    v_vigente record;
BEGIN
    -- Validación de cuenta activa
    SELECT * INTO v_cuenta FROM convcta WHERE cvecuenta = p_cvecuenta AND vigente = 'V';
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe una cuenta activa';
    END IF;
    -- Validación de exento/cancelada
    SELECT * INTO v_regprop FROM regprop WHERE cvecuenta = p_cvecuenta AND exento = 'S';
    IF FOUND THEN
        RAISE EXCEPTION 'Cuenta exenta. No puede usar esta opción';
    END IF;
    IF v_cuenta.vigente = 'C' THEN
        RAISE EXCEPTION 'Cuenta cancelada. No puede usar esta opción';
    END IF;
    -- Validación de registro vigente
    SELECT * INTO v_vigente FROM autpagoesp WHERE cvecuenta = p_cvecuenta AND cvepago IS NULL;
    IF FOUND THEN
        RAISE EXCEPTION 'Existe un registro para pago especial vigente...';
    END IF;
    -- Insertar autorización
    INSERT INTO autpagoesp (bimini, axoini, bimfin, axofin, fecaut, autorizo, cvecuenta, cvepago)
    VALUES (p_bimini, p_axoini, p_bimfin, p_axofin, CURRENT_DATE, p_autorizo, p_cvecuenta, NULL)
    RETURNING cveaut INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_autpagoesp_cancel
-- Tipo: CRUD
-- Descripción: Cancela un pago especial autorizado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_autpagoesp_cancel(p_cveaut integer, p_autorizo varchar)
RETURNS void AS $$
DECLARE
    v_pago record;
BEGIN
    SELECT * INTO v_pago FROM autpagoesp WHERE cveaut = p_cveaut;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Registro no encontrado';
    END IF;
    IF v_pago.cvepago = 999999 THEN
        RAISE EXCEPTION 'El pago autorizado ya está cancelado...';
    END IF;
    IF v_pago.cvepago IS NOT NULL AND v_pago.cvepago <> 999999 THEN
        RAISE EXCEPTION 'El pago autorizado seleccionado se encuentra pagado, no puedes cancelar...';
    END IF;
    UPDATE autpagoesp SET cvepago = 999999, fecaut = CURRENT_DATE, autorizo = p_autorizo WHERE cveaut = p_cveaut;
END;
$$ LANGUAGE plpgsql;

-- ============================================

