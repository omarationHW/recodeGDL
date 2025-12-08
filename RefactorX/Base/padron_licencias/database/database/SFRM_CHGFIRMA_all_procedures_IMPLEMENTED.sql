-- =====================================================================================
-- SFRM_CHGFIRMA - Stored Procedures para Cambio de Firma Electronica
-- Modulo: padron_licencias
-- Schema: comun
-- Fecha: 2025-11-21
-- Descripcion: Formulario para cambiar la firma electronica de un usuario por modulo
-- =====================================================================================

-- =====================================================================================
-- PARTE 1: CREACION DE TABLAS BASE
-- =====================================================================================

-- Tabla para almacenar las firmas de usuarios por modulo
CREATE TABLE IF NOT EXISTS comun.usuarios_firma (
    id BIGSERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    modulo_id INTEGER NOT NULL,
    firma VARCHAR(255) NOT NULL,  -- Almacena hash de la firma, NO texto plano
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP DEFAULT NOW(),
    activo BOOLEAN DEFAULT TRUE,
    UNIQUE(usuario_id, modulo_id)
);

-- Indices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_usuarios_firma_usuario_id ON comun.usuarios_firma(usuario_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_firma_modulo_id ON comun.usuarios_firma(modulo_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_firma_activo ON comun.usuarios_firma(activo);

-- Tabla de bitacora para registrar cambios de firma
CREATE TABLE IF NOT EXISTS comun.bitacora_cambio_firma (
    id BIGSERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    modulo_id INTEGER NOT NULL,
    accion VARCHAR(50) NOT NULL,
    descripcion TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indices para bitacora
CREATE INDEX IF NOT EXISTS idx_bitacora_firma_usuario_id ON comun.bitacora_cambio_firma(usuario_id);
CREATE INDEX IF NOT EXISTS idx_bitacora_firma_modulo_id ON comun.bitacora_cambio_firma(modulo_id);
CREATE INDEX IF NOT EXISTS idx_bitacora_firma_created_at ON comun.bitacora_cambio_firma(created_at);

-- Comentarios de tablas
COMMENT ON TABLE comun.usuarios_firma IS 'Almacena las firmas electronicas de usuarios por modulo (hash, no texto plano)';
COMMENT ON TABLE comun.bitacora_cambio_firma IS 'Registro de auditoria para cambios de firma electronica';

-- =====================================================================================
-- PARTE 2: FUNCIONES AUXILIARES
-- =====================================================================================

-- Funcion para hashear la firma (usando SHA256)
CREATE OR REPLACE FUNCTION comun.fn_hash_firma(p_firma VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Genera hash SHA256 de la firma
    RETURN encode(digest(p_firma, 'sha256'), 'hex');
END;
$$;

COMMENT ON FUNCTION comun.fn_hash_firma(VARCHAR) IS 'Genera hash SHA256 de una firma para almacenamiento seguro';

-- =====================================================================================
-- PARTE 3: SP PRINCIPAL - sp_upd_firma
-- =====================================================================================

CREATE OR REPLACE FUNCTION comun.sp_upd_firma(
    p_usuario VARCHAR,
    p_login VARCHAR,
    p_firma_actual VARCHAR,
    p_firma_nueva VARCHAR,
    p_firma_confirmacion VARCHAR,
    p_modulo_id INTEGER,
    p_ip_address VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    acceso INTEGER,
    mensaje VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_usuario_id INTEGER;
    v_usuario_activo BOOLEAN;
    v_firma_existente VARCHAR;
    v_hash_firma_actual VARCHAR;
    v_hash_firma_nueva VARCHAR;
    v_modulo_nombre VARCHAR;
BEGIN
    -- =========================================================================
    -- VALIDACION 1: Usuario existe
    -- =========================================================================
    SELECT u.id, u.activo
    INTO v_usuario_id, v_usuario_activo
    FROM comun.usuarios u
    WHERE LOWER(u.usuario) = LOWER(p_usuario)
       OR LOWER(u.login) = LOWER(p_login);

    IF v_usuario_id IS NULL THEN
        RETURN QUERY SELECT 1::INTEGER, 'Error: El usuario no existe en el sistema'::VARCHAR;
        RETURN;
    END IF;

    -- =========================================================================
    -- VALIDACION 2: Usuario esta activo
    -- =========================================================================
    IF v_usuario_activo IS NOT TRUE THEN
        RETURN QUERY SELECT 1::INTEGER, 'Error: El usuario no esta activo en el sistema'::VARCHAR;
        RETURN;
    END IF;

    -- =========================================================================
    -- VALIDACION 3: Tiene firma registrada para el modulo
    -- =========================================================================
    SELECT uf.firma
    INTO v_firma_existente
    FROM comun.usuarios_firma uf
    WHERE uf.usuario_id = v_usuario_id
      AND uf.modulo_id = p_modulo_id
      AND uf.activo = TRUE;

    IF v_firma_existente IS NULL THEN
        -- Obtener nombre del modulo para mensaje mas claro
        SELECT m.nombre INTO v_modulo_nombre
        FROM comun.modulos m
        WHERE m.id = p_modulo_id;

        v_modulo_nombre := COALESCE(v_modulo_nombre, 'ID: ' || p_modulo_id::VARCHAR);

        RETURN QUERY SELECT 1::INTEGER,
            ('Error: No tiene firma registrada para el modulo ' || v_modulo_nombre)::VARCHAR;
        RETURN;
    END IF;

    -- =========================================================================
    -- VALIDACION 4: Firma actual es correcta
    -- =========================================================================
    v_hash_firma_actual := comun.fn_hash_firma(p_firma_actual);

    IF v_firma_existente != v_hash_firma_actual THEN
        -- Registrar intento fallido en bitacora
        INSERT INTO comun.bitacora_cambio_firma (
            usuario_id, modulo_id, accion, descripcion, ip_address
        ) VALUES (
            v_usuario_id, p_modulo_id, 'INTENTO_FALLIDO',
            'Firma actual incorrecta', p_ip_address
        );

        RETURN QUERY SELECT 1::INTEGER, 'Error: La firma actual es incorrecta'::VARCHAR;
        RETURN;
    END IF;

    -- =========================================================================
    -- VALIDACION 5: Nueva firma cumple requisitos minimos (longitud >= 4)
    -- =========================================================================
    IF p_firma_nueva IS NULL OR LENGTH(TRIM(p_firma_nueva)) < 4 THEN
        RETURN QUERY SELECT 1::INTEGER,
            'Error: La nueva firma debe tener al menos 4 caracteres'::VARCHAR;
        RETURN;
    END IF;

    -- =========================================================================
    -- VALIDACION 6: Nueva firma != firma actual
    -- =========================================================================
    v_hash_firma_nueva := comun.fn_hash_firma(p_firma_nueva);

    IF v_hash_firma_nueva = v_firma_existente THEN
        RETURN QUERY SELECT 1::INTEGER,
            'Error: La nueva firma debe ser diferente a la firma actual'::VARCHAR;
        RETURN;
    END IF;

    -- =========================================================================
    -- VALIDACION 7: Confirmacion == nueva firma
    -- =========================================================================
    IF p_firma_nueva != p_firma_confirmacion THEN
        RETURN QUERY SELECT 1::INTEGER,
            'Error: La confirmacion de firma no coincide con la nueva firma'::VARCHAR;
        RETURN;
    END IF;

    -- =========================================================================
    -- ACTUALIZACION: Guardar nueva firma (hasheada)
    -- =========================================================================
    UPDATE comun.usuarios_firma
    SET firma = v_hash_firma_nueva,
        fecha_actualizacion = NOW()
    WHERE usuario_id = v_usuario_id
      AND modulo_id = p_modulo_id;

    -- =========================================================================
    -- BITACORA: Registrar cambio exitoso
    -- =========================================================================
    INSERT INTO comun.bitacora_cambio_firma (
        usuario_id, modulo_id, accion, descripcion, ip_address
    ) VALUES (
        v_usuario_id, p_modulo_id, 'CAMBIO_FIRMA',
        'Firma actualizada exitosamente', p_ip_address
    );

    -- =========================================================================
    -- RESPUESTA EXITOSA
    -- =========================================================================
    RETURN QUERY SELECT 0::INTEGER, 'Firma actualizada correctamente'::VARCHAR;

EXCEPTION
    WHEN OTHERS THEN
        -- Registrar error en bitacora
        INSERT INTO comun.bitacora_cambio_firma (
            usuario_id, modulo_id, accion, descripcion, ip_address
        ) VALUES (
            COALESCE(v_usuario_id, 0), COALESCE(p_modulo_id, 0), 'ERROR',
            'Error: ' || SQLERRM, p_ip_address
        );

        RETURN QUERY SELECT 1::INTEGER, ('Error interno: ' || SQLERRM)::VARCHAR;
END;
$$;

COMMENT ON FUNCTION comun.sp_upd_firma(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, VARCHAR)
IS 'Actualiza la firma electronica de un usuario para un modulo especifico con validaciones de seguridad';

-- =====================================================================================
-- PARTE 4: SP AUXILIAR - sp_get_firma_info
-- =====================================================================================

CREATE OR REPLACE FUNCTION comun.sp_get_firma_info(
    p_usuario VARCHAR,
    p_modulo_id INTEGER
)
RETURNS TABLE(
    tiene_firma BOOLEAN,
    fecha_ultima_actualizacion TIMESTAMP,
    modulo_nombre VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_usuario_id INTEGER;
BEGIN
    -- Obtener ID del usuario
    SELECT u.id INTO v_usuario_id
    FROM comun.usuarios u
    WHERE LOWER(u.usuario) = LOWER(p_usuario)
       OR LOWER(u.login) = LOWER(p_usuario);

    IF v_usuario_id IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            NULL::TIMESTAMP,
            NULL::VARCHAR;
        RETURN;
    END IF;

    -- Consultar informacion de firma
    RETURN QUERY
    SELECT
        CASE WHEN uf.id IS NOT NULL AND uf.activo = TRUE THEN TRUE ELSE FALSE END AS tiene_firma,
        uf.fecha_actualizacion AS fecha_ultima_actualizacion,
        COALESCE(m.nombre, 'Modulo ' || p_modulo_id::VARCHAR)::VARCHAR AS modulo_nombre
    FROM comun.modulos m
    LEFT JOIN comun.usuarios_firma uf
        ON uf.modulo_id = m.id
        AND uf.usuario_id = v_usuario_id
        AND uf.activo = TRUE
    WHERE m.id = p_modulo_id;

    -- Si no se encontro el modulo, devolver informacion basica
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            CASE WHEN EXISTS (
                SELECT 1 FROM comun.usuarios_firma uf2
                WHERE uf2.usuario_id = v_usuario_id
                AND uf2.modulo_id = p_modulo_id
                AND uf2.activo = TRUE
            ) THEN TRUE ELSE FALSE END AS tiene_firma,
            (SELECT uf3.fecha_actualizacion FROM comun.usuarios_firma uf3
             WHERE uf3.usuario_id = v_usuario_id AND uf3.modulo_id = p_modulo_id
             AND uf3.activo = TRUE LIMIT 1) AS fecha_ultima_actualizacion,
            ('Modulo ' || p_modulo_id::VARCHAR)::VARCHAR AS modulo_nombre;
    END IF;

END;
$$;

COMMENT ON FUNCTION comun.sp_get_firma_info(VARCHAR, INTEGER)
IS 'Obtiene informacion sobre la firma de un usuario para un modulo especifico';

-- =====================================================================================
-- PARTE 5: SP AUXILIAR - sp_get_modulos_usuario
-- =====================================================================================

CREATE OR REPLACE FUNCTION comun.sp_get_modulos_usuario(
    p_usuario VARCHAR
)
RETURNS TABLE(
    modulo_id INTEGER,
    modulo_nombre VARCHAR,
    tiene_firma BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_usuario_id INTEGER;
BEGIN
    -- Obtener ID del usuario
    SELECT u.id INTO v_usuario_id
    FROM comun.usuarios u
    WHERE LOWER(u.usuario) = LOWER(p_usuario)
       OR LOWER(u.login) = LOWER(p_usuario);

    IF v_usuario_id IS NULL THEN
        -- Usuario no encontrado, retornar vacio
        RETURN;
    END IF;

    -- Listar todos los modulos con indicador de si tiene firma
    RETURN QUERY
    SELECT
        m.id::INTEGER AS modulo_id,
        m.nombre::VARCHAR AS modulo_nombre,
        CASE
            WHEN uf.id IS NOT NULL AND uf.activo = TRUE THEN TRUE
            ELSE FALSE
        END AS tiene_firma
    FROM comun.modulos m
    LEFT JOIN comun.usuarios_firma uf
        ON uf.modulo_id = m.id
        AND uf.usuario_id = v_usuario_id
        AND uf.activo = TRUE
    WHERE m.activo = TRUE
    ORDER BY m.nombre;

END;
$$;

COMMENT ON FUNCTION comun.sp_get_modulos_usuario(VARCHAR)
IS 'Lista todos los modulos disponibles para un usuario indicando cuales tienen firma registrada';

-- =====================================================================================
-- PARTE 6: SP ADICIONAL - sp_crear_firma (Para crear firma inicial)
-- =====================================================================================

CREATE OR REPLACE FUNCTION comun.sp_crear_firma(
    p_usuario VARCHAR,
    p_modulo_id INTEGER,
    p_firma VARCHAR,
    p_firma_confirmacion VARCHAR,
    p_ip_address VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    acceso INTEGER,
    mensaje VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_usuario_id INTEGER;
    v_usuario_activo BOOLEAN;
    v_firma_existente INTEGER;
    v_hash_firma VARCHAR;
BEGIN
    -- Validar que el usuario existe
    SELECT u.id, u.activo
    INTO v_usuario_id, v_usuario_activo
    FROM comun.usuarios u
    WHERE LOWER(u.usuario) = LOWER(p_usuario)
       OR LOWER(u.login) = LOWER(p_usuario);

    IF v_usuario_id IS NULL THEN
        RETURN QUERY SELECT 1::INTEGER, 'Error: El usuario no existe en el sistema'::VARCHAR;
        RETURN;
    END IF;

    -- Validar usuario activo
    IF v_usuario_activo IS NOT TRUE THEN
        RETURN QUERY SELECT 1::INTEGER, 'Error: El usuario no esta activo'::VARCHAR;
        RETURN;
    END IF;

    -- Validar que no tenga firma existente para este modulo
    SELECT uf.id INTO v_firma_existente
    FROM comun.usuarios_firma uf
    WHERE uf.usuario_id = v_usuario_id
      AND uf.modulo_id = p_modulo_id
      AND uf.activo = TRUE;

    IF v_firma_existente IS NOT NULL THEN
        RETURN QUERY SELECT 1::INTEGER,
            'Error: Ya existe una firma para este modulo. Use cambio de firma.'::VARCHAR;
        RETURN;
    END IF;

    -- Validar longitud minima
    IF p_firma IS NULL OR LENGTH(TRIM(p_firma)) < 4 THEN
        RETURN QUERY SELECT 1::INTEGER,
            'Error: La firma debe tener al menos 4 caracteres'::VARCHAR;
        RETURN;
    END IF;

    -- Validar confirmacion
    IF p_firma != p_firma_confirmacion THEN
        RETURN QUERY SELECT 1::INTEGER,
            'Error: La confirmacion no coincide con la firma'::VARCHAR;
        RETURN;
    END IF;

    -- Crear firma hasheada
    v_hash_firma := comun.fn_hash_firma(p_firma);

    -- Insertar o actualizar (si existe inactiva)
    INSERT INTO comun.usuarios_firma (
        usuario_id, modulo_id, firma, fecha_creacion, fecha_actualizacion, activo
    ) VALUES (
        v_usuario_id, p_modulo_id, v_hash_firma, NOW(), NOW(), TRUE
    )
    ON CONFLICT (usuario_id, modulo_id)
    DO UPDATE SET
        firma = v_hash_firma,
        fecha_actualizacion = NOW(),
        activo = TRUE;

    -- Registrar en bitacora
    INSERT INTO comun.bitacora_cambio_firma (
        usuario_id, modulo_id, accion, descripcion, ip_address
    ) VALUES (
        v_usuario_id, p_modulo_id, 'CREAR_FIRMA',
        'Firma creada exitosamente', p_ip_address
    );

    RETURN QUERY SELECT 0::INTEGER, 'Firma creada correctamente'::VARCHAR;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 1::INTEGER, ('Error interno: ' || SQLERRM)::VARCHAR;
END;
$$;

COMMENT ON FUNCTION comun.sp_crear_firma(VARCHAR, INTEGER, VARCHAR, VARCHAR, VARCHAR)
IS 'Crea una nueva firma electronica para un usuario en un modulo especifico';

-- =====================================================================================
-- PARTE 7: SP ADICIONAL - sp_validar_firma (Para validar firma en operaciones)
-- =====================================================================================

CREATE OR REPLACE FUNCTION comun.sp_validar_firma(
    p_usuario VARCHAR,
    p_modulo_id INTEGER,
    p_firma VARCHAR
)
RETURNS TABLE(
    valido BOOLEAN,
    mensaje VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_usuario_id INTEGER;
    v_firma_almacenada VARCHAR;
    v_hash_firma_ingresada VARCHAR;
BEGIN
    -- Obtener usuario
    SELECT u.id INTO v_usuario_id
    FROM comun.usuarios u
    WHERE (LOWER(u.usuario) = LOWER(p_usuario) OR LOWER(u.login) = LOWER(p_usuario))
      AND u.activo = TRUE;

    IF v_usuario_id IS NULL THEN
        RETURN QUERY SELECT FALSE::BOOLEAN, 'Usuario no encontrado o inactivo'::VARCHAR;
        RETURN;
    END IF;

    -- Obtener firma almacenada
    SELECT uf.firma INTO v_firma_almacenada
    FROM comun.usuarios_firma uf
    WHERE uf.usuario_id = v_usuario_id
      AND uf.modulo_id = p_modulo_id
      AND uf.activo = TRUE;

    IF v_firma_almacenada IS NULL THEN
        RETURN QUERY SELECT FALSE::BOOLEAN, 'No tiene firma registrada para este modulo'::VARCHAR;
        RETURN;
    END IF;

    -- Comparar hashes
    v_hash_firma_ingresada := comun.fn_hash_firma(p_firma);

    IF v_firma_almacenada = v_hash_firma_ingresada THEN
        RETURN QUERY SELECT TRUE::BOOLEAN, 'Firma valida'::VARCHAR;
    ELSE
        -- Registrar intento fallido
        INSERT INTO comun.bitacora_cambio_firma (
            usuario_id, modulo_id, accion, descripcion
        ) VALUES (
            v_usuario_id, p_modulo_id, 'VALIDACION_FALLIDA',
            'Intento de validacion con firma incorrecta'
        );

        RETURN QUERY SELECT FALSE::BOOLEAN, 'Firma incorrecta'::VARCHAR;
    END IF;

END;
$$;

COMMENT ON FUNCTION comun.sp_validar_firma(VARCHAR, INTEGER, VARCHAR)
IS 'Valida la firma electronica de un usuario para autorizar operaciones';

-- =====================================================================================
-- PARTE 8: SP ADICIONAL - sp_historial_cambios_firma
-- =====================================================================================

CREATE OR REPLACE FUNCTION comun.sp_historial_cambios_firma(
    p_usuario VARCHAR,
    p_modulo_id INTEGER DEFAULT NULL,
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    usuario_id INTEGER,
    modulo_id INTEGER,
    modulo_nombre VARCHAR,
    accion VARCHAR,
    descripcion TEXT,
    ip_address VARCHAR,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_usuario_id INTEGER;
BEGIN
    -- Obtener usuario
    SELECT u.id INTO v_usuario_id
    FROM comun.usuarios u
    WHERE LOWER(u.usuario) = LOWER(p_usuario)
       OR LOWER(u.login) = LOWER(p_usuario);

    IF v_usuario_id IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        b.id,
        b.usuario_id,
        b.modulo_id,
        COALESCE(m.nombre, 'Modulo ' || b.modulo_id::VARCHAR)::VARCHAR AS modulo_nombre,
        b.accion::VARCHAR,
        b.descripcion,
        b.ip_address::VARCHAR,
        b.created_at
    FROM comun.bitacora_cambio_firma b
    LEFT JOIN comun.modulos m ON m.id = b.modulo_id
    WHERE b.usuario_id = v_usuario_id
      AND (p_modulo_id IS NULL OR b.modulo_id = p_modulo_id)
      AND (p_fecha_inicio IS NULL OR b.created_at::DATE >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR b.created_at::DATE <= p_fecha_fin)
    ORDER BY b.created_at DESC
    LIMIT 100;

END;
$$;

COMMENT ON FUNCTION comun.sp_historial_cambios_firma(VARCHAR, INTEGER, DATE, DATE)
IS 'Obtiene el historial de cambios de firma de un usuario con filtros opcionales';

-- =====================================================================================
-- PARTE 9: PERMISOS Y GRANTS
-- =====================================================================================

-- Grants para las funciones (ajustar segun roles del sistema)
-- GRANT EXECUTE ON FUNCTION comun.sp_upd_firma TO app_user;
-- GRANT EXECUTE ON FUNCTION comun.sp_get_firma_info TO app_user;
-- GRANT EXECUTE ON FUNCTION comun.sp_get_modulos_usuario TO app_user;
-- GRANT EXECUTE ON FUNCTION comun.sp_crear_firma TO app_user;
-- GRANT EXECUTE ON FUNCTION comun.sp_validar_firma TO app_user;
-- GRANT EXECUTE ON FUNCTION comun.sp_historial_cambios_firma TO app_user;

-- =====================================================================================
-- PARTE 10: VERIFICACION DE CREACION
-- =====================================================================================

DO $$
DECLARE
    v_count INTEGER;
    v_functions TEXT[] := ARRAY[
        'comun.fn_hash_firma',
        'comun.sp_upd_firma',
        'comun.sp_get_firma_info',
        'comun.sp_get_modulos_usuario',
        'comun.sp_crear_firma',
        'comun.sp_validar_firma',
        'comun.sp_historial_cambios_firma'
    ];
    v_func TEXT;
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'VERIFICACION DE STORED PROCEDURES CREADOS';
    RAISE NOTICE '============================================';

    FOREACH v_func IN ARRAY v_functions
    LOOP
        SELECT COUNT(*) INTO v_count
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname || '.' || p.proname = v_func;

        IF v_count > 0 THEN
            RAISE NOTICE '[OK] %', v_func;
        ELSE
            RAISE WARNING '[FALTA] %', v_func;
        END IF;
    END LOOP;

    -- Verificar tablas
    RAISE NOTICE '--------------------------------------------';
    RAISE NOTICE 'VERIFICACION DE TABLAS CREADAS';
    RAISE NOTICE '--------------------------------------------';

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'comun' AND table_name = 'usuarios_firma') THEN
        RAISE NOTICE '[OK] comun.usuarios_firma';
    ELSE
        RAISE WARNING '[FALTA] comun.usuarios_firma';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'comun' AND table_name = 'bitacora_cambio_firma') THEN
        RAISE NOTICE '[OK] comun.bitacora_cambio_firma';
    ELSE
        RAISE WARNING '[FALTA] comun.bitacora_cambio_firma';
    END IF;

    RAISE NOTICE '============================================';
    RAISE NOTICE 'DESPLIEGUE SFRM_CHGFIRMA COMPLETADO';
    RAISE NOTICE '============================================';
END;
$$;

-- =====================================================================================
-- FIN DEL SCRIPT
-- =====================================================================================
