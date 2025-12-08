-- ============================================
-- DEPLOY CONSOLIDADO: prophologramasfrm
-- Componente 78/95 - BATCH 16
-- Generado: 2025-11-20
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_c_contribholog_list
CREATE OR REPLACE FUNCTION public.sp_c_contribholog_list()
RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.idcontrib, c.nombre, c.domicilio, c.colonia, c.telefono, c.rfc, c.curp, c.email, c.feccap, c.capturista
    FROM c_contribholog c
    ORDER BY c.nombre;
END;
$$ LANGUAGE plpgsql;

-- SP 2/5: sp_c_contribholog_show
CREATE OR REPLACE FUNCTION public.sp_c_contribholog_show(p_idcontrib INTEGER)
RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.idcontrib, c.nombre, c.domicilio, c.colonia, c.telefono, c.rfc, c.curp, c.email, c.feccap, c.capturista
    FROM c_contribholog c
    WHERE c.idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;

-- SP 3/5: sp_c_contribholog_create
CREATE OR REPLACE FUNCTION public.sp_c_contribholog_create(
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_colonia VARCHAR,
    p_telefono VARCHAR,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_email VARCHAR,
    p_capturista VARCHAR
) RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
DECLARE
    v_idcontrib INTEGER;
BEGIN
    INSERT INTO c_contribholog (nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista)
    VALUES (p_nombre, p_domicilio, p_colonia, p_telefono, p_rfc, p_curp, p_email, NOW(), p_capturista)
    RETURNING c_contribholog.idcontrib INTO v_idcontrib;

    RETURN QUERY
    SELECT c.idcontrib, c.nombre, c.domicilio, c.colonia, c.telefono, c.rfc, c.curp, c.email, c.feccap, c.capturista
    FROM c_contribholog c WHERE c.idcontrib = v_idcontrib;
END;
$$ LANGUAGE plpgsql;

-- SP 4/5: sp_c_contribholog_update
CREATE OR REPLACE FUNCTION public.sp_c_contribholog_update(
    p_idcontrib INTEGER,
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_colonia VARCHAR,
    p_telefono VARCHAR,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_email VARCHAR,
    p_capturista VARCHAR
) RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
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
    WHERE c_contribholog.idcontrib = p_idcontrib;

    RETURN QUERY
    SELECT c.idcontrib, c.nombre, c.domicilio, c.colonia, c.telefono, c.rfc, c.curp, c.email, c.feccap, c.capturista
    FROM c_contribholog c WHERE c.idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;

-- SP 5/5: sp_c_contribholog_delete
CREATE OR REPLACE FUNCTION public.sp_c_contribholog_delete(p_idcontrib INTEGER)
RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
DECLARE
    v_row RECORD;
BEGIN
    SELECT * INTO v_row FROM c_contribholog WHERE c_contribholog.idcontrib = p_idcontrib;
    IF FOUND THEN
        DELETE FROM c_contribholog WHERE c_contribholog.idcontrib = p_idcontrib;
        RETURN QUERY SELECT v_row.idcontrib, v_row.nombre, v_row.domicilio, v_row.colonia, v_row.telefono,
                            v_row.rfc, v_row.curp, v_row.email, v_row.feccap, v_row.capturista;
    END IF;
END;
$$ LANGUAGE plpgsql;
