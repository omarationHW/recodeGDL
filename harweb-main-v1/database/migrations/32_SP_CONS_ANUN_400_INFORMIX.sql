-- =============================================
-- STORED PROCEDURES PARA CONSULTA DE ANUNCIOS AS/400
-- Módulo: LICENCIAS - Consulta Anuncios AS/400
-- Fecha: 2025-01-20
-- Descripción: Gestión específica de anuncios tipo 400 (publicidad urbana especial)
-- =============================================

-- =============================================
-- SP_CONS_ANUN_400_LIST
-- Descripción: Lista anuncios AS/400 con filtros avanzados
-- =============================================
CREATE PROCEDURE SP_CONS_ANUN_400_LIST(
    p_id_anuncio INTEGER DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_area_min DECIMAL(10,2) DEFAULT NULL,
    p_area_max DECIMAL(10,2) DEFAULT NULL,
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_estado VARCHAR(20) DEFAULT NULL,
    p_ubicacion VARCHAR(255) DEFAULT NULL,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 100
)
RETURNING
    id_anuncio INTEGER,
    id_licencia INTEGER,
    fecha_otorgamiento DATE,
    area_anuncio DECIMAL(10,2),
    bloqueado SMALLINT,
    medidas1 VARCHAR(50),
    medidas2 VARCHAR(50),
    ubicacion VARCHAR(255),
    numext_ubic VARCHAR(10),
    letraext_ubic VARCHAR(5),
    numint_ubic VARCHAR(10),
    letraint_ubic VARCHAR(5),
    total_registros INTEGER;

    DEFINE l_sql VARCHAR(2000);
    DEFINE l_where VARCHAR(1000);
    DEFINE l_total INTEGER;

    -- Construir WHERE dinámico
    LET l_where = " WHERE 1=1";

    IF p_id_anuncio IS NOT NULL THEN
        LET l_where = l_where || " AND id_anuncio = " || p_id_anuncio;
    END IF;

    IF p_id_licencia IS NOT NULL THEN
        LET l_where = l_where || " AND id_licencia = " || p_id_licencia;
    END IF;

    IF p_area_min IS NOT NULL THEN
        LET l_where = l_where || " AND area_anuncio >= " || p_area_min;
    END IF;

    IF p_area_max IS NOT NULL THEN
        LET l_where = l_where || " AND area_anuncio <= " || p_area_max;
    END IF;

    IF p_fecha_inicio IS NOT NULL THEN
        LET l_where = l_where || " AND fecha_otorgamiento >= '" || p_fecha_inicio || "'";
    END IF;

    IF p_fecha_fin IS NOT NULL THEN
        LET l_where = l_where || " AND fecha_otorgamiento <= '" || p_fecha_fin || "'";
    END IF;

    IF p_estado IS NOT NULL THEN
        IF p_estado = 'activo' THEN
            LET l_where = l_where || " AND (bloqueado = 0 OR bloqueado IS NULL)";
        ELIF p_estado = 'bloqueado' THEN
            LET l_where = l_where || " AND bloqueado > 0";
        END IF;
    END IF;

    IF p_ubicacion IS NOT NULL THEN
        LET l_where = l_where || " AND UPPER(ubicacion) LIKE '%" || UPPER(p_ubicacion) || "%'";
    END IF;

    -- Obtener total de registros
    LET l_sql = "SELECT COUNT(*) FROM anuncios_400" || l_where;
    PREPARE stmt_count FROM l_sql;
    EXECUTE stmt_count INTO l_total;
    FREE stmt_count;

    -- Consulta principal con paginación
    LET l_sql = "SELECT " ||
        "id_anuncio, id_licencia, fecha_otorgamiento, area_anuncio, " ||
        "bloqueado, medidas1, medidas2, ubicacion, " ||
        "numext_ubic, letraext_ubic, numint_ubic, letraint_ubic, " ||
        l_total || " as total_registros " ||
        "FROM anuncios_400" || l_where ||
        " ORDER BY id_anuncio DESC" ||
        " SKIP " || p_offset || " FIRST " || p_limit;

    PREPARE stmt_list FROM l_sql;
    EXECUTE stmt_list;
    FREE stmt_list;

END PROCEDURE;

