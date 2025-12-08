-- =====================================================================================
-- ARCHIVO: TDMCONECTION_all_procedures_IMPLEMENTED.sql
-- MODULO: padron_licencias
-- COMPONENTE: TDMConection
-- DESCRIPCION: Sistema de bitacora de conexiones - registra login/logout de usuarios
-- AUTOR: Claude Code Assistant
-- FECHA: 2025-11-21
-- VERSION: 1.0.0
-- =====================================================================================
-- CONTENIDO:
--   1. Tabla: comun.bitacora_conexiones (con indices)
--   2. SP: comun.sp_tdmconection_login - Registrar inicio de sesion
--   3. SP: comun.sp_tdmconection_logout - Registrar cierre de sesion
--   4. SP: comun.sp_tdmconection_get_history - Obtener historial de conexiones
-- =====================================================================================

-- ===================================================================================
-- SECCION 1: CREACION DE TABLA E INDICES
-- ===================================================================================

-- Tabla principal para almacenar bitacora de conexiones
CREATE TABLE IF NOT EXISTS comun.bitacora_conexiones (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    aplicacion VARCHAR(50) DEFAULT 'PADRON_LICENCIAS',
    login_time TIMESTAMP DEFAULT NOW(),
    logout_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Comentario de tabla
COMMENT ON TABLE comun.bitacora_conexiones IS 'Bitacora de conexiones de usuarios - registra login/logout para auditoria';

-- Comentarios de columnas
COMMENT ON COLUMN comun.bitacora_conexiones.id IS 'Identificador unico de la sesion';
COMMENT ON COLUMN comun.bitacora_conexiones.usuario IS 'Nombre de usuario que inicio sesion';
COMMENT ON COLUMN comun.bitacora_conexiones.ip_address IS 'Direccion IP desde donde se conecto (IPv4/IPv6)';
COMMENT ON COLUMN comun.bitacora_conexiones.user_agent IS 'Informacion del navegador/cliente';
COMMENT ON COLUMN comun.bitacora_conexiones.aplicacion IS 'Nombre de la aplicacion desde donde se conecto';
COMMENT ON COLUMN comun.bitacora_conexiones.login_time IS 'Fecha y hora de inicio de sesion';
COMMENT ON COLUMN comun.bitacora_conexiones.logout_time IS 'Fecha y hora de cierre de sesion (NULL si aun activa)';
COMMENT ON COLUMN comun.bitacora_conexiones.created_at IS 'Fecha de creacion del registro';

-- Indices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_bitacora_conexiones_usuario
    ON comun.bitacora_conexiones(usuario);

CREATE INDEX IF NOT EXISTS idx_bitacora_conexiones_login_time
    ON comun.bitacora_conexiones(login_time);

CREATE INDEX IF NOT EXISTS idx_bitacora_conexiones_aplicacion
    ON comun.bitacora_conexiones(aplicacion);

CREATE INDEX IF NOT EXISTS idx_bitacora_conexiones_activa
    ON comun.bitacora_conexiones(usuario, logout_time)
    WHERE logout_time IS NULL;

-- ===================================================================================
-- SECCION 2: SP - REGISTRAR INICIO DE SESION
-- ===================================================================================

CREATE OR REPLACE FUNCTION comun.sp_tdmconection_login(
    p_usuario VARCHAR,
    p_ip_address VARCHAR,
    p_user_agent VARCHAR DEFAULT NULL,
    p_aplicacion VARCHAR DEFAULT 'PADRON_LICENCIAS'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    sesion_id BIGINT,
    login_time TIMESTAMP
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_sesion_id BIGINT;
    v_login_time TIMESTAMP;
BEGIN
    -- =========================================================================
    -- Validacion de parametros requeridos
    -- =========================================================================
    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: El parametro p_usuario es requerido'::TEXT,
            NULL::BIGINT,
            NULL::TIMESTAMP;
        RETURN;
    END IF;

    IF p_ip_address IS NULL OR TRIM(p_ip_address) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: El parametro p_ip_address es requerido'::TEXT,
            NULL::BIGINT,
            NULL::TIMESTAMP;
        RETURN;
    END IF;

    -- =========================================================================
    -- Insertar registro de login
    -- =========================================================================
    v_login_time := NOW();

    INSERT INTO comun.bitacora_conexiones (
        usuario,
        ip_address,
        user_agent,
        aplicacion,
        login_time,
        created_at
    ) VALUES (
        TRIM(p_usuario),
        TRIM(p_ip_address),
        NULLIF(TRIM(COALESCE(p_user_agent, '')), ''),
        COALESCE(NULLIF(TRIM(p_aplicacion), ''), 'PADRON_LICENCIAS'),
        v_login_time,
        NOW()
    )
    RETURNING id INTO v_sesion_id;

    -- =========================================================================
    -- Retornar resultado exitoso
    -- =========================================================================
    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        FORMAT('Login registrado exitosamente para usuario: %s', p_usuario)::TEXT,
        v_sesion_id,
        v_login_time;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            FORMAT('Error al registrar login: %s', SQLERRM)::TEXT,
            NULL::BIGINT,
            NULL::TIMESTAMP;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.sp_tdmconection_login(VARCHAR, VARCHAR, VARCHAR, VARCHAR) IS
'Registra el inicio de sesion de un usuario en la bitacora de conexiones.
Parametros:
  - p_usuario: Nombre del usuario (requerido)
  - p_ip_address: Direccion IP del cliente (requerido)
  - p_user_agent: Informacion del navegador (opcional)
  - p_aplicacion: Nombre de la aplicacion (default: PADRON_LICENCIAS)
Retorna: success, message, sesion_id, login_time';

-- ===================================================================================
-- SECCION 3: SP - REGISTRAR CIERRE DE SESION
-- ===================================================================================

CREATE OR REPLACE FUNCTION comun.sp_tdmconection_logout(
    p_sesion_id BIGINT,
    p_usuario VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    duracion_minutos INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_login_time TIMESTAMP;
    v_logout_time TIMESTAMP;
    v_duracion_minutos INTEGER;
    v_usuario_sesion VARCHAR;
    v_ya_cerrada BOOLEAN;
BEGIN
    -- =========================================================================
    -- Validacion de parametros requeridos
    -- =========================================================================
    IF p_sesion_id IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: El parametro p_sesion_id es requerido'::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: El parametro p_usuario es requerido'::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- =========================================================================
    -- Verificar que la sesion existe
    -- =========================================================================
    SELECT
        bc.usuario,
        bc.login_time,
        bc.logout_time IS NOT NULL
    INTO
        v_usuario_sesion,
        v_login_time,
        v_ya_cerrada
    FROM comun.bitacora_conexiones bc
    WHERE bc.id = p_sesion_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            FORMAT('Error: No existe la sesion con ID: %s', p_sesion_id)::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- =========================================================================
    -- Validar que la sesion pertenece al usuario
    -- =========================================================================
    IF UPPER(TRIM(v_usuario_sesion)) <> UPPER(TRIM(p_usuario)) THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            FORMAT('Error: La sesion %s no pertenece al usuario %s', p_sesion_id, p_usuario)::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- =========================================================================
    -- Verificar que la sesion no haya sido cerrada previamente
    -- =========================================================================
    IF v_ya_cerrada THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            FORMAT('Error: La sesion %s ya fue cerrada previamente', p_sesion_id)::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- =========================================================================
    -- Registrar logout y calcular duracion
    -- =========================================================================
    v_logout_time := NOW();
    v_duracion_minutos := FLOOR(EXTRACT(EPOCH FROM (v_logout_time - v_login_time)) / 60)::INTEGER;

    UPDATE comun.bitacora_conexiones
    SET logout_time = v_logout_time
    WHERE id = p_sesion_id;

    -- =========================================================================
    -- Retornar resultado exitoso
    -- =========================================================================
    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        FORMAT('Logout registrado exitosamente. Duracion de sesion: %s minutos', v_duracion_minutos)::TEXT,
        v_duracion_minutos;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            FORMAT('Error al registrar logout: %s', SQLERRM)::TEXT,
            NULL::INTEGER;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.sp_tdmconection_logout(BIGINT, VARCHAR) IS
'Registra el cierre de sesion de un usuario en la bitacora de conexiones.
Parametros:
  - p_sesion_id: ID de la sesion a cerrar (requerido)
  - p_usuario: Nombre del usuario (requerido, para validacion)
Retorna: success, message, duracion_minutos
Validaciones:
  - La sesion debe existir
  - La sesion debe pertenecer al usuario
  - La sesion no debe haber sido cerrada previamente';

-- ===================================================================================
-- SECCION 4: SP - OBTENER HISTORIAL DE CONEXIONES
-- ===================================================================================

CREATE OR REPLACE FUNCTION comun.sp_tdmconection_get_history(
    p_usuario VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    sesion_id BIGINT,
    usuario VARCHAR,
    ip_address VARCHAR,
    user_agent VARCHAR,
    aplicacion VARCHAR,
    login_time TIMESTAMP,
    logout_time TIMESTAMP,
    duracion_minutos INTEGER,
    activa BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_limit INTEGER;
BEGIN
    -- =========================================================================
    -- Validar y establecer limite
    -- =========================================================================
    v_limit := COALESCE(p_limit, 100);

    -- Limitar maximo a 1000 registros para evitar sobrecarga
    IF v_limit > 1000 THEN
        v_limit := 1000;
    END IF;

    IF v_limit < 1 THEN
        v_limit := 100;
    END IF;

    -- =========================================================================
    -- Retornar historial de conexiones
    -- =========================================================================
    RETURN QUERY
    SELECT
        bc.id AS sesion_id,
        bc.usuario::VARCHAR,
        bc.ip_address::VARCHAR,
        bc.user_agent::VARCHAR,
        bc.aplicacion::VARCHAR,
        bc.login_time,
        bc.logout_time,
        CASE
            WHEN bc.logout_time IS NOT NULL THEN
                FLOOR(EXTRACT(EPOCH FROM (bc.logout_time - bc.login_time)) / 60)::INTEGER
            ELSE
                FLOOR(EXTRACT(EPOCH FROM (NOW() - bc.login_time)) / 60)::INTEGER
        END AS duracion_minutos,
        (bc.logout_time IS NULL)::BOOLEAN AS activa
    FROM comun.bitacora_conexiones bc
    WHERE
        -- Filtro por usuario (opcional)
        (p_usuario IS NULL OR UPPER(TRIM(bc.usuario)) = UPPER(TRIM(p_usuario)))
        -- Filtro por fecha desde (opcional)
        AND (p_fecha_desde IS NULL OR bc.login_time::DATE >= p_fecha_desde)
        -- Filtro por fecha hasta (opcional)
        AND (p_fecha_hasta IS NULL OR bc.login_time::DATE <= p_fecha_hasta)
    ORDER BY bc.login_time DESC
    LIMIT v_limit;

EXCEPTION
    WHEN OTHERS THEN
        -- En caso de error, retornar conjunto vacio
        -- El error se puede loguear en una tabla de errores si es necesario
        RAISE WARNING 'Error en sp_tdmconection_get_history: %', SQLERRM;
        RETURN;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.sp_tdmconection_get_history(VARCHAR, DATE, DATE, INTEGER) IS
'Obtiene el historial de conexiones de usuarios con filtros opcionales.
Parametros:
  - p_usuario: Filtrar por usuario especifico (opcional)
  - p_fecha_desde: Filtrar desde fecha (opcional)
  - p_fecha_hasta: Filtrar hasta fecha (opcional)
  - p_limit: Limite de registros (default: 100, max: 1000)
Retorna: sesion_id, usuario, ip_address, user_agent, aplicacion, login_time,
         logout_time, duracion_minutos, activa
Notas:
  - activa = TRUE si logout_time IS NULL
  - duracion_minutos se calcula hasta NOW() si la sesion esta activa
  - Ordenado por login_time DESC (mas recientes primero)';

-- ===================================================================================
-- SECCION 5: VERIFICACION DE OBJETOS CREADOS
-- ===================================================================================

-- Verificar que la tabla existe
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'comun'
        AND table_name = 'bitacora_conexiones'
    ) THEN
        RAISE NOTICE 'OK: Tabla comun.bitacora_conexiones existe';
    ELSE
        RAISE WARNING 'ERROR: Tabla comun.bitacora_conexiones NO existe';
    END IF;
END $$;

-- Verificar que los SPs existen
DO $$
BEGIN
    -- Verificar sp_tdmconection_login
    IF EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_schema = 'comun'
        AND routine_name = 'sp_tdmconection_login'
    ) THEN
        RAISE NOTICE 'OK: SP comun.sp_tdmconection_login existe';
    ELSE
        RAISE WARNING 'ERROR: SP comun.sp_tdmconection_login NO existe';
    END IF;

    -- Verificar sp_tdmconection_logout
    IF EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_schema = 'comun'
        AND routine_name = 'sp_tdmconection_logout'
    ) THEN
        RAISE NOTICE 'OK: SP comun.sp_tdmconection_logout existe';
    ELSE
        RAISE WARNING 'ERROR: SP comun.sp_tdmconection_logout NO existe';
    END IF;

    -- Verificar sp_tdmconection_get_history
    IF EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_schema = 'comun'
        AND routine_name = 'sp_tdmconection_get_history'
    ) THEN
        RAISE NOTICE 'OK: SP comun.sp_tdmconection_get_history existe';
    ELSE
        RAISE WARNING 'ERROR: SP comun.sp_tdmconection_get_history NO existe';
    END IF;
