-- ========================================
-- STORED PROCEDURES PARA CONSTANCIA NO OFICIAL
-- Sistema: HarWeb - Módulo de Licencias
-- Base: padron_licencias (Informix)
-- Fecha: 2025-09-30
-- ========================================

-- ========================================
-- SP_CONSTANCIA_NO_OFICIAL_LIST
-- Descripción: Lista todas las constancias no oficiales
-- Parámetros: Ninguno
-- Retorna: Listado completo de constancias no oficiales
-- ========================================
CREATE PROCEDURE SP_CONSTANCIA_NO_OFICIAL_LIST()
RETURNING
    axo INTEGER,
    folio INTEGER,
    propietario VARCHAR(80),
    actividad VARCHAR(120),
    ubicacion VARCHAR(100),
    zona INTEGER,
    subzona INTEGER,
    vigente CHAR(1),
    feccap DATE,
    capturista VARCHAR(30),
    observaciones VARCHAR(255),
    tipo_constancia VARCHAR(50),
    numero_oficial VARCHAR(20),
    colonia VARCHAR(60),
    cp VARCHAR(10),
    telefono VARCHAR(20),
    email VARCHAR(80);

    FOREACH c1 FOR
        SELECT
            axo,
            folio,
            propietario,
            actividad,
            ubicacion,
            zona,
            subzona,
            vigente,
            feccap,
            capturista,
            observaciones,
            CASE
                WHEN tipo_doc = 'CNO' THEN 'Constancia No Oficial'
                WHEN tipo_doc = 'CIN' THEN 'Constancia Informal'
                ELSE 'Documento Auxiliar'
            END as tipo_constancia,
            numero_oficial,
            colonia,
            cp,
            telefono,
            email
        FROM constancias_no_oficiales
        WHERE vigente = 'V'
        ORDER BY axo DESC, folio DESC
    INTO
        axo, folio, propietario, actividad, ubicacion, zona, subzona,
        vigente, feccap, capturista, observaciones, tipo_constancia,
        numero_oficial, colonia, cp, telefono, email

        RETURN axo, folio, propietario, actividad, ubicacion, zona, subzona,
               vigente, feccap, capturista, observaciones, tipo_constancia,
               numero_oficial, colonia, cp, telefono, email;
    END FOREACH;

END PROCEDURE;

-- ========================================
-- SP_CONSTANCIA_NO_OFICIAL_GET
-- Descripción: Obtiene el detalle de una constancia no oficial específica
-- Parámetros: p_axo (año), p_folio (folio)
-- Retorna: Detalle completo de la constancia
-- ========================================
CREATE PROCEDURE SP_CONSTANCIA_NO_OFICIAL_GET(
    p_axo INTEGER,
    p_folio INTEGER
)
RETURNING
    axo INTEGER,
    folio INTEGER,
    propietario VARCHAR(80),
    actividad VARCHAR(120),
    ubicacion VARCHAR(100),
    zona INTEGER,
    subzona INTEGER,
    vigente CHAR(1),
    feccap DATE,
    capturista VARCHAR(30),
    observaciones VARCHAR(255),
    tipo_doc VARCHAR(10),
    numero_oficial VARCHAR(20),
    colonia VARCHAR(60),
    cp VARCHAR(10),
    telefono VARCHAR(20),
    email VARCHAR(80),
    fecha_solicitud DATE,
    fecha_expedicion DATE,
    uso_solicitado VARCHAR(150);

    SELECT
        axo,
        folio,
        propietario,
        actividad,
        ubicacion,
        zona,
        subzona,
        vigente,
        feccap,
        capturista,
        observaciones,
        tipo_doc,
        numero_oficial,
        colonia,
        cp,
        telefono,
        email,
        fecha_solicitud,
        fecha_expedicion,
        uso_solicitado
    FROM constancias_no_oficiales
    WHERE axo = p_axo AND folio = p_folio
    INTO
        axo, folio, propietario, actividad, ubicacion, zona, subzona,
        vigente, feccap, capturista, observaciones, tipo_doc,
        numero_oficial, colonia, cp, telefono, email,
        fecha_solicitud, fecha_expedicion, uso_solicitado;

    RETURN axo, folio, propietario, actividad, ubicacion, zona, subzona,
           vigente, feccap, capturista, observaciones, tipo_doc,
           numero_oficial, colonia, cp, telefono, email,
           fecha_solicitud, fecha_expedicion, uso_solicitado;

END PROCEDURE;

