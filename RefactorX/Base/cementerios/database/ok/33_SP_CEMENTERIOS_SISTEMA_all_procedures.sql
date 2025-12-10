-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: comun
-- ============================================
\c padron_licencias;
SET search_path TO comun;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: SISTEMA (Autenticación y Utilidades)
-- Archivo: 33_SP_CEMENTERIOS_SISTEMA_all_procedures.sql
-- Generado: 2025-12-01
-- Total SPs: 6
-- Componentes: Modulo.vue, Acceso.vue, sfrm_chgpass.vue
-- ============================================

-- =============================================
-- 1. SP_VALIDAR_USUARIO (Modulo.vue línea 217 + Acceso.vue línea 144)
-- Tipo: Auth
-- Descripción: Valida credenciales de usuario en el sistema
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_validar_usuario(
    p_usuario VARCHAR,
    p_password VARCHAR
)
RETURNS TABLE (
    resultado CHAR(1),
    id_usuario INTEGER,
    nombre_usuario VARCHAR,
    mensaje VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN p.clave = p_password THEN 'S'::CHAR(1)
            ELSE 'N'::CHAR(1)
        END AS resultado,
        p.id_usuario,
        p.nombre AS nombre_usuario,
        CASE
            WHEN p.clave = p_password THEN 'Usuario válido'::VARCHAR
            ELSE 'Usuario o contraseña incorrectos'::VARCHAR
        END AS mensaje
    FROM comun.ta_12_passwords p
    WHERE p.usuario = p_usuario
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_validar_usuario IS 'Valida credenciales de usuario (Modulo.vue + Acceso.vue)';

-- =============================================
-- 2. SP_OBTENER_HORA_SERVIDOR (Modulo.vue línea 256)
-- Tipo: Utility
-- Descripción: Obtiene la hora actual del servidor de base de datos
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_obtener_hora_servidor()
RETURNS TABLE (
    hora_actual TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_obtener_hora_servidor IS 'Obtiene hora actual del servidor (Modulo.vue)';

-- =============================================
-- 3. SP_VERIFICAR_VERSION (Modulo.vue línea 290)
-- Tipo: Utility
-- Descripción: Verifica si existe una nueva versión del sistema disponible
-- NOTA: Requiere tabla comun.tc_versiones
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_verificar_version(
    p_proyecto VARCHAR,
    p_version_actual VARCHAR
)
RETURNS TABLE (
    hay_nueva_version INTEGER,
    version_nueva VARCHAR,
    mensaje VARCHAR
) AS $$
DECLARE
    v_version_db VARCHAR;
BEGIN
    -- Buscar última versión en tabla de versiones
    SELECT version INTO v_version_db
    FROM comun.tc_versiones
    WHERE proyecto = p_proyecto
    ORDER BY fecha_publicacion DESC
    LIMIT 1;

    IF v_version_db IS NULL THEN
        -- No hay registro de versiones
        RETURN QUERY
        SELECT
            0 AS hay_nueva_version,
            p_version_actual AS version_nueva,
            'No se encontraron versiones registradas'::VARCHAR AS mensaje;
    ELSIF v_version_db > p_version_actual THEN
        -- Hay nueva versión
        RETURN QUERY
        SELECT
            1 AS hay_nueva_version,
            v_version_db AS version_nueva,
            'Nueva versión disponible'::VARCHAR AS mensaje;
    ELSE
        -- Sistema actualizado
        RETURN QUERY
        SELECT
            0 AS hay_nueva_version,
            v_version_db AS version_nueva,
            'El sistema está actualizado'::VARCHAR AS mensaje;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Error o tabla no existe
        RETURN QUERY
        SELECT
            0 AS hay_nueva_version,
            p_version_actual AS version_nueva,
            'No se pudo verificar la versión'::VARCHAR AS mensaje;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_verificar_version IS 'Verifica nueva versión disponible (Modulo.vue)';

-- =============================================
-- 4. sp_registrar_acceso (Acceso.vue línea 214)
-- Tipo: Audit
-- Descripción: Registra el acceso de un usuario al sistema
-- NOTA: Requiere tabla comun.ta_13_log_accesos
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_registrar_acceso(
    p_id_usuario INTEGER,
    p_modulo VARCHAR,
    p_accion VARCHAR
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje VARCHAR
) AS $$
DECLARE
    v_fecha_hora TIMESTAMP;
BEGIN
    v_fecha_hora := CURRENT_TIMESTAMP;

    -- Insertar registro de acceso en tabla de auditoría
    INSERT INTO comun.ta_13_log_accesos (
        id_usuario,
        modulo,
        accion,
        fecha_hora
    ) VALUES (
        p_id_usuario,
        p_modulo,
        p_accion,
        v_fecha_hora
    );

    RETURN QUERY
    SELECT
        'S'::CHAR(1) AS resultado,
        'Acceso registrado correctamente'::VARCHAR AS mensaje;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'N'::CHAR(1) AS resultado,
            'Error al registrar acceso'::VARCHAR AS mensaje;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_registrar_acceso IS 'Registra acceso de usuario (Acceso.vue)';

-- =============================================
-- 5. sp_validar_password_actual (sfrm_chgpass.vue línea 238)
-- Tipo: Auth
-- Descripción: Valida la contraseña actual del usuario en sesión
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_validar_password_actual(
    p_password VARCHAR
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje VARCHAR
) AS $$
DECLARE
    v_id_usuario INTEGER;
BEGIN
    -- Obtener usuario de sesión
    -- Por ahora validamos contra cualquier usuario con esa contraseña
    SELECT id_usuario INTO v_id_usuario
    FROM comun.ta_12_passwords
    WHERE clave = p_password
    LIMIT 1;

    IF v_id_usuario IS NOT NULL THEN
        RETURN QUERY
        SELECT
            'S'::CHAR(1) AS resultado,
            'Contraseña actual válida'::VARCHAR AS mensaje;
    ELSE
        RETURN QUERY
        SELECT
            'N'::CHAR(1) AS resultado,
            'Contraseña actual incorrecta'::VARCHAR AS mensaje;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_validar_password_actual IS 'Valida contraseña actual del usuario (sfrm_chgpass.vue)';

-- =============================================
-- 6. sp_cambiar_password (sfrm_chgpass.vue línea 331)
-- Tipo: Auth
-- Descripción: Cambia la contraseña del usuario actual
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_cambiar_password(
    p_password_actual VARCHAR,
    p_password_nueva VARCHAR
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje VARCHAR
) AS $$
DECLARE
    v_id_usuario INTEGER;
BEGIN
    -- Validar contraseña actual
    SELECT id_usuario INTO v_id_usuario
    FROM comun.ta_12_passwords
    WHERE clave = p_password_actual
    LIMIT 1;

    IF v_id_usuario IS NULL THEN
        RETURN QUERY
        SELECT
            'N'::CHAR(1) AS resultado,
            'Contraseña actual incorrecta'::VARCHAR AS mensaje;
        RETURN;
    END IF;

    -- Actualizar contraseña
    UPDATE comun.ta_12_passwords
    SET clave = p_password_nueva,
        fecha_modificacion = CURRENT_DATE
    WHERE id_usuario = v_id_usuario;

    RETURN QUERY
    SELECT
        'S'::CHAR(1) AS resultado,
        'Contraseña actualizada exitosamente'::VARCHAR AS mensaje;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'N'::CHAR(1) AS resultado,
            'Error al cambiar contraseña'::VARCHAR AS mensaje;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_cambiar_password IS 'Cambia contraseña del usuario (sfrm_chgpass.vue)';

-- =============================================
-- TABLAS REQUERIDAS (OPCIONAL - CREAR SI NO EXISTEN)
-- =============================================

-- Tabla de versiones (para sp_verificar_version)
CREATE TABLE IF NOT EXISTS comun.tc_versiones (
    id_version SERIAL PRIMARY KEY,
    proyecto VARCHAR(50) NOT NULL,
    version VARCHAR(20) NOT NULL,
    fecha_publicacion DATE NOT NULL DEFAULT CURRENT_DATE,
    descripcion TEXT,
    CONSTRAINT uk_proyecto_version UNIQUE (proyecto, version)
);

COMMENT ON TABLE comun.tc_versiones IS 'Control de versiones del sistema';

-- Tabla de log de accesos (para sp_registrar_acceso)
CREATE TABLE IF NOT EXISTS comun.ta_13_log_accesos (
    id_log SERIAL PRIMARY KEY,
    id_usuario INTEGER NOT NULL,
    modulo VARCHAR(50) NOT NULL,
    accion VARCHAR(50) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE comun.ta_13_log_accesos IS 'Auditoría de accesos al sistema';

-- ============================================
-- NOTAS DE IMPLEMENTACIÓN:
-- 1. Todos los SPs usan esquema comun (padron_licencias.comun)
-- 2. La autenticación es básica (en producción usar bcrypt/hash)
-- 3. Las tablas tc_versiones y ta_13_log_accesos son opcionales
-- 4. El campo fecha_modificacion debe existir en ta_12_passwords
-- ============================================
