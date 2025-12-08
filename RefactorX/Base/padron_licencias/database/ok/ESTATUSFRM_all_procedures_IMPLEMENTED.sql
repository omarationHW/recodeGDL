-- ============================================================================
-- STORED PROCEDURES COMPLETOS - COMPONENTE: estatusfrm
-- Módulo: padron_licencias
-- Descripción: Gestión de estatus de revisiones de trámites
-- Total SPs: 3
-- Fecha Implementación: 2025-11-20
-- ============================================================================
--
-- FUNCIONALIDADES IMPLEMENTADAS:
-- 1. estatusfrm_sp_get_revision_info     - Obtener información de revisión actual
-- 2. estatusfrm_sp_get_historial_estatus - Obtener historial de cambios de estatus
-- 3. estatusfrm_sp_cambiar_estatus_revision - Cambiar estatus de revisión
--
-- TABLAS PRINCIPALES:
-- - informix.revisiones: Tabla principal de revisiones
-- - informix.seg_revision: Seguimiento de revisiones
-- - informix.tramites: Trámites relacionados
-- - informix.c_giros: Catálogo de giros
-- - informix.dependencias: Dependencias responsables
--
-- CARACTERÍSTICAS:
-- - Gestión completa de estatus de revisiones
-- - Historial completo de cambios
-- - Validaciones de negocio
-- - Actualización automática de trámites
-- - Manejo de prórrogas
-- - Reglas especiales por dependencia
-- ============================================================================

-- ============================================================================
-- SP 1/3: estatusfrm_sp_get_revision_info
-- Descripción: Obtiene información completa de la revisión actual de un trámite
-- Tipo: CONSULTA
-- ============================================================================

