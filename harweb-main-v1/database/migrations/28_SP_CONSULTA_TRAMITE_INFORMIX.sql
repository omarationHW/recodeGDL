-- =============================================
-- STORED PROCEDURES PARA MODULO DE CONSULTA DE TRAMITES
-- Versión: 1.0
-- Fecha: 2024-09-30
-- Autor: Sistema HarWeb
-- Descripción: Stored procedures para gestión y consulta de trámites
-- =============================================

-- =============================================
-- SP_CONSULTA_TRAMITE_LIST
-- Descripción: Lista trámites con filtros y paginación
-- =============================================
CREATE PROCEDURE sp_consulta_tramite_list(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 10,
    p_search VARCHAR(100) DEFAULT '',
    p_estatus CHAR(1) DEFAULT '',
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL
)
RETURNING
    id_tramite INTEGER,
    folio VARCHAR(50),
    propietario VARCHAR(80),
    rfc VARCHAR(13),
    cvecuenta INTEGER,
    actividad VARCHAR(255),
    ubicacion VARCHAR(200),
    colonia_ubic VARCHAR(50),
    numext_ubic VARCHAR(10),
    estatus CHAR(1),
    feccap DATETIME YEAR TO SECOND,
    capturista VARCHAR(30),
    observaciones VARCHAR(255),
    inversion DECIMAL(15,2),
    num_empleados INTEGER,
    sup_autorizada DECIMAL(10,2),
    total_registros INTEGER;

DEFINE v_offset INTEGER;
DEFINE v_total INTEGER;
DEFINE v_where_clause VARCHAR(500);

-- Calcular offset para paginación
LET v_offset = (p_page - 1) * p_limit;

-- Construir condición WHERE dinámica
LET v_where_clause = " WHERE 1=1 ";

-- Aplicar filtros de búsqueda
IF p_search IS NOT NULL AND LENGTH(TRIM(p_search)) > 0 THEN
    LET v_where_clause = v_where_clause ||
        " AND (UPPER(t.propietario) LIKE UPPER('%" || p_search || "%') " ||
        " OR UPPER(t.actividad) LIKE UPPER('%" || p_search || "%') " ||
        " OR CAST(t.id_tramite AS VARCHAR(20)) LIKE '%" || p_search || "%' " ||
        " OR UPPER(t.rfc) LIKE UPPER('%" || p_search || "%')) ";
END IF;

-- Filtro por estatus
IF p_estatus IS NOT NULL AND LENGTH(TRIM(p_estatus)) > 0 THEN
    LET v_where_clause = v_where_clause || " AND t.estatus = '" || p_estatus || "' ";
END IF;

-- Filtro por rango de fechas
IF p_fecha_inicio IS NOT NULL THEN
    LET v_where_clause = v_where_clause || " AND t.feccap >= '" || p_fecha_inicio || "' ";
END IF;

IF p_fecha_fin IS NOT NULL THEN
    LET v_where_clause = v_where_clause || " AND t.feccap <= '" || p_fecha_fin || " 23:59:59' ";
END IF;

-- Obtener total de registros
EXECUTE IMMEDIATE "SELECT COUNT(*) FROM tramites t " || v_where_clause INTO v_total;

-- Retornar resultados paginados
FOREACH EXECUTE IMMEDIATE
    "SELECT t.id_tramite, t.folio, t.propietario, t.rfc, t.cvecuenta, " ||
    "       t.actividad, t.ubicacion, t.colonia_ubic, t.numext_ubic, " ||
    "       t.estatus, t.feccap, t.capturista, t.observaciones, " ||
    "       t.inversion, t.num_empleados, t.sup_autorizada, " ||
    "       " || v_total || " as total_registros " ||
    "FROM tramites t " || v_where_clause ||
    " ORDER BY t.feccap DESC, t.id_tramite DESC " ||
    " SKIP " || v_offset || " FIRST " || p_limit
    INTO id_tramite, folio, propietario, rfc, cvecuenta,
         actividad, ubicacion, colonia_ubic, numext_ubic,
         estatus, feccap, capturista, observaciones,
         inversion, num_empleados, sup_autorizada, total_registros

    RETURN id_tramite, folio, propietario, rfc, cvecuenta,
           actividad, ubicacion, colonia_ubic, numext_ubic,
           estatus, feccap, capturista, observaciones,
           inversion, num_empleados, sup_autorizada, total_registros;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_CONSULTA_TRAMITE_GET
