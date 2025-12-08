-- =====================================================================================
-- SEMAFORO - Stored Procedures Completos
-- =====================================================================================
-- Módulo: padron_licencias
-- Componente: SEMAFORO
-- Descripción: Sistema de semáforo aleatorio para inspecciones
-- Schema: comun
-- Fecha: 2025-11-21
-- Autor: RefactorX Generator
-- =====================================================================================
-- SPs Incluidos:
--   1. sp_semaforo_get_random_color - Obtener color aleatorio (ROJO/VERDE)
--   2. sp_semaforo_register_result - Registrar resultado de semáforo
--   3. sp_semaforo_get_history - Obtener historial de semáforos
-- =====================================================================================

-- ===================================================================================
-- TABLA: semaforo_historial
-- ===================================================================================
-- Descripción: Almacena el historial de resultados del semáforo de inspecciones
-- ===================================================================================

CREATE TABLE IF NOT EXISTS comun.semaforo_historial (
    id BIGSERIAL PRIMARY KEY,
    licencia_id INTEGER,
    color VARCHAR(10) NOT NULL,
    color_code VARCHAR(10),
    usuario VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_semaforo_historial_licencia_id
    ON comun.semaforo_historial(licencia_id);
CREATE INDEX IF NOT EXISTS idx_semaforo_historial_created_at
    ON comun.semaforo_historial(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_semaforo_historial_color
    ON comun.semaforo_historial(color);

COMMENT ON TABLE comun.semaforo_historial IS 'Historial de resultados del semáforo de inspecciones';
COMMENT ON COLUMN comun.semaforo_historial.id IS 'Identificador único del registro';
COMMENT ON COLUMN comun.semaforo_historial.licencia_id IS 'ID de la licencia asociada';
COMMENT ON COLUMN comun.semaforo_historial.color IS 'Color resultante: ROJO o VERDE';
COMMENT ON COLUMN comun.semaforo_historial.color_code IS 'Código hexadecimal del color';
COMMENT ON COLUMN comun.semaforo_historial.usuario IS 'Usuario que generó el semáforo';
COMMENT ON COLUMN comun.semaforo_historial.created_at IS 'Fecha y hora de creación del registro';


-- ===================================================================================
-- SP 1: sp_semaforo_get_random_color
-- ===================================================================================
-- Descripción: Genera un color aleatorio (ROJO o VERDE) con probabilidad 50/50
-- Parámetros: Ninguno
-- Retorna: color, color_code, timestamp_generado
-- ===================================================================================

DROP FUNCTION IF EXISTS comun.sp_semaforo_get_random_color();

CREATE OR REPLACE FUNCTION comun.sp_semaforo_get_random_color()
RETURNS TABLE(
    color VARCHAR,
    color_code VARCHAR,
    timestamp_generado TIMESTAMP
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_random_value DOUBLE PRECISION;
    v_color VARCHAR(10);
    v_color_code VARCHAR(10);
BEGIN
    -- Generar valor aleatorio
    v_random_value := random();

    -- Determinar color basado en probabilidad 50/50
    IF v_random_value < 0.5 THEN
        v_color := 'ROJO';
        v_color_code := '#FF0000';
    ELSE
        v_color := 'VERDE';
        v_color_code := '#00FF00';
    END IF;

    -- Retornar resultado
    RETURN QUERY
    SELECT
        v_color::VARCHAR AS color,
        v_color_code::VARCHAR AS color_code,
        NOW()::TIMESTAMP AS timestamp_generado;

EXCEPTION WHEN OTHERS THEN
    -- En caso de error, retornar ROJO por defecto con mensaje de error
    RAISE WARNING 'Error en sp_semaforo_get_random_color: %', SQLERRM;
    RETURN QUERY
    SELECT
        'ROJO'::VARCHAR AS color,
        '#FF0000'::VARCHAR AS color_code,
        NOW()::TIMESTAMP AS timestamp_generado;
END;
$$;

COMMENT ON FUNCTION comun.sp_semaforo_get_random_color() IS
'Genera un color aleatorio (ROJO/VERDE) con probabilidad 50/50 para el sistema de semáforo de inspecciones';


-- ===================================================================================
-- SP 2: sp_semaforo_register_result
-- ===================================================================================
-- Descripción: Registra el resultado de un semáforo en el historial
-- Parámetros:
--   p_licencia_id: ID de la licencia (requerido)
--   p_color: Color del semáforo - ROJO o VERDE (requerido)
--   p_usuario: Usuario que registra (opcional)
-- Retorna: success, message, registro_id
-- ===================================================================================

DROP FUNCTION IF EXISTS comun.sp_semaforo_register_result(INTEGER, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION comun.sp_semaforo_register_result(
    p_licencia_id INTEGER,
    p_color VARCHAR,
    p_usuario VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    registro_id BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_color_upper VARCHAR(10);
    v_color_code VARCHAR(10);
    v_nuevo_id BIGINT;
BEGIN
    -- Validar parámetro licencia_id
    IF p_licencia_id IS NULL THEN
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Error: El parámetro licencia_id es requerido'::TEXT AS message,
            NULL::BIGINT AS registro_id;
        RETURN;
    END IF;

    -- Validar parámetro color
    IF p_color IS NULL OR TRIM(p_color) = '' THEN
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Error: El parámetro color es requerido'::TEXT AS message,
            NULL::BIGINT AS registro_id;
        RETURN;
    END IF;

    -- Normalizar color a mayúsculas
    v_color_upper := UPPER(TRIM(p_color));

    -- Validar que el color sea ROJO o VERDE
    IF v_color_upper NOT IN ('ROJO', 'VERDE') THEN
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Error: El color debe ser ROJO o VERDE. Valor recibido: ' || p_color::TEXT AS message,
            NULL::BIGINT AS registro_id;
        RETURN;
    END IF;

    -- Asignar código de color
    IF v_color_upper = 'ROJO' THEN
        v_color_code := '#FF0000';
    ELSE
        v_color_code := '#00FF00';
    END IF;

    -- Insertar registro en historial
    INSERT INTO comun.semaforo_historial (
        licencia_id,
        color,
        color_code,
        usuario,
        created_at
    ) VALUES (
        p_licencia_id,
        v_color_upper,
        v_color_code,
        COALESCE(TRIM(p_usuario), 'SISTEMA'),
        NOW()
    )
    RETURNING id INTO v_nuevo_id;

    -- Retornar éxito
    RETURN QUERY
    SELECT
        TRUE::BOOLEAN AS success,
        'Registro de semáforo creado exitosamente. ID: ' || v_nuevo_id::TEXT AS message,
        v_nuevo_id AS registro_id;

EXCEPTION WHEN OTHERS THEN
    -- Manejo de errores
    RETURN QUERY
    SELECT
        FALSE::BOOLEAN AS success,
        'Error al registrar semáforo: ' || SQLERRM::TEXT AS message,
        NULL::BIGINT AS registro_id;
END;
$$;

COMMENT ON FUNCTION comun.sp_semaforo_register_result(INTEGER, VARCHAR, VARCHAR) IS
'Registra el resultado de un semáforo (ROJO/VERDE) en el historial para una licencia específica';


-- ===================================================================================
-- SP 3: sp_semaforo_get_history
-- ===================================================================================
-- Descripción: Obtiene el historial de semáforos con filtros opcionales
-- Parámetros:
--   p_licencia_id: ID de licencia para filtrar (opcional)
--   p_fecha_desde: Fecha inicial del rango (opcional)
--   p_fecha_hasta: Fecha final del rango (opcional)
--   p_limit: Límite de registros a retornar (default 100)
-- Retorna: Registros del historial ordenados por fecha DESC
-- ===================================================================================

DROP FUNCTION IF EXISTS comun.sp_semaforo_get_history(INTEGER, TIMESTAMP, TIMESTAMP, INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_semaforo_get_history(
    p_licencia_id INTEGER DEFAULT NULL,
    p_fecha_desde TIMESTAMP DEFAULT NULL,
    p_fecha_hasta TIMESTAMP DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id BIGINT,
    licencia_id INTEGER,
    color VARCHAR,
    color_code VARCHAR,
    usuario VARCHAR,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_limit INTEGER;
BEGIN
    -- Validar y establecer límite
    v_limit := COALESCE(p_limit, 100);
    IF v_limit <= 0 THEN
        v_limit := 100;
    END IF;
    IF v_limit > 1000 THEN
        v_limit := 1000; -- Límite máximo de seguridad
    END IF;

    -- Consultar historial con filtros dinámicos
    RETURN QUERY
    SELECT
        sh.id,
        sh.licencia_id,
        sh.color::VARCHAR,
        sh.color_code::VARCHAR,
        sh.usuario::VARCHAR,
        sh.created_at
    FROM comun.semaforo_historial sh
    WHERE
        -- Filtro por licencia_id (opcional)
        (p_licencia_id IS NULL OR sh.licencia_id = p_licencia_id)
        -- Filtro por fecha desde (opcional)
        AND (p_fecha_desde IS NULL OR sh.created_at >= p_fecha_desde)
        -- Filtro por fecha hasta (opcional)
        AND (p_fecha_hasta IS NULL OR sh.created_at <= p_fecha_hasta)
    ORDER BY sh.created_at DESC
    LIMIT v_limit;

EXCEPTION WHEN OTHERS THEN
    -- En caso de error, retornar conjunto vacío y registrar warning
    RAISE WARNING 'Error en sp_semaforo_get_history: %', SQLERRM;
    RETURN;
END;
$$;

COMMENT ON FUNCTION comun.sp_semaforo_get_history(INTEGER, TIMESTAMP, TIMESTAMP, INTEGER) IS
'Obtiene el historial de semáforos con filtros opcionales por licencia y rango de fechas';


-- ===================================================================================
-- VERIFICACIÓN DE INSTALACIÓN
-- ===================================================================================

DO $$
DECLARE
    v_count INTEGER := 0;
    v_table_exists BOOLEAN;
    v_sp1_exists BOOLEAN;
    v_sp2_exists BOOLEAN;
    v_sp3_exists BOOLEAN;
BEGIN
    -- Verificar tabla
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'comun'
        AND table_name = 'semaforo_historial'
    ) INTO v_table_exists;

    -- Verificar SP 1
    SELECT EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = 'sp_semaforo_get_random_color'
    ) INTO v_sp1_exists;

    -- Verificar SP 2
    SELECT EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = 'sp_semaforo_register_result'
    ) INTO v_sp2_exists;

    -- Verificar SP 3
    SELECT EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = 'sp_semaforo_get_history'
    ) INTO v_sp3_exists;

    -- Mostrar resultados
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'VERIFICACIÓN DE INSTALACIÓN - SEMAFORO';
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'Tabla comun.semaforo_historial: %', CASE WHEN v_table_exists THEN 'OK' ELSE 'FALTA' END;
    RAISE NOTICE 'SP comun.sp_semaforo_get_random_color: %', CASE WHEN v_sp1_exists THEN 'OK' ELSE 'FALTA' END;
    RAISE NOTICE 'SP comun.sp_semaforo_register_result: %', CASE WHEN v_sp2_exists THEN 'OK' ELSE 'FALTA' END;
    RAISE NOTICE 'SP comun.sp_semaforo_get_history: %', CASE WHEN v_sp3_exists THEN 'OK' ELSE 'FALTA' END;
    RAISE NOTICE '=====================================================';

    IF v_table_exists AND v_sp1_exists AND v_sp2_exists AND v_sp3_exists THEN
        RAISE NOTICE 'ESTADO: TODOS LOS COMPONENTES INSTALADOS CORRECTAMENTE';
    ELSE
        RAISE WARNING 'ESTADO: ALGUNOS COMPONENTES FALTAN - REVISAR';
    END IF;
    RAISE NOTICE '=====================================================';
END;
$$;


-- ===================================================================================
-- EJEMPLOS DE USO
-- ===================================================================================
/*
-- 1. Obtener color aleatorio:
SELECT * FROM comun.sp_semaforo_get_random_color();

-- 2. Registrar resultado de semáforo:
SELECT * FROM comun.sp_semaforo_register_result(12345, 'ROJO', 'usuario_prueba');
SELECT * FROM comun.sp_semaforo_register_result(12345, 'VERDE', 'usuario_prueba');

-- 3. Obtener historial completo (últimos 100):
SELECT * FROM comun.sp_semaforo_get_history();

-- 4. Obtener historial de una licencia específica:
SELECT * FROM comun.sp_semaforo_get_history(p_licencia_id := 12345);

-- 5. Obtener historial con rango de fechas:
SELECT * FROM comun.sp_semaforo_get_history(
    p_fecha_desde := '2025-01-01'::TIMESTAMP,
    p_fecha_hasta := '2025-12-31'::TIMESTAMP
);

-- 6. Obtener historial con todos los filtros:
SELECT * FROM comun.sp_semaforo_get_history(
    p_licencia_id := 12345,
    p_fecha_desde := '2025-01-01'::TIMESTAMP,
    p_fecha_hasta := '2025-12-31'::TIMESTAMP,
    p_limit := 50
);

-- 7. Flujo completo de uso del semáforo:
DO $$
DECLARE
    v_color_result RECORD;
    v_register_result RECORD;
BEGIN
    -- Generar color aleatorio
    SELECT * INTO v_color_result FROM comun.sp_semaforo_get_random_color();
    RAISE NOTICE 'Color generado: % (%)', v_color_result.color, v_color_result.color_code;

    -- Registrar resultado
    SELECT * INTO v_register_result
    FROM comun.sp_semaforo_register_result(99999, v_color_result.color, 'test_user');
    RAISE NOTICE 'Registro: % - %', v_register_result.success, v_register_result.message;
END;
$$;
*/

-- ===================================================================================
-- FIN DEL SCRIPT
-- ===================================================================================
-- Componente: SEMAFORO
-- Total SPs: 3
-- Tabla creada: comun.semaforo_historial
-- ===================================================================================
