-- ============================================
-- STORED PROCEDURES MIGRADOS - INFORMIX
-- Formulario: BUSQUEDAACTIVIDADFRM
-- Archivo: 34_SP_BUSQUEDA_ACTIVIDAD_INFORMIX.sql
-- Migración y actualización para patrón eRequest/eResponse
-- Fecha: 2025-09-30
-- Total SPs: 6
-- ============================================

-- SP 1/6: SP_BUSQUEDA_ACTIVIDAD_LIST
-- Tipo: List
-- Descripción: Lista actividades económicas con filtros avanzados y paginación para búsqueda de giros comerciales e industriales
-- Parámetros entrada: p_scian (INTEGER), p_descripcion (LVARCHAR), p_limite (INTEGER), p_offset (INTEGER)
-- Parámetros salida: id_giro, cod_giro, descripcion, vigente, axo, costo, refrendo, clasificacion, tipo_actividad
-- --------------------------------------------

CREATE PROCEDURE SP_BUSQUEDA_ACTIVIDAD_LIST(
    p_scian INTEGER DEFAULT NULL,
    p_descripcion LVARCHAR(255) DEFAULT '',
    p_clasificacion LVARCHAR(50) DEFAULT '',
    p_limite INTEGER DEFAULT 25,
    p_offset INTEGER DEFAULT 0
)
RETURNING INTEGER AS id_giro,
          INTEGER AS cod_giro,
          LVARCHAR(255) AS descripcion,
          CHAR(1) AS vigente,
          INTEGER AS axo,
          DECIMAL(10,2) AS costo,
          DECIMAL(10,2) AS refrendo,
          LVARCHAR(50) AS clasificacion,
          LVARCHAR(30) AS tipo_actividad;