-- Descripción: Obtiene detalles de un trámite específico
-- =============================================
CREATE PROCEDURE sp_consulta_tramite_get(
    p_id_tramite INTEGER
)
RETURNING
    id_tramite INTEGER,
    folio VARCHAR(50),
    propietario VARCHAR(80),
    rfc VARCHAR(13),
    cvecuenta INTEGER,
    actividad VARCHAR(255),
    ubicacion VARCHAR(200),
    colonia_ubic VARCHAR(50),
    numext_ubic VARCHAR(10),
    estatus CHAR(1),
    feccap DATETIME YEAR TO SECOND,
    capturista VARCHAR(30),
    observaciones VARCHAR(255),
    inversion DECIMAL(15,2),
    num_empleados INTEGER,
    sup_autorizada DECIMAL(10,2),
    tipo_tramite INTEGER,
    computer VARCHAR(50);

RETURN SELECT
    t.id_tramite,
    t.folio,
    t.propietario,
    t.rfc,
    t.cvecuenta,
    t.actividad,
    t.ubicacion,
    t.colonia_ubic,
    t.numext_ubic,
    t.estatus,
    t.feccap,
    t.capturista,
    t.observaciones,
    t.inversion,
    t.num_empleados,
    t.sup_autorizada,
    t.tipo_tramite,
    t.computer
FROM tramites t
WHERE t.id_tramite = p_id_tramite;

END PROCEDURE;

-- =============================================
-- SP_CONSULTA_TRAMITE_CREATE
-- Descripción: Crea un nuevo trámite
-- =============================================
CREATE PROCEDURE sp_consulta_tramite_create(
    p_tipo_tramite INTEGER,
    p_propietario VARCHAR(80),
    p_rfc VARCHAR(13),
    p_cvecuenta INTEGER,
    p_ubicacion VARCHAR(200),
    p_colonia_ubic VARCHAR(50),
    p_numext_ubic VARCHAR(10),
    p_actividad VARCHAR(255),
    p_estatus CHAR(1),
    p_capturista VARCHAR(30),
    p_observaciones VARCHAR(255),
    p_inversion DECIMAL(15,2),
    p_num_empleados INTEGER,
    p_sup_autorizada DECIMAL(10,2),
    p_computer VARCHAR(50)
)
RETURNING
    success INTEGER,
    message VARCHAR(255),
    id_tramite INTEGER;

DEFINE v_new_id INTEGER;
DEFINE v_folio VARCHAR(50);

-- Obtener siguiente ID
SELECT MAX(id_tramite) + 1 FROM tramites INTO v_new_id;
IF v_new_id IS NULL THEN
    LET v_new_id = 1;
END IF;

-- Generar folio
LET v_folio = 'TR-' || YEAR(TODAY) || '-' || LPAD(v_new_id, 6, '0');

-- Insertar nuevo trámite
BEGIN
    INSERT INTO tramites (
        id_tramite, tipo_tramite, folio, propietario, rfc, cvecuenta,
        ubicacion, colonia_ubic, numext_ubic, actividad, estatus,
        feccap, capturista, observaciones, inversion, num_empleados,
        sup_autorizada, computer
    ) VALUES (
        v_new_id, p_tipo_tramite, v_folio, p_propietario, p_rfc, p_cvecuenta,
        p_ubicacion, p_colonia_ubic, p_numext_ubic, p_actividad, p_estatus,
        CURRENT, p_capturista, p_observaciones, p_inversion, p_num_empleados,
        p_sup_autorizada, p_computer
    );

    RETURN 1, 'Trámite creado exitosamente con ID: ' || v_new_id, v_new_id;

    ON EXCEPTION
        RETURN 0, 'Error al crear trámite: ' || SQLSTATE, 0;
END;

END PROCEDURE;

-- =============================================
-- SP_CONSULTA_TRAMITE_UPDATE
-- Descripción: Actualiza un trámite existente
-- =============================================
CREATE PROCEDURE sp_consulta_tramite_update(
    p_id_tramite INTEGER,
    p_propietario VARCHAR(80),
    p_rfc VARCHAR(13),
    p_cvecuenta INTEGER,
    p_ubicacion VARCHAR(200),
    p_actividad VARCHAR(255),
    p_estatus CHAR(1),
    p_observaciones VARCHAR(255)
)
RETURNING
    success INTEGER,
    message VARCHAR(255);

DEFINE v_count INTEGER;

-- Verificar que el trámite existe
SELECT COUNT(*) FROM tramites WHERE id_tramite = p_id_tramite INTO v_count;

IF v_count = 0 THEN
    RETURN 0, 'Trámite no encontrado';
END IF;

-- Actualizar trámite
BEGIN
    UPDATE tramites SET
        propietario = p_propietario,
        rfc = p_rfc,
        cvecuenta = p_cvecuenta,
        ubicacion = p_ubicacion,
        actividad = p_actividad,
        estatus = p_estatus,
        observaciones = p_observaciones
    WHERE id_tramite = p_id_tramite;

    RETURN 1, 'Trámite actualizado exitosamente';

    ON EXCEPTION
        RETURN 0, 'Error al actualizar trámite: ' || SQLSTATE;