-- =============================================
-- SP_CONS_ANUN_400_GET
-- Descripción: Obtiene detalle completo de un anuncio AS/400
-- =============================================
CREATE PROCEDURE SP_CONS_ANUN_400_GET(
    p_id_anuncio INTEGER
)
RETURNING
    id_anuncio INTEGER,
    id_licencia INTEGER,
    fecha_otorgamiento DATE,
    area_anuncio DECIMAL(10,2),
    bloqueado SMALLINT,
    medidas1 VARCHAR(50),
    medidas2 VARCHAR(50),
    ubicacion VARCHAR(255),
    numext_ubic VARCHAR(10),
    letraext_ubic VARCHAR(5),
    numint_ubic VARCHAR(10),
    letraint_ubic VARCHAR(5),
    fecha_registro DATETIME YEAR TO SECOND,
    usuario_registro VARCHAR(50),
    fecha_modificacion DATETIME YEAR TO SECOND,
    usuario_modificacion VARCHAR(50),
    observaciones LVARCHAR(1000),
    tipo_publicidad VARCHAR(100),
    zona_urbana VARCHAR(100),
    estatus_legal VARCHAR(50);

    SELECT
        a.id_anuncio,
        a.id_licencia,
        a.fecha_otorgamiento,
        a.area_anuncio,
        a.bloqueado,
        a.medidas1,
        a.medidas2,
        a.ubicacion,
        a.numext_ubic,
        a.letraext_ubic,
        a.numint_ubic,
        a.letraint_ubic,
        a.fecha_registro,
        a.usuario_registro,
        a.fecha_modificacion,
        a.usuario_modificacion,
        a.observaciones,
        a.tipo_publicidad,
        a.zona_urbana,
        a.estatus_legal
    FROM anuncios_400 a
    WHERE a.id_anuncio = p_id_anuncio;

END PROCEDURE;

-- =============================================
-- SP_CONS_ANUN_400_CREATE
-- Descripción: Crea un nuevo anuncio AS/400
-- =============================================
CREATE PROCEDURE SP_CONS_ANUN_400_CREATE(
    p_id_licencia INTEGER,
    p_area_anuncio DECIMAL(10,2),
    p_medidas1 VARCHAR(50),
    p_medidas2 VARCHAR(50),
    p_ubicacion VARCHAR(255),
    p_numext_ubic VARCHAR(10),
    p_letraext_ubic VARCHAR(5),
    p_numint_ubic VARCHAR(10),
    p_letraint_ubic VARCHAR(5),
    p_tipo_publicidad VARCHAR(100),
    p_zona_urbana VARCHAR(100),
    p_observaciones LVARCHAR(1000),
    p_usuario VARCHAR(50)
)
RETURNING id_anuncio INTEGER, mensaje VARCHAR(255);

    DEFINE l_id_anuncio INTEGER;
    DEFINE l_existe INTEGER;
    DEFINE l_mensaje VARCHAR(255);

    -- Validar que la licencia existe
    SELECT COUNT(*) INTO l_existe
    FROM licencias l
    WHERE l.id_licencia = p_id_licencia;

    IF l_existe = 0 THEN
        LET l_mensaje = 'Error: La licencia especificada no existe';
        RETURN 0, l_mensaje;
    END IF;

    -- Obtener siguiente ID
    SELECT NVL(MAX(id_anuncio), 0) + 1 INTO l_id_anuncio
    FROM anuncios_400;

    -- Insertar nuevo anuncio
    INSERT INTO anuncios_400 (
        id_anuncio,
        id_licencia,
        fecha_otorgamiento,
        area_anuncio,
        bloqueado,
        medidas1,
        medidas2,
        ubicacion,
        numext_ubic,
        letraext_ubic,
        numint_ubic,
        letraint_ubic,
        fecha_registro,
        usuario_registro,
        tipo_publicidad,
        zona_urbana,
        estatus_legal,
        observaciones
    ) VALUES (
        l_id_anuncio,
        p_id_licencia,
        TODAY,
        p_area_anuncio,
        0,
        p_medidas1,
        p_medidas2,
        p_ubicacion,
        p_numext_ubic,
        p_letraext_ubic,
        p_numint_ubic,
        p_letraint_ubic,
        CURRENT,
        p_usuario,
        p_tipo_publicidad,
        p_zona_urbana,
        'ACTIVO',
        p_observaciones
    );

    LET l_mensaje = 'Anuncio AS/400 creado exitosamente';
    RETURN l_id_anuncio, l_mensaje;

END PROCEDURE;