-- ========================================
-- SP_CONSTANCIA_NO_OFICIAL_CREATE
-- Descripción: Crea una nueva constancia no oficial
-- Parámetros: Datos de la constancia
-- Retorna: Año y folio de la nueva constancia
-- ========================================
CREATE PROCEDURE SP_CONSTANCIA_NO_OFICIAL_CREATE(
    p_propietario VARCHAR(80),
    p_actividad VARCHAR(120),
    p_ubicacion VARCHAR(100),
    p_zona INTEGER,
    p_subzona INTEGER,
    p_capturista VARCHAR(30),
    p_observaciones VARCHAR(255),
    p_tipo_doc VARCHAR(10),
    p_numero_oficial VARCHAR(20),
    p_colonia VARCHAR(60),
    p_cp VARCHAR(10),
    p_telefono VARCHAR(20),
    p_email VARCHAR(80),
    p_uso_solicitado VARCHAR(150)
)
RETURNING
    axo INTEGER,
    folio INTEGER,
    resultado VARCHAR(100);

    DEFINE v_axo INTEGER;
    DEFINE v_folio INTEGER;
    DEFINE v_count INTEGER;

    -- Obtener el año actual
    LET v_axo = YEAR(TODAY);

    -- Obtener el siguiente folio para el año actual
    SELECT NVL(MAX(folio), 0) + 1
    FROM constancias_no_oficiales
    WHERE axo = v_axo
    INTO v_folio;

    -- Validar campos obligatorios
    IF p_propietario IS NULL OR LENGTH(TRIM(p_propietario)) = 0 THEN
        RETURN NULL, NULL, 'Error: El propietario es obligatorio';
    END IF;

    IF p_actividad IS NULL OR LENGTH(TRIM(p_actividad)) = 0 THEN
        RETURN NULL, NULL, 'Error: La actividad es obligatoria';
    END IF;

    IF p_ubicacion IS NULL OR LENGTH(TRIM(p_ubicacion)) = 0 THEN
        RETURN NULL, NULL, 'Error: La ubicación es obligatoria';
    END IF;

    -- Insertar la nueva constancia
    INSERT INTO constancias_no_oficiales (
        axo,
        folio,
        propietario,
        actividad,
        ubicacion,
        zona,
        subzona,
        vigente,
        feccap,
        capturista,
        observaciones,
        tipo_doc,
        numero_oficial,
        colonia,
        cp,
        telefono,
        email,
        fecha_solicitud,
        fecha_expedicion,
        uso_solicitado
    ) VALUES (
        v_axo,
        v_folio,
        TRIM(p_propietario),
        TRIM(p_actividad),
        TRIM(p_ubicacion),
        p_zona,
        p_subzona,
        'V',
        TODAY,
        TRIM(p_capturista),
        TRIM(p_observaciones),
        NVL(p_tipo_doc, 'CNO'),
        TRIM(p_numero_oficial),
        TRIM(p_colonia),
        TRIM(p_cp),
        TRIM(p_telefono),
        TRIM(p_email),
        TODAY,
        NULL,
        TRIM(p_uso_solicitado)
    );

    RETURN v_axo, v_folio, 'Constancia creada exitosamente';

END PROCEDURE;

-- ========================================
-- SP_CONSTANCIA_NO_OFICIAL_UPDATE
-- Descripción: Actualiza una constancia no oficial existente
-- Parámetros: Año, folio y datos a actualizar
-- Retorna: Resultado de la operación
-- ========================================
CREATE PROCEDURE SP_CONSTANCIA_NO_OFICIAL_UPDATE(
    p_axo INTEGER,
    p_folio INTEGER,
    p_propietario VARCHAR(80),
    p_actividad VARCHAR(120),
    p_ubicacion VARCHAR(100),
    p_zona INTEGER,
    p_subzona INTEGER,
    p_observaciones VARCHAR(255),
    p_numero_oficial VARCHAR(20),
    p_colonia VARCHAR(60),
    p_cp VARCHAR(10),
    p_telefono VARCHAR(20),
    p_email VARCHAR(80),
    p_uso_solicitado VARCHAR(150)
)
RETURNING
    resultado VARCHAR(100);

    DEFINE v_count INTEGER;

    -- Verificar que la constancia existe
    SELECT COUNT(*)
    FROM constancias_no_oficiales
    WHERE axo = p_axo AND folio = p_folio
    INTO v_count;

    IF v_count = 0 THEN
        RETURN 'Error: La constancia no existe';
    END IF;

    -- Validar campos obligatorios
    IF p_propietario IS NULL OR LENGTH(TRIM(p_propietario)) = 0 THEN
        RETURN 'Error: El propietario es obligatorio';
    END IF;

    IF p_actividad IS NULL OR LENGTH(TRIM(p_actividad)) = 0 THEN
        RETURN 'Error: La actividad es obligatoria';
    END IF;

    IF p_ubicacion IS NULL OR LENGTH(TRIM(p_ubicacion)) = 0 THEN
        RETURN 'Error: La ubicación es obligatoria';
    END IF;

    -- Actualizar la constancia
    UPDATE constancias_no_oficiales SET
        propietario = TRIM(p_propietario),
        actividad = TRIM(p_actividad),
        ubicacion = TRIM(p_ubicacion),
        zona = p_zona,
        subzona = p_subzona,
        observaciones = TRIM(p_observaciones),
        numero_oficial = TRIM(p_numero_oficial),
        colonia = TRIM(p_colonia),
        cp = TRIM(p_cp),
        telefono = TRIM(p_telefono),
        email = TRIM(p_email),
        uso_solicitado = TRIM(p_uso_solicitado)
    WHERE axo = p_axo AND folio = p_folio;

    RETURN 'Constancia actualizada exitosamente';

