-- ============================================
-- DEPLOY: empresasfrm.vue
-- Módulo: padron_licencias
-- Total SPs: 5
-- Fecha: 2025-11-20
-- ============================================

\echo 'Desplegando empresasfrm (5 SPs)...'

CREATE OR REPLACE FUNCTION public.sp_empresas_estadisticas()
RETURNS TABLE(
    total BIGINT,
    vigentes BIGINT,
    canceladas BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::BIGINT,
    COUNT(*) FILTER (WHERE vigente = 'V')::BIGINT,
    COUNT(*) FILTER (WHERE vigente = 'C')::BIGINT
  FROM comun.empresas;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_empresas_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20,
    p_filtro TEXT DEFAULT NULL
)
RETURNS TABLE(
    empresa INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    colonia_ubic VARCHAR,
    zona SMALLINT,
    subzona SMALLINT,
    vigente CHAR,
    total_registros BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
    v_total BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    SELECT COUNT(*) INTO v_total
    FROM comun.empresas e
    WHERE p_filtro IS NULL
       OR UPPER(e.propietario) LIKE '%' || UPPER(p_filtro) || '%'
       OR UPPER(e.rfc) LIKE '%' || UPPER(p_filtro) || '%'
       OR UPPER(e.ubicacion) LIKE '%' || UPPER(p_filtro) || '%';

    RETURN QUERY
    SELECT
        e.empresa, e.propietario, e.rfc, e.ubicacion, e.numext_ubic,
        e.colonia_ubic, e.zona, e.subzona, e.vigente, v_total
    FROM comun.empresas e
    WHERE p_filtro IS NULL
       OR UPPER(e.propietario) LIKE '%' || UPPER(p_filtro) || '%'
       OR UPPER(e.rfc) LIKE '%' || UPPER(p_filtro) || '%'
       OR UPPER(e.ubicacion) LIKE '%' || UPPER(p_filtro) || '%'
    ORDER BY e.empresa DESC
    LIMIT p_page_size OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_empresas_get(p_empresa INTEGER)
RETURNS TABLE(
    empresa INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    domicilio VARCHAR,
    numext_prop INTEGER,
    numint_prop VARCHAR,
    colonia_prop VARCHAR,
    telefono_prop VARCHAR,
    email VARCHAR,
    cvecalle INTEGER,
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    letraext_ubic VARCHAR,
    numint_ubic VARCHAR,
    letraint_ubic VARCHAR,
    colonia_ubic VARCHAR,
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_cajones INTEGER,
    num_empleados INTEGER,
    aforo INTEGER,
    inversion NUMERIC,
    rhorario VARCHAR,
    zona SMALLINT,
    subzona SMALLINT,
    recaud SMALLINT,
    vigente CHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.empresa, e.propietario, e.rfc, e.curp, e.domicilio,
        e.numext_prop, e.numint_prop, e.colonia_prop, e.telefono_prop, e.email,
        e.cvecalle, e.ubicacion, e.numext_ubic, e.letraext_ubic, e.numint_ubic,
        e.letraint_ubic, e.colonia_ubic, e.sup_construida, e.sup_autorizada,
        e.num_cajones, e.num_empleados, e.aforo, e.inversion, e.rhorario,
        e.zona, e.subzona, e.recaud, e.vigente
    FROM comun.empresas e
    WHERE e.empresa = p_empresa;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_empresas_create(
    p_propietario VARCHAR,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_domicilio VARCHAR,
    p_telefono_prop VARCHAR,
    p_email VARCHAR,
    p_ubicacion VARCHAR,
    p_numext_ubic INTEGER,
    p_colonia_ubic VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT, empresa INTEGER) AS $$
DECLARE
    v_empresa INTEGER;
BEGIN
    SELECT COALESCE(MAX(empresa),0)+1 INTO v_empresa FROM comun.empresas;

    INSERT INTO comun.empresas (
        empresa, propietario, rfc, curp, domicilio, telefono_prop, email,
        ubicacion, numext_ubic, colonia_ubic, vigente
    ) VALUES (
        v_empresa, p_propietario, p_rfc, p_curp, p_domicilio, p_telefono_prop,
        p_email, p_ubicacion, p_numext_ubic, p_colonia_ubic, 'V'
    );

    RETURN QUERY SELECT TRUE, 'Empresa creada exitosamente'::TEXT, v_empresa;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_empresas_update(
    p_empresa INTEGER,
    p_propietario VARCHAR,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_domicilio VARCHAR,
    p_telefono_prop VARCHAR,
    p_email VARCHAR,
    p_ubicacion VARCHAR,
    p_numext_ubic INTEGER,
    p_colonia_ubic VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE comun.empresas SET
        propietario = p_propietario,
        rfc = p_rfc,
        curp = p_curp,
        domicilio = p_domicilio,
        telefono_prop = p_telefono_prop,
        email = p_email,
        ubicacion = p_ubicacion,
        numext_ubic = p_numext_ubic,
        colonia_ubic = p_colonia_ubic
    WHERE empresa = p_empresa;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Empresa actualizada exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Empresa no encontrada'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_empresas_delete(p_empresa INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE comun.empresas SET vigente = 'C' WHERE empresa = p_empresa;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Empresa cancelada exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Empresa no encontrada'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'empresasfrm completado'
