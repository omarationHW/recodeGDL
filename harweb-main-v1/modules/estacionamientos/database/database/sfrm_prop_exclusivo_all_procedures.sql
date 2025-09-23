-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_prop_exclusivo
-- Generado: 2025-08-27 16:06:00
-- Total SPs: 4
-- ============================================

-- SP 1/4: ex_propietario_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro en ex_propietario si el RFC no existe.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION ex_propietario_create(
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
    v_id integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ex_propietario WHERE rfc = p_rfc;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Este RFC ya está registrado.', NULL;
        RETURN;
    END IF;
    INSERT INTO ex_propietario (sociedad, rfc, propietario, domicilio, colonia, telefono, celular, email, fecha_in)
    VALUES (p_sociedad, p_rfc, p_propietario, p_domicilio, p_colonia, p_telefono, p_celular, p_email, CURRENT_DATE)
    RETURNING id INTO v_id;
    RETURN QUERY SELECT true, 'Fue dado de alta el registro.', v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: ex_propietario_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente de ex_propietario por id.
-- --------------------------------------------

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

-- ============================================

-- SP 3/4: ex_propietario_by_rfc
-- Tipo: Catalog
-- Descripción: Obtiene registros de ex_propietario por RFC.
-- --------------------------------------------

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

-- ============================================

-- SP 4/4: ex_propietario_by_id
-- Tipo: Catalog
-- Descripción: Obtiene un registro de ex_propietario por id.
-- --------------------------------------------

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

-- ============================================

