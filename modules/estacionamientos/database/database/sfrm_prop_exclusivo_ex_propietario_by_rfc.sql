-- Stored Procedure: ex_propietario_by_rfc
-- Tipo: Catalog
-- Descripción: Obtiene registros de ex_propietario por RFC.
-- Generado para formulario: sfrm_prop_exclusivo
-- Fecha: 2025-08-27 16:06:00

CREATE OR REPLACE FUNCTION ex_propietario_by_rfc(p_rfc VARCHAR(13))
RETURNS TABLE(
    id integer,
    rfc varchar,
    sociedad char(1),
    propietario varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    celular varchar,
    email varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, rfc, sociedad, propietario, domicilio, colonia, telefono, celular, email
    FROM ex_propietario
    WHERE rfc = p_rfc;
END;
$$ LANGUAGE plpgsql;