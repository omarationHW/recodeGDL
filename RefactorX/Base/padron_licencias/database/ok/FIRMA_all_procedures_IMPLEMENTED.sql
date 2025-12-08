-- ============================================
-- CONFIGURACION BASE DE DATOS: padron_licencias
-- ESQUEMA: comun (funcionalidad compartida)
-- ============================================
-- \c padron_licencias;
-- SET search_path TO comun, public;

-- ============================================
-- STORED PROCEDURES PARA SISTEMA DE FIRMAS DIGITALES
-- Convencion: comun.sp_firma_XXX
-- Implementado: 2025-11-21
-- Actualizado: Batch 13 - Componente 78/95 (82.1%)
-- Tablas: usuarios
-- Modulo: FIRMA (Validacion y guardado de firma digital)
-- ============================================

-- ============================================
-- TABLA REFERENCIA: usuarios
-- Campos requeridos: id, nombre, firma_digital, usuario, estado
-- Campos opcionales: fecha_actualizacion, fecbaj
-- ============================================

-- ============================================
-- INDICES RECOMENDADOS (ejecutar si no existen)
-- ============================================
-- CREATE INDEX IF NOT EXISTS idx_usuarios_firma_digital ON usuarios(firma_digital) WHERE firma_digital IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_usuarios_estado ON usuarios(estado);
-- CREATE INDEX IF NOT EXISTS idx_usuarios_usuario ON usuarios(usuario);

-- ============================================
-- SP 1/2: comun.sp_firma_validate
-- Tipo: Validation/Authentication
-- Descripcion: Valida si la firma digital ingresada es correcta
--              y retorna informacion del usuario asociado.
--              Incluye validaciones de estado activo del usuario.
-- Parametros:
--   p_firma_digital: TEXT - Firma digital a validar
-- Retorna: TABLE con is_valid, usuario_id, nombre, usuario, message
-- ============================================

DROP FUNCTION IF EXISTS comun.sp_firma_validate(TEXT);

CREATE OR REPLACE FUNCTION comun.sp_firma_validate(
    p_firma_digital TEXT
)
RETURNS TABLE(
    is_valid BOOLEAN,
    usuario_id INTEGER,
    nombre TEXT,
    usuario VARCHAR,
    message TEXT
) AS $$
DECLARE
    v_usuario_id INTEGER;
    v_nombre TEXT;
    v_usuario VARCHAR;
    v_estado VARCHAR;
BEGIN
    -- Validar que la firma no sea nula o vacia
    IF p_firma_digital IS NULL OR TRIM(p_firma_digital) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS is_valid,
            NULL::INTEGER AS usuario_id,
            NULL::TEXT AS nombre,
            NULL::VARCHAR AS usuario,
            'La firma digital es requerida.'::TEXT AS message;
        RETURN;
    END IF;

    -- Buscar usuario por firma digital
    SELECT
        u.id,
        u.nombre,
        u.usuario,
        COALESCE(u.estado, 'A')
    INTO
        v_usuario_id,
        v_nombre,
        v_usuario,
        v_estado
    FROM usuarios u
    WHERE u.firma_digital = p_firma_digital
    LIMIT 1;

    -- Verificar si se encontro el usuario
    IF v_usuario_id IS NOT NULL THEN
        -- Verificar estado del usuario (A/ACTIVO = Activo, B/INACTIVO = Baja/Inactivo)
        IF v_estado IN ('B', 'I', 'INACTIVO', 'BAJA') THEN
            RETURN QUERY SELECT
                FALSE::BOOLEAN AS is_valid,
                v_usuario_id AS usuario_id,
                v_nombre AS nombre,
                v_usuario AS usuario,
                'El usuario asociado a esta firma esta inactivo o dado de baja.'::TEXT AS message;
            RETURN;
        END IF;

        -- Firma valida y usuario activo
        RETURN QUERY SELECT
            TRUE::BOOLEAN AS is_valid,
            v_usuario_id AS usuario_id,
            v_nombre AS nombre,
            v_usuario AS usuario,
            'Firma validada correctamente.'::TEXT AS message;
    ELSE
        -- Firma no encontrada
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS is_valid,
            NULL::INTEGER AS usuario_id,
            NULL::TEXT AS nombre,
            NULL::VARCHAR AS usuario,
            'Firma digital no valida o no encontrada.'::TEXT AS message;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS is_valid,
            NULL::INTEGER AS usuario_id,
            NULL::TEXT AS nombre,
            NULL::VARCHAR AS usuario,
            ('Error al validar firma: ' || SQLERRM)::TEXT AS message;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION comun.sp_firma_validate(TEXT) TO PUBLIC;

