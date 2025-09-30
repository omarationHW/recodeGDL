-- =====================================================================================
-- SP_CONSULTA_ANUNCIO_INFORMIX.sql
-- Stored Procedures para el módulo de Consulta de Anuncios Publicitarios
-- Sistema: HARWEB - Módulo LICENCIAS
-- Autor: Sistema Automatizado
-- Fecha: 2024
-- =====================================================================================

-- FUNCIÓN: SP_CONSULTA_ANUNCIO_LIST
-- DESCRIPCIÓN: Lista requerimientos de anuncios publicitarios con filtros y paginación
-- PARÁMETROS:
--   p_limit: Número de registros por página
--   p_offset: Desplazamiento para paginación
--   p_search: Término de búsqueda (CVE REQ, ID Anuncio, Folio, Capturista)
-- =====================================================================================

CREATE PROCEDURE SP_CONSULTA_ANUNCIO_LIST(
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0,
    p_search VARCHAR(255) DEFAULT NULL
)

    DEFINE v_sql_base LVARCHAR(4000);
    DEFINE v_sql_count LVARCHAR(4000);
    DEFINE v_sql_final LVARCHAR(4000);
    DEFINE v_where_clause LVARCHAR(1000);
    DEFINE v_total_records INTEGER;

    -- Construir cláusula WHERE base
    LET v_where_clause = " WHERE 1=1 ";

    -- Agregar filtro de búsqueda si se proporciona
    IF p_search IS NOT NULL AND LENGTH(TRIM(p_search)) > 0 THEN
        LET v_where_clause = v_where_clause ||
            " AND (ra.cvereq LIKE '%" || TRIM(p_search) || "%' OR " ||
            "      ra.id_anuncio LIKE '%" || TRIM(p_search) || "%' OR " ||
            "      ra.folioreq LIKE '%" || TRIM(p_search) || "%' OR " ||
            "      ra.capturista LIKE '%" || TRIM(p_search) || "%') ";
    END IF;

    -- Consulta base para datos
    LET v_sql_base =
        "SELECT " ||
        "    ra.cvereq, " ||
        "    ra.id_anuncio, " ||
        "    ra.folioreq, " ||
        "    ra.axoreq, " ||
        "    ra.recaud, " ||
        "    ra.tipolic, " ||
        "    ra.cveproceso, " ||
        "    ra.vigencia, " ||
        "    ra.derechos, " ||
        "    ra.recargos, " ||
        "    ra.formas, " ||
        "    ra.gastos, " ||
        "    ra.multa, " ||
        "    ra.gastos_req, " ||
        "    ra.total, " ||
        "    ra.fecemi, " ||
        "    ra.fecentejec, " ||
        "    ra.feccit, " ||
        "    ra.fecprac, " ||
        "    ra.capturista, " ||
        "    ra.cveejecut, " ||
        "    ra.nodiligenciado, " ||
        "    ra.obs, " ||
        "    COUNT(*) OVER() as total_records " ||
        "FROM requerimiento_anuncios ra ";

    -- Consulta para contar total de registros
    LET v_sql_count =
        "SELECT COUNT(*) as total " ||
        "FROM requerimiento_anuncios ra " ||
        v_where_clause;

    -- Ejecutar consulta de conteo
    EXECUTE IMMEDIATE v_sql_count INTO v_total_records;

    -- Consulta final con paginación
    LET v_sql_final = v_sql_base || v_where_clause ||
        " ORDER BY ra.fecemi DESC, ra.cvereq DESC " ||
        " SKIP " || p_offset || " FIRST " || p_limit;

    -- Ejecutar consulta final
    EXECUTE IMMEDIATE v_sql_final;

END PROCEDURE;

-- =====================================================================================
-- FUNCIÓN: SP_CONSULTA_ANUNCIO_GET
-- DESCRIPCIÓN: Obtiene detalles específicos de un requerimiento de anuncio
-- PARÁMETROS:
--   p_cvereq: Clave del requerimiento
-- =====================================================================================

