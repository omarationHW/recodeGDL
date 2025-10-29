-- Stored Procedure: sp_get_predio_data
-- Tipo: CRUD
-- Descripción: Obtiene los datos del predio, propietario y ubicación para la abstención de movimientos.
-- Generado para formulario: abstenmov
-- Fecha: 2025-08-27 22:46:13

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
    SELECT * INTO v_predio FROM catastro WHERE cvecuenta = p_cvecuenta;
    SELECT * INTO v_ubicacion FROM ubicacion WHERE cvecuenta = p_cvecuenta;
    SELECT * INTO v_regprop FROM regprop WHERE cvecuenta = p_cvecuenta AND vigencia = 'V' AND encabeza = 'S';
    IF v_regprop IS NOT NULL THEN
        SELECT * INTO v_contrib FROM contrib WHERE cvecont = v_regprop.cvecont;
    END IF;
    predio := to_jsonb(v_predio);
    propietario := to_jsonb(v_contrib);
    ubicacion := to_jsonb(v_ubicacion);
    regprop := to_jsonb(v_regprop);
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;