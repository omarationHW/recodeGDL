-- ============================================
-- STORED PROCEDURES COMPLETOS - FIRMAUSUARIO
-- Esquema: INFORMIX
-- Base de Datos: padron_licencias
-- Componente: FirmaUsuario.vue
-- Generado: 2025-09-23
-- ============================================

\c padron_licencias;
SET search_path TO informix;

-- ============================================
-- 1. CREAR TABLAS NECESARIAS
-- ============================================

-- Tabla usuarios_autenticacion para el manejo de PINs y sesiones
CREATE TABLE IF NOT EXISTS informix.usuarios_autenticacion (
    id SERIAL PRIMARY KEY,
    usuario VARCHAR(100) UNIQUE NOT NULL,
    pin VARCHAR(255) NOT NULL, -- PIN hasheado
    estado INTEGER DEFAULT 1 CHECK (estado IN (0, 1)), -- 0=Bloqueado, 1=Activo
    intentos_fallidos INTEGER DEFAULT 0,
    ultimo_acceso TIMESTAMP,
    sesion_activa BOOLEAN DEFAULT FALSE,
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla sesiones_usuarios para tracking de sesiones
CREATE TABLE IF NOT EXISTS informix.sesiones_usuarios (
    id SERIAL PRIMARY KEY,
    usuario_autenticacion_id INTEGER REFERENCES informix.usuarios_autenticacion(id) ON DELETE CASCADE,
    fecha_inicio TIMESTAMP DEFAULT NOW(),
    fecha_fin TIMESTAMP NULL,
    ip_address INET,
    user_agent TEXT,
    token_sesion VARCHAR(255),
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para optimización
CREATE INDEX IF NOT EXISTS idx_usuarios_auth_usuario ON informix.usuarios_autenticacion(usuario);
CREATE INDEX IF NOT EXISTS idx_usuarios_auth_estado ON informix.usuarios_autenticacion(estado);
CREATE INDEX IF NOT EXISTS idx_usuarios_auth_sesion_activa ON informix.usuarios_autenticacion(sesion_activa);
CREATE INDEX IF NOT EXISTS idx_sesiones_fecha_inicio ON informix.sesiones_usuarios(fecha_inicio);
CREATE INDEX IF NOT EXISTS idx_sesiones_activa ON informix.sesiones_usuarios(activa);

-- ============================================
-- 2. INSERTAR DATOS DE PRUEBA
-- ============================================

-- Insertar usuarios de ejemplo con PINs hasheados (usando crypt)
INSERT INTO informix.usuarios_autenticacion (usuario, pin, estado, observaciones) VALUES
('admin', crypt('1234', gen_salt('bf')), 1, 'Usuario administrador'),
('user1', crypt('5678', gen_salt('bf')), 1, 'Usuario operativo'),
('user2', crypt('9012', gen_salt('bf')), 0, 'Usuario bloqueado'),
('test', crypt('0000', gen_salt('bf')), 1, 'Usuario de pruebas')
ON CONFLICT (usuario) DO NOTHING;

-- ============================================
-- 3. STORED PROCEDURES
-- ============================================

-- SP 1: sp_firmausuario_list - Listar usuarios con filtros y paginación
-- ============================================
CREATE OR REPLACE FUNCTION informix.sp_firmausuario_list(
    p_usuario VARCHAR DEFAULT NULL,
    p_estado INTEGER DEFAULT NULL,
    p_sesion_activa INTEGER DEFAULT NULL,
    p_limite INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    usuario VARCHAR,
    pin VARCHAR,
    ultimo_acceso TIMESTAMP,
    sesion_activa BOOLEAN,
    intentos_fallidos INTEGER,
    estado INTEGER,
    observaciones TEXT,
    total_registros BIGINT
) AS $$
DECLARE
    total_count BIGINT;
BEGIN
    -- Obtener el conteo total para paginación
    SELECT COUNT(*) INTO total_count
    FROM informix.usuarios_autenticacion ua
    WHERE (p_usuario IS NULL OR ua.usuario ILIKE '%' || p_usuario || '%')
      AND (p_estado IS NULL OR ua.estado = p_estado)
      AND (p_sesion_activa IS NULL OR ua.sesion_activa = (p_sesion_activa = 1));

    -- Retornar los datos paginados con el total
    RETURN QUERY
    SELECT
        ua.id,
        ua.usuario,
        CASE WHEN ua.pin IS NOT NULL THEN '****' ELSE NULL END AS pin,
        ua.ultimo_acceso,
        ua.sesion_activa,
        ua.intentos_fallidos,
        ua.estado,
        ua.observaciones,
        total_count
    FROM informix.usuarios_autenticacion ua
    WHERE (p_usuario IS NULL OR ua.usuario ILIKE '%' || p_usuario || '%')
      AND (p_estado IS NULL OR ua.estado = p_estado)
      AND (p_sesion_activa IS NULL OR ua.sesion_activa = (p_sesion_activa = 1))
    ORDER BY ua.usuario
    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- SP 2: sp_firmausuario_mantener - CRUD para usuarios
-- ============================================
CREATE OR REPLACE FUNCTION informix.sp_firmausuario_mantener(
    p_operacion CHAR(1), -- 'I'=Insert, 'U'=Update, 'D'=Delete
    p_id INTEGER DEFAULT NULL,
    p_usuario VARCHAR DEFAULT NULL,
    p_pin VARCHAR DEFAULT NULL,
    p_estado INTEGER DEFAULT 1,
    p_reset_intentos INTEGER DEFAULT 0,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id INTEGER
) AS $$
DECLARE
    v_id INTEGER;
    v_exists INTEGER;
BEGIN
    IF p_operacion = 'I' THEN
        -- INSERT - Crear nuevo usuario
        IF p_usuario IS NULL OR p_pin IS NULL THEN
            RETURN QUERY SELECT FALSE, 'Usuario y PIN son requeridos'::TEXT, NULL::INTEGER;
            RETURN;
        END IF;

        -- Verificar si el usuario ya existe
        SELECT COUNT(*) INTO v_exists
        FROM informix.usuarios_autenticacion
        WHERE usuario = p_usuario;

        IF v_exists > 0 THEN
            RETURN QUERY SELECT FALSE, 'El usuario ya existe'::TEXT, NULL::INTEGER;
            RETURN;
        END IF;

        -- Insertar nuevo usuario con PIN hasheado
        INSERT INTO informix.usuarios_autenticacion (
            usuario, pin, estado, observaciones
        ) VALUES (
            p_usuario,
            crypt(p_pin, gen_salt('bf')),
            p_estado,
            p_observaciones
        ) RETURNING informix.usuarios_autenticacion.id INTO v_id;

        RETURN QUERY SELECT TRUE, 'Usuario creado correctamente'::TEXT, v_id;

    ELSIF p_operacion = 'U' THEN
        -- UPDATE - Actualizar usuario existente
        IF p_id IS NULL THEN
            RETURN QUERY SELECT FALSE, 'ID es requerido para actualizar'::TEXT, NULL::INTEGER;
            RETURN;
        END IF;

        -- Verificar si el usuario existe
        SELECT COUNT(*) INTO v_exists
        FROM informix.usuarios_autenticacion
        WHERE id = p_id;

        IF v_exists = 0 THEN
            RETURN QUERY SELECT FALSE, 'Usuario no encontrado'::TEXT, NULL::INTEGER;
            RETURN;
        END IF;

        -- Actualizar usuario
        UPDATE informix.usuarios_autenticacion
        SET
            usuario = COALESCE(p_usuario, usuario),
            pin = CASE
                WHEN p_pin IS NOT NULL THEN crypt(p_pin, gen_salt('bf'))
                ELSE pin
            END,
            estado = COALESCE(p_estado, estado),
            intentos_fallidos = CASE
                WHEN p_reset_intentos = 1 THEN 0
                ELSE intentos_fallidos
            END,
            observaciones = COALESCE(p_observaciones, observaciones),
            updated_at = NOW()
        WHERE id = p_id;

        RETURN QUERY SELECT TRUE, 'Usuario actualizado correctamente'::TEXT, p_id;

    ELSIF p_operacion = 'D' THEN
        -- DELETE - Eliminar usuario
        IF p_id IS NULL THEN
            RETURN QUERY SELECT FALSE, 'ID es requerido para eliminar'::TEXT, NULL::INTEGER;
            RETURN;
        END IF;

        -- Verificar si el usuario existe
        SELECT COUNT(*) INTO v_exists
        FROM informix.usuarios_autenticacion
        WHERE id = p_id;

        IF v_exists = 0 THEN
            RETURN QUERY SELECT FALSE, 'Usuario no encontrado'::TEXT, NULL::INTEGER;
            RETURN;
        END IF;

        -- Eliminar sesiones del usuario primero
        DELETE FROM informix.sesiones_usuarios
        WHERE usuario_autenticacion_id = p_id;

        -- Eliminar usuario
        DELETE FROM informix.usuarios_autenticacion
        WHERE id = p_id;

        RETURN QUERY SELECT TRUE, 'Usuario eliminado correctamente'::TEXT, p_id;

    ELSE
        RETURN QUERY SELECT FALSE, 'Operación no válida. Use I, U o D'::TEXT, NULL::INTEGER;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- SP 3: sp_firmausuario_autenticar - Autenticar usuario con PIN
-- ============================================
CREATE OR REPLACE FUNCTION informix.sp_firmausuario_autenticar(
    p_usuario VARCHAR,
    p_pin VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    autenticado BOOLEAN,
    usuario_id INTEGER,
    sesion_token VARCHAR
) AS $$
DECLARE
    v_usuario_record RECORD;
    v_pin_valido BOOLEAN := FALSE;
    v_token VARCHAR(255);
    v_sesion_id INTEGER;
BEGIN
    -- Buscar el usuario
    SELECT id, usuario, pin, estado, intentos_fallidos, sesion_activa
    INTO v_usuario_record
    FROM informix.usuarios_autenticacion
    WHERE usuario = p_usuario;

    -- Verificar si el usuario existe
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado'::TEXT, FALSE, NULL::INTEGER, NULL::VARCHAR;
        RETURN;
    END IF;

    -- Verificar si el usuario está bloqueado
    IF v_usuario_record.estado = 0 THEN
        RETURN QUERY SELECT FALSE, 'Usuario bloqueado'::TEXT, FALSE, v_usuario_record.id, NULL::VARCHAR;
        RETURN;
    END IF;

    -- Verificar si hay demasiados intentos fallidos
    IF v_usuario_record.intentos_fallidos >= 3 THEN
        -- Bloquear usuario automáticamente
        UPDATE informix.usuarios_autenticacion
        SET estado = 0, updated_at = NOW()
        WHERE id = v_usuario_record.id;

        RETURN QUERY SELECT FALSE, 'Usuario bloqueado por intentos fallidos'::TEXT, FALSE, v_usuario_record.id, NULL::VARCHAR;
        RETURN;
    END IF;

    -- Verificar PIN
    SELECT (v_usuario_record.pin = crypt(p_pin, v_usuario_record.pin)) INTO v_pin_valido;

    IF v_pin_valido THEN
        -- PIN correcto: resetear intentos fallidos y crear sesión

        -- Generar token único para la sesión
        v_token := 'sess_' || extract(epoch from now())::text || '_' || v_usuario_record.id::text;

        -- Cerrar sesiones anteriores
        UPDATE informix.sesiones_usuarios
        SET activa = FALSE, fecha_fin = NOW()
        WHERE usuario_autenticacion_id = v_usuario_record.id AND activa = TRUE;

        -- Crear nueva sesión
        INSERT INTO informix.sesiones_usuarios (
            usuario_autenticacion_id,
            ip_address,
            user_agent,
            token_sesion,
            activa
        ) VALUES (
            v_usuario_record.id,
            inet '127.0.0.1', -- Se podría pasar como parámetro
            'Sistema Web', -- Se podría pasar como parámetro
            v_token,
            TRUE
        ) RETURNING id INTO v_sesion_id;

        -- Actualizar usuario: resetear intentos, marcar sesión activa, último acceso
        UPDATE informix.usuarios_autenticacion
        SET
            intentos_fallidos = 0,
            sesion_activa = TRUE,
            ultimo_acceso = NOW(),
            updated_at = NOW()
        WHERE id = v_usuario_record.id;

        RETURN QUERY SELECT TRUE, 'Autenticación exitosa'::TEXT, TRUE, v_usuario_record.id, v_token;
    ELSE
        -- PIN incorrecto: incrementar intentos fallidos
        UPDATE informix.usuarios_autenticacion
        SET
            intentos_fallidos = intentos_fallidos + 1,
            updated_at = NOW()
        WHERE id = v_usuario_record.id;

        RETURN QUERY SELECT FALSE, 'PIN incorrecto'::TEXT, FALSE, v_usuario_record.id, NULL::VARCHAR;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- SP 4: sp_firmausuario_sesiones - Obtener historial de sesiones
-- ============================================
CREATE OR REPLACE FUNCTION informix.sp_firmausuario_sesiones(
    p_usuario VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    ip_address TEXT,
    user_agent TEXT,
    activa BOOLEAN,
    duracion_minutos INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id,
        s.fecha_inicio,
        s.fecha_fin,
        s.ip_address::TEXT,
        s.user_agent,
        s.activa,
        CASE
            WHEN s.fecha_fin IS NOT NULL THEN
                EXTRACT(EPOCH FROM (s.fecha_fin - s.fecha_inicio))::INTEGER / 60
            ELSE
                EXTRACT(EPOCH FROM (NOW() - s.fecha_inicio))::INTEGER / 60
        END AS duracion_minutos
    FROM informix.sesiones_usuarios s
    INNER JOIN informix.usuarios_autenticacion ua ON s.usuario_autenticacion_id = ua.id
    WHERE ua.usuario = p_usuario
    ORDER BY s.fecha_inicio DESC
    LIMIT 50; -- Limitar a las últimas 50 sesiones
END;
$$ LANGUAGE plpgsql;

-- SP 5: sp_firmausuario_cerrar_sesion - Cerrar sesión activa
-- ============================================
CREATE OR REPLACE FUNCTION informix.sp_firmausuario_cerrar_sesion(
    p_usuario VARCHAR,
    p_token_sesion VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_usuario_id INTEGER;
    v_sesiones_cerradas INTEGER := 0;
BEGIN
    -- Obtener ID del usuario
    SELECT id INTO v_usuario_id
    FROM informix.usuarios_autenticacion
    WHERE usuario = p_usuario;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado'::TEXT;
        RETURN;
    END IF;

    -- Cerrar sesiones (específica por token o todas las activas)
    IF p_token_sesion IS NOT NULL THEN
        -- Cerrar sesión específica
        UPDATE informix.sesiones_usuarios
        SET activa = FALSE, fecha_fin = NOW()
        WHERE usuario_autenticacion_id = v_usuario_id
          AND token_sesion = p_token_sesion
          AND activa = TRUE;
        GET DIAGNOSTICS v_sesiones_cerradas = ROW_COUNT;
    ELSE
        -- Cerrar todas las sesiones activas del usuario
        UPDATE informix.sesiones_usuarios
        SET activa = FALSE, fecha_fin = NOW()
        WHERE usuario_autenticacion_id = v_usuario_id
          AND activa = TRUE;
        GET DIAGNOSTICS v_sesiones_cerradas = ROW_COUNT;
    END IF;

    -- Actualizar estado de sesión en usuarios_autenticacion
    UPDATE informix.usuarios_autenticacion
    SET sesion_activa = FALSE, updated_at = NOW()
    WHERE id = v_usuario_id;

    IF v_sesiones_cerradas > 0 THEN
        RETURN QUERY SELECT TRUE, format('Se cerraron %s sesiones', v_sesiones_cerradas)::TEXT;
    ELSE
        RETURN QUERY SELECT TRUE, 'No había sesiones activas'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 4. GRANT PERMISSIONS
-- ============================================

-- Otorgar permisos sobre las tablas
GRANT SELECT, INSERT, UPDATE, DELETE ON informix.usuarios_autenticacion TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON informix.sesiones_usuarios TO PUBLIC;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA informix TO PUBLIC;

-- Otorgar permisos sobre las funciones
GRANT EXECUTE ON FUNCTION informix.sp_firmausuario_list TO PUBLIC;
GRANT EXECUTE ON FUNCTION informix.sp_firmausuario_mantener TO PUBLIC;
GRANT EXECUTE ON FUNCTION informix.sp_firmausuario_autenticar TO PUBLIC;
GRANT EXECUTE ON FUNCTION informix.sp_firmausuario_sesiones TO PUBLIC;
GRANT EXECUTE ON FUNCTION informix.sp_firmausuario_cerrar_sesion TO PUBLIC;

-- ============================================
-- 5. QUERIES DE VALIDACIÓN
-- ============================================

-- Validar estructura de tablas
SELECT 'usuarios_autenticacion' as tabla, COUNT(*) as total_registros
FROM informix.usuarios_autenticacion
UNION ALL
SELECT 'sesiones_usuarios' as tabla, COUNT(*) as total_registros
FROM informix.sesiones_usuarios;

-- Test de funciones
SELECT 'Test sp_firmausuario_list' as test;
SELECT * FROM informix.sp_firmausuario_list();

SELECT 'Test sp_firmausuario_autenticar' as test;
SELECT * FROM informix.sp_firmausuario_autenticar('admin', '1234');

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================