DEFINE v_current_year INTEGER;

    -- Obtener el año actual
    LET v_current_year = YEAR(TODAY);

    RETURN
        cg.id_giro,
        cg.cod_giro,
        cg.descripcion,
        cg.vigente,
        COALESCE(cvl.axo, v_current_year) AS axo,
        COALESCE(cvl.costo, 0.00) AS costo,
        COALESCE(cvl.refrendo, 0.00) AS refrendo,
        CASE
            WHEN cg.cod_giro BETWEEN 111000 AND 199999 THEN 'AGRICULTURA'
            WHEN cg.cod_giro BETWEEN 211000 AND 239999 THEN 'MINERIA'
            WHEN cg.cod_giro BETWEEN 311000 AND 339999 THEN 'MANUFACTURA'
            WHEN cg.cod_giro BETWEEN 431000 AND 469999 THEN 'COMERCIO'
            WHEN cg.cod_giro BETWEEN 481000 AND 499999 THEN 'TRANSPORTE'
            WHEN cg.cod_giro BETWEEN 511000 AND 519999 THEN 'INFORMACION'
            WHEN cg.cod_giro BETWEEN 521000 AND 529999 THEN 'FINANCIERO'
            WHEN cg.cod_giro BETWEEN 531000 AND 539999 THEN 'INMOBILIARIO'
            WHEN cg.cod_giro BETWEEN 541000 AND 569999 THEN 'PROFESIONALES'
            WHEN cg.cod_giro BETWEEN 611000 AND 624999 THEN 'EDUCACION'
            WHEN cg.cod_giro BETWEEN 711000 AND 713999 THEN 'ENTRETENIMIENTO'
            WHEN cg.cod_giro BETWEEN 721000 AND 722999 THEN 'HOSPEDAJE'
            WHEN cg.cod_giro BETWEEN 811000 AND 814999 THEN 'OTROS_SERVICIOS'
            ELSE 'SIN_CLASIFICAR'
        END AS clasificacion,
        CASE
            WHEN cg.cod_giro BETWEEN 311000 AND 339999 THEN 'INDUSTRIAL'
            WHEN cg.cod_giro BETWEEN 431000 AND 469999 THEN 'COMERCIAL'
            WHEN cg.cod_giro BETWEEN 541000 AND 814999 THEN 'SERVICIOS'
            ELSE 'MIXTO'
        END AS tipo_actividad
    FROM c_giros cg
    LEFT JOIN c_valoreslic cvl ON cvl.id_giro = cg.id_giro AND cvl.axo = v_current_year
    WHERE cg.id_giro >= 5000
      AND cg.vigente = 'V'
      AND cg.id_giro <> cg.cod_giro
      AND (p_scian IS NULL OR cg.cod_giro = p_scian)
      AND (
        p_descripcion IS NULL OR
        p_descripcion = '' OR
        UPPER(cg.descripcion) LIKE '%' || UPPER(p_descripcion) || '%'
      )
      AND (
        p_clasificacion IS NULL OR
        p_clasificacion = '' OR
        p_clasificacion = 'TODOS' OR
        CASE
            WHEN cg.cod_giro BETWEEN 111000 AND 199999 THEN 'AGRICULTURA'
            WHEN cg.cod_giro BETWEEN 211000 AND 239999 THEN 'MINERIA'
            WHEN cg.cod_giro BETWEEN 311000 AND 339999 THEN 'MANUFACTURA'
            WHEN cg.cod_giro BETWEEN 431000 AND 469999 THEN 'COMERCIO'
            WHEN cg.cod_giro BETWEEN 481000 AND 499999 THEN 'TRANSPORTE'
            WHEN cg.cod_giro BETWEEN 511000 AND 519999 THEN 'INFORMACION'
            WHEN cg.cod_giro BETWEEN 521000 AND 529999 THEN 'FINANCIERO'
            WHEN cg.cod_giro BETWEEN 531000 AND 539999 THEN 'INMOBILIARIO'
            WHEN cg.cod_giro BETWEEN 541000 AND 569999 THEN 'PROFESIONALES'
            WHEN cg.cod_giro BETWEEN 611000 AND 624999 THEN 'EDUCACION'
            WHEN cg.cod_giro BETWEEN 711000 AND 713999 THEN 'ENTRETENIMIENTO'
            WHEN cg.cod_giro BETWEEN 721000 AND 722999 THEN 'HOSPEDAJE'
            WHEN cg.cod_giro BETWEEN 811000 AND 814999 THEN 'OTROS_SERVICIOS'
            ELSE 'SIN_CLASIFICAR'
        END = p_clasificacion
      )
    ORDER BY cg.descripcion
    SKIP p_offset FIRST p_limite;

END PROCEDURE;

-- SP 2/6: SP_BUSQUEDA_ACTIVIDAD_GET
-- Tipo: Get
-- Descripción: Obtiene detalle completo de una actividad económica específica
-- Parámetros entrada: p_id_giro (INTEGER)
-- Parámetros salida: Detalle completo de la actividad con histórico de costos
-- --------------------------------------------

CREATE PROCEDURE SP_BUSQUEDA_ACTIVIDAD_GET(p_id_giro INTEGER)
RETURNING INTEGER AS id_giro,
          INTEGER AS cod_giro,
          LVARCHAR(255) AS descripcion,
          CHAR(1) AS vigente,
          DECIMAL(10,2) AS costo_actual,
          DECIMAL(10,2) AS refrendo_actual,
          INTEGER AS axo_actual,
          LVARCHAR(50) AS clasificacion,
          LVARCHAR(30) AS tipo_actividad,
          INTEGER AS total_licencias,
          INTEGER AS total_tramites,
          DATETIME YEAR TO SECOND AS fecha_alta,
          LVARCHAR(50) AS usuario_alta,
          DATETIME YEAR TO SECOND AS fecha_baja,
          LVARCHAR(50) AS usuario_baja;

