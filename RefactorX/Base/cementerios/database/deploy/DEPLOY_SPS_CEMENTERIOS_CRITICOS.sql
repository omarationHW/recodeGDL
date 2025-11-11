-- ============================================================================
-- STORED PROCEDURES CRÍTICOS - MÓDULO CEMENTERIOS
-- ============================================================================
-- Ejecutar INMEDIATAMENTE en PostgreSQL para que funcione el módulo
--
-- USO: psql -U postgres -d nombre_bd -f DEPLOY_SPS_CEMENTERIOS_CRITICOS.sql
-- ============================================================================

\echo '🚀 Instalando SPs Críticos de Cementerios...'

-- ============================================================================
-- 1. SP_CEM_LISTAR_CEMENTERIOS - Lista todos los cementerios
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_listar_cementerios()
RETURNS TABLE (
    cementerio VARCHAR,
    nombre VARCHAR,
    direccion VARCHAR,
    activo BOOLEAN
) AS $$
BEGIN
    -- Si existe tabla cementerios
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'cementerios') THEN
        RETURN QUERY
        SELECT
            c.cementerio::VARCHAR,
            c.nombre::VARCHAR,
            COALESCE(c.direccion, '')::VARCHAR,
            COALESCE(c.activo, true)::BOOLEAN
        FROM cementerios c
        ORDER BY c.nombre;
    ELSE
        -- Datos por defecto si no existe la tabla
        RETURN QUERY
        SELECT 'GUAD'::VARCHAR, 'Cementerio de Guadalajara'::VARCHAR, 'Guadalajara'::VARCHAR, true::BOOLEAN
        UNION ALL
        SELECT 'JARD'::VARCHAR, 'Cementerio Jardín'::VARCHAR, 'Jardín'::VARCHAR, true::BOOLEAN
        UNION ALL
        SELECT 'SAND'::VARCHAR, 'Cementerio San Andrés'::VARCHAR, 'San Andrés'::VARCHAR, true::BOOLEAN;
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_listar_cementerios'

-- ============================================================================
-- 2. SP_CEM_CONSULTAR_FOLIO - Consulta un folio específico
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
    usuario VARCHAR,
    fecha_mov TIMESTAMP
) AS $$
BEGIN
    -- Verificar si existe la tabla
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'datosrcm') THEN
        RETURN QUERY
        SELECT
            'N'::CHAR(1),
            'Tabla datosrcm no existe'::VARCHAR,
            NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR,
            NULL::INTEGER, NULL::VARCHAR, NULL::INTEGER, NULL::VARCHAR,
            NULL::INTEGER, NULL::VARCHAR, NULL::INTEGER, NULL::VARCHAR,
            NULL::DECIMAL, NULL::VARCHAR, NULL::VARCHAR,
            NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR,
            NULL::INTEGER, NULL::TEXT, NULL::VARCHAR, NULL::TIMESTAMP;
        RETURN;
    END IF;

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
        COALESCE(d.usuario, 'SYSTEM')::VARCHAR,
        COALESCE(d.fecha_mov, CURRENT_TIMESTAMP)::TIMESTAMP
    FROM datosrcm d
    LEFT JOIN cementerios c ON d.cementerio = c.cementerio
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
            NULL::INTEGER, NULL::TEXT, NULL::VARCHAR, NULL::TIMESTAMP;
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_consultar_folio'

