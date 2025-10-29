-- Stored Procedure: sp_autpagoesp_authorize
-- Tipo: CRUD
-- Descripción: Autoriza un pago especial para una cuenta
-- Generado para formulario: PagosEspe
-- Fecha: 2025-08-27 14:06:05

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