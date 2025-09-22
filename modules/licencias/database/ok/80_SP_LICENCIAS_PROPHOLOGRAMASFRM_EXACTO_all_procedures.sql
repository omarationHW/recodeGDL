-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PROPHOLOGRAMASFRM (EXACTO del archivo original)
-- Archivo: 80_SP_LICENCIAS_PROPHOLOGRAMASFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PROPHOLOGRAMASFRM (EXACTO del archivo original)
-- Archivo: 80_SP_LICENCIAS_PROPHOLOGRAMASFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PROPHOLOGRAMASFRM (EXACTO del archivo original)
-- Archivo: 80_SP_LICENCIAS_PROPHOLOGRAMASFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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