-- =============================================
-- SP_CONS_ANUN_400_UPDATE
-- Descripción: Actualiza un anuncio AS/400 existente
-- =============================================
CREATE PROCEDURE SP_CONS_ANUN_400_UPDATE(
    p_id_anuncio INTEGER,
    p_area_anuncio DECIMAL(10,2),
    p_medidas1 VARCHAR(50),
    p_medidas2 VARCHAR(50),
    p_ubicacion VARCHAR(255),
    p_numext_ubic VARCHAR(10),
    p_letraext_ubic VARCHAR(5),
    p_numint_ubic VARCHAR(10),
    p_letraint_ubic VARCHAR(5),
    p_tipo_publicidad VARCHAR(100),
    p_zona_urbana VARCHAR(100),
    p_observaciones LVARCHAR(1000),
    p_usuario VARCHAR(50)
)
RETURNING mensaje VARCHAR(255);

    DEFINE l_existe INTEGER;
    DEFINE l_mensaje VARCHAR(255);

    -- Validar que el anuncio existe
    SELECT COUNT(*) INTO l_existe
    FROM anuncios_400
    WHERE id_anuncio = p_id_anuncio;

    IF l_existe = 0 THEN
        LET l_mensaje = 'Error: El anuncio especificado no existe';
        RETURN l_mensaje;
    END IF;

    -- Actualizar anuncio
    UPDATE anuncios_400 SET
        area_anuncio = p_area_anuncio,
        medidas1 = p_medidas1,
        medidas2 = p_medidas2,
        ubicacion = p_ubicacion,
        numext_ubic = p_numext_ubic,
        letraext_ubic = p_letraext_ubic,
        numint_ubic = p_numint_ubic,
        letraint_ubic = p_letraint_ubic,
        tipo_publicidad = p_tipo_publicidad,
        zona_urbana = p_zona_urbana,
        observaciones = p_observaciones,
        fecha_modificacion = CURRENT,
        usuario_modificacion = p_usuario
    WHERE id_anuncio = p_id_anuncio;

    LET l_mensaje = 'Anuncio AS/400 actualizado exitosamente';
    RETURN l_mensaje;

END PROCEDURE;

-- =============================================
-- SP_CONS_ANUN_400_DELETE
-- Descripción: Elimina un anuncio AS/400 (borrado lógico)
-- =============================================
CREATE PROCEDURE SP_CONS_ANUN_400_DELETE(
    p_id_anuncio INTEGER,
    p_usuario VARCHAR(50),
    p_motivo VARCHAR(255)
)
RETURNING mensaje VARCHAR(255);

    DEFINE l_existe INTEGER;
    DEFINE l_mensaje VARCHAR(255);

    -- Validar que el anuncio existe y no está bloqueado
    SELECT COUNT(*) INTO l_existe
    FROM anuncios_400
    WHERE id_anuncio = p_id_anuncio
    AND (bloqueado = 0 OR bloqueado IS NULL);

    IF l_existe = 0 THEN
        LET l_mensaje = 'Error: El anuncio no existe o ya está bloqueado';
        RETURN l_mensaje;
    END IF;

    -- Bloquear anuncio (borrado lógico)
    UPDATE anuncios_400 SET
        bloqueado = 1,
        estatus_legal = 'CANCELADO',
        observaciones = observaciones || ' | CANCELADO: ' || p_motivo,
        fecha_modificacion = CURRENT,
        usuario_modificacion = p_usuario
    WHERE id_anuncio = p_id_anuncio;

    LET l_mensaje = 'Anuncio AS/400 cancelado exitosamente';
    RETURN l_mensaje;

END PROCEDURE;

