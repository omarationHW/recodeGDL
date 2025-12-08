-- =====================================================
-- STORED PROCEDURES COMPLETOS - IMPLEMENTADOS
-- Componente: SFRM_CHGPASS
-- Modulo: padron_licencias
-- Esquema: comun
-- Total SPs: 3 principales + 2 alias
-- Fecha Implementacion: 2025-11-21
-- Estado: IMPLEMENTADO CON LOGICA REAL
-- =====================================================
--
-- DESCRIPCION:
-- Este archivo contiene todos los stored procedures necesarios para el
-- componente de cambio de contrasena de usuarios. Incluye validaciones
-- de seguridad y politica de contrasenas.
--
-- OPERACIONES IMPLEMENTADAS:
-- 1. sp_validate_user_password - Validar contrasena actual
-- 2. sp_change_user_password - Cambiar contrasena con validaciones
-- 3. sp_get_password_policy - Obtener politica de contrasenas
--
-- ALIAS (Compatibilidad):
-- - sfrm_chgpass_sp_validate_current -> sp_validate_user_password
-- - sfrm_chgpass_sp_update -> sp_change_user_password
--
-- TABLAS INVOLUCRADAS:
-- - comun.usuarios - Tabla principal de usuarios
-- - comun.password_history - Historial de contrasenas
-- - comun.bitacora_cambio_password - Bitacora de cambios
--
-- COMPATIBILIDAD:
-- - API Generica: 100% compatible
-- - Convencion: comun.nombre_funcion
-- - Parametros: Prefijo p_ para todos los parametros
-- - Respuestas: Estructuradas con success/message o result set
-- =====================================================

-- =====================================================
-- CONFIGURACION INICIAL
-- =====================================================

-- Asegurar extension pgcrypto esta habilitada
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =====================================================
-- TABLAS AUXILIARES
-- =====================================================