-- ============================================================================
-- 3. SP_CEM_CONSULTAR_PAGOS_FOLIO - Pagos de un folio
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_consultar_pagos_folio(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    anio INTEGER,
    fecha_mov TIMESTAMP,
    recibo VARCHAR,
    importe DECIMAL,
    descuento DECIMAL,
    bonificacion DECIMAL,
    recargo DECIMAL,
    total DECIMAL,
    usuario VARCHAR,
    nombre_usuario VARCHAR
) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pagosrcm') THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        p.anio::INTEGER,
        p.fecha_mov::TIMESTAMP,
        COALESCE(p.recibo, '')::VARCHAR,
        COALESCE(p.importe, 0)::DECIMAL,
        COALESCE(p.descuento, 0)::DECIMAL,
        COALESCE(p.bonificacion, 0)::DECIMAL,
        COALESCE(p.recargo, 0)::DECIMAL,
        (COALESCE(p.importe, 0) - COALESCE(p.descuento, 0) - COALESCE(p.bonificacion, 0) + COALESCE(p.recargo, 0))::DECIMAL as total,
        COALESCE(p.usuario, 'SYSTEM')::VARCHAR,
        COALESCE(u.nombre, p.usuario, 'SYSTEM')::VARCHAR as nombre_usuario
    FROM pagosrcm p
    LEFT JOIN usuarios u ON p.usuario = u.usuario
    WHERE p.control_rcm = p_control_rcm
    ORDER BY p.anio DESC;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_consultar_pagos_folio'

-- ============================================================================
-- 4. SP_CEM_CONSULTAR_CEMENTERIO - Consulta folios por cementerio
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

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'datosrcm') THEN
        RETURN;
    END IF;

    RETURN QUERY
    WITH total AS (
        SELECT COUNT(*)::BIGINT as cnt
        FROM datosrcm d
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
    FROM datosrcm d, total t
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
-- 5. SP_CEM_REPORTE_TITULOS - Reporte de títulos
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_reporte_titulos(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_cementerio VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    titulo VARCHAR,
    fecha DATE,
    control_rcm VARCHAR,
    nombre VARCHAR,
    cementerio VARCHAR,
    clase INTEGER,
    seccion INTEGER,
    linea INTEGER,
    fosa INTEGER,
    importe DECIMAL,
    recaudacion VARCHAR
) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'titulos') THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        t.titulo::VARCHAR,
        t.fecha::DATE,
        t.control_rcm::VARCHAR,
        t.nombre::VARCHAR,
        t.cementerio::VARCHAR,
        t.clase::INTEGER,
        t.seccion::INTEGER,
        t.linea::INTEGER,
        t.fosa::INTEGER,
        COALESCE(t.importe, 0)::DECIMAL,
        COALESCE(t.recaudacion, '')::VARCHAR
    FROM titulos t
    WHERE t.fecha BETWEEN p_fecha_desde AND p_fecha_hasta
      AND (p_cementerio IS NULL OR t.cementerio = p_cementerio)
    ORDER BY t.fecha DESC, t.titulo;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_reporte_titulos'

-- ============================================================================
-- 6. SP_CEM_REPORTE_BONIFICACIONES - Reporte de bonificaciones
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_reporte_bonificaciones(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_cementerio VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_bonificacion INTEGER,
    fecha_aplicacion DATE,
    control_rcm VARCHAR,
    nombre VARCHAR,
    cementerio VARCHAR,
    porcentaje DECIMAL,
    importe_bonificado DECIMAL,
    usuario VARCHAR,
    nombre_usuario VARCHAR,
    motivo TEXT
) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bonificaciones') THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        b.id_bonificacion::INTEGER,
        b.fecha_aplicacion::DATE,
        b.control_rcm::VARCHAR,
        d.nombre::VARCHAR,
        d.cementerio::VARCHAR,
        COALESCE(b.porcentaje, 0)::DECIMAL,
        COALESCE(b.importe_bonificado, 0)::DECIMAL,
        b.usuario::VARCHAR,
        COALESCE(u.nombre, b.usuario)::VARCHAR as nombre_usuario,
        COALESCE(b.motivo, '')::TEXT
    FROM bonificaciones b
    LEFT JOIN datosrcm d ON b.control_rcm::INTEGER = d.control_rcm
    LEFT JOIN usuarios u ON b.usuario = u.usuario
    WHERE b.fecha_aplicacion BETWEEN p_fecha_inicio AND p_fecha_fin
      AND (p_cementerio IS NULL OR d.cementerio = p_cementerio)
    ORDER BY b.fecha_aplicacion DESC;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_reporte_bonificaciones'