DEFINE v_current_year INTEGER;
DEFINE v_total_licencias INTEGER;
DEFINE v_total_tramites INTEGER;

    -- Obtener el año actual
    LET v_current_year = YEAR(TODAY);

    -- Contar licencias
    SELECT COUNT(*) INTO v_total_licencias
    FROM licencias
    WHERE id_giro = p_id_giro;

    -- Contar trámites
    SELECT COUNT(*) INTO v_total_tramites
    FROM tramites
    WHERE id_giro = p_id_giro;

    RETURN
        cg.id_giro,
        cg.cod_giro,
        cg.descripcion,
        cg.vigente,
        COALESCE(cvl.costo, 0.00) AS costo_actual,
        COALESCE(cvl.refrendo, 0.00) AS refrendo_actual,
        COALESCE(cvl.axo, v_current_year) AS axo_actual,
        CASE
            WHEN cg.cod_giro BETWEEN 111000 AND 199999 THEN 'AGRICULTURA'
            WHEN cg.cod_giro BETWEEN 211000 AND 239999 THEN 'MINERIA'
            WHEN cg.cod_giro BETWEEN 311000 AND 339999 THEN 'MANUFACTURA'
            WHEN cg.cod_giro BETWEEN 431000 AND 469999 THEN 'COMERCIO'
            WHEN cg.cod_giro BETWEEN 481000 AND 499999 THEN 'TRANSPORTE'
            WHEN cg.cod_giro BETWEEN 511000 AND 519999 THEN 'INFORMACION'
            WHEN cg.cod_giro BETWEEN 521000 AND 529999 THEN 'FINANCIERO'
            WHEN cg.cod_giro BETWEEN 531000 AND 539999 THEN 'INMOBILIARIO'
            WHEN cg.cod_giro BETWEEN 541000 AND 569999 THEN 'PROFESIONALES'
            WHEN cg.cod_giro BETWEEN 611000 AND 624999 THEN 'EDUCACION'
            WHEN cg.cod_giro BETWEEN 711000 AND 713999 THEN 'ENTRETENIMIENTO'
            WHEN cg.cod_giro BETWEEN 721000 AND 722999 THEN 'HOSPEDAJE'
            WHEN cg.cod_giro BETWEEN 811000 AND 814999 THEN 'OTROS_SERVICIOS'
            ELSE 'SIN_CLASIFICAR'
        END AS clasificacion,
        CASE
            WHEN cg.cod_giro BETWEEN 311000 AND 339999 THEN 'INDUSTRIAL'
            WHEN cg.cod_giro BETWEEN 431000 AND 469999 THEN 'COMERCIAL'
            WHEN cg.cod_giro BETWEEN 541000 AND 814999 THEN 'SERVICIOS'
            ELSE 'MIXTO'
        END AS tipo_actividad,
        v_total_licencias AS total_licencias,
        v_total_tramites AS total_tramites,
        cg.fecha_alta,
        cg.usuario_alta,
        cg.fecha_baja,
        cg.usuario_baja
    FROM c_giros cg
    LEFT JOIN c_valoreslic cvl ON cvl.id_giro = cg.id_giro AND cvl.axo = v_current_year
    WHERE cg.id_giro = p_id_giro;

END PROCEDURE;

-- SP 3/6: SP_BUSQUEDA_ACTIVIDAD_CREATE
-- Tipo: Create
-- Descripción: Crea una nueva actividad económica en el catálogo
-- Parámetros entrada: p_cod_giro (INTEGER), p_descripcion (LVARCHAR), p_usuario (LVARCHAR)
-- Parámetros salida: success (INTEGER), message (LVARCHAR), id_giro (INTEGER)
-- --------------------------------------------