CREATE OR REPLACE FUNCTION padron_licencias.estatusfrm_sp_get_revision_info(
    p_tramite VARCHAR
)
RETURNS TABLE(
    id_tramite INTEGER,
    tramite VARCHAR,
    contribuyente VARCHAR,
    giro VARCHAR,
    fecha_solicitud TIMESTAMP,
    estatus VARCHAR,
    fecha_actualizacion TIMESTAMP,
    id_revision INTEGER,
    id_dependencia INTEGER,
    dependencia VARCHAR,
    oficio VARCHAR,
    fecha_inicio TIMESTAMP,
    fecha_termino TIMESTAMP,
    usr_revisa VARCHAR,
    observacion TEXT,
    tipo_tramite INTEGER,
    dictamen INTEGER,
    calificacion NUMERIC,
    costo NUMERIC,
    fecha_consejo DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_tramite IS NULL OR TRIM(p_tramite) = '' THEN
        RAISE EXCEPTION 'El número de trámite es requerido';
    END IF;

    RETURN QUERY
    SELECT
        t.id_tramite,
        t.id_tramite::VARCHAR AS tramite,
        COALESCE(t.contribuyente, t.nombre_empresa, 'Sin nombre') AS contribuyente,
        COALESCE(g.descripcion, g.giro, 'Sin giro') AS giro,
        t.fecha_solicitud,
        CASE
            WHEN sr.estatus = 'P' THEN 'Pendiente'
            WHEN sr.estatus = 'E' THEN 'En Proceso'
            WHEN sr.estatus = 'A' THEN 'Aprobado'
            WHEN sr.estatus = 'N' THEN 'Rechazado'
            WHEN sr.estatus = 'R' THEN 'Requiere Información'
            WHEN sr.estatus = 'C' THEN 'Cancelado'
            WHEN sr.estatus = 'O' THEN 'Prórroga'
            ELSE 'Pendiente'
        END AS estatus,
        COALESCE(sr.feccap, r.fecha_inicio, t.fecha_solicitud) AS fecha_actualizacion,
        r.id_revision,
        r.id_dependencia,
        COALESCE(d.nombre, d.dependencia, 'Sin dependencia') AS dependencia,
        r.oficio,
        r.fecha_inicio,
        r.fecha_termino,
        sr.usr_revisa,
        sr.observacion,
        t.tipo_tramite,
        t.dictamen,
        t.calificacion,
        t.costo,
        t.fecha_consejo
    FROM informix.tramites t
    LEFT JOIN informix.revisiones r ON r.id_tramite = t.id_tramite
    LEFT JOIN informix.seg_revision sr ON sr.id_revision = r.id_revision
    LEFT JOIN informix.c_giros g ON g.id_giro = t.id_giro
    LEFT JOIN informix.dependencias d ON d.id_dependencia = r.id_dependencia
    WHERE t.id_tramite::VARCHAR = p_tramite
        AND sr.id = (
            SELECT MAX(sr2.id)
            FROM informix.seg_revision sr2
            WHERE sr2.id_revision = r.id_revision
        )
    ORDER BY sr.feccap DESC
    LIMIT 1;

    -- Verificar si se encontró el trámite
    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró información de revisión para el trámite: %', p_tramite;
    END IF;
END;
$$;

COMMENT ON FUNCTION padron_licencias.estatusfrm_sp_get_revision_info(VARCHAR) IS
'Obtiene información completa de la revisión actual de un trámite con estatus y dependencia';

-- ============================================================================
-- SP 2/3: estatusfrm_sp_get_historial_estatus
-- Descripción: Obtiene el historial completo de cambios de estatus de un trámite
-- Tipo: CONSULTA
-- ============================================================================

CREATE OR REPLACE FUNCTION padron_licencias.estatusfrm_sp_get_historial_estatus(
    p_tramite VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    id_revision INTEGER,
    fecha_cambio TIMESTAMP,
    estatus_anterior VARCHAR,
    estatus_nuevo VARCHAR,
    observaciones TEXT,
    usuario VARCHAR,
    oficio VARCHAR,
    fecha_revision DATE,
    numero_cambio INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_tramite IS NULL OR TRIM(p_tramite) = '' THEN
        RAISE EXCEPTION 'El número de trámite es requerido';
    END IF;

    RETURN QUERY
    WITH historial_ordenado AS (
        SELECT
            sr.id,
            sr.id_revision,
            sr.feccap AS fecha_cambio,
            LAG(
                CASE
                    WHEN sr.estatus = 'P' THEN 'Pendiente'
                    WHEN sr.estatus = 'E' THEN 'En Proceso'
                    WHEN sr.estatus = 'A' THEN 'Aprobado'
                    WHEN sr.estatus = 'N' THEN 'Rechazado'
                    WHEN sr.estatus = 'R' THEN 'Requiere Información'
                    WHEN sr.estatus = 'C' THEN 'Cancelado'
                    WHEN sr.estatus = 'O' THEN 'Prórroga'
                    ELSE 'Pendiente'
                END
            ) OVER (PARTITION BY sr.id_revision ORDER BY sr.feccap ASC, sr.id ASC) AS estatus_anterior,
            CASE
                WHEN sr.estatus = 'P' THEN 'Pendiente'
                WHEN sr.estatus = 'E' THEN 'En Proceso'
                WHEN sr.estatus = 'A' THEN 'Aprobado'
                WHEN sr.estatus = 'N' THEN 'Rechazado'
                WHEN sr.estatus = 'R' THEN 'Requiere Información'
                WHEN sr.estatus = 'C' THEN 'Cancelado'
                WHEN sr.estatus = 'O' THEN 'Prórroga'
                ELSE 'Pendiente'
            END AS estatus_nuevo,
            sr.observacion,
            sr.usr_revisa,
            sr.oficio,
            sr.fecha_revision,
            ROW_NUMBER() OVER (PARTITION BY sr.id_revision ORDER BY sr.feccap ASC, sr.id ASC) AS numero_cambio
        FROM informix.seg_revision sr
        INNER JOIN informix.revisiones r ON r.id_revision = sr.id_revision
        INNER JOIN informix.tramites t ON t.id_tramite = r.id_tramite
        WHERE t.id_tramite::VARCHAR = p_tramite
    )
    SELECT
        h.id,
        h.id_revision,
        h.fecha_cambio,
        COALESCE(h.estatus_anterior, 'Inicio') AS estatus_anterior,
        h.estatus_nuevo,
        COALESCE(TRIM(h.observacion), 'Sin observaciones') AS observaciones,
        COALESCE(TRIM(h.usr_revisa), 'Sistema') AS usuario,
        h.oficio,
        h.fecha_revision,
        h.numero_cambio
    FROM historial_ordenado h
    ORDER BY h.fecha_cambio DESC, h.id DESC;

    -- Verificar si se encontró historial
    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró historial de estatus para el trámite: %', p_tramite;
    END IF;
END;
$$;

COMMENT ON FUNCTION padron_licencias.estatusfrm_sp_get_historial_estatus(VARCHAR) IS
'Obtiene el historial completo de cambios de estatus de un trámite con estatus anterior y nuevo';

-- ============================================================================
-- SP 3/3: estatusfrm_sp_cambiar_estatus_revision
-- Descripción: Cambia el estatus de una revisión y actualiza tablas relacionadas
-- Tipo: TRANSACCIÓN (INSERT/UPDATE)
-- ============================================================================

CREATE OR REPLACE FUNCTION padron_licencias.estatusfrm_sp_cambiar_estatus_revision(
    p_tramite VARCHAR,
    p_estatus VARCHAR,
    p_observaciones TEXT,
    p_usuario VARCHAR,
    p_fecha_revision DATE DEFAULT NULL,
    p_oficio VARCHAR DEFAULT NULL,
    p_calificacion NUMERIC DEFAULT NULL,
    p_costo NUMERIC DEFAULT NULL,
    p_fecha_consejo DATE DEFAULT NULL,
    p_fecha_actual TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_revision INTEGER,
    estatus_anterior VARCHAR,
    estatus_nuevo VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_tramite INTEGER;
    v_id_revision INTEGER;
    v_id_dependencia INTEGER;
    v_id_seg_revision INTEGER;
    v_tramite_estatus VARCHAR;
    v_tramite_dictamen INTEGER;
    v_giro_clasificacion VARCHAR;
    v_tipo_tramite INTEGER;
    v_estatus_anterior VARCHAR;
    v_estatus_codigo VARCHAR;
    v_oficio VARCHAR;
    v_aprobado BOOLEAN := FALSE;
    v_no_aprobado BOOLEAN := FALSE;
BEGIN
    -- Validar parámetros requeridos
    IF p_tramite IS NULL OR TRIM(p_tramite) = '' THEN
        RAISE EXCEPTION 'El número de trámite es requerido';
    END IF;

    IF p_estatus IS NULL OR TRIM(p_estatus) = '' THEN
        RAISE EXCEPTION 'El estatus es requerido';
    END IF;

    IF p_observaciones IS NULL OR TRIM(p_observaciones) = '' THEN
        RAISE EXCEPTION 'Las observaciones son requeridas';
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RAISE EXCEPTION 'El usuario es requerido';
    END IF;

    -- Convertir estatus a código
    v_estatus_codigo := CASE
        WHEN UPPER(TRIM(p_estatus)) = 'PENDIENTE' THEN 'P'
        WHEN UPPER(TRIM(p_estatus)) = 'EN PROCESO' THEN 'E'
        WHEN UPPER(TRIM(p_estatus)) = 'APROBADO' THEN 'A'
        WHEN UPPER(TRIM(p_estatus)) = 'RECHAZADO' THEN 'N'
        WHEN UPPER(TRIM(p_estatus)) = 'REQUIERE INFORMACIÓN' THEN 'R'
        WHEN UPPER(TRIM(p_estatus)) = 'REQUIERE INFORMACION' THEN 'R'
        WHEN UPPER(TRIM(p_estatus)) = 'CANCELADO' THEN 'C'
        WHEN UPPER(TRIM(p_estatus)) = 'PRÓRROGA' THEN 'O'
        WHEN UPPER(TRIM(p_estatus)) = 'PRORROGA' THEN 'O'
        ELSE p_estatus -- Si ya viene en código
    END;

    -- Buscar datos del trámite y revisión
    SELECT
        t.id_tramite,
        r.id_revision,
        r.id_dependencia,
        r.oficio,
        t.tipo_tramite,
        t.dictamen,
        CASE
            WHEN sr.estatus = 'P' THEN 'Pendiente'
            WHEN sr.estatus = 'E' THEN 'En Proceso'
            WHEN sr.estatus = 'A' THEN 'Aprobado'
            WHEN sr.estatus = 'N' THEN 'Rechazado'
            WHEN sr.estatus = 'R' THEN 'Requiere Información'
            WHEN sr.estatus = 'C' THEN 'Cancelado'
            WHEN sr.estatus = 'O' THEN 'Prórroga'
            ELSE 'Pendiente'
        END
    INTO
        v_id_tramite,
        v_id_revision,
        v_id_dependencia,
        v_oficio,
        v_tipo_tramite,
        v_tramite_dictamen,
        v_estatus_anterior
    FROM informix.tramites t
    LEFT JOIN informix.revisiones r ON r.id_tramite = t.id_tramite
    LEFT JOIN informix.seg_revision sr ON sr.id_revision = r.id_revision
    WHERE t.id_tramite::VARCHAR = p_tramite
        AND sr.id = (
            SELECT MAX(sr2.id)
            FROM informix.seg_revision sr2
            WHERE sr2.id_revision = r.id_revision
        )
    LIMIT 1;

    -- Verificar que existe el trámite
    IF v_id_tramite IS NULL THEN
        RETURN QUERY SELECT
            FALSE,
            'No se encontró el trámite especificado: ' || p_tramite,
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::VARCHAR;
        RETURN;
    END IF;

    -- Verificar que existe la revisión
    IF v_id_revision IS NULL THEN
        RETURN QUERY SELECT
            FALSE,
            'No se encontró revisión activa para el trámite: ' || p_tramite,
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::VARCHAR;
        RETURN;
    END IF;

    -- Obtener el último registro de seg_revision
    SELECT id INTO v_id_seg_revision
    FROM informix.seg_revision
    WHERE id_revision = v_id_revision
    ORDER BY id DESC
    LIMIT 1;

    IF v_id_seg_revision IS NULL THEN
        RETURN QUERY SELECT
            FALSE,
            'No existe seguimiento de revisión para el trámite: ' || p_tramite,
            v_id_revision,
            NULL::VARCHAR,
            NULL::VARCHAR;
        RETURN;
    END IF;

    -- Verificar si el estatus actual permite cambios
    IF EXISTS (
        SELECT 1
        FROM informix.seg_revision
        WHERE id = v_id_seg_revision
            AND estatus IN ('A','C','N')
            AND v_estatus_codigo NOT IN ('A','C','N')
    ) THEN
        RETURN QUERY SELECT
            FALSE,
            'El estatus actual no se puede cambiar. Ya está Aprobado, Cancelado o Rechazado',
            v_id_revision,
            v_estatus_anterior,
            p_estatus;
        RETURN;
    END IF;

    -- Actualizar seg_revision actual
    UPDATE informix.seg_revision
    SET
        estatus = v_estatus_codigo,
        fecha_revision = COALESCE(p_fecha_revision, fecha_revision),
        oficio = COALESCE(p_oficio, oficio),
        usr_revisa = p_usuario,
        feccap = p_fecha_actual,
        observacion = COALESCE(observacion, '') ||
            CASE WHEN COALESCE(observacion, '') = '' THEN '' ELSE E'\n' END ||
            '[' || TO_CHAR(p_fecha_actual, 'YYYY-MM-DD HH24:MI:SS') || '] ' ||
            COALESCE(TRIM(p_observaciones), '')
    WHERE id = v_id_seg_revision;

    -- Si es prórroga u observación, insertar nuevo seg_revision
    IF v_estatus_codigo IN ('O','R') THEN
        INSERT INTO informix.seg_revision (
            id_revision,
            oficio,
            fecha_revision,
            usr_revisa,
            estatus,
            feccap,
            observacion
        )
        VALUES (
            v_id_revision,
            COALESCE(p_oficio, v_oficio),
            COALESCE(p_fecha_revision, CURRENT_DATE),
            p_usuario,
            v_estatus_codigo,
            p_fecha_actual,
            '[' || TO_CHAR(p_fecha_actual, 'YYYY-MM-DD HH24:MI:SS') || '] ' ||
            COALESCE(TRIM(p_observaciones), '')
        );
    END IF;

    -- Actualizar tabla revisiones
    UPDATE informix.revisiones
    SET
        estatus = v_estatus_codigo,
        fecha_termino = CASE
            WHEN v_estatus_codigo IN ('A','N','C') THEN p_fecha_actual
            ELSE fecha_termino
        END
    WHERE id_revision = v_id_revision;

    -- Lógica de negocio según estatus

    -- Si es NO APROBADO/RECHAZADO, actualizar trámite a rechazado
    IF v_estatus_codigo = 'N' THEN
        UPDATE informix.tramites
        SET estatus = 'R'
        WHERE id_tramite = v_id_tramite;
        v_no_aprobado := TRUE;
    END IF;

    -- Si es CANCELADO, cambiar estatus del trámite
    IF v_estatus_codigo = 'C' THEN
        UPDATE informix.tramites
        SET estatus = 'C'
        WHERE id_tramite = v_id_tramite;
    END IF;

    -- Si es APROBADO y dependencia es obras públicas (26), poner dictamen=1
    IF v_estatus_codigo = 'A' AND v_id_dependencia = 26 THEN
        UPDATE informix.tramites
        SET dictamen = 1
        WHERE id_tramite = v_id_tramite;
    END IF;

    -- Si es APROBADO y dependencia es comité de giros restringidos (25,38)
    -- guardar calificación, costo y fecha consejo
    IF v_estatus_codigo = 'A' AND v_id_dependencia IN (25,38) THEN
        SELECT clasificacion
        INTO v_giro_clasificacion
        FROM informix.c_giros
        WHERE id_giro = (
            SELECT id_giro
            FROM informix.tramites
            WHERE id_tramite = v_id_tramite
        );

        IF v_giro_clasificacion = 'D' AND v_tipo_tramite IN (1,13) THEN
            UPDATE informix.tramites
            SET
                calificacion = COALESCE(p_calificacion, calificacion),
                costo = COALESCE(p_costo, costo),
                fecha_consejo = COALESCE(p_fecha_consejo, fecha_consejo)
            WHERE id_tramite = v_id_tramite;
        END IF;
    END IF;

    -- Si es APROBADO y dictamen=1, verificar si todas las revisiones están aprobadas
    IF v_estatus_codigo = 'A' AND v_tramite_dictamen = 1 THEN
        IF NOT EXISTS (
            SELECT 1
            FROM informix.revisiones r
            JOIN informix.seg_revision s ON s.id_revision = r.id_revision
            WHERE r.id_tramite = v_id_tramite
                AND s.estatus NOT IN ('A')
                AND s.id = (
                    SELECT MAX(s2.id)
                    FROM informix.seg_revision s2
                    WHERE s2.id_revision = r.id_revision
                )
        ) THEN
            v_aprobado := TRUE;
            -- Opcional: Cambiar estatus del trámite a aprobado
            -- UPDATE informix.tramites SET estatus = 'A' WHERE id_tramite = v_id_tramite;
        END IF;
    END IF;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        TRUE,
        'Estatus actualizado correctamente de "' || v_estatus_anterior || '" a "' || p_estatus || '"',
        v_id_revision,
        v_estatus_anterior,
        p_estatus;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            'Error al cambiar estatus: ' || SQLERRM,
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::VARCHAR;
END;
$$;

COMMENT ON FUNCTION padron_licencias.estatusfrm_sp_cambiar_estatus_revision(
    VARCHAR, VARCHAR, TEXT, VARCHAR, DATE, VARCHAR, NUMERIC, NUMERIC, DATE, TIMESTAMP
) IS 'Cambia el estatus de una revisión y actualiza tablas relacionadas con validaciones de negocio';

-- ============================================================================
-- GRANTS - Permisos de ejecución
-- ============================================================================

GRANT EXECUTE ON FUNCTION padron_licencias.estatusfrm_sp_get_revision_info(VARCHAR) TO PUBLIC;
GRANT EXECUTE ON FUNCTION padron_licencias.estatusfrm_sp_get_historial_estatus(VARCHAR) TO PUBLIC;
GRANT EXECUTE ON FUNCTION padron_licencias.estatusfrm_sp_cambiar_estatus_revision(
    VARCHAR, VARCHAR, TEXT, VARCHAR, DATE, VARCHAR, NUMERIC, NUMERIC, DATE, TIMESTAMP
) TO PUBLIC;

-- ============================================================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================================================
-- Total Stored Procedures: 3
--
-- LISTA DE SPs:
-- 1. padron_licencias.estatusfrm_sp_get_revision_info
-- 2. padron_licencias.estatusfrm_sp_get_historial_estatus
-- 3. padron_licencias.estatusfrm_sp_cambiar_estatus_revision
--
-- SCHEMAS UTILIZADOS:
-- - padron_licencias (Functions)
-- - informix (Tables)
--
-- TABLAS UTILIZADAS:
-- - informix.tramites
-- - informix.revisiones
-- - informix.seg_revision
-- - informix.c_giros
-- - informix.dependencias
--
-- CARACTERÍSTICAS PRINCIPALES:
-- ✓ Consulta de información de revisión actual
-- ✓ Historial completo de cambios de estatus
-- ✓ Cambio de estatus con validaciones de negocio
-- ✓ Actualización automática de trámites
-- ✓ Manejo de prórrogas y observaciones
-- ✓ Reglas especiales por dependencia (Obras Públicas, Comité de Giros)
-- ✓ Validación de estatus finales (no modificables)
-- ✓ Registro de usuario y fecha en cada cambio
-- ✓ Concatenación de observaciones históricas
-- ✓ Control de dictámenes
--
-- VALIDACIONES IMPLEMENTADAS:
-- ✓ Parámetros requeridos no nulos ni vacíos
-- ✓ Existencia de trámite y revisión
-- ✓ Validación de estatus finales no modificables
-- ✓ Validación de dependencias específicas
-- ✓ Validación de giros y tipo de trámite
-- ✓ Manejo de errores con EXCEPTION
--
-- RUTA DEL ARCHIVO:
-- C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/ESTATUSFRM_all_procedures_IMPLEMENTED.sql
--
-- ============================================================================
-- FIN DEL ARCHIVO
-- ============================================================================