END PROCEDURE;

-- ========================================
-- SP_CONSTANCIA_NO_OFICIAL_DELETE
-- Descripción: Marca como cancelada una constancia no oficial
-- Parámetros: p_axo (año), p_folio (folio)
-- Retorna: Resultado de la operación
-- ========================================
CREATE PROCEDURE SP_CONSTANCIA_NO_OFICIAL_DELETE(
    p_axo INTEGER,
    p_folio INTEGER
)
RETURNING
    resultado VARCHAR(100);

    DEFINE v_count INTEGER;

    -- Verificar que la constancia existe
    SELECT COUNT(*)
    FROM constancias_no_oficiales
    WHERE axo = p_axo AND folio = p_folio AND vigente = 'V'
    INTO v_count;

    IF v_count = 0 THEN
        RETURN 'Error: La constancia no existe o ya está cancelada';
    END IF;

    -- Cancelar la constancia (no eliminación física)
    UPDATE constancias_no_oficiales SET
        vigente = 'C',
        fecha_cancelacion = TODAY
    WHERE axo = p_axo AND folio = p_folio;

    RETURN 'Constancia cancelada exitosamente';

END PROCEDURE;

-- ========================================
-- SP_CONSTANCIA_NO_OFICIAL_ESTADISTICAS
-- Descripción: Obtiene estadísticas de constancias no oficiales
-- Parámetros: Ninguno
-- Retorna: Estadísticas generales
-- ========================================
CREATE PROCEDURE SP_CONSTANCIA_NO_OFICIAL_ESTADISTICAS()
RETURNING
    periodo VARCHAR(20),
    total_constancias INTEGER,
    constancias_vigentes INTEGER,
    constancias_canceladas INTEGER,
    constancias_mes_actual INTEGER,
    constancias_año_actual INTEGER;

    DEFINE v_axo_actual INTEGER;
    DEFINE v_mes_actual INTEGER;

    LET v_axo_actual = YEAR(TODAY);
    LET v_mes_actual = MONTH(TODAY);

    -- Estadísticas del año actual
    SELECT
        v_axo_actual||'',
        COUNT(*),
        SUM(CASE WHEN vigente = 'V' THEN 1 ELSE 0 END),
        SUM(CASE WHEN vigente = 'C' THEN 1 ELSE 0 END),
        SUM(CASE WHEN YEAR(feccap) = v_axo_actual AND MONTH(feccap) = v_mes_actual THEN 1 ELSE 0 END),
        SUM(CASE WHEN YEAR(feccap) = v_axo_actual THEN 1 ELSE 0 END)
    FROM constancias_no_oficiales
    WHERE axo = v_axo_actual
    INTO periodo, total_constancias, constancias_vigentes, constancias_canceladas,
         constancias_mes_actual, constancias_año_actual;

    RETURN periodo, total_constancias, constancias_vigentes, constancias_canceladas,
           constancias_mes_actual, constancias_año_actual;

END PROCEDURE;

-- ========================================
-- TABLA PARA CONSTANCIAS NO OFICIALES
-- (Comentario para referencia - crear si no existe)
-- ========================================
/*
CREATE TABLE constancias_no_oficiales (
    axo INTEGER NOT NULL,
    folio INTEGER NOT NULL,
    propietario VARCHAR(80) NOT NULL,
    actividad VARCHAR(120) NOT NULL,
    ubicacion VARCHAR(100) NOT NULL,
    zona INTEGER,
    subzona INTEGER,
    vigente CHAR(1) DEFAULT 'V',
    feccap DATE DEFAULT TODAY,
    capturista VARCHAR(30),
    observaciones VARCHAR(255),
    tipo_doc VARCHAR(10) DEFAULT 'CNO',
    numero_oficial VARCHAR(20),
    colonia VARCHAR(60),
    cp VARCHAR(10),
    telefono VARCHAR(20),
    email VARCHAR(80),
    fecha_solicitud DATE,
    fecha_expedicion DATE,
    fecha_cancelacion DATE,
    uso_solicitado VARCHAR(150),
    PRIMARY KEY (axo, folio)
);

CREATE INDEX idx_constancias_no_oficiales_propietario ON constancias_no_oficiales(propietario);
CREATE INDEX idx_constancias_no_oficiales_ubicacion ON constancias_no_oficiales(ubicacion);
CREATE INDEX idx_constancias_no_oficiales_vigente ON constancias_no_oficiales(vigente);
CREATE INDEX idx_constancias_no_oficiales_feccap ON constancias_no_oficiales(feccap);
*/

-- ========================================
-- FIN DEL ARCHIVO
-- ========================================