-- Stored Procedure: sp_validate_hasta_form
-- Tipo: CRUD
-- Descripción: Valida los datos del formulario 'Pagar hasta' (bimestre y año). Devuelve un registro con los campos validados y un mensaje.
-- Generado para formulario: Hastafrm
-- Fecha: 2025-08-27 12:20:58

CREATE OR REPLACE FUNCTION sp_validate_hasta_form(p_bimestre integer, p_anio integer)
RETURNS TABLE(
    is_valid boolean,
    bimestre integer,
    anio integer,
    message text
) AS $$
DECLARE
    current_year integer := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    IF p_bimestre IS NULL OR p_bimestre < 1 OR p_bimestre > 6 THEN
        RETURN QUERY SELECT false, p_bimestre, p_anio, 'Bimestre inválido!';
        RETURN;
    END IF;
    IF p_anio IS NULL OR p_anio < 1970 OR p_anio > current_year THEN
        RETURN QUERY SELECT false, p_bimestre, p_anio, 'Año inválido!';
        RETURN;
    END IF;
    RETURN QUERY SELECT true, p_bimestre, p_anio, 'Datos validados correctamente.';
END;
$$ LANGUAGE plpgsql;