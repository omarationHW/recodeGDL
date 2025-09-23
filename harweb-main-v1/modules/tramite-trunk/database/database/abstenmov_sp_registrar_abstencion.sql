-- Stored Procedure: sp_registrar_abstencion
-- Tipo: CRUD
-- Descripción: Registra la abstención de movimientos para una cuenta catastral.
-- Generado para formulario: abstenmov
-- Fecha: 2025-08-27 22:46:13

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
    SELECT * INTO v_convcta FROM convcta WHERE cvecuenta = p_cvecuenta;
    IF v_convcta IS NULL OR v_convcta.claveutm = '' THEN
        RAISE EXCEPTION 'No hay cuenta activa!';
    END IF;
    SELECT * INTO v_catastro FROM catastro WHERE cvecuenta = p_cvecuenta;
    IF v_catastro.vigente = 'C' THEN
        RAISE EXCEPTION 'Esta cuenta está cancelada, la abstención no es posible!';
    END IF;
    IF v_catastro.cvemov = 12 THEN
        RAISE EXCEPTION 'Ya existe una abstención activa.';
    END IF;
    UPDATE catastro SET
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