END;

END PROCEDURE;

-- =============================================
-- SP_CONSULTA_TRAMITE_UPDATE_STATUS
-- Descripción: Cambia el estatus de un trámite
-- =============================================
CREATE PROCEDURE sp_consulta_tramite_update_status(
    p_id_tramite INTEGER,
    p_estatus CHAR(1),
    p_motivo VARCHAR(255),
    p_usuario VARCHAR(30)
)
RETURNING
    success INTEGER,
    message VARCHAR(255);

DEFINE v_count INTEGER;
DEFINE v_estatus_anterior CHAR(1);

-- Verificar que el trámite existe
SELECT COUNT(*), estatus
FROM tramites
WHERE id_tramite = p_id_tramite
INTO v_count, v_estatus_anterior;

IF v_count = 0 THEN
    RETURN 0, 'Trámite no encontrado';
END IF;

IF v_estatus_anterior = p_estatus THEN
    RETURN 0, 'El trámite ya tiene el estatus solicitado';
END IF;

-- Actualizar estatus
BEGIN
    UPDATE tramites SET
        estatus = p_estatus
    WHERE id_tramite = p_id_tramite;

    -- Registrar en historial (si existe tabla de historial)
    -- INSERT INTO historial_tramites ...

    RETURN 1, 'Estatus del trámite actualizado de ' || v_estatus_anterior || ' a ' || p_estatus;

    ON EXCEPTION
        RETURN 0, 'Error al actualizar estatus: ' || SQLSTATE;
END;

END PROCEDURE;

-- =============================================
-- SP_CONSULTA_TRAMITE_ESTADISTICAS
-- Descripción: Obtiene estadísticas de trámites
-- =============================================
CREATE PROCEDURE sp_consulta_tramite_estadisticas(
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL
)
RETURNING
    total_tramites INTEGER,
    activos INTEGER,
    cancelados INTEGER,
    temporales INTEGER,
    rechazados INTEGER,
    tramites_mes_actual INTEGER,
    promedio_mensual DECIMAL(10,2);

DEFINE v_where_clause VARCHAR(200);
DEFINE v_total, v_activos, v_cancelados, v_temporales, v_rechazados INTEGER;
DEFINE v_tramites_mes, v_meses INTEGER;
DEFINE v_promedio DECIMAL(10,2);

-- Construir filtro de fechas
LET v_where_clause = " WHERE 1=1 ";

IF p_fecha_inicio IS NOT NULL THEN
    LET v_where_clause = v_where_clause || " AND feccap >= '" || p_fecha_inicio || "' ";
END IF;

IF p_fecha_fin IS NOT NULL THEN
    LET v_where_clause = v_where_clause || " AND feccap <= '" || p_fecha_fin || " 23:59:59' ";
END IF;

-- Obtener totales por estatus
EXECUTE IMMEDIATE "SELECT COUNT(*) FROM tramites " || v_where_clause INTO v_total;
EXECUTE IMMEDIATE "SELECT COUNT(*) FROM tramites " || v_where_clause || " AND estatus = 'A'" INTO v_activos;
EXECUTE IMMEDIATE "SELECT COUNT(*) FROM tramites " || v_where_clause || " AND estatus = 'C'" INTO v_cancelados;
EXECUTE IMMEDIATE "SELECT COUNT(*) FROM tramites " || v_where_clause || " AND estatus = 'T'" INTO v_temporales;
EXECUTE IMMEDIATE "SELECT COUNT(*) FROM tramites " || v_where_clause || " AND estatus = 'R'" INTO v_rechazados;

-- Trámites del mes actual
SELECT COUNT(*)
FROM tramites
WHERE YEAR(feccap) = YEAR(TODAY)
  AND MONTH(feccap) = MONTH(TODAY)
INTO v_tramites_mes;

-- Calcular promedio mensual (últimos 12 meses)
SELECT COUNT(*) / 12.0
FROM tramites
WHERE feccap >= TODAY - 365
INTO v_promedio;

RETURN v_total, v_activos, v_cancelados, v_temporales, v_rechazados,
       v_tramites_mes, v_promedio;

END PROCEDURE;

-- =============================================
-- SP_CONSULTA_TRAMITE_HISTORIAL
-- Descripción: Obtiene historial de cambios de un trámite
-- =============================================
CREATE PROCEDURE sp_consulta_tramite_historial(
    p_id_tramite INTEGER,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 10
)
RETURNING
    id_historial INTEGER,
    id_tramite INTEGER,
    fecha_cambio DATETIME YEAR TO SECOND,
    usuario VARCHAR(30),
    campo_modificado VARCHAR(50),
    valor_anterior VARCHAR(255),
    valor_nuevo VARCHAR(255),
    motivo VARCHAR(255),
    total_registros INTEGER;