COMMENT ON FUNCTION comun.sp_firma_validate(TEXT) IS
'Valida una firma digital y retorna informacion del usuario asociado.
Verifica que el usuario este activo antes de validar.
Parametros: p_firma_digital (TEXT)
Retorna: is_valid, usuario_id, nombre, usuario, message';

-- ============================================
-- SP 2/2: comun.sp_firma_save
-- Tipo: CRUD (Update)
-- Descripcion: Guarda o actualiza la firma digital de un usuario.
--              Incluye validaciones de existencia y unicidad.
-- Parametros:
--   p_usuario_id: INTEGER - ID del usuario
--   p_firma_digital: TEXT - Nueva firma digital
--   p_usuario_modifica: VARCHAR - Usuario que realiza el cambio (opcional)
-- Retorna: TABLE con success, message, usuario_id
-- ============================================

DROP FUNCTION IF EXISTS comun.sp_firma_save(INTEGER, TEXT);
DROP FUNCTION IF EXISTS comun.sp_firma_save(INTEGER, TEXT, VARCHAR);

CREATE OR REPLACE FUNCTION comun.sp_firma_save(
    p_usuario_id INTEGER,
    p_firma_digital TEXT,
    p_usuario_modifica VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    usuario_id INTEGER
) AS $$
DECLARE
    v_usuario_existe BOOLEAN;
    v_nombre_usuario TEXT;
    v_usuario_actual VARCHAR;
    v_firma_anterior TEXT;
    v_rows_affected INTEGER;
BEGIN
    -- Validar parametros requeridos
    IF p_usuario_id IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'El ID de usuario es requerido.'::TEXT AS message,
            NULL::INTEGER AS usuario_id;
        RETURN;
    END IF;

    IF p_firma_digital IS NULL OR TRIM(p_firma_digital) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'La firma digital es requerida.'::TEXT AS message,
            p_usuario_id AS usuario_id;
        RETURN;
    END IF;

    -- Verificar que el usuario exista y obtener datos actuales
    SELECT
        TRUE,
        u.nombre,
        u.usuario,
        u.firma_digital
    INTO
        v_usuario_existe,
        v_nombre_usuario,
        v_usuario_actual,
        v_firma_anterior
    FROM usuarios u
    WHERE u.id = p_usuario_id;

    IF NOT COALESCE(v_usuario_existe, FALSE) THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            ('Usuario con ID ' || p_usuario_id || ' no encontrado.')::TEXT AS message,
            p_usuario_id AS usuario_id;
        RETURN;
    END IF;

    -- Verificar si la firma ya esta en uso por otro usuario
    IF EXISTS (
        SELECT 1 FROM usuarios
        WHERE firma_digital = p_firma_digital
        AND id != p_usuario_id
    ) THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'Esta firma digital ya esta asignada a otro usuario.'::TEXT AS message,
            p_usuario_id AS usuario_id;
        RETURN;
    END IF;

    -- Verificar si la firma es la misma (no hay cambio)
    IF v_firma_anterior = p_firma_digital THEN
        RETURN QUERY SELECT
            TRUE::BOOLEAN AS success,
            'La firma digital no ha cambiado.'::TEXT AS message,
            p_usuario_id AS usuario_id;
        RETURN;
    END IF;

    -- Actualizar la firma digital
    UPDATE usuarios
    SET firma_digital = p_firma_digital
    WHERE id = p_usuario_id;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT
            TRUE::BOOLEAN AS success,
            ('Firma digital actualizada correctamente para ' || COALESCE(v_nombre_usuario, v_usuario_actual, p_usuario_id::TEXT) || '.')::TEXT AS message,
            p_usuario_id AS usuario_id;
    ELSE
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'No se pudo actualizar la firma digital.'::TEXT AS message,
            p_usuario_id AS usuario_id;
    END IF;

