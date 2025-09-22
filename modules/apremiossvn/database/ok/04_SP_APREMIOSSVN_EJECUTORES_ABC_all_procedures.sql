-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO APREMIOSSVN - EJECUTORES ABC (ESTRUCTURA ORIGINAL)
-- Archivo: 04_SP_APREMIOSSVN_EJECUTORES_ABC_all_procedures.sql
-- Basado en: ABCEjec_all_procedures.sql
-- ============================================

-- SP_APREMIOSSVN_EJECUTORES_LIST - Lista ejecutores por recaudadora
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTORES_LIST(
    p_id_rec INTEGER
) RETURNS TABLE(
    cve_eje INTEGER,
    ini_rfc VARCHAR(4),
    fec_rfc DATE,
    hom_rfc VARCHAR(3),
    nombre VARCHAR(60),
    id_rec SMALLINT,
    oficio VARCHAR(14),
    fecinic DATE,
    fecterm DATE,
    vigencia CHAR(1)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.cve_eje,
        e.ini_rfc,
        e.fec_rfc,
        e.hom_rfc,
        e.nombre,
        e.id_rec,
        e.oficio,
        e.fecinic,
        e.fecterm,
        e.vigencia
    FROM public.ta_15_ejecutores e
    WHERE e.id_rec = p_id_rec
    ORDER BY e.cve_eje;
END;
$$;

-- SP_APREMIOSSVN_EJECUTOR_GET - Obtener ejecutor específico
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTOR_GET(
    p_cve_eje INTEGER, 
    p_id_rec INTEGER
) RETURNS TABLE(
    cve_eje INTEGER,
    ini_rfc VARCHAR(4),
    fec_rfc DATE,
    hom_rfc VARCHAR(3),
    nombre VARCHAR(60),
    id_rec SMALLINT,
    oficio VARCHAR(14),
    fecinic DATE,
    fecterm DATE,
    vigencia CHAR(1)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.cve_eje,
        e.ini_rfc,
        e.fec_rfc,
        e.hom_rfc,
        e.nombre,
        e.id_rec,
        e.oficio,
        e.fecinic,
        e.fecterm,
        e.vigencia
    FROM public.ta_15_ejecutores e
    WHERE e.cve_eje = p_cve_eje AND e.id_rec = p_id_rec;
END;
$$;

-- SP_APREMIOSSVN_EJECUTOR_CREATE - Crear nuevo ejecutor
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTOR_CREATE(
    p_cve_eje INTEGER,
    p_ini_rfc VARCHAR(4),
    p_fec_rfc DATE,
    p_hom_rfc VARCHAR(3),
    p_nombre VARCHAR(60),
    p_id_rec SMALLINT,
    p_oficio VARCHAR(14),
    p_fecinic DATE,
    p_fecterm DATE
) RETURNS TABLE(
    result TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    existe INTEGER;
BEGIN
    SELECT COUNT(*) INTO existe 
    FROM public.ta_15_ejecutores 
    WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
    
    IF existe > 0 THEN
        RETURN QUERY SELECT 'Ya existe ejecutor con ese número en la recaudadora'::TEXT;
        RETURN;
    END IF;
    
    INSERT INTO public.ta_15_ejecutores (
        cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, oficio, fecinic, fecterm, vigencia
    ) VALUES (
        p_cve_eje, p_ini_rfc, p_fec_rfc, p_hom_rfc, p_nombre, p_id_rec, p_oficio, p_fecinic, p_fecterm, 'A'
    );
    
    RETURN QUERY SELECT 'OK'::TEXT;
END;
$$;

-- SP_APREMIOSSVN_EJECUTOR_UPDATE - Actualizar ejecutor
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTOR_UPDATE(
    p_cve_eje INTEGER,
    p_id_rec SMALLINT,
    p_ini_rfc VARCHAR(4),
    p_fec_rfc DATE,
    p_hom_rfc VARCHAR(3),
    p_nombre VARCHAR(60),
    p_oficio VARCHAR(14),
    p_fecinic DATE,
    p_fecterm DATE
) RETURNS TABLE(
    result TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.ta_15_ejecutores
    SET 
        ini_rfc = p_ini_rfc,
        fec_rfc = p_fec_rfc,
        hom_rfc = p_hom_rfc,
        nombre = p_nombre,
        oficio = p_oficio,
        fecinic = p_fecinic,
        fecterm = p_fecterm,
        vigencia = 'A'
    WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
    
    IF FOUND THEN
        RETURN QUERY SELECT 'OK'::TEXT;
    ELSE
        RETURN QUERY SELECT 'No existe ejecutor'::TEXT;
    END IF;
END;
$$;

-- SP_APREMIOSSVN_EJECUTOR_TOGGLE_VIGENCIA - Cambiar vigencia de ejecutor
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTOR_TOGGLE_VIGENCIA(
    p_cve_eje INTEGER, 
    p_id_rec SMALLINT
) RETURNS TABLE(
    result TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    v_actual CHAR(1);
BEGIN
    SELECT vigencia INTO v_actual 
    FROM public.ta_15_ejecutores 
    WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
    
    IF v_actual IS NULL THEN
        RETURN QUERY SELECT 'No existe ejecutor'::TEXT;
        RETURN;
    END IF;
    
    IF v_actual = 'A' THEN
        UPDATE public.ta_15_ejecutores 
        SET vigencia = 'B' 
        WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
        RETURN QUERY SELECT 'Baja'::TEXT;
    ELSE
        UPDATE public.ta_15_ejecutores 
        SET vigencia = 'A' 
        WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
        RETURN QUERY SELECT 'Reactivado'::TEXT;
    END IF;
END;
$$;

-- SP_APREMIOSSVN_EJECUTOR_HISTORIA_INSERT - Registrar historial
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTOR_HISTORIA_INSERT(
    p_cve_eje INTEGER,
    p_id_rec SMALLINT,
    p_usuario INTEGER,
    p_accion VARCHAR(20),
    p_fecha TIMESTAMP DEFAULT NOW()
) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO public.ta_15_ejecutores_historia (
        cve_eje, id_rec, usuario, accion, fecha
    ) VALUES (
        p_cve_eje, p_id_rec, p_usuario, p_accion, p_fecha
    );
END;
$$;

-- SP_APREMIOSSVN_EJECUTOR_BUSCAR_CVE - Buscar ejecutor por clave
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTOR_BUSCAR_CVE(
    p_cve VARCHAR(10)
) RETURNS TABLE(
    cve_eje INTEGER,
    nombre VARCHAR(60),
    id_rec SMALLINT,
    vigencia CHAR(1),
    oficio VARCHAR(14)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.cve_eje,
        e.nombre,
        e.id_rec,
        e.vigencia,
        e.oficio
    FROM public.ta_15_ejecutores e
    WHERE CAST(e.cve_eje AS VARCHAR) LIKE '%' || p_cve || '%'
    ORDER BY e.nombre;
END;
$$;

-- SP_APREMIOSSVN_EJECUTOR_BUSCAR_NOMBRE - Buscar ejecutor por nombre
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTOR_BUSCAR_NOMBRE(
    p_nombre VARCHAR(60)
) RETURNS TABLE(
    cve_eje INTEGER,
    nombre VARCHAR(60),
    id_rec SMALLINT,
    vigencia CHAR(1),
    oficio VARCHAR(14)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.cve_eje,
        e.nombre,
        e.id_rec,
        e.vigencia,
        e.oficio
    FROM public.ta_15_ejecutores e
    WHERE e.nombre ILIKE '%' || p_nombre || '%'
    ORDER BY e.nombre;
END;
$$;