DEFINE v_offset INTEGER;
DEFINE v_total INTEGER;

-- Calcular offset
LET v_offset = (p_page - 1) * p_limit;

-- Obtener total de registros
SELECT COUNT(*)
FROM historial_tramites
WHERE id_tramite = p_id_tramite
INTO v_total;

-- Retornar historial paginado
FOREACH
    SELECT h.id_historial, h.id_tramite, h.fecha_cambio, h.usuario,
           h.campo_modificado, h.valor_anterior, h.valor_nuevo, h.motivo,
           v_total as total_registros
    FROM historial_tramites h
    WHERE h.id_tramite = p_id_tramite
    ORDER BY h.fecha_cambio DESC
    SKIP v_offset FIRST p_limit
    INTO id_historial, id_tramite, fecha_cambio, usuario,
         campo_modificado, valor_anterior, valor_nuevo, motivo, total_registros

    RETURN id_historial, id_tramite, fecha_cambio, usuario,
           campo_modificado, valor_anterior, valor_nuevo, motivo, total_registros;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_CONSULTA_TRAMITE_EXPORT
-- Descripción: Exporta datos de trámites para Excel/CSV
-- =============================================
CREATE PROCEDURE sp_consulta_tramite_export(
    p_search VARCHAR(100) DEFAULT '',
    p_estatus CHAR(1) DEFAULT '',
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_formato VARCHAR(10) DEFAULT 'CSV'
)
RETURNING
    id_tramite INTEGER,
    folio VARCHAR(50),
    propietario VARCHAR(80),
    rfc VARCHAR(13),
    cvecuenta INTEGER,
    actividad VARCHAR(255),
    ubicacion VARCHAR(200),
    estatus VARCHAR(20),
    fecha_captura VARCHAR(20),
    capturista VARCHAR(30),
    inversion DECIMAL(15,2),
    num_empleados INTEGER,
    sup_autorizada DECIMAL(10,2);

DEFINE v_where_clause VARCHAR(500);
DEFINE v_estatus_desc VARCHAR(20);

-- Construir condición WHERE
LET v_where_clause = " WHERE 1=1 ";

IF p_search IS NOT NULL AND LENGTH(TRIM(p_search)) > 0 THEN
    LET v_where_clause = v_where_clause ||
        " AND (UPPER(t.propietario) LIKE UPPER('%" || p_search || "%') " ||
        " OR UPPER(t.actividad) LIKE UPPER('%" || p_search || "%') " ||
        " OR CAST(t.id_tramite AS VARCHAR(20)) LIKE '%" || p_search || "%') ";
END IF;

IF p_estatus IS NOT NULL AND LENGTH(TRIM(p_estatus)) > 0 THEN
    LET v_where_clause = v_where_clause || " AND t.estatus = '" || p_estatus || "' ";
END IF;

IF p_fecha_inicio IS NOT NULL THEN
    LET v_where_clause = v_where_clause || " AND t.feccap >= '" || p_fecha_inicio || "' ";
END IF;

IF p_fecha_fin IS NOT NULL THEN
    LET v_where_clause = v_where_clause || " AND t.feccap <= '" || p_fecha_fin || " 23:59:59' ";
END IF;

-- Retornar datos para exportar
FOREACH EXECUTE IMMEDIATE
    "SELECT t.id_tramite, t.folio, t.propietario, t.rfc, t.cvecuenta, " ||
    "       t.actividad, t.ubicacion, t.estatus, " ||
    "       TO_CHAR(t.feccap, '%d/%m/%Y %H:%M') as fecha_captura, " ||
    "       t.capturista, t.inversion, t.num_empleados, t.sup_autorizada " ||
    "FROM tramites t " || v_where_clause ||
    " ORDER BY t.feccap DESC"
    INTO id_tramite, folio, propietario, rfc, cvecuenta,
         actividad, ubicacion, estatus, fecha_captura,
         capturista, inversion, num_empleados, sup_autorizada

    -- Convertir estatus a texto descriptivo
    CASE estatus
        WHEN 'A' THEN LET v_estatus_desc = 'Activo';
        WHEN 'C' THEN LET v_estatus_desc = 'Cancelado';
        WHEN 'T' THEN LET v_estatus_desc = 'Temporal';
        WHEN 'R' THEN LET v_estatus_desc = 'Rechazado';
        ELSE LET v_estatus_desc = estatus;
    END CASE;

    RETURN id_tramite, folio, propietario, rfc, cvecuenta,
           actividad, ubicacion, v_estatus_desc, fecha_captura,
           capturista, inversion, num_empleados, sup_autorizada;
END FOREACH;

END PROCEDURE;

-- =============================================
-- Fin de archivo de Stored Procedures
-- =============================================