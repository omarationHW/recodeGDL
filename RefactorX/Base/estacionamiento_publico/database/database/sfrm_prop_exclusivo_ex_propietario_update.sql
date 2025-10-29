-- Stored Procedure: ex_propietario_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente de ex_propietario por id.
-- Generado para formulario: sfrm_prop_exclusivo
-- Fecha: 2025-08-27 16:06:00

CREATE OR REPLACE FUNCTION ex_propietario_update(
    p_id integer,
    p_sociedad CHAR(1),
    p_rfc VARCHAR(13),
    p_propietario VARCHAR(255),
    p_domicilio VARCHAR(60),
    p_colonia VARCHAR(50),
    p_telefono VARCHAR(15),
    p_celular VARCHAR(15),
    p_email VARCHAR(60)
) RETURNS TABLE(success boolean, message text, id integer) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ex_propietario WHERE id = p_id;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el registro.', NULL;
        RETURN;
    END IF;
    UPDATE ex_propietario
    SET sociedad = p_sociedad,
        rfc = p_rfc,
        propietario = p_propietario,
        domicilio = p_domicilio,
        colonia = p_colonia,
        telefono = p_telefono,
        celular = p_celular,
        email = p_email
    WHERE id = p_id;
    RETURN QUERY SELECT true, 'Cambio efectuado.', p_id;
END;
$$ LANGUAGE plpgsql;