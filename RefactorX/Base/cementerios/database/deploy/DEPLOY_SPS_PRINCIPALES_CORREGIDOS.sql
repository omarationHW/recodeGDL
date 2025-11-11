-- ============================================================================
-- STORED PROCEDURES PRINCIPALES - MÓDULO CEMENTERIOS
-- Adaptados para PostgreSQL con nombres de tabla correctos
-- Base: padron_licencias, Schema: comun
-- ============================================================================
-- Tablas principales:
--   comun.ta_13_datosrcm - Folios/Propiedades
--   db_ingresos.tc_13_cementerios - Catálogo de cementerios
--   db_ingresos.ta_13_pagosrcm - Pagos
--   db_ingresos.ta_13_bonifrcm - Bonificaciones
--   comun.ta_12_passwords - Usuarios
-- ============================================================================

\echo '🚀 Instalando SPs Principales de Cementerios...'

-- ============================================================================
-- 1. sp_cem_listar_cementerios - Lista todos los cementerios
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_listar_cementerios()
RETURNS TABLE (
    cementerio VARCHAR,
    nombre VARCHAR,
    direccion VARCHAR,
    activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.cementerio::VARCHAR,
        c.nombre::VARCHAR,
        COALESCE(c.domicilio, '')::VARCHAR as direccion,
        true::BOOLEAN as activo
    FROM db_ingresos.tc_13_cementerios c
    ORDER BY c.nombre;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_listar_cementerios'

-- ============================================================================
-- 2. sp_cem_consultar_folio - Consulta un folio específico
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_consultar_folio(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje VARCHAR,
    control_rcm INTEGER,
    cementerio VARCHAR,
    cementerio_nombre VARCHAR,
    clase INTEGER,
    clase_alfa VARCHAR,
    seccion INTEGER,
    seccion_alfa VARCHAR,
    linea INTEGER,
    linea_alfa VARCHAR,
    fosa INTEGER,
    fosa_alfa VARCHAR,
    metros DECIMAL,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    axo_pagado INTEGER,
    observaciones TEXT,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR,
    fecha_alta DATE,
    vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        'S'::CHAR(1) as resultado,
        'Folio encontrado'::VARCHAR as mensaje,
        d.control_rcm::INTEGER,
        d.cementerio::VARCHAR,
        COALESCE(c.nombre, d.cementerio)::VARCHAR as cementerio_nombre,
        d.clase::INTEGER,
        COALESCE(d.clase_alfa, '')::VARCHAR,
        d.seccion::INTEGER,
        COALESCE(d.seccion_alfa, '')::VARCHAR,
        d.linea::INTEGER,
        COALESCE(d.linea_alfa, '')::VARCHAR,
        d.fosa::INTEGER,
        COALESCE(d.fosa_alfa, '')::VARCHAR,
        COALESCE(d.metros, 0)::DECIMAL,
        d.nombre::VARCHAR,
        COALESCE(d.domicilio, '')::VARCHAR,
        COALESCE(d.exterior, '')::VARCHAR,
        COALESCE(d.interior, '')::VARCHAR,
        COALESCE(d.colonia, '')::VARCHAR,
        COALESCE(d.axo_pagado, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER) as axo_pagado,
        COALESCE(d.observaciones, '')::TEXT,
        d.usuario::INTEGER,
        d.fecha_mov::DATE,
        COALESCE(d.tipo, '')::VARCHAR,
        d.fecha_alta::DATE,
        COALESCE(d.vigencia, '')::VARCHAR
    FROM comun.ta_13_datosrcm d
    LEFT JOIN db_ingresos.tc_13_cementerios c ON d.cementerio = c.cementerio
    WHERE d.control_rcm = p_control_rcm
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            'N'::CHAR(1),
            'Folio no encontrado'::VARCHAR,
            p_control_rcm::INTEGER,
            NULL::VARCHAR, NULL::VARCHAR, NULL::INTEGER, NULL::VARCHAR,
            NULL::INTEGER, NULL::VARCHAR, NULL::INTEGER, NULL::VARCHAR,
            NULL::INTEGER, NULL::VARCHAR, NULL::DECIMAL, NULL::VARCHAR,
            NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::DATE,
            NULL::VARCHAR, NULL::DATE, NULL::VARCHAR;
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_consultar_folio'

-- ============================================================================
-- 3. sp_cem_consultar_pagos_folio - Pagos de un folio
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_consultar_pagos_folio(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    tipo_pago VARCHAR,
    fecha DATE,
    recibo VARCHAR,
    importe DECIMAL,
    descuento DECIMAL,
    bonificacion DECIMAL,
    recargo DECIMAL,
    total DECIMAL,
    usuario INTEGER,
    nombre_usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        'MANTENIMIENTO'::VARCHAR as tipo_pago,
        p.fecha::DATE,
        COALESCE(p.recibo, '')::VARCHAR,
        COALESCE(p.importe, 0)::DECIMAL,
        COALESCE(p.descuento, 0)::DECIMAL,
        COALESCE(p.bonificacion, 0)::DECIMAL,
        COALESCE(p.recargo, 0)::DECIMAL,
        (COALESCE(p.importe, 0) - COALESCE(p.descuento, 0) - COALESCE(p.bonificacion, 0) + COALESCE(p.recargo, 0))::DECIMAL as total,
        p.usuario::INTEGER,
        COALESCE(u.nombre, 'SYSTEM')::VARCHAR as nombre_usuario
    FROM db_ingresos.ta_13_pagosrcm p
    LEFT JOIN comun.ta_12_passwords u ON p.usuario = u.id_usuario
    WHERE p.control_rcm = p_control_rcm
    ORDER BY p.fecha DESC;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_consultar_pagos_folio'

-- ============================================================================
-- 4. sp_cem_consultar_cementerio - Consulta folios por cementerio
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_consultar_cementerio(
    p_cementerio VARCHAR,
    p_clase INTEGER DEFAULT NULL,
    p_seccion INTEGER DEFAULT NULL,
    p_linea INTEGER DEFAULT NULL,
    p_fosa INTEGER DEFAULT NULL,
    p_nombre VARCHAR DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    total_records BIGINT,
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase INTEGER,
    seccion INTEGER,
    linea INTEGER,
    fosa INTEGER,
    nombre VARCHAR,
    axo_pagado INTEGER,
    metros DECIMAL
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_limit;

    RETURN QUERY
    WITH total AS (
        SELECT COUNT(*)::BIGINT as cnt
        FROM comun.ta_13_datosrcm d
        WHERE d.cementerio = p_cementerio
          AND (p_clase IS NULL OR d.clase = p_clase)
          AND (p_seccion IS NULL OR d.seccion = p_seccion)
          AND (p_linea IS NULL OR d.linea = p_linea)
          AND (p_fosa IS NULL OR d.fosa = p_fosa)
          AND (p_nombre IS NULL OR UPPER(d.nombre) LIKE '%' || UPPER(p_nombre) || '%')
    )
    SELECT
        t.cnt,
        d.control_rcm::INTEGER,
        d.cementerio::VARCHAR,
        d.clase::INTEGER,
        d.seccion::INTEGER,
        d.linea::INTEGER,
        d.fosa::INTEGER,
        d.nombre::VARCHAR,
        COALESCE(d.axo_pagado, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER) as axo_pagado,
        COALESCE(d.metros, 0)::DECIMAL
    FROM comun.ta_13_datosrcm d, total t
    WHERE d.cementerio = p_cementerio
      AND (p_clase IS NULL OR d.clase = p_clase)
      AND (p_seccion IS NULL OR d.seccion = p_seccion)
      AND (p_linea IS NULL OR d.linea = p_linea)
      AND (p_fosa IS NULL OR d.fosa = p_fosa)
      AND (p_nombre IS NULL OR UPPER(d.nombre) LIKE '%' || UPPER(p_nombre) || '%')
    ORDER BY d.clase, d.seccion, d.linea, d.fosa
    LIMIT p_limit OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_consultar_cementerio'

-- ============================================================================
-- 5. sp_cem_buscar_folio - Búsqueda de folios (para ABCFolio)
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_buscar_folio(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    nombre VARCHAR,
    domicilio VARCHAR,
    clase INTEGER,
    seccion INTEGER,
    linea INTEGER,
    fosa INTEGER,
    metros DECIMAL,
    axo_pagado INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.control_rcm::INTEGER,
        d.cementerio::VARCHAR,
        d.nombre::VARCHAR,
        COALESCE(d.domicilio, '')::VARCHAR,
        d.clase::INTEGER,
        d.seccion::INTEGER,
        d.linea::INTEGER,
        d.fosa::INTEGER,
        COALESCE(d.metros, 0)::DECIMAL,
        COALESCE(d.axo_pagado, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER) as axo_pagado
    FROM comun.ta_13_datosrcm d
    WHERE d.control_rcm = p_control_rcm;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_buscar_folio'

-- ============================================================================
-- 6. sp_cem_consultar_folios_por_nombre - Búsqueda por nombre
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_consultar_folios_por_nombre(
    p_nombre VARCHAR,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    cementerio_nombre VARCHAR,
    nombre VARCHAR,
    domicilio VARCHAR,
    clase INTEGER,
    seccion INTEGER,
    linea INTEGER,
    fosa INTEGER,
    axo_pagado INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.control_rcm::INTEGER,
        d.cementerio::VARCHAR,
        COALESCE(c.nombre, d.cementerio)::VARCHAR as cementerio_nombre,
        d.nombre::VARCHAR,
        COALESCE(d.domicilio, '')::VARCHAR,
        d.clase::INTEGER,
        d.seccion::INTEGER,
        d.linea::INTEGER,
        d.fosa::INTEGER,
        COALESCE(d.axo_pagado, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER) as axo_pagado
    FROM comun.ta_13_datosrcm d
    LEFT JOIN db_ingresos.tc_13_cementerios c ON d.cementerio = c.cementerio
    WHERE UPPER(d.nombre) LIKE '%' || UPPER(p_nombre) || '%'
    ORDER BY d.nombre
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_consultar_folios_por_nombre'

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
\echo ''
\echo '=========================================='
\echo 'VERIFICACIÓN DE SPs INSTALADOS'
\echo '=========================================='

SELECT
    routine_name as sp_instalado
FROM information_schema.routines
WHERE routine_schema = 'comun'
    AND routine_type = 'FUNCTION'
    AND routine_name LIKE 'sp_cem_%'
ORDER BY routine_name;

\echo ''
\echo '=========================================='
\echo '✅ INSTALACIÓN COMPLETADA'
\echo '=========================================='
\echo 'SPs principales instalados:'
\echo '  1. sp_cem_listar_cementerios'
\echo '  2. sp_cem_consultar_folio'
\echo '  3. sp_cem_consultar_pagos_folio'
\echo '  4. sp_cem_consultar_cementerio'
\echo '  5. sp_cem_buscar_folio'
\echo '  6. sp_cem_consultar_folios_por_nombre'
\echo ''
\echo 'Ahora prueba el módulo en el navegador'
\echo '=========================================='