-- ============================================================================
-- 7. SP_CEM_REPORTE_CUENTAS_COBRAR - Cuentas por cobrar
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_reporte_cuentas_cobrar(
    p_cementerio VARCHAR DEFAULT NULL,
    p_anio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    control_rcm VARCHAR,
    cementerio VARCHAR,
    nombre VARCHAR,
    domicilio VARCHAR,
    axo_pagado INTEGER,
    anios_adeudo INTEGER
) AS $$
DECLARE
    v_anio_ref INTEGER;
BEGIN
    v_anio_ref := COALESCE(p_anio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'datosrcm') THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        d.control_rcm::VARCHAR,
        d.cementerio::VARCHAR,
        d.nombre::VARCHAR,
        COALESCE(d.domicilio, '')::VARCHAR,
        COALESCE(d.axo_pagado, v_anio_ref)::INTEGER,
        (v_anio_ref - COALESCE(d.axo_pagado, v_anio_ref))::INTEGER as anios_adeudo
    FROM datosrcm d
    WHERE COALESCE(d.axo_pagado, v_anio_ref) < v_anio_ref
      AND (p_cementerio IS NULL OR d.cementerio = p_cementerio)
    ORDER BY anios_adeudo DESC, d.cementerio, d.control_rcm;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_reporte_cuentas_cobrar'

-- ============================================================================
-- 8. SP_CEM_LISTAR_MOVIMIENTOS - Lista movimientos
-- ============================================================================
CREATE OR REPLACE FUNCTION sp_cem_listar_movimientos(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_cementerio VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    fecha_mov TIMESTAMP,
    control_rcm VARCHAR,
    cementerio VARCHAR,
    nombre VARCHAR,
    usuario VARCHAR,
    nombre_usuario VARCHAR,
    observaciones TEXT
) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimientos') THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        m.fecha_mov::TIMESTAMP,
        m.control_rcm::VARCHAR,
        d.cementerio::VARCHAR,
        d.nombre::VARCHAR,
        m.usuario::VARCHAR,
        COALESCE(u.nombre, m.usuario)::VARCHAR as nombre_usuario,
        COALESCE(m.observaciones, '')::TEXT
    FROM movimientos m
    LEFT JOIN datosrcm d ON m.control_rcm::INTEGER = d.control_rcm
    LEFT JOIN usuarios u ON m.usuario = u.usuario
    WHERE m.fecha_mov::DATE BETWEEN p_fecha_inicio AND p_fecha_fin
      AND (p_cementerio IS NULL OR d.cementerio = p_cementerio)
    ORDER BY m.fecha_mov DESC;
END;
$$ LANGUAGE plpgsql;

\echo '✓ sp_cem_listar_movimientos'

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
\echo ''
\echo '=========================================='
\echo 'VERIFICACIÓN DE SPS INSTALADOS'
\echo '=========================================='

SELECT
    routine_name as sp_instalado
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND routine_type = 'FUNCTION'
    AND routine_name LIKE 'sp_cem_%'
ORDER BY routine_name;

\echo ''
\echo '=========================================='
\echo '✅ INSTALACIÓN COMPLETADA'
\echo '=========================================='
\echo 'SPs críticos instalados:'
\echo '  1. sp_cem_listar_cementerios'
\echo '  2. sp_cem_consultar_folio'
\echo '  3. sp_cem_consultar_pagos_folio'
\echo '  4. sp_cem_consultar_cementerio'
\echo '  5. sp_cem_reporte_titulos'
\echo '  6. sp_cem_reporte_bonificaciones'
\echo '  7. sp_cem_reporte_cuentas_cobrar'
\echo '  8. sp_cem_listar_movimientos'
\echo ''
\echo 'Ahora prueba el módulo en el navegador'
\echo '=========================================='
