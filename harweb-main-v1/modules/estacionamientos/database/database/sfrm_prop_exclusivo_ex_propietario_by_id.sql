-- Stored Procedure: ex_propietario_by_id
-- Tipo: Catalog
-- Descripción: Obtiene un registro de ex_propietario por id.
-- Generado para formulario: sfrm_prop_exclusivo
-- Fecha: 2025-08-27 16:06:00

CREATE OR REPLACE FUNCTION ex_propietario_by_id(p_id integer)
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
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;