CREATE PROCEDURE SP_CONSULTA_ANUNCIO_GET(
    p_cvereq INTEGER
)

    SELECT
        ra.cvereq,
        ra.id_anuncio,
        ra.folioreq,
        ra.axoreq,
        ra.recaud,
        ra.tipolic,
        ra.cveproceso,
        ra.vigencia,
        ra.derechos,
        ra.recargos,
        ra.formas,
        ra.gastos,
        ra.multa,
        ra.gastos_req,
        ra.total,
        ra.fecemi,
        ra.fecentejec,
        ra.feccit,
        ra.fecprac,
        ra.capturista,
        ra.cveejecut,
        ra.nodiligenciado,
        ra.obs,
        -- Información adicional calculada
        CASE ra.vigencia
            WHEN 'V' THEN 'Vigente'
            WHEN 'C' THEN 'Cancelado'
            WHEN 'S' THEN 'Suspendido'
            ELSE 'No Vigente'
        END as vigencia_text,
        CASE ra.cveproceso
            WHEN 'N' THEN 'Nuevo'
            WHEN 'P' THEN 'En Proceso'
            WHEN 'C' THEN 'Completado'
            WHEN 'X' THEN 'Cancelado'
            ELSE 'Sin Proceso'
        END as proceso_text,
        CASE ra.recaud
            WHEN 1 THEN 'GUADALAJARA'
            WHEN 2 THEN 'ZAPOPAN'
            WHEN 3 THEN 'TLAQUEPAQUE'
            WHEN 4 THEN 'TONALÁ'
            ELSE 'DESCONOCIDA'
        END as recaud_text
    FROM requerimiento_anuncios ra
    WHERE ra.cvereq = p_cvereq;

END PROCEDURE;

-- =====================================================================================
-- FUNCIÓN: SP_CONSULTA_ANUNCIO_CREATE
-- DESCRIPCIÓN: Crear nuevo requerimiento de anuncio publicitario
-- PARÁMETROS: Datos del nuevo requerimiento
-- =====================================================================================

CREATE PROCEDURE SP_CONSULTA_ANUNCIO_CREATE(
    p_folioreq VARCHAR(50),
    p_axoreq INTEGER,
    p_recaud INTEGER,
    p_tipolic CHAR(1) DEFAULT 'A',
    p_derechos DECIMAL(10,2) DEFAULT 0.00,
    p_recargos DECIMAL(10,2) DEFAULT 0.00,
    p_formas DECIMAL(10,2) DEFAULT 0.00,
    p_gastos DECIMAL(10,2) DEFAULT 0.00,
    p_multa DECIMAL(10,2) DEFAULT 0.00,
    p_gastos_req DECIMAL(10,2) DEFAULT 0.00,
    p_vigencia CHAR(1) DEFAULT 'V',
    p_cveproceso CHAR(1) DEFAULT 'N',
    p_obs VARCHAR(500) DEFAULT NULL,
    p_capturista VARCHAR(50) DEFAULT 'SISTEMA'
)

    DEFINE v_new_cvereq INTEGER;
    DEFINE v_total_calculado DECIMAL(10,2);
    DEFINE v_id_anuncio VARCHAR(20);

    -- Calcular total
    LET v_total_calculado = p_derechos + p_recargos + p_formas + p_gastos + p_multa + p_gastos_req;

    -- Generar nuevo CVE REQ
    SELECT NVL(MAX(cvereq), 0) + 1 INTO v_new_cvereq
    FROM requerimiento_anuncios;

    -- Generar ID Anuncio
    LET v_id_anuncio = 'ANU' || p_axoreq || '-' || LPAD(v_new_cvereq, 6, '0');

    -- Insertar nuevo requerimiento
    INSERT INTO requerimiento_anuncios (
        cvereq,
        id_anuncio,
        folioreq,
        axoreq,
        recaud,
        tipolic,
        derechos,
        recargos,
        formas,
        gastos,
        multa,
        gastos_req,
        total,
        vigencia,
        cveproceso,
        fecemi,
        capturista,
        obs,
        nodiligenciado
    ) VALUES (
        v_new_cvereq,
        v_id_anuncio,
        p_folioreq,
        p_axoreq,
        p_recaud,
        p_tipolic,
        p_derechos,
        p_recargos,
        p_formas,
        p_gastos,
        p_multa,
        p_gastos_req,
        v_total_calculado,
        p_vigencia,
        p_cveproceso,
        TODAY,
        p_capturista,
        p_obs,
        'N'
    );

    -- Retornar el nuevo registro creado
    SELECT
        cvereq,
        id_anuncio,
        folioreq,
        total,
        'Requerimiento de anuncio creado exitosamente' as mensaje
    FROM requerimiento_anuncios
    WHERE cvereq = v_new_cvereq;

END PROCEDURE;