-- =============================================
-- SP_CONS_ANUN_400_ESTADISTICAS
-- Descripción: Obtiene estadísticas específicas de anuncios AS/400
-- =============================================
CREATE PROCEDURE SP_CONS_ANUN_400_ESTADISTICAS(
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL
)
RETURNING
    total_anuncios INTEGER,
    anuncios_activos INTEGER,
    anuncios_bloqueados INTEGER,
    area_total DECIMAL(15,2),
    area_promedio DECIMAL(10,2),
    anuncios_mes_actual INTEGER,
    crecimiento_mensual DECIMAL(5,2),
    tipo_mas_comun VARCHAR(100),
    zona_mas_activa VARCHAR(100);

    DEFINE l_total_anuncios INTEGER;
    DEFINE l_anuncios_activos INTEGER;
    DEFINE l_anuncios_bloqueados INTEGER;
    DEFINE l_area_total DECIMAL(15,2);
    DEFINE l_area_promedio DECIMAL(10,2);
    DEFINE l_anuncios_mes_actual INTEGER;
    DEFINE l_anuncios_mes_anterior INTEGER;
    DEFINE l_crecimiento_mensual DECIMAL(5,2);
    DEFINE l_tipo_mas_comun VARCHAR(100);
    DEFINE l_zona_mas_activa VARCHAR(100);
    DEFINE l_fecha_inicio, l_fecha_fin DATE;

    -- Establecer fechas por defecto si no se proporcionan
    IF p_fecha_inicio IS NULL THEN
        LET l_fecha_inicio = MDY(1, 1, YEAR(TODAY));
    ELSE
        LET l_fecha_inicio = p_fecha_inicio;
    END IF;

    IF p_fecha_fin IS NULL THEN
        LET l_fecha_fin = TODAY;
    ELSE
        LET l_fecha_fin = p_fecha_fin;
    END IF;

    -- Total de anuncios en el período
    SELECT COUNT(*) INTO l_total_anuncios
    FROM anuncios_400
    WHERE fecha_otorgamiento BETWEEN l_fecha_inicio AND l_fecha_fin;

    -- Anuncios activos
    SELECT COUNT(*) INTO l_anuncios_activos
    FROM anuncios_400
    WHERE fecha_otorgamiento BETWEEN l_fecha_inicio AND l_fecha_fin
    AND (bloqueado = 0 OR bloqueado IS NULL);

    -- Anuncios bloqueados
    SELECT COUNT(*) INTO l_anuncios_bloqueados
    FROM anuncios_400
    WHERE fecha_otorgamiento BETWEEN l_fecha_inicio AND l_fecha_fin
    AND bloqueado > 0;

    -- Área total y promedio
    SELECT
        NVL(SUM(area_anuncio), 0),
        NVL(AVG(area_anuncio), 0)
    INTO l_area_total, l_area_promedio
    FROM anuncios_400
    WHERE fecha_otorgamiento BETWEEN l_fecha_inicio AND l_fecha_fin
    AND (bloqueado = 0 OR bloqueado IS NULL);

    -- Anuncios del mes actual
    SELECT COUNT(*) INTO l_anuncios_mes_actual
    FROM anuncios_400
    WHERE MONTH(fecha_otorgamiento) = MONTH(TODAY)
    AND YEAR(fecha_otorgamiento) = YEAR(TODAY);

    -- Anuncios del mes anterior
    SELECT COUNT(*) INTO l_anuncios_mes_anterior
    FROM anuncios_400
    WHERE MONTH(fecha_otorgamiento) = MONTH(TODAY) - 1
    AND YEAR(fecha_otorgamiento) = YEAR(TODAY);

    -- Cálculo de crecimiento mensual
    IF l_anuncios_mes_anterior > 0 THEN
        LET l_crecimiento_mensual = ((l_anuncios_mes_actual - l_anuncios_mes_anterior) * 100.0) / l_anuncios_mes_anterior;
    ELSE
        LET l_crecimiento_mensual = 0;
    END IF;

    -- Tipo más común
    SELECT FIRST 1 tipo_publicidad INTO l_tipo_mas_comun
    FROM anuncios_400
    WHERE fecha_otorgamiento BETWEEN l_fecha_inicio AND l_fecha_fin
    AND tipo_publicidad IS NOT NULL
    GROUP BY tipo_publicidad
    ORDER BY COUNT(*) DESC;

    -- Zona más activa
    SELECT FIRST 1 zona_urbana INTO l_zona_mas_activa
    FROM anuncios_400
    WHERE fecha_otorgamiento BETWEEN l_fecha_inicio AND l_fecha_fin
    AND zona_urbana IS NOT NULL
    GROUP BY zona_urbana
    ORDER BY COUNT(*) DESC;

    -- Retornar resultados
    RETURN
        l_total_anuncios,
        l_anuncios_activos,
        l_anuncios_bloqueados,
        l_area_total,
        l_area_promedio,
        l_anuncios_mes_actual,
        l_crecimiento_mensual,
        l_tipo_mas_comun,
        l_zona_mas_activa;

END PROCEDURE;

-- =============================================
-- COMENTARIOS ADICIONALES
-- =============================================
-- Estos stored procedures están diseñados para:
-- 1. SP_CONS_ANUN_400_LIST: Búsquedas avanzadas con filtros múltiples y paginación
-- 2. SP_CONS_ANUN_400_GET: Consulta detallada de un anuncio específico
-- 3. SP_CONS_ANUN_400_CREATE: Creación de nuevos anuncios con validaciones
-- 4. SP_CONS_ANUN_400_UPDATE: Actualización de datos de anuncios existentes
-- 5. SP_CONS_ANUN_400_DELETE: Cancelación de anuncios (borrado lógico)
-- 6. SP_CONS_ANUN_400_ESTADISTICAS: Métricas y análisis de anuncios AS/400
--
-- Características especiales para anuncios tipo 400:
-- - Gestión de medidas específicas (medidas1, medidas2)
-- - Control de área y ubicación detallada
-- - Clasificación por tipo de publicidad y zona urbana
-- - Estados específicos (activo, bloqueado, cancelado)
-- - Auditoría completa de cambios
-- =============================================