-- =============================================
-- DEPLOY FINAL: 4 SPs Faltantes Estacionamiento Público
-- Fecha: 2025-11-23
-- Objetivo: Completar 100% el módulo estacionamiento_publico
-- SPs incluidos:
--   1. sp_sfrm_baja_pub
--   2. spget_lic_detalles
--   3. spget_lic_grales
--   4. spubreports
-- =============================================

-- Conectar a la base de datos correcta
\c gdl

-- =============================================
-- SP 1/4: sp_sfrm_baja_pub
-- Descripción: Procesa la baja de estacionamiento público
-- Usado por: BajasPublicos.vue
-- =============================================

DROP FUNCTION IF EXISTS estacionamiento_publico.sp_sfrm_baja_pub(VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION estacionamiento_publico.sp_sfrm_baja_pub(
    p_numlic VARCHAR(50),
    p_motivo TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR(255),
    folio_baja INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_estado VARCHAR(1);
    v_folio_baja INTEGER;
BEGIN
    -- Validar parámetros
    IF p_numlic IS NULL OR TRIM(p_numlic) = '' THEN
        RETURN QUERY SELECT FALSE, 'Debe proporcionar un número de licencia'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT FALSE, 'Debe proporcionar un motivo de baja'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    -- Buscar la licencia
    SELECT id, movto_cve
    INTO v_id, v_estado
    FROM estacionamiento_publico.pubmain
    WHERE numlicencia = p_numlic::INTEGER
    LIMIT 1;

    -- Verificar si existe
    IF v_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar estado
    IF v_estado = 'C' THEN
        RETURN QUERY SELECT FALSE, 'La licencia ya está dada de baja'::VARCHAR(255), NULL::INTEGER;
        RETURN;
    END IF;

    -- Generar folio de baja
    SELECT COALESCE(MAX(folio_baja), 0) + 1
    INTO v_folio_baja
    FROM estacionamiento_publico.pubmain
    WHERE folio_baja IS NOT NULL;

    -- Actualizar registro
    UPDATE estacionamiento_publico.pubmain
    SET
        movto_cve = 'C',
        fecha_baja = CURRENT_DATE,
        folio_baja = v_folio_baja,
        observaciones = COALESCE(observaciones || ' | ', '') ||
                       'BAJA: ' || p_motivo || ' (Fecha: ' || CURRENT_DATE::TEXT || ')'
    WHERE id = v_id;

    RETURN QUERY SELECT TRUE, 'Baja registrada correctamente. Folio: ' || v_folio_baja, v_folio_baja;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al procesar la baja: ' || SQLERRM, NULL::INTEGER;
END;
$$;

-- =============================================
-- SP 2/4: spget_lic_detalles
-- Descripción: Obtiene detalles de licencia
-- Usado por: ConsultaPublicos.vue, EdoCtaPublicos.vue
-- =============================================

DROP FUNCTION IF EXISTS estacionamiento_publico.spget_lic_detalles(INTEGER);

CREATE OR REPLACE FUNCTION estacionamiento_publico.spget_lic_detalles(
    p_numlicencia INTEGER
)
RETURNS TABLE(
    id INTEGER,
    numlicencia INTEGER,
    nombre VARCHAR(100),
    rfc VARCHAR(13),
    ubicacion VARCHAR(255),
    colonia VARCHAR(100),
    zona INTEGER,
    subzona INTEGER,
    id_giro INTEGER,
    desc_giro VARCHAR(200),
    fecha_alta DATE,
    vigente VARCHAR(1),
    tipo_pago VARCHAR(20),
    movto_cve VARCHAR(1),
    saldo_total NUMERIC(10,2),
    ultimo_pago DATE,
    observaciones TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.numlicencia,
        p.nombre,
        p.rfc,
        p.direccion AS ubicacion,
        p.colonia,
        p.zona,
        p.subzona,
        p.id_giro,
        g.nombre_giro AS desc_giro,
        p.fecha_alta,
        p.movto_cve AS vigente,
        p.tipo_pago,
        p.movto_cve,
        COALESCE(
            (SELECT SUM(monto)
             FROM estacionamiento_publico.adeudos
             WHERE id_licencia = p.id
             AND pagado = FALSE), 0
        ) AS saldo_total,
        (SELECT MAX(fecha_pago)
         FROM estacionamiento_publico.pagos
         WHERE id_licencia = p.id) AS ultimo_pago,
        p.observaciones
    FROM estacionamiento_publico.pubmain p
    LEFT JOIN estacionamiento_publico.cat_giros g ON p.id_giro = g.id
    WHERE p.numlicencia = p_numlicencia
    LIMIT 1;
END;
$$;

-- =============================================
-- SP 3/4: spget_lic_grales
-- Descripción: Obtiene datos generales de licencia
-- Usado por: InfoPublicos.vue, ReportesPublicos.vue
-- =============================================

DROP FUNCTION IF EXISTS estacionamiento_publico.spget_lic_grales(INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION estacionamiento_publico.spget_lic_grales(
    p_numlicencia INTEGER,
    p_cero INTEGER DEFAULT 0,
    p_reca INTEGER DEFAULT 4
)
RETURNS TABLE(
    clave INTEGER,
    msg VARCHAR(100),
    id INTEGER,
    bloq INTEGER,
    vigente VARCHAR(1),
    id_giro INTEGER,
    desc_giro VARCHAR(96),
    actividad VARCHAR(130),
    propietario VARCHAR(80),
    ubicacion VARCHAR(255),
    numext INTEGER,
    colonia VARCHAR(25),
    zona INTEGER,
    subzona INTEGER,
    rfc VARCHAR(13),
    licencia INTEGER,
    fecha_alta DATE,
    tipo_pago VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_registro RECORD;
BEGIN
    -- Buscar licencia
    SELECT
        p.id,
        p.numlicencia,
        p.nombre AS propietario,
        p.rfc,
        p.direccion AS ubicacion,
        p.num_ext AS numext,
        p.colonia,
        p.zona,
        p.subzona,
        p.id_giro,
        g.nombre_giro AS desc_giro,
        g.actividad,
        p.movto_cve AS vigente,
        CASE WHEN p.bloqueado = TRUE THEN 1 ELSE 0 END AS bloq,
        p.fecha_alta,
        p.tipo_pago
    INTO v_registro
    FROM estacionamiento_publico.pubmain p
    LEFT JOIN estacionamiento_publico.cat_giros g ON p.id_giro = g.id
    WHERE p.numlicencia = p_numlicencia
    LIMIT 1;

    IF v_registro.id IS NULL THEN
        RETURN QUERY SELECT
            1 AS clave,
            'Licencia no encontrada'::VARCHAR(100) AS msg,
            NULL::INTEGER AS id,
            0 AS bloq,
            NULL::VARCHAR(1) AS vigente,
            NULL::INTEGER AS id_giro,
            NULL::VARCHAR(96) AS desc_giro,
            NULL::VARCHAR(130) AS actividad,
            NULL::VARCHAR(80) AS propietario,
            NULL::VARCHAR(255) AS ubicacion,
            NULL::INTEGER AS numext,
            NULL::VARCHAR(25) AS colonia,
            NULL::INTEGER AS zona,
            NULL::INTEGER AS subzona,
            NULL::VARCHAR(13) AS rfc,
            p_numlicencia AS licencia,
            NULL::DATE AS fecha_alta,
            NULL::VARCHAR(20) AS tipo_pago;
    ELSE
        RETURN QUERY SELECT
            0 AS clave,
            'OK'::VARCHAR(100) AS msg,
            v_registro.id,
            v_registro.bloq,
            v_registro.vigente,
            v_registro.id_giro,
            v_registro.desc_giro,
            v_registro.actividad,
            v_registro.propietario,
            v_registro.ubicacion,
            v_registro.numext,
            v_registro.colonia,
            v_registro.zona,
            v_registro.subzona,
            v_registro.rfc,
            v_registro.numlicencia AS licencia,
            v_registro.fecha_alta,
            v_registro.tipo_pago;
    END IF;
END;
$$;

-- =============================================
-- SP 4/4: spubreports
-- Descripción: Genera reportes de estacionamientos públicos
-- Usado por: ReportesPublicos.vue y múltiples componentes
-- =============================================

DROP FUNCTION IF EXISTS estacionamiento_publico.spubreports(VARCHAR, DATE, DATE, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION estacionamiento_publico.spubreports(
    p_tipo_reporte VARCHAR(50),
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_zona INTEGER DEFAULT NULL,
    p_subzona INTEGER DEFAULT NULL
)
RETURNS TABLE(
    tipo_registro VARCHAR(50),
    total_registros BIGINT,
    total_activos BIGINT,
    total_bajas BIGINT,
    total_adeudo NUMERIC,
    total_pagado NUMERIC,
    zona INTEGER,
    subzona INTEGER,
    descripcion TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Reporte general
    IF p_tipo_reporte = 'GENERAL' OR p_tipo_reporte IS NULL THEN
        RETURN QUERY
        SELECT
            'GENERAL'::VARCHAR(50) AS tipo_registro,
            COUNT(*) AS total_registros,
            COUNT(CASE WHEN movto_cve = 'A' THEN 1 END) AS total_activos,
            COUNT(CASE WHEN movto_cve = 'C' THEN 1 END) AS total_bajas,
            COALESCE(SUM(
                (SELECT SUM(monto)
                 FROM estacionamiento_publico.adeudos a
                 WHERE a.id_licencia = p.id
                 AND a.pagado = FALSE)
            ), 0) AS total_adeudo,
            COALESCE(SUM(
                (SELECT SUM(monto)
                 FROM estacionamiento_publico.pagos pg
                 WHERE pg.id_licencia = p.id
                 AND pg.fecha_pago >= COALESCE(p_fecha_inicio, '1900-01-01')
                 AND pg.fecha_pago <= COALESCE(p_fecha_fin, CURRENT_DATE))
            ), 0) AS total_pagado,
            p_zona AS zona,
            p_subzona AS subzona,
            'Reporte General de Estacionamientos Públicos'::TEXT AS descripcion
        FROM estacionamiento_publico.pubmain p
        WHERE (p_zona IS NULL OR p.zona = p_zona)
        AND (p_subzona IS NULL OR p.subzona = p_subzona);

    -- Reporte por zonas
    ELSIF p_tipo_reporte = 'ZONAS' THEN
        RETURN QUERY
        SELECT
            'ZONA'::VARCHAR(50) AS tipo_registro,
            p.zona::BIGINT AS total_registros,
            COUNT(*) AS total_activos,
            COUNT(CASE WHEN movto_cve = 'C' THEN 1 END) AS total_bajas,
            COALESCE(SUM(
                (SELECT SUM(monto)
                 FROM estacionamiento_publico.adeudos a
                 WHERE a.id_licencia = p.id
                 AND a.pagado = FALSE)
            ), 0) AS total_adeudo,
            0::NUMERIC AS total_pagado,
            p.zona,
            0 AS subzona,
            'Zona ' || p.zona::TEXT AS descripcion
        FROM estacionamiento_publico.pubmain p
        WHERE (p_zona IS NULL OR p.zona = p_zona)
        GROUP BY p.zona
        ORDER BY p.zona;

    -- Reporte de adeudos
    ELSIF p_tipo_reporte = 'ADEUDOS' THEN
        RETURN QUERY
        SELECT
            'ADEUDO'::VARCHAR(50) AS tipo_registro,
            COUNT(DISTINCT p.id) AS total_registros,
            COUNT(DISTINCT CASE WHEN p.movto_cve = 'A' THEN p.id END) AS total_activos,
            0::BIGINT AS total_bajas,
            COALESCE(SUM(a.monto), 0) AS total_adeudo,
            0::NUMERIC AS total_pagado,
            p.zona,
            p.subzona,
            'Reporte de Adeudos'::TEXT AS descripcion
        FROM estacionamiento_publico.pubmain p
        INNER JOIN estacionamiento_publico.adeudos a ON p.id = a.id_licencia
        WHERE a.pagado = FALSE
        AND (p_zona IS NULL OR p.zona = p_zona)
        AND (p_subzona IS NULL OR p.subzona = p_subzona)
        GROUP BY p.zona, p.subzona;

    -- Reporte de pagos
    ELSIF p_tipo_reporte = 'PAGOS' THEN
        RETURN QUERY
        SELECT
            'PAGOS'::VARCHAR(50) AS tipo_registro,
            COUNT(DISTINCT pg.id_licencia) AS total_registros,
            COUNT(DISTINCT pg.id) AS total_activos,
            0::BIGINT AS total_bajas,
            0::NUMERIC AS total_adeudo,
            COALESCE(SUM(pg.monto), 0) AS total_pagado,
            p.zona,
            p.subzona,
            'Reporte de Pagos del período'::TEXT AS descripcion
        FROM estacionamiento_publico.pagos pg
        INNER JOIN estacionamiento_publico.pubmain p ON pg.id_licencia = p.id
        WHERE pg.fecha_pago >= COALESCE(p_fecha_inicio, CURRENT_DATE - INTERVAL '30 days')
        AND pg.fecha_pago <= COALESCE(p_fecha_fin, CURRENT_DATE)
        AND (p_zona IS NULL OR p.zona = p_zona)
        AND (p_subzona IS NULL OR p.subzona = p_subzona)
        GROUP BY p.zona, p.subzona;
    END IF;
END;
$$;

-- =============================================
-- PERMISOS Y COMENTARIOS
-- =============================================

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION estacionamiento_publico.sp_sfrm_baja_pub TO refact;
GRANT EXECUTE ON FUNCTION estacionamiento_publico.spget_lic_detalles TO refact;
GRANT EXECUTE ON FUNCTION estacionamiento_publico.spget_lic_grales TO refact;
GRANT EXECUTE ON FUNCTION estacionamiento_publico.spubreports TO refact;

-- Agregar comentarios
COMMENT ON FUNCTION estacionamiento_publico.sp_sfrm_baja_pub IS 'Procesa la baja de un estacionamiento público';
COMMENT ON FUNCTION estacionamiento_publico.spget_lic_detalles IS 'Obtiene detalles completos de una licencia de estacionamiento';
COMMENT ON FUNCTION estacionamiento_publico.spget_lic_grales IS 'Obtiene datos generales de una licencia';
COMMENT ON FUNCTION estacionamiento_publico.spubreports IS 'Genera diversos reportes de estacionamientos públicos';

-- =============================================
-- VERIFICACIÓN
-- =============================================

-- Verificar que los SPs se crearon correctamente
SELECT
    n.nspname AS schema,
    p.proname AS function_name,
    pg_get_function_identity_arguments(p.oid) AS arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'estacionamiento_publico'
AND p.proname IN ('sp_sfrm_baja_pub', 'spget_lic_detalles', 'spget_lic_grales', 'spubreports')
ORDER BY p.proname;

-- Mensaje final
SELECT 'DEPLOY COMPLETADO: 4 SPs de estacionamiento_publico instalados correctamente' AS resultado;