-- =====================================================================================
-- FUNCIÓN: SP_CONSULTA_ANUNCIO_UPDATE
-- DESCRIPCIÓN: Actualizar requerimiento de anuncio existente
-- PARÁMETROS: Datos a actualizar del requerimiento
-- =====================================================================================

CREATE PROCEDURE SP_CONSULTA_ANUNCIO_UPDATE(
    p_cvereq INTEGER,
    p_derechos DECIMAL(10,2),
    p_recargos DECIMAL(10,2),
    p_formas DECIMAL(10,2),
    p_gastos DECIMAL(10,2),
    p_multa DECIMAL(10,2),
    p_gastos_req DECIMAL(10,2),
    p_total DECIMAL(10,2),
    p_vigencia CHAR(1),
    p_cveproceso CHAR(1),
    p_nodiligenciado CHAR(1) DEFAULT 'N',
    p_fecentejec DATE DEFAULT NULL,
    p_feccit DATE DEFAULT NULL,
    p_fecprac DATE DEFAULT NULL,
    p_obs VARCHAR(500) DEFAULT NULL
)

    DEFINE v_rows_affected INTEGER;

    -- Actualizar el requerimiento
    UPDATE requerimiento_anuncios SET
        derechos = p_derechos,
        recargos = p_recargos,
        formas = p_formas,
        gastos = p_gastos,
        multa = p_multa,
        gastos_req = p_gastos_req,
        total = p_total,
        vigencia = p_vigencia,
        cveproceso = p_cveproceso,
        nodiligenciado = p_nodiligenciado,
        fecentejec = p_fecentejec,
        feccit = p_feccit,
        fecprac = p_fecprac,
        obs = p_obs,
        fecmod = TODAY
    WHERE cvereq = p_cvereq;

    LET v_rows_affected = SQLCA.SQLERRD[3];

    -- Verificar si se actualizó algún registro
    IF v_rows_affected > 0 THEN
        -- Retornar el registro actualizado
        SELECT
            cvereq,
            id_anuncio,
            folioreq,
            total,
            vigencia,
            cveproceso,
            'Requerimiento actualizado exitosamente' as mensaje
        FROM requerimiento_anuncios
        WHERE cvereq = p_cvereq;
    ELSE
        -- Retornar error si no se encontró el registro
        SELECT
            p_cvereq as cvereq,
            NULL as id_anuncio,
            NULL as folioreq,
            0 as total,
            NULL as vigencia,
            NULL as cveproceso,
            'Error: No se encontró el requerimiento especificado' as mensaje;
    END IF;

END PROCEDURE;

-- =====================================================================================
-- FUNCIÓN: SP_CONSULTA_ANUNCIO_DELETE
-- DESCRIPCIÓN: Eliminar (marcar como cancelado) un requerimiento de anuncio
-- PARÁMETROS:
--   p_cvereq: Clave del requerimiento a eliminar
-- =====================================================================================

CREATE PROCEDURE SP_CONSULTA_ANUNCIO_DELETE(
    p_cvereq INTEGER
)

    DEFINE v_rows_affected INTEGER;

    -- En lugar de eliminar, marcar como cancelado
    UPDATE requerimiento_anuncios SET
        vigencia = 'C',
        cveproceso = 'X',
        fecmod = TODAY,
        obs = CASE
            WHEN obs IS NULL THEN 'Requerimiento cancelado el ' || TODAY
            ELSE obs || ' | Cancelado el ' || TODAY
        END
    WHERE cvereq = p_cvereq;

    LET v_rows_affected = SQLCA.SQLERRD[3];

    -- Verificar resultado
    IF v_rows_affected > 0 THEN
        SELECT
            p_cvereq as cvereq,
            'Requerimiento cancelado exitosamente' as mensaje,
            'success' as status
        FROM systables WHERE tabid = 1;
    ELSE
        SELECT
            p_cvereq as cvereq,
            'Error: No se encontró el requerimiento especificado' as mensaje,
            'error' as status
        FROM systables WHERE tabid = 1;
    END IF;

END PROCEDURE;

-- =====================================================================================
-- FUNCIÓN: SP_CONSULTA_ANUNCIO_ESTADISTICAS
-- DESCRIPCIÓN: Obtener estadísticas generales de requerimientos de anuncios
-- PARÁMETROS: Ninguno
-- =====================================================================================