CREATE PROCEDURE SP_BUSQUEDA_ACTIVIDAD_CREATE(
    p_cod_giro INTEGER,
    p_descripcion LVARCHAR(255),
    p_usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message,
          INTEGER AS id_giro;

DEFINE v_new_id INTEGER;
DEFINE v_exists INTEGER;

    -- Verificar si ya existe el código SCIAN
    SELECT COUNT(*) INTO v_exists
    FROM c_giros
    WHERE cod_giro = p_cod_giro;

    IF v_exists > 0 THEN
        RETURN 0, 'Ya existe una actividad con el código SCIAN especificado', NULL;
    END IF;

    -- Obtener nuevo ID
    SELECT COALESCE(MAX(id_giro), 5000) + 1 INTO v_new_id
    FROM c_giros
    WHERE id_giro >= 5000;

    -- Insertar nueva actividad
    INSERT INTO c_giros (
        id_giro,
        cod_giro,
        descripcion,
        vigente,
        fecha_alta,
        usuario_alta
    ) VALUES (
        v_new_id,
        p_cod_giro,
        p_descripcion,
        'V',
        CURRENT,
        p_usuario
    );

    RETURN 1, 'Actividad creada exitosamente', v_new_id;

END PROCEDURE;

-- SP 4/6: SP_BUSQUEDA_ACTIVIDAD_UPDATE
-- Tipo: Update
-- Descripción: Actualiza una actividad económica existente
-- Parámetros entrada: p_id_giro (INTEGER), p_descripcion (LVARCHAR), p_vigente (CHAR), p_usuario (LVARCHAR)
-- Parámetros salida: success (INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE SP_BUSQUEDA_ACTIVIDAD_UPDATE(
    p_id_giro INTEGER,
    p_descripcion LVARCHAR(255),
    p_vigente CHAR(1),
    p_usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_exists INTEGER;

    -- Verificar si existe la actividad
    SELECT COUNT(*) INTO v_exists
    FROM c_giros
    WHERE id_giro = p_id_giro;

    IF v_exists = 0 THEN
        RETURN 0, 'No se encontró la actividad especificada';
    END IF;

    -- Actualizar actividad
    UPDATE c_giros SET
        descripcion = p_descripcion,
        vigente = p_vigente,
        fecha_baja = CASE WHEN p_vigente = 'B' THEN CURRENT ELSE fecha_baja END,
        usuario_baja = CASE WHEN p_vigente = 'B' THEN p_usuario ELSE usuario_baja END
    WHERE id_giro = p_id_giro;

    RETURN 1, 'Actividad actualizada exitosamente';

END PROCEDURE;

-- SP 5/6: SP_BUSQUEDA_ACTIVIDAD_DELETE
-- Tipo: Delete
-- Descripción: Marca como baja una actividad económica (soft delete)
-- Parámetros entrada: p_id_giro (INTEGER), p_usuario (LVARCHAR)
-- Parámetros salida: success (INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE SP_BUSQUEDA_ACTIVIDAD_DELETE(
    p_id_giro INTEGER,
    p_usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_exists INTEGER;
DEFINE v_tiene_licencias INTEGER;
DEFINE v_tiene_tramites INTEGER;

    -- Verificar si existe la actividad
    SELECT COUNT(*) INTO v_exists
    FROM c_giros
    WHERE id_giro = p_id_giro AND vigente = 'V';

    IF v_exists = 0 THEN
        RETURN 0, 'No se encontró la actividad especificada o ya está dada de baja';
    END IF;

    -- Verificar si tiene licencias asociadas
    SELECT COUNT(*) INTO v_tiene_licencias
    FROM licencias
    WHERE id_giro = p_id_giro;

    -- Verificar si tiene trámites asociados
    SELECT COUNT(*) INTO v_tiene_tramites
    FROM tramites
    WHERE id_giro = p_id_giro;

    IF v_tiene_licencias > 0 OR v_tiene_tramites > 0 THEN
        RETURN 0, 'No se puede dar de baja la actividad porque tiene licencias o trámites asociados';
    END IF;

    -- Dar de baja la actividad
    UPDATE c_giros SET
        vigente = 'B',
        fecha_baja = CURRENT,
        usuario_baja = p_usuario
    WHERE id_giro = p_id_giro;

    RETURN 1, 'Actividad dada de baja exitosamente';

END PROCEDURE;

-- SP 6/6: SP_BUSQUEDA_ACTIVIDAD_ESTADISTICAS
-- Tipo: Statistics
-- Descripción: Obtiene estadísticas generales del catálogo de actividades económicas
-- Parámetros entrada: Ninguno
-- Parámetros salida: Estadísticas agrupadas por clasificación y tipo
-- --------------------------------------------

CREATE PROCEDURE SP_BUSQUEDA_ACTIVIDAD_ESTADISTICAS()
RETURNING LVARCHAR(50) AS clasificacion,
          LVARCHAR(30) AS tipo_actividad,
          INTEGER AS total_actividades,
          INTEGER AS actividades_vigentes,
          INTEGER AS actividades_baja,
          INTEGER AS con_licencias,
          INTEGER AS con_tramites,
          DECIMAL(12,2) AS costo_promedio,
          DECIMAL(12,2) AS refrendo_promedio;

DEFINE v_current_year INTEGER;

    -- Obtener el año actual
    LET v_current_year = YEAR(TODAY);

    RETURN
        CASE
            WHEN cg.cod_giro BETWEEN 111000 AND 199999 THEN 'AGRICULTURA'
            WHEN cg.cod_giro BETWEEN 211000 AND 239999 THEN 'MINERIA'
            WHEN cg.cod_giro BETWEEN 311000 AND 339999 THEN 'MANUFACTURA'
            WHEN cg.cod_giro BETWEEN 431000 AND 469999 THEN 'COMERCIO'
            WHEN cg.cod_giro BETWEEN 481000 AND 499999 THEN 'TRANSPORTE'
            WHEN cg.cod_giro BETWEEN 511000 AND 519999 THEN 'INFORMACION'
            WHEN cg.cod_giro BETWEEN 521000 AND 529999 THEN 'FINANCIERO'
            WHEN cg.cod_giro BETWEEN 531000 AND 539999 THEN 'INMOBILIARIO'
            WHEN cg.cod_giro BETWEEN 541000 AND 569999 THEN 'PROFESIONALES'
            WHEN cg.cod_giro BETWEEN 611000 AND 624999 THEN 'EDUCACION'
            WHEN cg.cod_giro BETWEEN 711000 AND 713999 THEN 'ENTRETENIMIENTO'
            WHEN cg.cod_giro BETWEEN 721000 AND 722999 THEN 'HOSPEDAJE'
            WHEN cg.cod_giro BETWEEN 811000 AND 814999 THEN 'OTROS_SERVICIOS'
            ELSE 'SIN_CLASIFICAR'
        END AS clasificacion,
        CASE
            WHEN cg.cod_giro BETWEEN 311000 AND 339999 THEN 'INDUSTRIAL'
            WHEN cg.cod_giro BETWEEN 431000 AND 469999 THEN 'COMERCIAL'
            WHEN cg.cod_giro BETWEEN 541000 AND 814999 THEN 'SERVICIOS'
            ELSE 'MIXTO'
        END AS tipo_actividad,
        COUNT(*) AS total_actividades,
        SUM(CASE WHEN cg.vigente = 'V' THEN 1 ELSE 0 END) AS actividades_vigentes,
        SUM(CASE WHEN cg.vigente = 'B' THEN 1 ELSE 0 END) AS actividades_baja,
        COUNT(DISTINCT l.id_giro) AS con_licencias,
        COUNT(DISTINCT t.id_giro) AS con_tramites,
        AVG(COALESCE(cvl.costo, 0.00)) AS costo_promedio,
        AVG(COALESCE(cvl.refrendo, 0.00)) AS refrendo_promedio
    FROM c_giros cg
    LEFT JOIN c_valoreslic cvl ON cvl.id_giro = cg.id_giro AND cvl.axo = v_current_year
    LEFT JOIN licencias l ON l.id_giro = cg.id_giro
    LEFT JOIN tramites t ON t.id_giro = cg.id_giro
    WHERE cg.id_giro >= 5000
      AND cg.id_giro <> cg.cod_giro
    GROUP BY 1, 2
    HAVING COUNT(*) > 0
    ORDER BY 1, 2;

END PROCEDURE;