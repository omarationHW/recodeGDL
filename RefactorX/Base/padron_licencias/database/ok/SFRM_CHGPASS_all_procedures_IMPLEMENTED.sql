-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- Habilitar extensión pgcrypto si no existe
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================
-- STORED PROCEDURES PARA CAMBIO DE CONTRASEÑA
-- Convención: sp_change_password_XXX
-- Implementado: 2025-11-20
-- Tablas: users (o usuarios)
-- Módulo: SFRM_CHGPASS (Prioridad Alta)
-- ============================================

-- ============================================
-- SP 1/2: sp_validate_user_password
-- Tipo: Validation
-- Descripción: Valida si la contraseña actual es correcta para el usuario
-- API Compatible: RETURNS TABLE
-- SECURITY DEFINER: Para acceso controlado a password_hash
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_validate_user_password(
    p_username TEXT,
    p_password TEXT
)
RETURNS TABLE(
    is_valid BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT (u.password_hash = crypt(p_password, u.password_hash)) AS is_valid
    FROM users u
    WHERE u.username = p_username;

    -- Si no encuentra el usuario, retornar FALSE
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE AS is_valid;
    END IF;
END;
$$;

COMMENT ON FUNCTION public.sp_validate_user_password(TEXT, TEXT) IS 'Valida contraseña actual de usuario';

-- ============================================
-- SP 2/2: sp_change_user_password
-- Tipo: Update
-- Descripción: Cambia la contraseña del usuario con validaciones de negocio
-- API Compatible: RETURNS TABLE
-- SECURITY DEFINER: Para actualización segura de password
-- Validaciones:
--   - Usuario existe
--   - Contraseña actual es correcta
--   - Nueva contraseña != actual
--   - Primeros 3 caracteres diferentes
--   - Formato: letras + números, 6-8 caracteres
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_change_user_password(
    p_username TEXT,
    p_current_password TEXT,
    p_new_password TEXT
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
BEGIN
    -- 1. Verificar que el usuario existe
    SELECT * INTO v_user FROM users WHERE username = p_username;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            FALSE AS success,
            'Usuario no encontrado'::TEXT AS message;
        RETURN;
    END IF;

    -- 2. Validar contraseña actual
    IF v_user.password_hash <> crypt(p_current_password, v_user.password_hash) THEN
        RETURN QUERY
        SELECT
            FALSE AS success,
            'La clave actual no es correcta'::TEXT AS message;
        RETURN;
    END IF;

    -- 3. Validar que nueva contraseña sea diferente de la actual
    IF p_current_password = p_new_password THEN
        RETURN QUERY
        SELECT
            FALSE AS success,
            'La nueva clave no debe ser igual a la actual'::TEXT AS message;
        RETURN;
    END IF;

    -- 4. Validar que los primeros 3 caracteres sean diferentes
    IF substring(p_current_password from 1 for 3) = substring(p_new_password from 1 for 3) THEN
        RETURN QUERY
        SELECT
            FALSE AS success,
            'Los tres primeros caracteres deben ser diferentes a la clave actual'::TEXT AS message;
        RETURN;
    END IF;

    -- 5. Validar formato de nueva contraseña
    -- Debe contener letras y números, 6-8 caracteres
    IF NOT (p_new_password ~ '^(?=.*[a-z])(?=.*[0-9])[a-z0-9]{6,8}$') THEN
        RETURN QUERY
        SELECT
            FALSE AS success,
            'La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres'::TEXT AS message;
        RETURN;
    END IF;

    -- 6. Actualizar la contraseña
    UPDATE users
    SET password_hash = crypt(p_new_password, gen_salt('bf')),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE username = p_username;

    -- 7. Registrar en bitácora (opcional)
    INSERT INTO bitacora_cambio_password (username, fecha_cambio, ip_origen)
    VALUES (p_username, CURRENT_TIMESTAMP, inet_client_addr())
    ON CONFLICT DO NOTHING;

    RETURN QUERY
    SELECT
        TRUE AS success,
        'Clave cambiada exitosamente'::TEXT AS message;
END;
$$;

COMMENT ON FUNCTION public.sp_change_user_password(TEXT, TEXT, TEXT) IS 'Cambia contraseña de usuario con validaciones completas';

-- ============================================
-- FUNCIONES ADICIONALES PARA BITÁCORA
-- ============================================

-- SP ADICIONAL: sp_bitacora_chgpass
-- Registra cambios de contraseña en bitácora
CREATE OR REPLACE FUNCTION public.sp_bitacora_chgpass(
    p_username TEXT,
    p_accion TEXT,
    p_resultado TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO bitacora_cambio_password (
        username,
        accion,
        resultado,
        fecha_registro,
        ip_origen
    )
    VALUES (
        p_username,
        p_accion,
        p_resultado,
        CURRENT_TIMESTAMP,
        inet_client_addr()
    );

    RETURN QUERY
    SELECT
        TRUE AS success,
        'Registro en bitácora exitoso'::TEXT AS message;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE AS success,
            'Error al registrar en bitácora: ' || SQLERRM AS message;
END;
$$;

COMMENT ON FUNCTION public.sp_bitacora_chgpass(TEXT, TEXT, TEXT) IS 'Registra cambios de contraseña en bitácora';

-- ============================================
-- ALIASES PARA COMPATIBILIDAD
-- ============================================

-- Alias: validate_user_password (sin prefijo sp_)
CREATE OR REPLACE FUNCTION public.validate_user_password(
    p_username TEXT,
    p_password TEXT
)
RETURNS TABLE(
    is_valid BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.sp_validate_user_password(p_username, p_password);
END;
$$;

COMMENT ON FUNCTION public.validate_user_password(TEXT, TEXT) IS 'Alias de sp_validate_user_password';

-- Alias: change_user_password (sin prefijo sp_)
CREATE OR REPLACE FUNCTION public.change_user_password(
    p_username TEXT,
    p_current_password TEXT,
    p_new_password TEXT
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
    SELECT * FROM public.sp_change_user_password(p_username, p_current_password, p_new_password);
END;
$$;

COMMENT ON FUNCTION public.change_user_password(TEXT, TEXT, TEXT) IS 'Alias de sp_change_user_password';

-- Alias: sfrm_chgpass_sp_update (Para compatibilidad con nomenclatura)
CREATE OR REPLACE FUNCTION public.sfrm_chgpass_sp_update(
    p_username TEXT,
    p_current_password TEXT,
    p_new_password TEXT
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
    SELECT * FROM public.sp_change_user_password(p_username, p_current_password, p_new_password);
END;
$$;

COMMENT ON FUNCTION public.sfrm_chgpass_sp_update(TEXT, TEXT, TEXT) IS 'Alias de sp_change_user_password';

-- Alias: sfrm_chgpass_sp_validate_current
CREATE OR REPLACE FUNCTION public.sfrm_chgpass_sp_validate_current(
    p_username TEXT,
    p_password TEXT
)
RETURNS TABLE(
    is_valid BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.sp_validate_user_password(p_username, p_password);
END;
$$;

COMMENT ON FUNCTION public.sfrm_chgpass_sp_validate_current(TEXT, TEXT) IS 'Alias de sp_validate_user_password';

-- ============================================
-- TABLAS AUXILIARES (Crear si no existen)
-- ============================================

-- Tabla para bitácora de cambios de contraseña
CREATE TABLE IF NOT EXISTS public.bitacora_cambio_password (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    accion VARCHAR(50) DEFAULT 'CAMBIO_PASSWORD',
    resultado VARCHAR(50) DEFAULT 'EXITOSO',
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origen INET,
    CONSTRAINT bitacora_chgpass_username_fecha_key UNIQUE (username, fecha_cambio)
);

CREATE INDEX IF NOT EXISTS idx_bitacora_chgpass_username ON public.bitacora_cambio_password(username);
CREATE INDEX IF NOT EXISTS idx_bitacora_chgpass_fecha ON public.bitacora_cambio_password(fecha_cambio DESC);

COMMENT ON TABLE public.bitacora_cambio_password IS 'Bitácora de cambios de contraseña de usuarios';

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
IMPLEMENTACIÓN COMPLETADA - 2025-11-20

Stored Procedures implementados: 7 SPs
- 2 SPs principales para cambio de contraseña
- 1 SP para bitácora
- 4 SPs alias para compatibilidad

Tablas utilizadas (schema public):
- users (o usuarios): Tabla de usuarios del sistema
  Campos necesarios:
  - id: INTEGER PRIMARY KEY
  - username: VARCHAR UNIQUE
  - password_hash: TEXT (hash bcrypt)
  - fecha_actualizacion: TIMESTAMP

- bitacora_cambio_password: Tabla de auditoría
  Campos:
  - id: SERIAL PRIMARY KEY
  - username: VARCHAR
  - accion: VARCHAR
  - resultado: VARCHAR
  - fecha_cambio: TIMESTAMP
  - ip_origen: INET

Extensiones requeridas:
- pgcrypto: Para funciones crypt() y gen_salt('bf')

Funcionalidades implementadas:
1. Validación de contraseña actual
2. Cambio de contraseña con múltiples validaciones:
   - Usuario existe
   - Contraseña actual correcta
   - Nueva contraseña diferente
   - Primeros 3 caracteres diferentes
   - Formato: letras + números, 6-8 caracteres
3. Registro en bitácora con IP de origen
4. Hash seguro con bcrypt (blowfish)
5. SECURITY DEFINER para acceso controlado

Características de seguridad:
- Password hash con bcrypt
- SECURITY DEFINER para funciones sensibles
- Validación de formato de contraseña
- Registro de IP de origen
- Bitácora de cambios
- Prevención de contraseñas similares

Uso desde API genérico:
POST /api/generic
{
  "eRequest": {
    "Operacion": "sp_change_user_password",
    "Base": "padron_licencias",
    "Esquema": "public",
    "Parametros": [
      {"nombre": "p_username", "valor": "usuario123", "tipo": "text"},
      {"nombre": "p_current_password", "valor": "pass123", "tipo": "text"},
      {"nombre": "p_new_password", "valor": "nueva456", "tipo": "text"}
    ]
  }
}

POST /api/generic
{
  "eRequest": {
    "Operacion": "sp_validate_user_password",
    "Base": "padron_licencias",
    "Esquema": "public",
    "Parametros": [
      {"nombre": "p_username", "valor": "usuario123", "tipo": "text"},
      {"nombre": "p_password", "valor": "pass123", "tipo": "text"}
    ]
  }
}
*/