CREATE PROCEDURE SP_CONSULTA_ANUNCIO_ESTADISTICAS()

    SELECT
        -- Conteos por vigencia
        COUNT(*) as total_requerimientos,
        SUM(CASE WHEN vigencia = 'V' THEN 1 ELSE 0 END) as vigentes,
        SUM(CASE WHEN vigencia = 'C' THEN 1 ELSE 0 END) as cancelados,
        SUM(CASE WHEN vigencia = 'S' THEN 1 ELSE 0 END) as suspendidos,

        -- Conteos por proceso
        SUM(CASE WHEN cveproceso = 'N' THEN 1 ELSE 0 END) as nuevos,
        SUM(CASE WHEN cveproceso = 'P' THEN 1 ELSE 0 END) as en_proceso,
        SUM(CASE WHEN cveproceso = 'C' THEN 1 ELSE 0 END) as completados,
        SUM(CASE WHEN cveproceso = 'X' THEN 1 ELSE 0 END) as proceso_cancelados,

        -- Totales monetarios
        SUM(total) as total_importe,
        SUM(derechos) as total_derechos,
        SUM(recargos) as total_recargos,
        SUM(multa) as total_multas,

        -- Promedios
        AVG(total) as promedio_importe,

        -- Conteos por recaudadora
        SUM(CASE WHEN recaud = 1 THEN 1 ELSE 0 END) as guadalajara,
        SUM(CASE WHEN recaud = 2 THEN 1 ELSE 0 END) as zapopan,
        SUM(CASE WHEN recaud = 3 THEN 1 ELSE 0 END) as tlaquepaque,
        SUM(CASE WHEN recaud = 4 THEN 1 ELSE 0 END) as tonala,

        -- Fechas
        MIN(fecemi) as fecha_primer_requerimiento,
        MAX(fecemi) as fecha_ultimo_requerimiento,

        -- Año actual
        YEAR(TODAY) as anio_actual,
        SUM(CASE WHEN YEAR(fecemi) = YEAR(TODAY) THEN 1 ELSE 0 END) as requerimientos_anio_actual

    FROM requerimiento_anuncios;

END PROCEDURE;

-- =====================================================================================
-- DATOS DE PRUEBA PARA TESTING
-- =====================================================================================

-- Crear tabla si no existe (solo para referencia de estructura)
/*
CREATE TABLE IF NOT EXISTS requerimiento_anuncios (
    cvereq INTEGER NOT NULL PRIMARY KEY,
    id_anuncio VARCHAR(20),
    folioreq VARCHAR(50),
    axoreq INTEGER,
    recaud INTEGER,
    tipolic CHAR(1) DEFAULT 'A',
    cveproceso CHAR(1) DEFAULT 'N',
    vigencia CHAR(1) DEFAULT 'V',
    derechos DECIMAL(10,2) DEFAULT 0.00,
    recargos DECIMAL(10,2) DEFAULT 0.00,
    formas DECIMAL(10,2) DEFAULT 0.00,
    gastos DECIMAL(10,2) DEFAULT 0.00,
    multa DECIMAL(10,2) DEFAULT 0.00,
    gastos_req DECIMAL(10,2) DEFAULT 0.00,
    total DECIMAL(10,2) DEFAULT 0.00,
    fecemi DATE DEFAULT TODAY,
    fecentejec DATE,
    feccit DATE,
    fecprac DATE,
    fecmod DATE,
    capturista VARCHAR(50),
    cveejecut VARCHAR(20),
    nodiligenciado CHAR(1) DEFAULT 'N',
    obs VARCHAR(500)
);
*/

-- =====================================================================================
-- PERMISOS Y COMENTARIOS FINALES
-- =====================================================================================

-- Otorgar permisos a los usuarios del sistema
-- GRANT EXECUTE ON SP_CONSULTA_ANUNCIO_LIST TO PUBLIC;
-- GRANT EXECUTE ON SP_CONSULTA_ANUNCIO_GET TO PUBLIC;
-- GRANT EXECUTE ON SP_CONSULTA_ANUNCIO_CREATE TO PUBLIC;
-- GRANT EXECUTE ON SP_CONSULTA_ANUNCIO_UPDATE TO PUBLIC;
-- GRANT EXECUTE ON SP_CONSULTA_ANUNCIO_DELETE TO PUBLIC;
-- GRANT EXECUTE ON SP_CONSULTA_ANUNCIO_ESTADISTICAS TO PUBLIC;

-- FIN DEL ARCHIVO
-- =====================================================================================