-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: prophologramasfrm
-- Generado: 2025-08-27 18:56:37
-- Total SPs: 5
-- ============================================

-- SP 1/5: get_contribholog_list
-- Tipo: Catalog
-- Descripción: Obtiene la lista completa de propietarios de hologramas ordenados por nombre.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_contribholog_list()
RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap timestamp,
    capturista varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog
    ORDER BY nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: get_contribholog_by_id
-- Tipo: Catalog
-- Descripción: Obtiene un propietario de holograma por su idcontrib.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_contribholog_by_id(p_idcontrib integer)
RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap timestamp,
    capturista varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog
    WHERE idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: insert_contribholog
-- Tipo: CRUD
-- Descripción: Inserta un nuevo propietario de holograma y retorna el registro insertado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION insert_contribholog(
    p_nombre varchar,
    p_domicilio varchar,
    p_colonia varchar,
    p_telefono varchar,
    p_rfc varchar,
    p_curp varchar,
    p_email varchar,
    p_capturista varchar
) RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap timestamp,
    capturista varchar
) AS $$
DECLARE
    v_idcontrib integer;
BEGIN
    INSERT INTO c_contribholog (nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista)
    VALUES (p_nombre, p_domicilio, p_colonia, p_telefono, p_rfc, p_curp, p_email, NOW(), p_capturista)
    RETURNING idcontrib INTO v_idcontrib;

    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog WHERE idcontrib = v_idcontrib;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: update_contribholog
-- Tipo: CRUD
-- Descripción: Actualiza un propietario de holograma existente y retorna el registro actualizado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION update_contribholog(
    p_idcontrib integer,
    p_nombre varchar,
    p_domicilio varchar,
    p_colonia varchar,
    p_telefono varchar,
    p_rfc varchar,
    p_curp varchar,
    p_email varchar,
    p_capturista varchar
) RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap timestamp,
    capturista varchar
) AS $$
BEGIN
    UPDATE c_contribholog
    SET nombre = p_nombre,
        domicilio = p_domicilio,
        colonia = p_colonia,
        telefono = p_telefono,
        rfc = p_rfc,
        curp = p_curp,
        email = p_email,
        capturista = p_capturista
    WHERE idcontrib = p_idcontrib;

    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog WHERE idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: delete_contribholog
-- Tipo: CRUD
-- Descripción: Elimina un propietario de holograma por idcontrib y retorna el registro eliminado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION delete_contribholog(p_idcontrib integer)
RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap timestamp,
    capturista varchar
) AS $$
DECLARE
    v_row RECORD;
BEGIN
    SELECT * INTO v_row FROM c_contribholog WHERE idcontrib = p_idcontrib;
    IF FOUND THEN
        DELETE FROM c_contribholog WHERE idcontrib = p_idcontrib;
        RETURN QUERY SELECT v_row.*;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