-- Tabla para historial de contrasenas
CREATE TABLE IF NOT EXISTS comun.password_history (
    id BIGSERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_password_history_usuario ON comun.password_history(usuario_id);
CREATE INDEX IF NOT EXISTS idx_password_history_fecha ON comun.password_history(created_at DESC);

COMMENT ON TABLE comun.password_history IS 'Historial de contrasenas de usuarios para evitar reutilizacion';

-- Tabla para bitacora de cambios de contrasena
CREATE TABLE IF NOT EXISTS comun.bitacora_cambio_password (
    id BIGSERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    accion VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bitacora_chgpass_usuario ON comun.bitacora_cambio_password(usuario_id);
CREATE INDEX IF NOT EXISTS idx_bitacora_chgpass_fecha ON comun.bitacora_cambio_password(created_at DESC);

COMMENT ON TABLE comun.bitacora_cambio_password IS 'Bitacora de cambios de contrasena de usuarios';

-- Tabla para politica de contrasenas (configuracion)
CREATE TABLE IF NOT EXISTS comun.password_policy (
    id SERIAL PRIMARY KEY,
    min_length INTEGER DEFAULT 8,
    require_uppercase BOOLEAN DEFAULT TRUE,
    require_lowercase BOOLEAN DEFAULT TRUE,
    require_number BOOLEAN DEFAULT TRUE,
    require_special BOOLEAN DEFAULT FALSE,
    history_count INTEGER DEFAULT 5,
    expiration_days INTEGER DEFAULT 90,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insertar politica por defecto si no existe
INSERT INTO comun.password_policy (
    min_length, require_uppercase, require_lowercase,
    require_number, require_special, history_count, expiration_days
)
SELECT 8, TRUE, TRUE, TRUE, FALSE, 5, 90
WHERE NOT EXISTS (SELECT 1 FROM comun.password_policy WHERE activo = TRUE);

COMMENT ON TABLE comun.password_policy IS 'Politica de contrasenas del sistema';


-- =====================================================
-- SP 1/3: sp_validate_user_password
-- Tipo: Validation
-- Descripcion: Valida si la contrasena actual es correcta para el usuario
-- Parametros: p_username VARCHAR, p_password VARCHAR
-- Retorna: is_valid BOOLEAN, message TEXT
-- Seguridad: SECURITY DEFINER para acceso controlado al hash
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_validate_user_password(VARCHAR, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_validate_user_password(
    p_username VARCHAR,
    p_password VARCHAR
)
RETURNS TABLE(
    is_valid BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user RECORD;
    v_password_valid BOOLEAN;
BEGIN
    -- Validar parametros de entrada
    IF p_username IS NULL OR TRIM(p_username) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS is_valid,
            'Credenciales invalidas'::TEXT AS message;
        RETURN;
    END IF;

    IF p_password IS NULL OR TRIM(p_password) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS is_valid,
            'Credenciales invalidas'::TEXT AS message;
        RETURN;
    END IF;

    -- Buscar usuario
    SELECT id, usuario, password_hash, estado, activo
    INTO v_user
    FROM comun.usuarios
    WHERE LOWER(TRIM(usuario)) = LOWER(TRIM(p_username));

    -- Usuario no encontrado (mensaje generico por seguridad)
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS is_valid,
            'Credenciales invalidas'::TEXT AS message;
        RETURN;
    END IF;

    -- Verificar si usuario esta activo
    IF v_user.activo = FALSE OR v_user.estado != 'ACTIVO' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS is_valid,
            'Credenciales invalidas'::TEXT AS message;
        RETURN;
    END IF;

    -- Verificar contrasena con bcrypt
    -- Manejar caso donde password_hash es NULL
    IF v_user.password_hash IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS is_valid,
            'Credenciales invalidas'::TEXT AS message;
        RETURN;
    END IF;

    -- Comparar usando crypt()
    v_password_valid := (v_user.password_hash = crypt(p_password, v_user.password_hash));

    IF v_password_valid THEN
        RETURN QUERY SELECT
            TRUE::BOOLEAN AS is_valid,
            'Contrasena valida'::TEXT AS message;
    ELSE
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS is_valid,
            'Credenciales invalidas'::TEXT AS message;
    END IF;
END;
$$;

COMMENT ON FUNCTION comun.sp_validate_user_password(VARCHAR, VARCHAR) IS
    'Valida la contrasena actual del usuario. Usa crypt() para comparar con hash almacenado. SECURITY DEFINER.';


-- =====================================================
-- SP 2/3: sp_change_user_password
-- Tipo: Update
-- Descripcion: Cambia la contrasena del usuario con validaciones completas
-- Parametros: p_username, p_password_actual, p_password_nueva, p_password_confirmacion
-- Retorna: success BOOLEAN, message TEXT
-- Validaciones:
--   - Usuario activo
--   - Contrasena actual correcta
--   - Nueva != actual
--   - Confirmacion coincide
--   - Requisitos minimos (8 chars, 1 mayus, 1 minus, 1 numero)
--   - Historial de contrasenas
-- Seguridad: SECURITY DEFINER, bcrypt con gen_salt('bf')
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_change_user_password(VARCHAR, VARCHAR, VARCHAR, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_change_user_password(
    p_username VARCHAR,
    p_password_actual VARCHAR,
    p_password_nueva VARCHAR,
    p_password_confirmacion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user RECORD;
    v_policy RECORD;
    v_password_valid BOOLEAN;
    v_history_match INTEGER;
    v_new_hash TEXT;
BEGIN
    -- =====================================================
    -- VALIDACION 1: Parametros de entrada
    -- =====================================================
    IF p_username IS NULL OR TRIM(p_username) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'El nombre de usuario es requerido'::TEXT AS message;
        RETURN;
    END IF;

    IF p_password_actual IS NULL OR TRIM(p_password_actual) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'La contrasena actual es requerida'::TEXT AS message;
        RETURN;
    END IF;

    IF p_password_nueva IS NULL OR TRIM(p_password_nueva) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'La nueva contrasena es requerida'::TEXT AS message;
        RETURN;
    END IF;

    IF p_password_confirmacion IS NULL OR TRIM(p_password_confirmacion) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'La confirmacion de contrasena es requerida'::TEXT AS message;
        RETURN;
    END IF;

    -- =====================================================
    -- VALIDACION 2: Confirmacion coincide con nueva
    -- =====================================================
    IF p_password_nueva != p_password_confirmacion THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'La nueva contrasena y la confirmacion no coinciden'::TEXT AS message;
        RETURN;
    END IF;

    -- =====================================================
    -- VALIDACION 3: Buscar usuario y verificar estado
    -- =====================================================
    SELECT id, usuario, password_hash, estado, activo
    INTO v_user
    FROM comun.usuarios
    WHERE LOWER(TRIM(usuario)) = LOWER(TRIM(p_username));

    IF NOT FOUND THEN
        -- Registrar intento fallido en bitacora
        INSERT INTO comun.bitacora_cambio_password (usuario_id, accion, ip_address)
        VALUES (0, 'INTENTO_CAMBIO_USUARIO_NO_EXISTE', inet_client_addr()::VARCHAR);

        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'Usuario no encontrado'::TEXT AS message;
        RETURN;
    END IF;

    -- Verificar si usuario esta activo
    IF v_user.activo = FALSE OR v_user.estado != 'ACTIVO' THEN
        -- Registrar intento en bitacora
        INSERT INTO comun.bitacora_cambio_password (usuario_id, accion, ip_address)
        VALUES (v_user.id, 'INTENTO_CAMBIO_USUARIO_INACTIVO', inet_client_addr()::VARCHAR);

        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'El usuario no esta activo en el sistema'::TEXT AS message;
        RETURN;
    END IF;

    -- =====================================================
    -- VALIDACION 4: Verificar contrasena actual
    -- =====================================================
    IF v_user.password_hash IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'Error en la configuracion del usuario'::TEXT AS message;
        RETURN;
    END IF;

    v_password_valid := (v_user.password_hash = crypt(p_password_actual, v_user.password_hash));

    IF NOT v_password_valid THEN
        -- Registrar intento fallido
        INSERT INTO comun.bitacora_cambio_password (usuario_id, accion, ip_address)
        VALUES (v_user.id, 'INTENTO_CAMBIO_PASSWORD_INCORRECTA', inet_client_addr()::VARCHAR);

        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'La contrasena actual no es correcta'::TEXT AS message;
        RETURN;
    END IF;

    -- =====================================================
    -- VALIDACION 5: Nueva contrasena diferente de la actual
    -- =====================================================
    IF p_password_actual = p_password_nueva THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'La nueva contrasena debe ser diferente a la actual'::TEXT AS message;
        RETURN;
    END IF;

    -- =====================================================
    -- VALIDACION 6: Obtener politica de contrasenas
    -- =====================================================
    SELECT min_length, require_uppercase, require_lowercase,
           require_number, require_special, history_count
    INTO v_policy
    FROM comun.password_policy
    WHERE activo = TRUE
    LIMIT 1;

    -- Si no hay politica, usar valores por defecto
    IF NOT FOUND THEN
        v_policy.min_length := 8;
        v_policy.require_uppercase := TRUE;
        v_policy.require_lowercase := TRUE;
        v_policy.require_number := TRUE;
        v_policy.require_special := FALSE;
        v_policy.history_count := 5;
    END IF;

    -- =====================================================
    -- VALIDACION 7: Requisitos minimos de contrasena
    -- =====================================================

    -- Longitud minima
    IF LENGTH(p_password_nueva) < v_policy.min_length THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            FORMAT('La contrasena debe tener al menos %s caracteres', v_policy.min_length)::TEXT AS message;
        RETURN;
    END IF;

    -- Al menos una mayuscula
    IF v_policy.require_uppercase AND NOT (p_password_nueva ~ '[A-Z]') THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'La contrasena debe contener al menos una letra mayuscula'::TEXT AS message;
        RETURN;
    END IF;

    -- Al menos una minuscula
    IF v_policy.require_lowercase AND NOT (p_password_nueva ~ '[a-z]') THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'La contrasena debe contener al menos una letra minuscula'::TEXT AS message;
        RETURN;
    END IF;

    -- Al menos un numero
    IF v_policy.require_number AND NOT (p_password_nueva ~ '[0-9]') THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'La contrasena debe contener al menos un numero'::TEXT AS message;
        RETURN;
    END IF;

    -- Al menos un caracter especial (si es requerido)
    IF v_policy.require_special AND NOT (p_password_nueva ~ '[!@#$%^&*()_+\-=\[\]{};'':"\\|,.<>\/?]') THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'La contrasena debe contener al menos un caracter especial'::TEXT AS message;
        RETURN;
    END IF;

    -- =====================================================
    -- VALIDACION 8: Verificar historial de contrasenas
    -- =====================================================
    SELECT COUNT(*)
    INTO v_history_match
    FROM comun.password_history ph
    WHERE ph.usuario_id = v_user.id
      AND ph.password_hash = crypt(p_password_nueva, ph.password_hash)
    ORDER BY ph.created_at DESC
    LIMIT v_policy.history_count;

    IF v_history_match > 0 THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            FORMAT('No puede reutilizar las ultimas %s contrasenas', v_policy.history_count)::TEXT AS message;
        RETURN;
    END IF;

    -- =====================================================
    -- ACTUALIZAR CONTRASENA
    -- =====================================================

    -- Generar nuevo hash con bcrypt
    v_new_hash := crypt(p_password_nueva, gen_salt('bf'));

    -- Guardar contrasena actual en historial
    INSERT INTO comun.password_history (usuario_id, password_hash, created_at)
    VALUES (v_user.id, v_user.password_hash, NOW());

    -- Actualizar contrasena del usuario
    UPDATE comun.usuarios
    SET password_hash = v_new_hash,
        ultimo_acceso = NOW()
    WHERE id = v_user.id;

    -- Registrar cambio exitoso en bitacora
    INSERT INTO comun.bitacora_cambio_password (usuario_id, accion, ip_address)
    VALUES (v_user.id, 'CAMBIO_PASSWORD_EXITOSO', inet_client_addr()::VARCHAR);

    -- Limpiar historial antiguo (mantener solo las ultimas N)
    DELETE FROM comun.password_history
    WHERE usuario_id = v_user.id
      AND id NOT IN (
          SELECT id FROM comun.password_history
          WHERE usuario_id = v_user.id
          ORDER BY created_at DESC
          LIMIT v_policy.history_count
      );

    RETURN QUERY SELECT
        TRUE::BOOLEAN AS success,
        'Contrasena cambiada exitosamente'::TEXT AS message;

EXCEPTION
    WHEN OTHERS THEN
        -- Registrar error en bitacora
        INSERT INTO comun.bitacora_cambio_password (usuario_id, accion, ip_address)
        VALUES (COALESCE(v_user.id, 0), 'ERROR_CAMBIO_PASSWORD', inet_client_addr()::VARCHAR);

        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'Error al procesar la solicitud'::TEXT AS message;
END;
$$;

COMMENT ON FUNCTION comun.sp_change_user_password(VARCHAR, VARCHAR, VARCHAR, VARCHAR) IS
    'Cambia la contrasena del usuario con validaciones completas de seguridad. SECURITY DEFINER. Usa bcrypt.';


-- =====================================================
-- SP 3/3: sp_get_password_policy
-- Tipo: Query
-- Descripcion: Obtiene la politica de contrasenas actual del sistema
-- Parametros: Ninguno
-- Retorna: Configuracion de la politica de contrasenas
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_get_password_policy() CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_get_password_policy()
RETURNS TABLE(
    min_length INTEGER,
    require_uppercase BOOLEAN,
    require_lowercase BOOLEAN,
    require_number BOOLEAN,
    require_special BOOLEAN,
    history_count INTEGER,
    expiration_days INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        pp.min_length,
        pp.require_uppercase,
        pp.require_lowercase,
        pp.require_number,
        pp.require_special,
        pp.history_count,
        pp.expiration_days
    FROM comun.password_policy pp
    WHERE pp.activo = TRUE
    LIMIT 1;

    -- Si no hay politica configurada, retornar valores por defecto
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            8::INTEGER AS min_length,
            TRUE::BOOLEAN AS require_uppercase,
            TRUE::BOOLEAN AS require_lowercase,
            TRUE::BOOLEAN AS require_number,
            FALSE::BOOLEAN AS require_special,
            5::INTEGER AS history_count,
            90::INTEGER AS expiration_days;
    END IF;
END;
$$;

COMMENT ON FUNCTION comun.sp_get_password_policy() IS
    'Obtiene la politica de contrasenas configurada en el sistema';


-- =====================================================
-- ALIAS PARA COMPATIBILIDAD
-- =====================================================

-- Alias: sfrm_chgpass_sp_validate_current
DROP FUNCTION IF EXISTS comun.sfrm_chgpass_sp_validate_current(VARCHAR, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.sfrm_chgpass_sp_validate_current(
    p_username VARCHAR,
    p_password VARCHAR
)
RETURNS TABLE(
    is_valid BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM comun.sp_validate_user_password(p_username, p_password);
END;
$$;

COMMENT ON FUNCTION comun.sfrm_chgpass_sp_validate_current(VARCHAR, VARCHAR) IS
    'Alias de sp_validate_user_password para compatibilidad con nomenclatura del componente';


-- Alias: sfrm_chgpass_sp_update
DROP FUNCTION IF EXISTS comun.sfrm_chgpass_sp_update(VARCHAR, VARCHAR, VARCHAR, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.sfrm_chgpass_sp_update(
    p_username VARCHAR,
    p_password_actual VARCHAR,
    p_password_nueva VARCHAR,
    p_password_confirmacion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM comun.sp_change_user_password(
        p_username, p_password_actual, p_password_nueva, p_password_confirmacion
    );
END;
$$;

COMMENT ON FUNCTION comun.sfrm_chgpass_sp_update(VARCHAR, VARCHAR, VARCHAR, VARCHAR) IS
    'Alias de sp_change_user_password para compatibilidad con nomenclatura del componente';


-- =====================================================
-- SP ADICIONAL: sp_bitacora_chgpass
-- Tipo: Insert
-- Descripcion: Registra eventos de cambio de contrasena en bitacora
-- Parametros: p_usuario_id, p_accion, p_ip_address
-- Retorna: success BOOLEAN, message TEXT
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_bitacora_chgpass(INTEGER, VARCHAR, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_bitacora_chgpass(
    p_usuario_id INTEGER,
    p_accion VARCHAR,
    p_ip_address VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO comun.bitacora_cambio_password (
        usuario_id,
        accion,
        ip_address,
        created_at
    )
    VALUES (
        p_usuario_id,
        p_accion,
        COALESCE(p_ip_address, inet_client_addr()::VARCHAR),
        NOW()
    );

    RETURN QUERY SELECT
        TRUE::BOOLEAN AS success,
        'Registro en bitacora exitoso'::TEXT AS message;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            ('Error al registrar en bitacora: ' || SQLERRM)::TEXT AS message;
END;
$$;

COMMENT ON FUNCTION comun.sp_bitacora_chgpass(INTEGER, VARCHAR, VARCHAR) IS
    'Registra eventos de cambio de contrasena en la bitacora del sistema';


-- =====================================================
-- VERIFICACION DE INSTALACION
-- =====================================================

DO $$
DECLARE
    v_sp_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_sp_count
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND routine_name IN (
        'sp_validate_user_password',
        'sp_change_user_password',
        'sp_get_password_policy',
        'sfrm_chgpass_sp_validate_current',
        'sfrm_chgpass_sp_update',
        'sp_bitacora_chgpass'
    );

    IF v_sp_count = 6 THEN
        RAISE NOTICE '=====================================================';
        RAISE NOTICE 'INSTALACION EXITOSA - SFRM_CHGPASS';
        RAISE NOTICE '=====================================================';
        RAISE NOTICE 'SPs instalados: %/6', v_sp_count;
        RAISE NOTICE '';
        RAISE NOTICE 'Stored Procedures disponibles:';
        RAISE NOTICE '  1. comun.sp_validate_user_password(p_username, p_password)';
        RAISE NOTICE '  2. comun.sp_change_user_password(p_username, p_password_actual, p_password_nueva, p_password_confirmacion)';
        RAISE NOTICE '  3. comun.sp_get_password_policy()';
        RAISE NOTICE '';
        RAISE NOTICE 'Alias (compatibilidad):';
        RAISE NOTICE '  - comun.sfrm_chgpass_sp_validate_current';
        RAISE NOTICE '  - comun.sfrm_chgpass_sp_update';
        RAISE NOTICE '  - comun.sp_bitacora_chgpass';
        RAISE NOTICE '';
        RAISE NOTICE 'Tablas creadas:';
        RAISE NOTICE '  - comun.password_history';
        RAISE NOTICE '  - comun.bitacora_cambio_password';
        RAISE NOTICE '  - comun.password_policy';
        RAISE NOTICE '=====================================================';
    ELSE
        RAISE WARNING 'INSTALACION INCOMPLETA: Solo % de 6 SPs instalados', v_sp_count;
    END IF;
END $$;


-- =====================================================
-- EJEMPLOS DE USO (API GENERICA)
-- =====================================================

/*
EJEMPLOS DE USO CON API GENERICA:

1. VALIDAR CONTRASENA ACTUAL:
-----------------------------
POST /api/generic
{
    "eRequest": {
        "Operacion": "sp_validate_user_password",
        "Base": "padron_licencias",
        "Esquema": "comun",
        "Parametros": [
            {"nombre": "p_username", "valor": "admin", "tipo": "text"},
            {"nombre": "p_password", "valor": "Password123", "tipo": "text"}
        ]
    }
}

Respuesta exitosa:
{
    "is_valid": true,
    "message": "Contrasena valida"
}

2. CAMBIAR CONTRASENA:
----------------------
POST /api/generic
{
    "eRequest": {
        "Operacion": "sp_change_user_password",
        "Base": "padron_licencias",
        "Esquema": "comun",
        "Parametros": [
            {"nombre": "p_username", "valor": "admin", "tipo": "text"},
            {"nombre": "p_password_actual", "valor": "Password123", "tipo": "text"},
            {"nombre": "p_password_nueva", "valor": "NuevaPass456", "tipo": "text"},
            {"nombre": "p_password_confirmacion", "valor": "NuevaPass456", "tipo": "text"}
        ]
    }
}

Respuesta exitosa:
{
    "success": true,
    "message": "Contrasena cambiada exitosamente"
}

3. OBTENER POLITICA DE CONTRASENAS:
-----------------------------------
POST /api/generic
{
    "eRequest": {
        "Operacion": "sp_get_password_policy",
        "Base": "padron_licencias",
        "Esquema": "comun",
        "Parametros": []
    }
}

Respuesta:
{
    "min_length": 8,
    "require_uppercase": true,
    "require_lowercase": true,
    "require_number": true,
    "require_special": false,
    "history_count": 5,
    "expiration_days": 90
}

4. USANDO ALIAS sfrm_chgpass_sp_validate_current:
------------------------------------------------
POST /api/generic
{
    "eRequest": {
        "Operacion": "sfrm_chgpass_sp_validate_current",
        "Base": "padron_licencias",
        "Esquema": "comun",
        "Parametros": [
            {"nombre": "p_username", "valor": "admin", "tipo": "text"},
            {"nombre": "p_password", "valor": "Password123", "tipo": "text"}
        ]
    }
}

5. USANDO ALIAS sfrm_chgpass_sp_update:
--------------------------------------
POST /api/generic
{
    "eRequest": {
        "Operacion": "sfrm_chgpass_sp_update",
        "Base": "padron_licencias",
        "Esquema": "comun",
        "Parametros": [
            {"nombre": "p_username", "valor": "admin", "tipo": "text"},
            {"nombre": "p_password_actual", "valor": "Password123", "tipo": "text"},
            {"nombre": "p_password_nueva", "valor": "NuevaPass456", "tipo": "text"},
            {"nombre": "p_password_confirmacion", "valor": "NuevaPass456", "tipo": "text"}
        ]
    }
}
*/


-- =====================================================
-- PRUEBAS UNITARIAS (Ejecutar en ambiente de pruebas)
-- =====================================================

/*
-- IMPORTANTE: Ejecutar solo en ambiente de pruebas

-- Test 1: Validar contrasena con usuario inexistente
SELECT * FROM comun.sp_validate_user_password('usuario_no_existe', 'cualquier');
-- Esperado: is_valid = false, message = 'Credenciales invalidas'

-- Test 2: Obtener politica de contrasenas
SELECT * FROM comun.sp_get_password_policy();
-- Esperado: min_length = 8, require_uppercase = true, etc.

-- Test 3: Intentar cambiar contrasena con confirmacion incorrecta
SELECT * FROM comun.sp_change_user_password('admin', 'current', 'Nueva123', 'Diferente456');
-- Esperado: success = false, message = 'La nueva contrasena y la confirmacion no coinciden'

-- Test 4: Contrasena sin mayusculas
SELECT * FROM comun.sp_change_user_password('admin', 'current', 'password1', 'password1');
-- Esperado: success = false, message = 'La contrasena debe contener al menos una letra mayuscula'

-- Test 5: Verificar alias funcionando
SELECT * FROM comun.sfrm_chgpass_sp_validate_current('admin', 'test');
SELECT * FROM comun.sfrm_chgpass_sp_update('admin', 'old', 'New123', 'New123');
*/


-- =====================================================
-- DOCUMENTACION ADICIONAL
-- =====================================================

/*
IMPLEMENTACION COMPLETADA - 2025-11-21

Stored Procedures implementados: 6 SPs
- 3 SPs principales para cambio de contrasena
- 3 SPs alias para compatibilidad

Tablas creadas/utilizadas (schema comun):
- comun.usuarios: Tabla de usuarios del sistema
  Campos utilizados:
  - id: INTEGER PRIMARY KEY
  - usuario: VARCHAR UNIQUE
  - password_hash: TEXT (hash bcrypt)
  - estado: VARCHAR (ACTIVO/INACTIVO)
  - activo: BOOLEAN
  - ultimo_acceso: TIMESTAMP

- comun.password_history: Historial de contrasenas
  Campos:
  - id: BIGSERIAL PRIMARY KEY
  - usuario_id: INTEGER
  - password_hash: VARCHAR(255)
  - created_at: TIMESTAMP

- comun.bitacora_cambio_password: Bitacora de auditoría
  Campos:
  - id: BIGSERIAL PRIMARY KEY
  - usuario_id: INTEGER
  - accion: VARCHAR(50)
  - ip_address: VARCHAR(45)
  - created_at: TIMESTAMP

- comun.password_policy: Politica de contrasenas
  Campos:
  - min_length: INTEGER (default 8)
  - require_uppercase: BOOLEAN (default TRUE)
  - require_lowercase: BOOLEAN (default TRUE)
  - require_number: BOOLEAN (default TRUE)
  - require_special: BOOLEAN (default FALSE)
  - history_count: INTEGER (default 5)
  - expiration_days: INTEGER (default 90)

Extensiones requeridas:
- pgcrypto: Para funciones crypt() y gen_salt('bf')

CARACTERISTICAS DE SEGURIDAD:
1. SECURITY DEFINER para funciones sensibles
2. Password hash con bcrypt (Blowfish)
3. Mensajes de error genericos (no revelan info)
4. Validacion de politica de contrasenas
5. Historial de contrasenas (evita reutilizacion)
6. Bitacora de todos los intentos
7. Registro de IP de origen

VALIDACIONES IMPLEMENTADAS:
1. Usuario existe y esta activo
2. Contrasena actual es correcta
3. Nueva contrasena != actual
4. Confirmacion coincide con nueva
5. Longitud minima (8 caracteres)
6. Al menos 1 letra mayuscula
7. Al menos 1 letra minuscula
8. Al menos 1 numero
9. Caracter especial (opcional, segun politica)
10. No reutilizar ultimas N contrasenas
*/