EXCEPTION
    WHEN unique_violation THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'Esta firma digital ya esta en uso por otro usuario.'::TEXT AS message,
            p_usuario_id AS usuario_id;
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            ('Error al guardar firma: ' || SQLERRM)::TEXT AS message,
            p_usuario_id AS usuario_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION comun.sp_firma_save(INTEGER, TEXT, VARCHAR) TO PUBLIC;

COMMENT ON FUNCTION comun.sp_firma_save(INTEGER, TEXT, VARCHAR) IS
'Guarda o actualiza la firma digital de un usuario.
Incluye validaciones de existencia y unicidad de firma.
Parametros: p_usuario_id (INTEGER), p_firma_digital (TEXT), p_usuario_modifica (VARCHAR opcional)
Retorna: success, message, usuario_id';

-- ============================================
-- FUNCIONES AUXILIARES
-- ============================================

-- SP AUXILIAR: comun.sp_firma_exists
-- Verifica si un usuario tiene firma digital asignada
DROP FUNCTION IF EXISTS comun.sp_firma_exists(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_firma_exists(
    p_usuario_id INTEGER
)
RETURNS TABLE(
    has_firma BOOLEAN,
    usuario_id INTEGER,
    nombre TEXT,
    message TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (u.firma_digital IS NOT NULL AND TRIM(u.firma_digital) != '')::BOOLEAN AS has_firma,
        u.id AS usuario_id,
        u.nombre::TEXT AS nombre,
        CASE
            WHEN u.firma_digital IS NOT NULL AND TRIM(u.firma_digital) != ''
            THEN 'El usuario tiene una firma digital asignada.'
            ELSE 'El usuario no tiene firma digital asignada.'
        END::TEXT AS message
    FROM usuarios u
    WHERE u.id = p_usuario_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS has_firma,
            p_usuario_id AS usuario_id,
            NULL::TEXT AS nombre,
            'Usuario no encontrado.'::TEXT AS message;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION comun.sp_firma_exists(INTEGER) TO PUBLIC;

COMMENT ON FUNCTION comun.sp_firma_exists(INTEGER) IS
'Verifica si un usuario tiene firma digital asignada.
Parametros: p_usuario_id (INTEGER)
Retorna: has_firma, usuario_id, nombre, message';

-- SP AUXILIAR: comun.sp_firma_delete
-- Elimina (limpia) la firma digital de un usuario
DROP FUNCTION IF EXISTS comun.sp_firma_delete(INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION comun.sp_firma_delete(
    p_usuario_id INTEGER,
    p_usuario_modifica VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    usuario_id INTEGER
) AS $$
DECLARE
    v_rows_affected INTEGER;
    v_nombre_usuario TEXT;
BEGIN
    IF p_usuario_id IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'El ID de usuario es requerido.'::TEXT AS message,
            NULL::INTEGER AS usuario_id;
        RETURN;
    END IF;

    SELECT nombre INTO v_nombre_usuario
    FROM usuarios WHERE id = p_usuario_id;

    IF v_nombre_usuario IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'Usuario no encontrado.'::TEXT AS message,
            p_usuario_id AS usuario_id;
        RETURN;
    END IF;

    UPDATE usuarios
    SET firma_digital = NULL
    WHERE id = p_usuario_id;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT
            TRUE::BOOLEAN AS success,
            ('Firma digital eliminada para ' || COALESCE(v_nombre_usuario, p_usuario_id::TEXT) || '.')::TEXT AS message,
            p_usuario_id AS usuario_id;
    ELSE
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            'No se pudo eliminar la firma digital.'::TEXT AS message,
            p_usuario_id AS usuario_id;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN AS success,
            ('Error al eliminar firma: ' || SQLERRM)::TEXT AS message,
            p_usuario_id AS usuario_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION comun.sp_firma_delete(INTEGER, VARCHAR) TO PUBLIC;

COMMENT ON FUNCTION comun.sp_firma_delete(INTEGER, VARCHAR) IS
'Elimina la firma digital de un usuario (establece como NULL).
Parametros: p_usuario_id (INTEGER), p_usuario_modifica (VARCHAR opcional)
Retorna: success, message, usuario_id';

-- ============================================
-- FUNCIONES ALIAS PARA COMPATIBILIDAD (schema public)
-- ============================================

DROP FUNCTION IF EXISTS public.sp_firma_validate(TEXT);
CREATE OR REPLACE FUNCTION public.sp_firma_validate(p_firma_digital TEXT)
RETURNS TABLE(is_valid BOOLEAN, usuario_id INTEGER, nombre TEXT, usuario VARCHAR, message TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM comun.sp_firma_validate(p_firma_digital);
END;
$$;

DROP FUNCTION IF EXISTS public.sp_firma_save(INTEGER, TEXT);
DROP FUNCTION IF EXISTS public.sp_firma_save(INTEGER, TEXT, VARCHAR);
CREATE OR REPLACE FUNCTION public.sp_firma_save(p_usuario_id INTEGER, p_firma_digital TEXT, p_usuario_modifica VARCHAR DEFAULT NULL)
RETURNS TABLE(success BOOLEAN, message TEXT, usuario_id INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM comun.sp_firma_save(p_usuario_id, p_firma_digital, p_usuario_modifica);
END;
$$;

-- Alias sin prefijo sp_ para compatibilidad legacy
DROP FUNCTION IF EXISTS public.firma_validate(TEXT);
CREATE OR REPLACE FUNCTION public.firma_validate(p_firma_digital TEXT)
RETURNS TABLE(is_valid BOOLEAN, usuario_id INTEGER, nombre TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT fv.is_valid, fv.usuario_id, fv.nombre
    FROM comun.sp_firma_validate(p_firma_digital) fv;
END;
$$;

DROP FUNCTION IF EXISTS public.firma_save(INTEGER, TEXT);
CREATE OR REPLACE FUNCTION public.firma_save(p_usuario_id INTEGER, p_firma_digital TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT fs.success, fs.message
    FROM comun.sp_firma_save(p_usuario_id, p_firma_digital, NULL) fs;
END;
$$;

COMMENT ON FUNCTION public.sp_firma_validate(TEXT) IS 'Alias -> comun.sp_firma_validate';
COMMENT ON FUNCTION public.sp_firma_save(INTEGER, TEXT, VARCHAR) IS 'Alias -> comun.sp_firma_save';
COMMENT ON FUNCTION public.firma_validate(TEXT) IS 'Alias legacy -> comun.sp_firma_validate';
COMMENT ON FUNCTION public.firma_save(INTEGER, TEXT) IS 'Alias legacy -> comun.sp_firma_save';

-- ============================================
-- RESUMEN DE IMPLEMENTACION
-- ============================================
/*
Componente: firma
Esquema principal: comun
Batch: 13 (Componente 78/95 - 82.1%)
Fecha: 2025-11-21

Total SPs implementados: 4 principales + 4 alias = 8 funciones

SPs Principales (schema comun):
  1. comun.sp_firma_validate(TEXT) - Validar firma digital
  2. comun.sp_firma_save(INTEGER, TEXT, VARCHAR) - Guardar/actualizar firma
  3. comun.sp_firma_exists(INTEGER) - Verificar si existe firma
  4. comun.sp_firma_delete(INTEGER, VARCHAR) - Eliminar firma

Alias Compatibilidad (schema public):
  5. public.sp_firma_validate(TEXT)
  6. public.sp_firma_save(INTEGER, TEXT, VARCHAR)
  7. public.firma_validate(TEXT) - legacy
  8. public.firma_save(INTEGER, TEXT) - legacy

Caracteristicas:
  - Validaciones de parametros NULL y vacios
  - Verificacion de unicidad de firma
  - Validacion de estado del usuario (activo/inactivo)
  - Manejo de excepciones con SQLERRM
  - SECURITY DEFINER para control de acceso
  - Comentarios documentando cada funcion
  - Indices recomendados incluidos

Tabla usuarios campos requeridos:
  - id: INTEGER PRIMARY KEY
  - nombre: TEXT/VARCHAR
  - usuario: VARCHAR
  - firma_digital: TEXT
  - estado: VARCHAR (A/ACTIVO, B/BAJA, I/INACTIVO)

Uso API generico:
POST /api/generic
{
  "eRequest": {
    "Operacion": "sp_firma_validate",
    "Base": "padron_licencias",
    "Esquema": "comun",
    "Parametros": [
      {"nombre": "p_firma_digital", "valor": "FIRMA_HASH_123", "tipo": "text"}
    ]
  }
}
*/

-- FIN DEL ARCHIVO
