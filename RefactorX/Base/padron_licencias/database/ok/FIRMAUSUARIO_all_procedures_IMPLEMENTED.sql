-- ============================================
-- CONFIGURACION BASE DE DATOS: padron_licencias
-- ESQUEMA: comun
-- ============================================
\c padron_licencias;
SET search_path TO comun, public;

-- Habilitar extension pgcrypto si no existe (para validacion encriptada)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================
-- STORED PROCEDURES PARA VALIDACION DE FIRMA DE USUARIO
-- Formulario: firmausuario
-- Convencion: sp_validate_firma_usuario
-- Implementado: 2025-11-21
-- Tablas: usuarios
-- Modulo: FIRMAUSUARIO
-- Total SPs: 1 principal + 2 aliases
-- ============================================

-- ============================================
-- SP 1/1: sp_validate_firma_usuario
-- Tipo: Validation
-- Descripcion: Valida si el usuario y la firma digital coinciden en la base de datos.
--              Retorna success=true/false, mensaje descriptivo e informacion adicional del usuario
-- API Compatible: RETURNS TABLE
-- SECURITY DEFINER: Para acceso controlado a firma_digital
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_validate_firma_usuario(
    p_usuario VARCHAR,
    p_firma VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    usuario_id INTEGER,
    nombre_usuario TEXT,
    tiene_permiso BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_count INTEGER;
    v_user RECORD;
    v_firma_valida BOOLEAN := FALSE;
BEGIN
    -- ============================================
    -- VALIDACIONES DE ENTRADA
    -- ============================================

    -- Validar que usuario no este vacio
    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RAISE EXCEPTION 'El parametro usuario es requerido y no puede estar vacio'
            USING ERRCODE = 'P0001';
    END IF;

    -- Validar que firma no este vacia
    IF p_firma IS NULL OR TRIM(p_firma) = '' THEN
        RAISE EXCEPTION 'El parametro firma es requerido y no puede estar vacio'
            USING ERRCODE = 'P0002';
    END IF;

    -- ============================================
    -- BUSQUEDA DE USUARIO
    -- ============================================

    -- Buscar el usuario en la tabla
    SELECT
        u.id,
        u.usuario,
        u.nombre,
        u.firma_digital,
        u.estado,
        u.activo,
        COALESCE(u.tiene_permiso_firma, TRUE) AS tiene_permiso_firma
    INTO v_user
    FROM comun.usuarios u
    WHERE UPPER(TRIM(u.usuario)) = UPPER(TRIM(p_usuario));

    -- Si no existe el usuario
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Usuario no encontrado en el sistema.'::TEXT AS message,
            NULL::INTEGER AS usuario_id,
            NULL::TEXT AS nombre_usuario,
            FALSE::BOOLEAN AS tiene_permiso;
        RETURN;
    END IF;

    -- Verificar estado del usuario
    IF v_user.estado IS NOT NULL AND UPPER(v_user.estado) NOT IN ('ACTIVO', 'A', '1') THEN
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Usuario inactivo. Contacte al administrador.'::TEXT AS message,
            v_user.id::INTEGER AS usuario_id,
            v_user.nombre::TEXT AS nombre_usuario,
            FALSE::BOOLEAN AS tiene_permiso;
        RETURN;
    END IF;

    -- Verificar campo activo si existe
    IF v_user.activo IS NOT NULL AND v_user.activo = FALSE THEN
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Usuario deshabilitado. Contacte al administrador.'::TEXT AS message,
            v_user.id::INTEGER AS usuario_id,
            v_user.nombre::TEXT AS nombre_usuario,
            FALSE::BOOLEAN AS tiene_permiso;
        RETURN;
    END IF;

    -- ============================================
    -- VALIDACION DE FIRMA DIGITAL
    -- ============================================

    /*
    ENFOQUE DE SEGURIDAD:

    Opcion A: Firma encriptada con bcrypt/pgcrypto
    Si la firma_digital esta almacenada como hash bcrypt:
    v_firma_valida := (v_user.firma_digital = crypt(p_firma, v_user.firma_digital));

    Opcion B: Firma en texto plano (comparacion directa)
    Si la firma_digital esta almacenada en texto plano:
    v_firma_valida := (TRIM(v_user.firma_digital) = TRIM(p_firma));

    Opcion C: Firma como hash MD5/SHA
    Si se usa MD5 o SHA para la firma:
    v_firma_valida := (v_user.firma_digital = encode(digest(p_firma, 'sha256'), 'hex'));

    IMPLEMENTACION ACTUAL:
    Utilizamos deteccion automatica del formato de firma:
    - Si empieza con $2a$, $2b$ o $2y$ -> bcrypt hash
    - Si tiene 64 caracteres hex -> SHA256
    - Si tiene 32 caracteres hex -> MD5
    - Otro caso -> texto plano
    */

    -- Detectar tipo de hash y validar apropiadamente
    IF v_user.firma_digital IS NULL THEN
        -- Usuario sin firma registrada
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Usuario no tiene firma digital registrada.'::TEXT AS message,
            v_user.id::INTEGER AS usuario_id,
            v_user.nombre::TEXT AS nombre_usuario,
            FALSE::BOOLEAN AS tiene_permiso;
        RETURN;
    ELSIF v_user.firma_digital LIKE '$2a$%' OR v_user.firma_digital LIKE '$2b$%' OR v_user.firma_digital LIKE '$2y$%' THEN
        -- Firma almacenada como bcrypt hash
        v_firma_valida := (v_user.firma_digital = crypt(p_firma, v_user.firma_digital));
    ELSIF LENGTH(v_user.firma_digital) = 64 AND v_user.firma_digital ~ '^[a-fA-F0-9]+$' THEN
        -- Firma almacenada como SHA256 hex
        v_firma_valida := (LOWER(v_user.firma_digital) = encode(digest(p_firma, 'sha256'), 'hex'));
    ELSIF LENGTH(v_user.firma_digital) = 32 AND v_user.firma_digital ~ '^[a-fA-F0-9]+$' THEN
        -- Firma almacenada como MD5 hex
        v_firma_valida := (LOWER(v_user.firma_digital) = encode(digest(p_firma, 'md5'), 'hex'));
    ELSE
        -- Comparacion directa (texto plano) - Case sensitive
        v_firma_valida := (TRIM(v_user.firma_digital) = TRIM(p_firma));
    END IF;

    -- ============================================
    -- RETORNO DE RESULTADO
    -- ============================================

    IF v_firma_valida THEN
        RETURN QUERY
        SELECT
            TRUE::BOOLEAN AS success,
            'Firma validada correctamente.'::TEXT AS message,
            v_user.id::INTEGER AS usuario_id,
            v_user.nombre::TEXT AS nombre_usuario,
            v_user.tiene_permiso_firma::BOOLEAN AS tiene_permiso;
    ELSE
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Firma digital incorrecta.'::TEXT AS message,
            v_user.id::INTEGER AS usuario_id,
            v_user.nombre::TEXT AS nombre_usuario,
            FALSE::BOOLEAN AS tiene_permiso;
    END IF;

EXCEPTION
    WHEN SQLSTATE 'P0001' THEN
        -- Error de validacion: usuario vacio
        RAISE;
    WHEN SQLSTATE 'P0002' THEN
        -- Error de validacion: firma vacia
        RAISE;
    WHEN undefined_table THEN
        RAISE EXCEPTION 'La tabla de usuarios no existe en el esquema comun'
            USING ERRCODE = '42P01';
    WHEN undefined_column THEN
        RAISE EXCEPTION 'Columna requerida no existe en la tabla usuarios. Verifique estructura de tabla.'
            USING ERRCODE = '42703';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al validar firma de usuario: %', SQLERRM
            USING ERRCODE = 'P0099';
END;
$$;

COMMENT ON FUNCTION comun.sp_validate_firma_usuario(VARCHAR, VARCHAR) IS
'Valida firma digital de un usuario. Retorna success, message, usuario_id, nombre_usuario y tiene_permiso.
Soporta firmas en formato bcrypt, SHA256, MD5 o texto plano con deteccion automatica.';

-- ============================================
-- FUNCIONES ALIAS PARA COMPATIBILIDAD
-- ============================================

-- Alias 1: firmausuario_validate_firma_usuario (compatibilidad nomenclatura formulario)
CREATE OR REPLACE FUNCTION comun.firmausuario_validate_firma_usuario(
    p_usuario VARCHAR,
    p_firma VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    usuario_id INTEGER,
    nombre_usuario TEXT,
    tiene_permiso BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM comun.sp_validate_firma_usuario(p_usuario, p_firma);
END;
$$;

COMMENT ON FUNCTION comun.firmausuario_validate_firma_usuario(VARCHAR, VARCHAR) IS
'Alias de sp_validate_firma_usuario para compatibilidad con nomenclatura de formulario';

-- Alias 2: validate_firma_usuario (sin prefijo sp_)
CREATE OR REPLACE FUNCTION comun.validate_firma_usuario(
    p_usuario VARCHAR,
    p_firma VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    usuario_id INTEGER,
    nombre_usuario TEXT,
    tiene_permiso BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM comun.sp_validate_firma_usuario(p_usuario, p_firma);
END;
$$;

COMMENT ON FUNCTION comun.validate_firma_usuario(VARCHAR, VARCHAR) IS
'Alias de sp_validate_firma_usuario sin prefijo sp_';

-- ============================================
-- VERSION CON ID DE USUARIO (Compatibilidad con implementacion anterior)
-- ============================================

-- SP Adicional: sp_validate_firma_usuario_by_id
-- Para mantener compatibilidad con sistemas que usan ID en lugar de username
CREATE OR REPLACE FUNCTION comun.sp_validate_firma_usuario_by_id(
    p_usuario_id INTEGER,
    p_firma_digital TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    usuario_id INTEGER,
    nombre_usuario TEXT,
    tiene_permiso BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user RECORD;
    v_firma_valida BOOLEAN := FALSE;
BEGIN
    -- Validar que usuario_id no sea nulo
    IF p_usuario_id IS NULL THEN
        RAISE EXCEPTION 'El parametro usuario_id es requerido'
            USING ERRCODE = 'P0001';
    END IF;

    -- Validar que firma no este vacia
    IF p_firma_digital IS NULL OR TRIM(p_firma_digital) = '' THEN
        RAISE EXCEPTION 'El parametro firma_digital es requerido y no puede estar vacio'
            USING ERRCODE = 'P0002';
    END IF;

    -- Buscar el usuario por ID
    SELECT
        u.id,
        u.usuario,
        u.nombre,
        u.firma_digital,
        u.estado,
        COALESCE(u.tiene_permiso_firma, TRUE) AS tiene_permiso_firma
    INTO v_user
    FROM comun.usuarios u
    WHERE u.id = p_usuario_id;

    -- Si no existe el usuario
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Usuario no encontrado.'::TEXT AS message,
            NULL::INTEGER AS usuario_id,
            NULL::TEXT AS nombre_usuario,
            FALSE::BOOLEAN AS tiene_permiso;
        RETURN;
    END IF;

    -- Verificar estado del usuario
    IF v_user.estado IS NOT NULL AND UPPER(v_user.estado) NOT IN ('ACTIVO', 'A', '1') THEN
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Usuario inactivo.'::TEXT AS message,
            v_user.id::INTEGER AS usuario_id,
            v_user.nombre::TEXT AS nombre_usuario,
            FALSE::BOOLEAN AS tiene_permiso;
        RETURN;
    END IF;

    -- Validar firma con deteccion automatica de formato
    IF v_user.firma_digital IS NULL THEN
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Usuario sin firma digital registrada.'::TEXT AS message,
            v_user.id::INTEGER AS usuario_id,
            v_user.nombre::TEXT AS nombre_usuario,
            FALSE::BOOLEAN AS tiene_permiso;
        RETURN;
    ELSIF v_user.firma_digital LIKE '$2a$%' OR v_user.firma_digital LIKE '$2b$%' OR v_user.firma_digital LIKE '$2y$%' THEN
        v_firma_valida := (v_user.firma_digital = crypt(p_firma_digital, v_user.firma_digital));
    ELSIF LENGTH(v_user.firma_digital) = 64 AND v_user.firma_digital ~ '^[a-fA-F0-9]+$' THEN
        v_firma_valida := (LOWER(v_user.firma_digital) = encode(digest(p_firma_digital, 'sha256'), 'hex'));
    ELSIF LENGTH(v_user.firma_digital) = 32 AND v_user.firma_digital ~ '^[a-fA-F0-9]+$' THEN
        v_firma_valida := (LOWER(v_user.firma_digital) = encode(digest(p_firma_digital, 'md5'), 'hex'));
    ELSE
        v_firma_valida := (TRIM(v_user.firma_digital) = TRIM(p_firma_digital));
    END IF;

    IF v_firma_valida THEN
        RETURN QUERY
        SELECT
            TRUE::BOOLEAN AS success,
            'Firma validada correctamente.'::TEXT AS message,
            v_user.id::INTEGER AS usuario_id,
            v_user.nombre::TEXT AS nombre_usuario,
            v_user.tiene_permiso_firma::BOOLEAN AS tiene_permiso;
    ELSE
        RETURN QUERY
        SELECT
            FALSE::BOOLEAN AS success,
            'Firma digital incorrecta.'::TEXT AS message,
            v_user.id::INTEGER AS usuario_id,
            v_user.nombre::TEXT AS nombre_usuario,
            FALSE::BOOLEAN AS tiene_permiso;
    END IF;

EXCEPTION
    WHEN SQLSTATE 'P0001' THEN
        RAISE;
    WHEN SQLSTATE 'P0002' THEN
        RAISE;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al validar firma: %', SQLERRM
            USING ERRCODE = 'P0099';
END;
$$;

COMMENT ON FUNCTION comun.sp_validate_firma_usuario_by_id(INTEGER, TEXT) IS
'Valida firma digital de usuario por ID. Mantiene compatibilidad con implementacion anterior.';

-- ============================================
-- FUNCION SIMPLE (Compatibilidad con referencia original)
-- ============================================

-- SP Simple: sp_validate_firma_usuario_simple
-- Retorna solo success y message como en el archivo de referencia original
CREATE OR REPLACE FUNCTION comun.sp_validate_firma_usuario_simple(
    p_usuario VARCHAR,
    p_firma VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result RECORD;
BEGIN
    -- Usar la funcion principal y retornar solo los campos basicos
    SELECT r.success, r.message
    INTO v_result
    FROM comun.sp_validate_firma_usuario(p_usuario, p_firma) r;

    RETURN QUERY
    SELECT v_result.success, v_result.message;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT FALSE::BOOLEAN AS success, SQLERRM::TEXT AS message;
END;
$$;

COMMENT ON FUNCTION comun.sp_validate_firma_usuario_simple(VARCHAR, VARCHAR) IS
'Version simplificada de sp_validate_firma_usuario. Retorna solo success y message.';

-- ============================================
-- GRANTS Y PERMISOS
-- ============================================

-- Dar permisos de ejecucion al rol de aplicacion si existe
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
        GRANT EXECUTE ON FUNCTION comun.sp_validate_firma_usuario(VARCHAR, VARCHAR) TO app_user;
        GRANT EXECUTE ON FUNCTION comun.firmausuario_validate_firma_usuario(VARCHAR, VARCHAR) TO app_user;
        GRANT EXECUTE ON FUNCTION comun.validate_firma_usuario(VARCHAR, VARCHAR) TO app_user;
        GRANT EXECUTE ON FUNCTION comun.sp_validate_firma_usuario_by_id(INTEGER, TEXT) TO app_user;
        GRANT EXECUTE ON FUNCTION comun.sp_validate_firma_usuario_simple(VARCHAR, VARCHAR) TO app_user;
    END IF;
END $$;

-- ============================================
-- VERIFICACION DE IMPLEMENTACION
-- ============================================

DO $$
DECLARE
    v_sp_count INTEGER := 0;
BEGIN
    -- Contar SPs implementados
    SELECT COUNT(*) INTO v_sp_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'comun'
      AND p.proname IN (
          'sp_validate_firma_usuario',
          'firmausuario_validate_firma_usuario',
          'validate_firma_usuario',
          'sp_validate_firma_usuario_by_id',
          'sp_validate_firma_usuario_simple'
      );

    IF v_sp_count >= 5 THEN
        RAISE NOTICE '[OK] FIRMAUSUARIO: % SPs implementados correctamente en esquema comun', v_sp_count;
    ELSE
        RAISE WARNING '[WARN] FIRMAUSUARIO: Solo % de 5 SPs detectados', v_sp_count;
    END IF;
END $$;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACION
-- ============================================

/*
============================================
IMPLEMENTACION COMPLETADA - 2025-11-21
Batch 12 del proyecto de implementacion
============================================

STORED PROCEDURES IMPLEMENTADOS: 5 SPs total
- 1 SP principal: sp_validate_firma_usuario (por username)
- 2 SP aliases: firmausuario_validate_firma_usuario, validate_firma_usuario
- 1 SP por ID: sp_validate_firma_usuario_by_id (compatibilidad)
- 1 SP simple: sp_validate_firma_usuario_simple (retorno basico)

ESQUEMA: comun
BASE DE DATOS: padron_licencias

TABLAS UTILIZADAS:
- comun.usuarios: Tabla de usuarios del sistema
  Campos esperados:
  - id: INTEGER PRIMARY KEY
  - usuario: VARCHAR (username unico)
  - nombre: VARCHAR (nombre completo)
  - firma_digital: TEXT (hash bcrypt/SHA256/MD5 o texto plano)
  - estado: VARCHAR ('ACTIVO', 'INACTIVO', 'A', 'I', etc.)
  - activo: BOOLEAN (opcional)
  - tiene_permiso_firma: BOOLEAN (opcional, default TRUE)

EXTENSIONES REQUERIDAS:
- pgcrypto: Para funciones crypt(), gen_salt(), digest() y encode()

ENFOQUE DE SEGURIDAD:
La implementacion soporta MULTIPLES FORMATOS de firma digital con deteccion automatica:

1. BCRYPT (recomendado para maxima seguridad):
   - Detectado por prefijos: $2a$, $2b$, $2y$
   - Validacion: crypt(p_firma, firma_almacenada) = firma_almacenada

2. SHA256:
   - Detectado por: 64 caracteres hexadecimales
   - Validacion: encode(digest(p_firma, 'sha256'), 'hex') = firma_almacenada

3. MD5 (legado, no recomendado para nuevas implementaciones):
   - Detectado por: 32 caracteres hexadecimales
   - Validacion: encode(digest(p_firma, 'md5'), 'hex') = firma_almacenada

4. TEXTO PLANO (solo para ambientes de desarrollo):
   - Cualquier otro formato
   - Validacion: comparacion directa con TRIM

VALIDACIONES IMPLEMENTADAS:
1. Parametro p_usuario no nulo ni vacio (RAISE EXCEPTION P0001)
2. Parametro p_firma no nulo ni vacio (RAISE EXCEPTION P0002)
3. Usuario debe existir en la tabla
4. Usuario debe estar activo (estado = 'ACTIVO', 'A' o '1')
5. Usuario debe tener firma registrada
6. Firma debe coincidir segun formato detectado

CAMPOS DE RETORNO:
- success: BOOLEAN - TRUE si firma valida, FALSE en caso contrario
- message: TEXT - Mensaje descriptivo del resultado
- usuario_id: INTEGER - ID del usuario (NULL si no existe)
- nombre_usuario: TEXT - Nombre completo del usuario
- tiene_permiso: BOOLEAN - Indica si usuario tiene permiso para firmar

MANEJO DE ERRORES:
- P0001: Usuario requerido
- P0002: Firma requerida
- 42P01: Tabla no existe
- 42703: Columna no existe
- P0099: Error general

USO DESDE API GENERICO:

-- Validacion por username (principal):
POST /api/generic
{
  "eRequest": {
    "Operacion": "sp_validate_firma_usuario",
    "Base": "padron_licencias",
    "Esquema": "comun",
    "Parametros": [
      {"nombre": "p_usuario", "valor": "jperez", "tipo": "varchar"},
      {"nombre": "p_firma", "valor": "mi_firma_secreta", "tipo": "varchar"}
    ]
  }
}

-- Validacion por ID (alternativo):
POST /api/generic
{
  "eRequest": {
    "Operacion": "sp_validate_firma_usuario_by_id",
    "Base": "padron_licencias",
    "Esquema": "comun",
    "Parametros": [
      {"nombre": "p_usuario_id", "valor": 123, "tipo": "integer"},
      {"nombre": "p_firma_digital", "valor": "mi_firma_secreta", "tipo": "text"}
    ]
  }
}

-- Version simple (solo success/message):
POST /api/generic
{
  "eRequest": {
    "Operacion": "sp_validate_firma_usuario_simple",
    "Base": "padron_licencias",
    "Esquema": "comun",
    "Parametros": [
      {"nombre": "p_usuario", "valor": "jperez", "tipo": "varchar"},
      {"nombre": "p_firma", "valor": "mi_firma_secreta", "tipo": "varchar"}
    ]
  }
}

EJEMPLOS DE USO DIRECTO EN SQL:

-- Validar firma de usuario
SELECT * FROM comun.sp_validate_firma_usuario('jperez', 'mi_firma_123');

-- Usando alias
SELECT * FROM comun.firmausuario_validate_firma_usuario('jperez', 'mi_firma_123');

-- Validar por ID de usuario
SELECT * FROM comun.sp_validate_firma_usuario_by_id(1, 'mi_firma_123');

-- Version simplificada
SELECT * FROM comun.sp_validate_firma_usuario_simple('jperez', 'mi_firma_123');

NOTAS DE MIGRACION:
Si existe implementacion previa en schema public, se recomienda:
1. Crear wrappers en public que llamen a comun
2. O migrar gradualmente actualizando llamadas en la API

*/