END $$;

-- ===================================================================================
-- SECCION 6: EJEMPLOS DE USO
-- ===================================================================================

/*
-- EJEMPLO 1: Registrar login
SELECT * FROM comun.sp_tdmconection_login(
    'jperez',                           -- p_usuario
    '192.168.1.100',                    -- p_ip_address
    'Mozilla/5.0 (Windows NT 10.0)',    -- p_user_agent
    'PADRON_LICENCIAS'                  -- p_aplicacion
);
-- Resultado esperado: success=true, message='Login registrado...', sesion_id=123, login_time=...

-- EJEMPLO 2: Registrar logout
SELECT * FROM comun.sp_tdmconection_logout(
    123,        -- p_sesion_id (el ID retornado por login)
    'jperez'    -- p_usuario
);
-- Resultado esperado: success=true, message='Logout registrado...', duracion_minutos=45

-- EJEMPLO 3: Obtener historial completo (ultimos 100)
SELECT * FROM comun.sp_tdmconection_get_history();

-- EJEMPLO 4: Obtener historial de un usuario especifico
SELECT * FROM comun.sp_tdmconection_get_history('jperez');

-- EJEMPLO 5: Obtener historial con rango de fechas
SELECT * FROM comun.sp_tdmconection_get_history(
    NULL,           -- p_usuario (todos)
    '2025-11-01',   -- p_fecha_desde
    '2025-11-21',   -- p_fecha_hasta
    50              -- p_limit
);

-- EJEMPLO 6: Obtener sesiones activas (sin logout)
SELECT * FROM comun.sp_tdmconection_get_history()
WHERE activa = TRUE;

-- EJEMPLO 7: Obtener sesiones de hoy
SELECT * FROM comun.sp_tdmconection_get_history(
    NULL,
    CURRENT_DATE,
    CURRENT_DATE,
    500
);
*/

-- ===================================================================================
-- FIN DEL SCRIPT
-- ===================================================================================
-- Resumen de objetos creados:
--   - Tabla: comun.bitacora_conexiones
--   - Indices: idx_bitacora_conexiones_usuario, idx_bitacora_conexiones_login_time,
--              idx_bitacora_conexiones_aplicacion, idx_bitacora_conexiones_activa
--   - SP: comun.sp_tdmconection_login(VARCHAR, VARCHAR, VARCHAR, VARCHAR)
--   - SP: comun.sp_tdmconection_logout(BIGINT, VARCHAR)
--   - SP: comun.sp_tdmconection_get_history(VARCHAR, DATE, DATE, INTEGER)
-- ===================================================================================
