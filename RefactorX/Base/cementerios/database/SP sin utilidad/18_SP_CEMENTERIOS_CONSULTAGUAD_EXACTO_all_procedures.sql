-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONSULTAGUAD (EXACTO del archivo original)
-- Archivo: 18_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: consulta_guad_por_rcm
-- Tipo: Report
-- Descripción: Consulta registros de Guadalajara por clase, sección y línea (RCM)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION consulta_guad_por_rcm(
    p_clase integer,
    p_seccion integer,
    p_linea integer
)
RETURNS TABLE (
    clase text,
    seccion text,
    linea text,
    fosa text,
    ppago text,
    nombre text,
    fcompra timestamp,
    otros text,
    clave smallint,
    medida double precision,
    calle text,
    colonia text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        clase,
        seccion,
        linea,
        fosa,
        ppago,
        nombre,
        fcompra,
        otros,
        clave,
        medida,
        calle,
        colonia
    FROM regprop
    WHERE clase = p_clase::text
      AND seccion = p_seccion::text
      AND linea >= p_linea::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONSULTAGUAD (EXACTO del archivo original)
-- Archivo: 18_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: consulta_guad_por_partida
-- Tipo: Report
-- Descripción: Consulta registros de Guadalajara por partida de pago (ppago LIKE)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION consulta_guad_por_partida(
    p_partida text
)
RETURNS TABLE (
    clase text,
    seccion text,
    linea text,
    fosa text,
    ppago text,
    nombre text,
    fcompra timestamp,
    otros text,
    clave smallint,
    medida double precision,
    calle text,
    colonia text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        clase,
        seccion,
        linea,
        fosa,
        ppago,
        nombre,
        fcompra,
        otros,
        clave,
        medida,
        calle,
        colonia
    FROM regprop
    WHERE ppago ILIKE '%' || p_partida || '%';
END;
$$ LANGUAGE plpgsql;

-- ============================================

